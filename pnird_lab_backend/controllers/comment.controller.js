const mongoose = require('mongoose');
const Comment = require("../models/comment.js")
const Post = require("../models/Post");
const Study = require("../models/studies.js");
const User = require("../models/User.js");
const Notification = require("../models/notifications");


const createComment = async (req, res) => {
    const { entityId, entityType } = req.params;
    const { comment, username } = req.body;

    try {
        let entity;
        if (entityType === "post") {
            entity = await Post.findById(entityId);
        } else if (entityType === "study") {
            entity = await Study.findById(entityId);
        } else {
            return res.status(400).json({ message: "Invalid entity type" });
        }

        if (!entity) {
            return res.status(404).json({ message: `${entityType} not found` });
        }

        // Create the comment
        const createdComment = await Comment.create({
            entityId,
            entityType,
            comment,
            username,
        });

        // Add the comment's ObjectId to the corresponding entity's comments array
        if (entityType === "post") {
            entity.comments.push(createdComment._id);
            await entity.save();
     
            const sender = await User.findOne({ username: req.body.username });
            const post = await Post.findById(entityId);
            
                await Notification.create({ //problem is notification for created comment is not being sent
                  userId: post.userId._id,
                  type: "comment",
                  senderId: sender._id,
                  message: `${req.body.username} commented on your post.`,
                  referenceId: post._id,
                });
            
              
        } else if (entityType === "study") {
            entity.comments.push(createdComment._id);
            await entity.save();

            const sender = await User.findOne({ username: req.body.username });
            const post = await Post.findById(entityId);
            await Notification.create({ 
                userId: post.userId._id,
                type: "comment",
                senderId: sender._id,
                message: `${req.body.username} commented on your study.`,
                referenceId: post._id,
              });
        }
        res.status(201).json(createdComment);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};

const getCommentsByEntity = async (req, res) => {
    const { entityId, entityType } = req.params;
    try {
        let comments;
        if (entityType === "post") {
            const post = await Post.findById(entityId);
            if (!post) {
                return res.status(404).json({ message: 'Post not found' });
            }
            comments = await Comment.find({ entityId: post._id, entityType: "post" }).sort({ createdAt: -1 });
        } else if (entityType === "study") {
            const study = await Study.findById(entityId);
            if (!study) {
                return res.status(404).json({ message: 'Study not found' });
            }
            comments = await Comment.find({ entityId: study._id, entityType: "study" }).sort({ createdAt: -1 });
        } else {
            return res.status(400).json({ message: "Invalid entity type" });
        }

        res.status(200).json(comments);
    } catch (error) {
        console.error("Error in getCommentsByEntity:", error);
        res.status(500).json({ message: error.message });
    }
};


const addReply = async (req, res) => {
    const { commentId } = req.params;
    const { username, reply } = req.body;

    try {
        // Find the comment by ID
        const comment = await Comment.findById(commentId);
        if (comment) {
            // Push the reply to the replies array
            comment.replies.push({
                username,
                comment: reply,  // This should match the schema's 'comment' field
                createdAt: new Date(),  // Include createdAt timestamp
            });
            await comment.save();  // Save the updated comment
            res.status(201).json(comment);  // Return the updated comment
        } else {
            res.status(404).json({ message: "Comment not found" });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};



module.exports = {
    createComment,
    getCommentsByEntity,
    addReply,
};