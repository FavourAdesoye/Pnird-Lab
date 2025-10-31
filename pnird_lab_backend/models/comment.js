const mongoose = require("mongoose") 

const ReplySchema = new mongoose.Schema({
    username: { type: String, required: true },
    comment: { type: String, required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
    createdAt: { type: Date, default: Date.now },
  });

const commentSchema = new mongoose.Schema({
    entityId:{
        type: mongoose.Schema.Types.ObjectId,
        refPath: 'entityType',
        required: true,
    },
    entityType: {
        type: String,
        required: true,
        enum: ['post', 'study'], // Add more types if needed
      },
    username:{
        type: String,
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    comment:{
        type: String,
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
    replies: [ReplySchema],
});

module.exports = mongoose.model("Comment", commentSchema);