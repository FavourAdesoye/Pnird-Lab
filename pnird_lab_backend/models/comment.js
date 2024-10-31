const mongoose = require("mongoose") 

const ReplySchema = new mongoose.Schema({
    username: { type: String, required: true },
    comment: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  });

const commentSchema = new mongoose.Schema({
    postId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Post',
        required: true,
    },
    username:{
        type: String,
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