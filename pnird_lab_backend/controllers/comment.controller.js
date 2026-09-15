const Comment = require("../models/comment.js");
const User = require("../models/User");
const Post = require("../models/Post");
const Study = require("../models/studies.js");
const Notification = require("../models/notifications");

const createComment = async (req, res) => {
  const { entityId, entityType } = req.params;
  const { comment } = req.body;

  try {
    if (!comment || String(comment).trim() === "") {
      return res.status(400).json({ message: "Comment is required" });
    }

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

    const user = req.mongoUser;

    const createdComment = await Comment.create({
      entityId,
      entityType,
      comment: String(comment).trim(),
      username: user.username,
      userId: user._id,
    });

    if (entityType === "post") {
      entity.comments.push(createdComment._id);
      await entity.save();

      const populatedPost = await Post.findById(entityId).populate("userId");
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

        try {
          const io = req.app ? req.app.get("io") : null;
          if (io) {
            const connectedUsers = req.app.get("connectedUsers");
            const authorSocketId = connectedUsers
              ? connectedUsers.get(postAuthorId.toString())
              : null;
            if (authorSocketId) {
              io.to(authorSocketId).emit("new_notification", {
                _id: notif._id.toString(),
                userId: postAuthorId.toString(),
                type: "comment",
                senderId: user._id.toString(),
                message: `${commenterName} commented on your post.`,
                referenceId: entityId.toString(),
                isRead: false,
                createdAt: notif.createdAt
                  ? new Date(notif.createdAt).toISOString()
                  : new Date().toISOString(),
              });
            }
          }
        } catch (socketError) {
          console.error("Error emitting notification:", socketError);
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
        return res.status(404).json({ message: "Post not found" });
      }
      comments = await Comment.find({ entityId: post._id, entityType: "post" })
        .populate("userId", "username profilePicture")
        .sort({ createdAt: -1 });
    } else if (entityType === "study") {
      const study = await Study.findById(entityId);
      if (!study) {
        return res.status(404).json({ message: "Study not found" });
      }
      comments = await Comment.find({ entityId: study._id, entityType: "study" })
        .populate("userId", "username profilePicture")
        .sort({ createdAt: -1 });
    } else {
      return res.status(400).json({ message: "Invalid entity type" });
    }

    for (let comment of comments) {
      if (!comment.userId) {
        const user = await User.findOne({ username: comment.username });
        if (user) {
          comment.userId = {
            _id: user._id,
            username: user.username,
            profilePicture: user.profilePicture || null,
          };
        }
      }

      for (let reply of comment.replies) {
        if (!reply.userId) {
          const user = await User.findOne({ username: reply.username });
          if (user) {
            reply.userId = {
              _id: user._id,
              username: user.username,
              profilePicture: user.profilePicture || null,
            };
          }
        } else if (reply.userId && typeof reply.userId === "object" && reply.userId._id) {
          // already shaped
        } else {
          const user = await User.findById(reply.userId);
          if (user) {
            reply.userId = {
              _id: user._id,
              username: user.username,
              profilePicture: user.profilePicture || null,
            };
          }
        }
      }
    }

    const plainComments = await Promise.all(
      comments.map(async (comment) => {
        const plainComment = comment.toObject();
        plainComment.replies = await Promise.all(
          comment.replies.map(async (reply) => {
            let userData = null;

            if (typeof reply.userId === "string") {
              const user = await User.findById(reply.userId);
              if (user) {
                userData = {
                  _id: user._id,
                  username: user.username,
                  profilePicture: user.profilePicture || null,
                };
              }
            } else if (reply.userId && typeof reply.userId === "object" && reply.userId._id) {
              if (reply.userId.username && reply.userId.profilePicture !== undefined) {
                userData = reply.userId;
              } else {
                const user = await User.findById(reply.userId._id);
                if (user) {
                  userData = {
                    _id: user._id,
                    username: user.username,
                    profilePicture: user.profilePicture || null,
                  };
                }
              }
            } else {
              const user = await User.findOne({ username: reply.username });
              if (user) {
                userData = {
                  _id: user._id,
                  username: user.username,
                  profilePicture: user.profilePicture || null,
                };
              }
            }

            return {
              _id: reply._id,
              username: reply.username,
              comment: reply.comment,
              createdAt: reply.createdAt,
              userId: userData,
            };
          })
        );
        return plainComment;
      })
    );

    res.status(200).json(plainComments);
  } catch (error) {
    console.error("Error in getCommentsByEntity:", error);
    res.status(500).json({ message: error.message });
  }
};

const addReply = async (req, res) => {
  const { commentId } = req.params;
  const { reply } = req.body;

  try {
    if (!reply || String(reply).trim() === "") {
      return res.status(400).json({ message: "Reply is required" });
    }

    const user = req.mongoUser;
    const comment = await Comment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    const replyData = {
      username: user.username,
      comment: String(reply).trim(),
      createdAt: new Date(),
      userId: user._id,
    };

    comment.replies.push(replyData);
    await comment.save();
    res.status(201).json(comment);
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
