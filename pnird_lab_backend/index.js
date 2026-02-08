const { EventEmitter } = require("events");
const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const helmet = require("helmet");
const morgan = require("morgan");
const cors = require("cors");
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const userRoute = require("./routes/users");
const postRoute = require("./routes/posts");
const commentRoute = require("./routes/comment");
const authRoute = require("./routes/auth");
const eventRoute = require("./routes/events");
const studyRoute = require("./routes/studies");
const messageRoute = require("./routes/message");
const notificationRoute = require("./routes/notifications");
const searchRoute = require("./routes/search");
const chatbotRoute = require("./routes/chatbot");
const Message = require("./models/messages");
const User = require("./models/User");
const Notification = require("./models/notifications");
const { createRateLimiter } = require("./middleware/rateLimit");

EventEmitter.defaultMaxListeners = 20;
dotenv.config();

const app = express();
const httpServer = createServer(app);
const port = Number(process.env.PORT) || 3000;

function parseAllowedOrigins() {
  const raw = process.env.CORS_ORIGINS;
  if (!raw) {
    return ["http://localhost:3000", "http://127.0.0.1:3000"];
  }

  return raw
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

const allowedOrigins = parseAllowedOrigins();

function configureFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return;
  }

  let credential;
  const keyPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  const keyJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

  try {
    if (keyJson) {
      const parsed = JSON.parse(keyJson);
      credential = admin.credential.cert(parsed);
    } else if (keyPath && fs.existsSync(path.resolve(keyPath))) {
      const serviceAccount = require(path.resolve(keyPath));
      credential = admin.credential.cert(serviceAccount);
    } else {
      credential = admin.credential.applicationDefault();
    }

    admin.initializeApp({ credential });
    console.log("Firebase Admin initialized");
  } catch (error) {
    console.error("Failed to initialize Firebase Admin:", error.message);
  }
}

configureFirebaseAdmin();

mongoose
  .connect(process.env.MONGO_URL)
  .then(() => console.log("DB Connection Successful"))
  .catch((error) => {
    console.error("DB Connection Error:", error.message);
  });

app.disable("x-powered-by");
app.set("trust proxy", 1);

app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginResourcePolicy: { policy: "cross-origin" },
  })
);

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Blocked by CORS policy"));
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    credentials: true,
  })
);

app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev"));
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true, limit: "1mb" }));
app.use("/uploads", express.static("uploads"));

app.use(
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 1200,
    message: "Too many requests from this IP.",
  })
);

app.use(
  "/api/search",
  createRateLimiter({
    windowMs: 60 * 1000,
    max: 80,
    message: "Search rate limit exceeded. Please slow down.",
  })
);

app.use(
  "/api/users",
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 300,
  })
);

app.use(
  "/api/auth",
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: "Too many authentication attempts. Try again later.",
  })
);

app.use("/api/posts", postRoute);
app.use("/api/users", userRoute);
app.use("/api/auth", authRoute);
app.use("/api/comments", commentRoute);
app.use("/api/studies", studyRoute);
app.use("/api/events", eventRoute);
app.use("/api/messages", messageRoute);
app.use("/api/notifications", notificationRoute);
app.use("/api/search", searchRoute);
app.use("/api/chatbot", chatbotRoute);

app.get("/", (_req, res) => {
  res.status(200).send("Welcome to Pnird Lab");
});

const io = new Server(httpServer, {
  cors: {
    origin: allowedOrigins,
    methods: ["GET", "POST"],
  },
});

const connectedUsers = new Map();
app.set("io", io);
app.set("connectedUsers", connectedUsers);

io.on("connection", (socket) => {
  socket.on("register", (userId) => {
    if (!userId) {
      return;
    }
    connectedUsers.set(String(userId), socket.id);
    socket.userId = String(userId);
  });

  socket.on("send_message", async (data = {}) => {
    try {
      const { senderId, recipientId, message } = data;
      if (!senderId || !recipientId || !message || typeof message !== "string") {
        socket.emit("error", { message: "Invalid message payload." });
        return;
      }

      const newMessage = new Message({ senderId, recipientId, message: message.trim() });
      const saved = await newMessage.save();

      const sender = await User.findById(senderId).select("username");
      const senderName = sender?.username || "Unknown";

      const notif = new Notification({
        userId: recipientId,
        type: "message",
        senderId,
        message: `${senderName} sent you a message.`,
        referenceId: saved._id,
      });
      await notif.save();

      const timestampISO = saved.timestamp
        ? new Date(saved.timestamp).toISOString()
        : new Date().toISOString();

      const recipientSocketId = connectedUsers.get(String(recipientId));
      if (recipientSocketId) {
        io.to(recipientSocketId).emit("receive_message", {
          senderId,
          message: message.trim(),
          timestamp: timestampISO,
        });

        io.to(recipientSocketId).emit("new_notification", {
          _id: String(notif._id),
          userId: String(recipientId),
          type: "message",
          senderId: String(senderId),
          message: `${senderName} sent you a message.`,
          referenceId: String(saved._id),
          isRead: false,
          createdAt: notif.createdAt
            ? new Date(notif.createdAt).toISOString()
            : new Date().toISOString(),
        });
      }

      socket.emit("message_sent", {
        messageId: saved._id,
        timestamp: timestampISO,
        message: message.trim(),
      });
    } catch (error) {
      console.error("Error sending message:", error.message);
      socket.emit("error", { message: "Failed to send message." });
    }
  });

  socket.on("disconnect", () => {
    if (socket.userId) {
      connectedUsers.delete(socket.userId);
    }
  });
});

app.use((_req, res) => {
  res.status(404).json({ message: "Route not found" });
});

app.use((err, _req, res, _next) => {
  console.error("Unhandled server error:", err.message);
  res.status(500).json({
    message: "An internal server error occurred.",
  });
});

httpServer.listen(port, () => {
  console.log(`Backend server running on port ${port}`);
});
