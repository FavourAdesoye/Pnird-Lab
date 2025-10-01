const { EventEmitter } = require("events");
EventEmitter.defaultMaxListeners = 20; // or higher if needed
const fs = require("fs");
const path = require("path");
const pdfParse = require("pdf-parse");  
const { HNSWLib } = require("@langchain/community/vectorstores/hnswlib");
const { FaissStore } = require("@langchain/community/vectorstores/faiss");
const { OllamaEmbeddings } = require("@langchain/ollama");
const { Ollama } = require("@langchain/ollama");
const { MemoryVectorStore } = require("langchain/vectorstores/memory");
const { ChatPromptTemplate } = require("@langchain/core/prompts");
const { createStuffDocumentsChain } = require("langchain/chains/combine_documents");
const { createRetrievalChain } = require("langchain/chains/retrieval");
const error =  require("console");
const express = require("express");
const app = express();
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const { default: helmet } = require("helmet");
const morgan = require("morgan");
const userRoute = require("./routes/users")
const postRoute = require("./routes/posts");
const commentRoute = require("./routes/comment")
const authRoute = require("./routes/auth");
const cors = require('cors');
const bodyParser = require("body-parser"); 
const eventRoute = require("./routes/events");
const studyRoute = require("./routes/studies")
const admin = require("firebase-admin")
dotenv.config();

const Port = process.env.PORT || 3000; 

mongoose.
connect(process.env.MONGO_URL

).then(()=>console.log("DB Connection Successful!")).catch((error) =>{
    console.log(error);
})
// Enable all CORS requests
app.use(cors());
//Middleware
app.use(express.json());
app.use(express.urlencoded({
    extended: true
}));
app.use(helmet());
app.use(morgan("common"));

app.use("/api/posts", postRoute);
app.use("/api/users", userRoute)
app.use("/api/auth", authRoute);
app.use("/api/comments", commentRoute);
app.use("/api/studies", studyRoute);
app.use("/api/events", eventRoute);


app.get("/", (req,res)=>{
    res.send("welcome to pnirdlab")
});
app.listen(Port, ()=>{
    console.log(`Backend server is runninnng on port ${Port}!`);
});


//parsing the json  
app.use(bodyParser.urlencoded({extended: false})); 
app.use(bodyParser.json()); 
app.use('/uploads', express.static('uploads')) 
app.use(express.json());

let qa;

async function setupQA() {
  const indexPath = path.join(__dirname, "pnird_index"); // directory to store FAISS index

  // ---- Embeddings ----
  const embeddings = new OllamaEmbeddings({
    model: "nomic-embed-text",
  });

  let vectorStore;

  if (fs.existsSync(indexPath)) {
    console.log("📂 Loading existing FAISS index...");
    vectorStore = await FaissStore.load(indexPath, embeddings);
  } else {
    console.log("📄 Processing PDF and creating new index...");
    const dataBuffer = fs.readFileSync(path.join(__dirname, "pnird.pdf"));
    const pdfData = await pdfParse(dataBuffer);

    const { RecursiveCharacterTextSplitter } = await import("langchain/text_splitter");
    const splitter = new RecursiveCharacterTextSplitter({
      chunkSize: 300,
      chunkOverlap: 50,
    });

    const docs = await splitter.createDocuments([pdfData.text]);

    vectorStore = await FaissStore.fromDocuments(docs, embeddings);
    await vectorStore.save(indexPath); // persist to disk
    console.log("✅ New FAISS index saved.");
  }

  // ---- LLM ----
  let modelName = "llama3:instruct";
  try {
    const llmTest = new Ollama({ model: modelName });
    await llmTest.invoke("test"); // sanity check
  } catch (err) {
    console.warn(`⚠️ Model ${modelName} not available, falling back to llama3.`);
    modelName = "llama3";
  }
  const llm = new Ollama({ model: modelName });

  // ---- Prompt ----
  const prompt = ChatPromptTemplate.fromTemplate(`
Answer the question based only on the provided context.

If the question asks for names, list ALL names clearly in bullet points. 
If the question asks about purpose, projects, or research, summarize those from the context.

Context:
{context}

Question: {input}
`);

  const combineDocsChain = await createStuffDocumentsChain({
    llm,
    prompt,
  });

  qa = await createRetrievalChain({
    retriever: vectorStore.asRetriever(),
    combineDocsChain,
  });

  console.log("✅ QA system ready");
}

setupQA().catch(err => {
  console.error("Failed to initialize QA:", err);
});

// Endpoint
app.post("/ask", async (req, res) => {
  try {
    const question = req.body.question;
    if (!question) {
      return res.status(400).json({ answer: "No question provided" });
    }

    if (!qa) {
      return res.status(503).json({ answer: "QA system not initialized yet. Try again later." });
    }

    const response = await qa.invoke({ input: question });
    res.json({ answer: response.answer });
  } catch (err) {
    console.error(err);
    res.status(500).json({ answer: "Error processing question" });
  }
});