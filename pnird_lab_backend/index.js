const {error} = require("console");
const express = require("express");
const app = express();
const http = require("http");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const { default: helmet } = require("helmet");
const morgan = require("morgan");
const userRoute = require("./routes/users")
const postRoute = require("./routes/posts");
const commentRoute = require("./routes/comment")
const authRoute = require("./routes/auth");
const cors = require('cors');
const { Server } = require("socket.io");
const bodyParser = require("body-parser"); 
const eventRoute = require("./routes/events");
const studyRoute = require("./routes/studies")
const messageRoute = require("./routes/message");
const Message = require("./models/messages");
const notificationRoute = require("./routes/notifications");
const admin = require("./firebase")
dotenv.config();



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

const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"],
        credentials: true
    },
});

let onlineUsers = {};

io.on("connection", (socket) => {
    console.log("New connection:", socket.id);
  
    socket.on("register", (userId) => {
      onlineUsers[userId] = socket.id;
    });
  
    socket.on("send_message", (data) => {
      const recipientSocket = onlineUsers[data.recipientId];
      
      if (recipientSocket) {
        io.to(recipientSocket).emit("receive_message", {
          senderId: data.senderId,
          message: data.message,
          timestamp: new Date().toISOString()
        });
      }
  
      // Save message to DB
      const newMessage = new Message({
        senderId: data.senderId,
        recipientId: data.recipientId,
        message: data.message,
      });
  
      newMessage.save().catch((err) => {
        console.error("Error saving message:", err.message);
      });
    });
  
    socket.on("disconnect", () => {
      for (const [userId, socketId] of Object.entries(onlineUsers)) {
        if (socketId === socket.id) {
          delete onlineUsers[userId];
          break;
        }
      }
      console.log("Disconnected:", socket.id);
    });
  });
const Port = process.env.PORT || 3000; 
server.listen(Port, () => {
    console.log("Socket.io and express server running on port 3000");
});
app.use("/api/posts", postRoute);
app.use("/api/users", userRoute)
app.use("/api/auth", authRoute);
app.use("/api/comments", commentRoute);
app.use("/api/studies", studyRoute);
app.use("/api/events", eventRoute);
app.use("/api/messages", messageRoute);
app.use("/api/notifications", notificationRoute);

app.get("/", (req,res)=>{
    res.send("welcome to pnirdlab")
});
// app.listen(Port, ()=>{
//     console.log(`Backend server is runninnng on port ${Port}!`);
// });


//parsing the json  
app.use(bodyParser.urlencoded({extended: false})); 
app.use(bodyParser.json()); 
app.use('/uploads', express.static('uploads')) 
app.use(express.json()); 



