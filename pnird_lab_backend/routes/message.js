// routes/messages.js
const express = require("express");
const router = express.Router();
const Message = require("../models/messages");
const User = require("../models/User");

router.post("/", async (req, res) => {
  try {
    const senderId = await User.findById(req.body.senderId);
    const recipientId = await User.findById(req.body.recipientId);
    const message = req.body.message;
    // const { senderId, recipientId, text } = req.body;
    if (senderId === recipientId) {
      const sender = await User.findById(senderId);
      if (!sender.isAdmin) {
        return res.status(403).json({ message: "Users cannot message themselves." });
      }
    }

    const newMessage = new Message({ senderId, recipientId, message });
    const saved = await newMessage.save();
    // Notify the recipient
    if (senderId !== recipientId) {
        const notif = new Notification({
          userId: recipientId,
          type: "message",
          senderId,
          message: `${senderName} sent you a message.`,
        });
        await notif.save();
      }
      
    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//Get all the messages the user has snet
router.get("/:userId", async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [
        { senderId: req.params.userId },
        { recipientId: req.params.userId }
      ]
    }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get unique chat users for a user
router.get("/chats/:firebaseUID", async (req, res) => {
    try {
      // Step 1: Find the actual user from Firebase UID
      const user = await User.findOne({ firebaseUID: req.params.firebaseUID });
  
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
  
      const userId = user._id.toString(); // MongoDB user ID used in messages
  
      // Step 2: Find all messages where this user is involved
      const messages = await Message.find({
        $or: [{ senderId: userId }, { recipientId: userId }],
      });
  
      const userIds = new Set();
  
      // Step 3: Collect all other users they’ve chatted with
      messages.forEach((msg) => {
        if (msg.senderId.toString() !== userId) userIds.add(msg.senderId.toString());
        if (msg.recipientId.toString() !== userId) userIds.add(msg.recipientId.toString());
      });
  
      // Step 4: Fetch those users for the chat list
      const users = await User.find({ _id: { $in: Array.from(userIds) } });
      res.json(users);
    } catch (err) {
      console.error("Error getting chat users:", err);
      res.status(500).json({ error: err.message });
    }
  });
  
  
module.exports = router;
