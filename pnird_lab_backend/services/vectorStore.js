const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

class VectorStore {
  constructor() {
    this.documents = [];
    this.embeddings = [];
    this.initialized = false;
  }

  // Parse PDF or text file and split into chunks
  async parsePDF(pdfPath) {
    try {
      const dataBuffer = fs.readFileSync(pdfPath);
      
      // Try parsing as PDF first
      try {
        const pdfData = await pdfParse(dataBuffer);
        if (pdfData.text && pdfData.text.trim().length > 0) {
          console.log('✅ Successfully parsed as PDF');
          const chunks = this.splitIntoChunks(pdfData.text, 500, 100);
          return chunks;
        }
      } catch (pdfError) {
        // If PDF parsing fails, try reading as plain text
        console.log('📄 PDF parsing failed, reading as text file...');
      }
      
      // Read as plain text file
      const textContent = dataBuffer.toString('utf-8');
      if (textContent.trim().length === 0) {
        throw new Error('File is empty');
      }
      
      console.log('✅ Successfully read as text file');
      const chunks = this.splitIntoChunks(textContent, 500, 100);
      return chunks;
    } catch (error) {
      console.error('Error parsing file:', error);
      throw error;
    }
  }

  // Split text into overlapping chunks
  splitIntoChunks(text, chunkSize, overlap) {
    const chunks = [];
    let start = 0;
    
    // Split by paragraphs first for better semantic chunks
    const paragraphs = text.split(/\n\s*\n/).filter(p => p.trim().length > 0);
    
    for (const paragraph of paragraphs) {
      const paraText = paragraph.trim();
      
      // If paragraph is smaller than chunk size, add it as-is
      if (paraText.length <= chunkSize) {
        chunks.push({
          text: paraText,
          start: start,
          end: start + paraText.length,
        });
        start += paraText.length + 2; // +2 for newline
      } else {
        // Split large paragraphs into chunks
        let paraStart = 0;
        while (paraStart < paraText.length) {
          const end = Math.min(paraStart + chunkSize, paraText.length);
          let chunk = paraText.substring(paraStart, end);
          
          // Try to break at sentence boundaries
          if (end < paraText.length) {
            const lastPeriod = chunk.lastIndexOf('.');
            const lastNewline = chunk.lastIndexOf('\n');
            const breakPoint = Math.max(lastPeriod, lastNewline);
            if (breakPoint > chunkSize * 0.5) {
              chunk = chunk.substring(0, breakPoint + 1);
              paraStart += breakPoint + 1;
            } else {
              paraStart = end - overlap;
            }
          } else {
            paraStart = end;
          }
          
          if (chunk.trim().length > 0) {
            chunks.push({
              text: chunk.trim(),
              start: start,
              end: start + chunk.length,
            });
            start += chunk.length;
          }
        }
        start += 2; // Account for paragraph separator
      }
    }
    
    return chunks;
  }

  // Create embeddings for all chunks in batches
  async createEmbeddings(chunks) {
    try {
      const batchSize = 100; // Process 100 chunks at a time
      const allEmbeddings = [];
      
      for (let i = 0; i < chunks.length; i += batchSize) {
        const batch = chunks.slice(i, i + batchSize);
        const texts = batch.map(chunk => chunk.text);
        
        console.log(`  Processing batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(chunks.length / batchSize)}...`);
        
        const response = await openai.embeddings.create({
          model: 'text-embedding-3-small', // Cost-effective embedding model
          input: texts,
        });

        const batchEmbeddings = response.data.map((item, index) => ({
          text: batch[index].text,
          embedding: item.embedding,
          start: batch[index].start,
          end: batch[index].end,
        }));
        
        allEmbeddings.push(...batchEmbeddings);
        
        // Small delay to avoid rate limiting
        if (i + batchSize < chunks.length) {
          await new Promise(resolve => setTimeout(resolve, 100));
        }
      }

      return allEmbeddings;
    } catch (error) {
      console.error('Error creating embeddings:', error);
      throw error;
    }
  }

  // Calculate cosine similarity
  cosineSimilarity(vecA, vecB) {
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
      normA += vecA[i] * vecA[i];
      normB += vecB[i] * vecB[i];
    }

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }

  // Find most relevant chunks for a query
  async search(query, topK = 3) {
    if (!this.initialized) {
      await this.initialize();
    }

    // If no embeddings exist, return empty
    if (this.embeddings.length === 0) {
      return [];
    }

    // Create embedding for query
    const queryResponse = await openai.embeddings.create({
      model: 'text-embedding-3-small',
      input: query,
    });

    const queryEmbedding = queryResponse.data[0].embedding;

    // Calculate similarities
    const similarities = this.embeddings.map((doc, index) => ({
      text: doc.text,
      similarity: this.cosineSimilarity(queryEmbedding, doc.embedding),
      start: doc.start,
      end: doc.end,
    }));

    // Sort by similarity and return top K
    return similarities
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topK)
      .filter(item => item.similarity > 0.5); // Only return relevant results
  }

  // Initialize vector store from PDF
  async initialize() {
    if (this.initialized) {
      return;
    }

    try {
      const pdfPath = path.join(__dirname, '../pnird.pdf');
      
      if (!fs.existsSync(pdfPath)) {
        console.warn('⚠️  PDF file not found at:', pdfPath);
        console.log('📝 You can add a PDF file later and restart the server to load it.');
        this.initialized = true;
        return;
      }

      console.log('📄 Parsing PDF...');
      const chunks = await this.parsePDF(pdfPath);
      
      if (chunks.length === 0) {
        console.warn('⚠️  PDF parsed but contains no text content');
        this.initialized = true;
        return;
      }
      
      console.log(`✅ Parsed ${chunks.length} chunks`);

      console.log('🔮 Creating embeddings...');
      this.embeddings = await this.createEmbeddings(chunks);
      console.log(`✅ Created ${this.embeddings.length} embeddings`);

      this.initialized = true;
      console.log('✅ Vector store initialized');
    } catch (error) {
      console.error('❌ Error initializing vector store:', error.message);
      this.initialized = true; // Set to true to prevent infinite retries
    }
  }

  // Reload PDF (useful if PDF is updated)
  async reload() {
    this.initialized = false;
    this.embeddings = [];
    await this.initialize();
  }
}

// Export singleton instance
module.exports = new VectorStore();

