const mongoose = require('mongoose');
const Comment = require("../models/comment.js")
const Post = require("../models/Post");

const createComment = async (req,res) => {
    const postId = req.params.postId;
    const { comment, username} = req.body;

    try{
        const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Create the comment
    const createdComment = await Comment.create({
      postId,
      comment,
      username,
    });

    // Add the comment's ObjectId to the post's comments array
    post.comments.push(createdComment._id);
    await post.save(); // Save the updated post

    res.status(201).json(createdComment);
    }catch(error){
        res.status(404).json({message:error})
    }
};

const getCommentsByPost = async (req, res) => {
    const postId = req.params.postId;
    try {
        // Fetch the post to get the comments array
        const post = await Post.findById(postId).sort({ createdAt: 'desc'});
        
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }

        // Now fetch comments based on the comment IDs in post.comments array
        const comments = await Comment.find({ _id: { $in: post.comments } }).sort({ createdAt: -1 });
        
        res.status(200).json(comments);
    } catch (error) {
        console.error("Error in getCommentsByPost:", error);
        res.status(500).json({ message: error.message });
    }
};

const addReply = async (req, res) => {
    const { commentId } = req.params;
    const { username, reply } = req.body;

    try {
        const comment = await Comment.findById(commentId);
        if (comment) {
            comment.replies.push({
                username,
                reply,
                commentId: mongoose.Types.ObjectId(commentId),
            });
            await comment.save();
            res.status(201).json(comment);
        } else {
            res.status(404).json({ message: "Comment not found" });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};


module.exports = {
    createComment,
    getCommentsByPost,
    addReply,
};