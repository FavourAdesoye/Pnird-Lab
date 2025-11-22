const mongoose = require("mongoose");

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true, // who the notification is for
  },
  type: {
    type: String,
    // Note: "study" and "event" are deprecated - use BroadcastNotification instead
    // Kept here for backward compatibility with old notifications in database
    enum: ["like", "comment", "new_post", "message", "study", "event"],
    required: true,
  },
  referenceId: {
    type: mongoose.Schema.Types.ObjectId,
    required: false, // e.g., postId, messageId, studyId
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true, // who triggered it
  },
  message: {
    type: String,
    required: true,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  
},{timestamps: true});

// Indexes for performance
NotificationSchema.index({ userId: 1, createdAt: -1 });
NotificationSchema.index({ userId: 1, isRead: 1 });
NotificationSchema.index({ type: 1, createdAt: -1 });

module.exports = mongoose.model("Notification", NotificationSchema);
