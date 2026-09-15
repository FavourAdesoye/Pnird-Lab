// routes/messages.js
const express = require("express");
const router = express.Router();
const Message = require("../models/messages");
const User = require("../models/User");
const Notification = require("../models/notifications");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { requireSelf, requireSelfFirebaseUid } = firebaseAuthMiddleware;

const publicChatUserFields = "username profilePicture role";

router.use(firebaseAuthMiddleware);

// Create a new message — sender is always the authenticated user
router.post("/", async (req, res) => {
  try {
    const senderId = String(req.mongoUser._id);
    const recipientId = String(req.body.recipientId || "").trim();
    const message = req.body.message;

    if (!recipientId || !message) {
      return res.status(400).json({ message: "recipientId and message are required." });
    }

    if (senderId === recipientId) {
      return res.status(403).json({ message: "Users cannot message themselves." });
    }

    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({ message: "Recipient not found." });
    }

    const sender = req.mongoUser;

    // Community members can only message staff
    if (sender.role === "community" && recipient.role !== "staff") {
      return res.status(403).json({
        message: "Community members can only message staff members.",
      });
    }

    const newMessage = new Message({ senderId, recipientId, message });
    const saved = await newMessage.save();

    const notif = new Notification({
      userId: recipientId,
      type: "message",
      senderId: senderId,
      message: `${sender.username} sent you a message.`,
      referenceId: saved._id,
    });
    await notif.save();

    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get unique chat users for the authenticated user
router.get(
  "/chats/:firebaseUID",
  requireSelfFirebaseUid("firebaseUID"),
  async (req, res) => {
    try {
      const user = req.mongoUser;
      const userId = user._id.toString();

      const messages = await Message.find({
        $or: [{ senderId: userId }, { recipientId: userId }],
      });

      const userIds = new Set();
      messages.forEach((msg) => {
        if (msg.senderId.toString() !== userId) userIds.add(msg.senderId.toString());
        if (msg.recipientId.toString() !== userId) userIds.add(msg.recipientId.toString());
      });

      const users = await User.find({ _id: { $in: Array.from(userIds) } }).select(
        publicChatUserFields
      );
      res.json(users);
    } catch (err) {
      console.error("Error getting chat users:", err);
      res.status(500).json({ error: err.message });
    }
  }
);

// Get all messages involving the authenticated user
router.get("/:userId", requireSelf("params", "userId"), async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [{ senderId: req.params.userId }, { recipientId: req.params.userId }],
    }).sort({ timestamp: 1 });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
