const { EventEmitter } = require("events");
EventEmitter.defaultMaxListeners = 20; // or higher if needed
const error =  require("console");
const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");
const app = express();
const httpServer = createServer(app);
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
const messageRoute = require("./routes/message");
const notificationRoute = require("./routes/notifications");
const searchRoute = require("./routes/search");
const chatbotRoute = require("./routes/chatbot");
const Message = require("./models/messages");
const User = require("./models/User");
const Notification = require("./models/notifications");
const admin = require("firebase-admin")
const serviceAccount = require("./pnird-lab-firebase-adminsdk-avod6-157fc3b4bb.json");

dotenv.config();

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized');
}

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
app.use("/api/messages", messageRoute);
app.use("/api/notifications", notificationRoute);
app.use("/api/search", searchRoute);
app.use("/api/chatbot", chatbotRoute);


app.get("/", (req,res)=>{
    res.send("welcome to pnirdlab")
});

// Initialize Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: "*", // In production, specify your Flutter app's origin
    methods: ["GET", "POST"]
  }
});

// Store connected users
const connectedUsers = new Map();

// Make io and connectedUsers accessible to routes
app.set('io', io);
app.set('connectedUsers', connectedUsers);

// Socket.IO connection handling
io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  // Register user when they connect
  socket.on("register", (userId) => {
    connectedUsers.set(userId, socket.id);
    socket.userId = userId;
    console.log(`User ${userId} registered with socket ${socket.id}`);
  });

  // Handle sending messages
  socket.on("send_message", async (data) => {
    try {
      const { senderId, recipientId, message } = data;
      
      // Save message to database
      const newMessage = new Message({ senderId, recipientId, message });
      const saved = await newMessage.save();
      
      // Get sender info for notification
      const sender = await User.findById(senderId);
      const senderName = sender ? sender.username : "Unknown";
      
      // Create notification
      const notif = new Notification({
        userId: recipientId,
        type: "message",
        senderId: senderId,
        message: `${senderName} sent you a message.`,
        referenceId: saved._id,
      });
      await notif.save();
      
      // Convert timestamp to ISO string for consistent formatting
      const timestampISO = saved.timestamp ? new Date(saved.timestamp).toISOString() : new Date().toISOString();
      
      // Send message to recipient if they're connected
      const recipientSocketId = connectedUsers.get(recipientId);
      if (recipientSocketId) {
        io.to(recipientSocketId).emit("receive_message", {
          senderId,
          message,
          timestamp: timestampISO,
        });
        
        // Send real-time notification
        io.to(recipientSocketId).emit("new_notification", {
          _id: notif._id.toString(),
          userId: recipientId,
          type: "message",
          senderId: senderId,
          message: `${senderName} sent you a message.`,
          referenceId: saved._id.toString(),
          isRead: false,
          createdAt: notif.createdAt ? new Date(notif.createdAt).toISOString() : new Date().toISOString(),
        });
      }
      
      // Also send confirmation back to sender with correct timestamp
      socket.emit("message_sent", {
        messageId: saved._id,
        timestamp: timestampISO,
        message: message, // Include message for UI update
      });
    } catch (err) {
      console.error("Error sending message:", err);
      socket.emit("error", { message: "Failed to send message" });
    }
  });

  // Handle disconnection
  socket.on("disconnect", () => {
    if (socket.userId) {
      connectedUsers.delete(socket.userId);
      console.log(`User ${socket.userId} disconnected`);
    }
    console.log("Client disconnected:", socket.id);
  });
});

// Start server with Socket.IO
httpServer.listen(Port, ()=>{
    console.log(`Backend server is running on port ${Port}!`);
    console.log(`Socket.IO server is ready!`);
});


//parsing the json  
app.use(bodyParser.urlencoded({extended: false})); 
app.use(bodyParser.json()); 
app.use('/uploads', express.static('uploads')) 
app.use(express.json());