// routes/messages.js
const express = require("express");
const router = express.Router();
const Message = require("../models/messages");
const User = require("../models/User");
const Notification = require("../models/notifications");

// Create a new message
router.post("/", async (req, res) => {
  try {
    const senderId = req.body.senderId;
    const recipientId = req.body.recipientId;
    const message = req.body.message;
    
    if (senderId === recipientId) {
        return res.status(403).json({ message: "Users cannot message themselves." });
    }

    // Check roles to enforce messaging rules
    const sender = await User.findById(senderId);
    const recipient = await User.findById(recipientId);
    
    if (!sender || !recipient) {
      return res.status(404).json({ message: "Sender or recipient not found." });
    }
    
    console.log("Sender ID:", senderId);
    console.log("Sender Name:", sender.username);
    console.log("Sender Role:", sender.role);
    console.log("Recipient Role:", recipient.role);
    
    // Community members can only message staff
    if (sender.role === 'community' && recipient.role !== 'staff') {
      return res.status(403).json({ 
        message: "Community members can only message staff members." 
      });
    }

    const newMessage = new Message({ senderId, recipientId, message });
    const saved = await newMessage.save();
    const senderName = sender.username;
    // Notify the recipient

        const notif = new Notification({
          userId: recipientId,
          type: "message",
          senderId: senderId,
          message: `${senderName} sent you a message.`,
          referenceId: saved._id,
        });
        await notif.save(); 
    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get unique chat users for a user (MUST be before /:userId route)
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

//Get all the messages the user has sent (MUST be after /chats/:firebaseUID route)
router.get("/:userId", async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [
        { senderId: req.params.userId },
        { recipientId: req.params.userId }
      ]
    }).sort({ timestamp: 1 }); // Sort by timestamp (oldest first)
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
  
module.exports = router;
