const mongoose = require("mongoose");

const BroadcastNotificationSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ["study", "event"],
    required: true,
  },
  referenceId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true, // Study or Event ID
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: false, // Optional: who created it
  },
}, { timestamps: true });

// Index for efficient queries
BroadcastNotificationSchema.index({ type: 1, createdAt: -1 });
BroadcastNotificationSchema.index({ createdAt: 1 });

module.exports = mongoose.model("BroadcastNotification", BroadcastNotificationSchema);

