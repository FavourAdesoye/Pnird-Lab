const mongoose = require('mongoose');
const Comment = require("../models/comment.js")
const User = require("../models/User");
const Post = require("../models/Post");
const Study = require("../models/studies.js");
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

        // Find the user to get their ID
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Create the comment
        const createdComment = await Comment.create({
            entityId,
            entityType,
            comment,
            username,
            userId: user._id,
        });


        // Add the comment's ObjectId to the corresponding entity's comments array
        if (entityType === "post") {
            entity.comments.push(createdComment._id);
            await entity.save();
            
            // Create notification for post author (don't notify if user comments on their own post)
            const populatedPost = await Post.findById(entityId).populate('userId');
            const postAuthorId = populatedPost.userId._id || populatedPost.userId;
            
            if (postAuthorId.toString() !== user._id.toString()) {
                const commenterName = user.username || "Someone";
                
                const notif = new Notification({
                    userId: postAuthorId,
                    type: "comment",
                    senderId: user._id,
                    message: `${commenterName} commented on your post.`,
                    referenceId: entityId,
                });
                await notif.save();
                
                // Emit Socket.IO notification
                try {
                    const io = req.app ? req.app.get('io') : null;
                    if (io) {
                        const connectedUsers = req.app.get('connectedUsers');
                        const authorSocketId = connectedUsers ? connectedUsers.get(postAuthorId.toString()) : null;
                        if (authorSocketId) {
                            io.to(authorSocketId).emit("new_notification", {
                                _id: notif._id.toString(),
                                userId: postAuthorId.toString(),
                                type: "comment",
                                senderId: user._id.toString(),
                                message: `${commenterName} commented on your post.`,
                                referenceId: entityId.toString(),
                                isRead: false,
                                createdAt: notif.createdAt ? new Date(notif.createdAt).toISOString() : new Date().toISOString(),
                            });
                        }
                    }
                } catch (socketError) {
                    console.error("Error emitting notification:", socketError);
                    // Don't fail the request if Socket.IO fails
                }
            }
        } else if (entityType === "study") {
            entity.comments.push(createdComment._id);
            await entity.save();
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
            comments = await Comment.find({ entityId: post._id, entityType: "post" })
                .populate('userId', 'username profilePicture')
                .sort({ createdAt: -1 });
        } else if (entityType === "study") {
            const study = await Study.findById(entityId);
            if (!study) {
                return res.status(404).json({ message: 'Study not found' });
            }
            comments = await Comment.find({ entityId: study._id, entityType: "study" })
                .populate('userId', 'username profilePicture')
                .sort({ createdAt: -1 });
        } else {
            return res.status(400).json({ message: "Invalid entity type" });
        }

        // For comments without userId (legacy comments), find user by username
        for (let comment of comments) {
            if (!comment.userId) {
                const user = await User.findOne({ username: comment.username });
                if (user) {
                    comment.userId = {
                        _id: user._id,
                        username: user.username,
                        profilePicture: user.profilePicture || null
                    };
                }
            }
            
            // Handle replies - populate user data for each reply
            for (let reply of comment.replies) {
                if (!reply.userId) {
                    const user = await User.findOne({ username: reply.username });
                    if (user) {
                        // Convert to plain object and add user data
                        reply.userId = {
                            _id: user._id,
                            username: user.username,
                            profilePicture: user.profilePicture || null
                        };
                    }
                } else if (reply.userId && typeof reply.userId === 'object' && reply.userId._id) {
                    // If userId is already populated, ensure it has the right structure
                    // No action needed
                } else {
                    // If userId is just an ObjectId, populate it
                    const user = await User.findById(reply.userId);
                    if (user) {
                        reply.userId = {
                            _id: user._id,
                            username: user.username,
                            profilePicture: user.profilePicture || null
                        };
                    }
                }
            }
        }

        // Convert to plain objects to ensure proper JSON serialization
        const plainComments = await Promise.all(comments.map(async (comment) => {
            const plainComment = comment.toObject();
            // Ensure replies have proper user data by using the modified reply objects
            plainComment.replies = await Promise.all(comment.replies.map(async (reply) => {
                // Create plain reply object
                let userData = null;
                
                // If userId is a string (ObjectId), fetch the user data
                if (typeof reply.userId === 'string') {
                    const user = await User.findById(reply.userId);
                    if (user) {
                        userData = {
                            _id: user._id,
                            username: user.username,
                            profilePicture: user.profilePicture || null
                        };
                    }
                } else if (reply.userId && typeof reply.userId === 'object' && reply.userId._id) {
                    // If userId is already populated with user data, use it
                    if (reply.userId.username && reply.userId.profilePicture !== undefined) {
                        userData = reply.userId;
                    } else {
                        // If it's just an ObjectId object, fetch the user data
                        const user = await User.findById(reply.userId._id);
                        if (user) {
                            userData = {
                                _id: user._id,
                                username: user.username,
                                profilePicture: user.profilePicture || null
                            };
                        }
                    }
                } else {
                    // If no userId, try to find by username
                    const user = await User.findOne({ username: reply.username });
                    if (user) {
                        userData = {
                            _id: user._id,
                            username: user.username,
                            profilePicture: user.profilePicture || null
                        };
                    }
                }
                
                const plainReply = {
                    _id: reply._id,
                    username: reply.username,
                    comment: reply.comment,
                    createdAt: reply.createdAt,
                    userId: userData
                };
                
                return plainReply;
            }));
            return plainComment;
        }));
        
        res.status(200).json(plainComments);
    } catch (error) {
        console.error("Error in getCommentsByEntity:", error);
        res.status(500).json({ message: error.message });
    }
};


const addReply = async (req, res) => {
    const { commentId } = req.params;
    const { username, reply } = req.body;

    try {
        // Find the user to get their ID (optional)
        const user = await User.findOne({ username });
        
        // Find the comment by ID
        const comment = await Comment.findById(commentId);
        if (comment) {
            // Create reply object
            const replyData = {
                username,
                comment: reply,  // This should match the schema's 'comment' field
                createdAt: new Date(),  // Include createdAt timestamp
            };
            
            // Add userId if user is found
            if (user) {
                replyData.userId = {
                    _id: user._id,
                    username: user.username,
                    profilePicture: user.profilePicture || null
                };
            }
            
            // Push the reply to the replies array
            comment.replies.push(replyData);
            await comment.save();  // Save the updated comment
            res.status(201).json(comment);  // Return the updated comment
        } else {
            res.status(404).json({ message: "Comment not found" });
        }
    } catch (error) {
        console.error("Error in addReply:", error);
        res.status(500).json({ message: error.message });
    }
};



module.exports = {
    createComment,
    getCommentsByEntity,
    addReply,
};