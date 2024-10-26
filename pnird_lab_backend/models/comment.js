const mongoose = require("mongoose") 

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
    replies: [{
        username:{
            type: String,
            required: true,
        },
        commentId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
        },
        reply: {
            type: String,
            required: true
        },
        createdAt: {
            type: Date,
            default: new Date().getTime()
        },
    },],
});

module.exports = mongoose.model("Comment", commentSchema);