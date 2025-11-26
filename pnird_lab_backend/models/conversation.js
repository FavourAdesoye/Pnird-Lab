const mongoose = require("mongoose");

const ConversationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true,
  },
  title: {
    type: String,
    default: "New Conversation",
  },
  messages: [
    {
      text: {
        type: String,
        required: true,
      },
      isUser: {
        type: Boolean,
        required: true,
      },
      timestamp: {
        type: Date,
        default: Date.now,
      },
    },
  ],
}, { timestamps: true });

// Index for faster queries
ConversationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model("Conversation", ConversationSchema);


