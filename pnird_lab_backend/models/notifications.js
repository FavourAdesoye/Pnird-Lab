const mongoose = require("mongoose");

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true, // who the notification is for
  },
  type: {
    type: String,
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

module.exports = mongoose.model("Notification", NotificationSchema);
