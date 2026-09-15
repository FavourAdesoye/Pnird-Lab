const router = require("express").Router();
const Post = require("../models/Post");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const User = require("../models/User");
const Notification = require("../models/notifications");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { requireStaff } = firebaseAuthMiddleware;

// Create a post with an image upload — authenticated staff only
router.post(
  "/upload",
  firebaseAuthMiddleware,
  requireStaff,
  upload.single("image"),
  async (req, res) => {
    try {
      const { img, description } = req.body;
      if (!description) {
        return res.status(400).json({ message: "description is required" });
      }

      const userId = String(req.mongoUser._id);

      let finalImageUrl;
      let cloudinaryPublicId = null;

      if (img) {
        finalImageUrl = img;
      } else if (req.file) {
        const result = await cloudinary.uploader.upload(req.file.path);
        finalImageUrl = result.secure_url;
        cloudinaryPublicId = result.public_id;

        const fs = require("fs");
        fs.unlinkSync(req.file.path);
      } else {
        return res.status(400).json({ message: "No image provided" });
      }

      const post = new Post({
        userId,
        description,
        img: finalImageUrl,
        cloudinary_id: cloudinaryPublicId,
        likes: [],
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      await post.save();
      res.status(201).json(post);
    } catch (err) {
      console.error("Error details:", err.message);
      res.status(500).json({ message: "Failed to create post" });
    }
  }
);

// Get all posts (public) — before /:id
router.get("/", async (req, res) => {
  try {
    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .populate("userId", "username profilePicture")
      .populate("comments");
    res.status(200).json(posts);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch posts" });
  }
});

// Get posts for a specific user using firebase id (public)
router.get("/user/:userId", async (req, res) => {
  try {
    const uid = req.params.userId;
    const user = await User.findOne({ firebaseUID: uid });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const userPosts = await Post.find({ userId: user.id })
      .sort({ createdAt: -1 })
      .populate("userId", "username profilePicture");
    if (!userPosts.length) {
      return res.status(200).json({ message: "No posts available for this user" });
    }
    res.status(200).json(userPosts);
  } catch (err) {
    console.error("Error fetching user posts:", err);
    res.status(500).json({
      error: "Failed to fetch user posts",
      details: err.message,
    });
  }
});

// GET posts by regular MongoDB userId (public)
router.get("/user/id/:id", async (req, res) => {
  try {
    const posts = await Post.find({ userId: req.params.id })
      .sort({ createdAt: -1 })
      .populate("userId", "username profilePicture")
      .populate("comments");
    res.status(200).json(posts);
  } catch (error) {
    console.error("Error fetching user posts:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Like / unlike a post — authenticated user only
router.put("/:id/like", firebaseAuthMiddleware, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id).populate("userId");
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    const likerId = String(req.mongoUser._id);
    const postAuthorId = post.userId._id || post.userId;

    if (!post.likes.map(String).includes(likerId)) {
      await post.updateOne({ $push: { likes: likerId } });

      if (postAuthorId.toString() !== likerId) {
        const likerName = req.mongoUser.username || "Someone";

        const notif = new Notification({
          userId: postAuthorId,
          type: "like",
          senderId: likerId,
          message: `${likerName} liked your post.`,
          referenceId: post._id,
        });
        await notif.save();

        const io = req.app.get("io");
        if (io) {
          const connectedUsers = req.app.get("connectedUsers");
          const authorSocketId = connectedUsers
            ? connectedUsers.get(postAuthorId.toString())
            : null;
          if (authorSocketId) {
            io.to(authorSocketId).emit("new_notification", {
              _id: notif._id.toString(),
              userId: postAuthorId.toString(),
              type: "like",
              senderId: likerId,
              message: `${likerName} liked your post.`,
              referenceId: post._id.toString(),
              isRead: false,
              createdAt: notif.createdAt
                ? new Date(notif.createdAt).toISOString()
                : new Date().toISOString(),
            });
          }
        }
      }

      res.status(200).json("The post has been liked");
    } else {
      await post.updateOne({ $pull: { likes: likerId } });
      res.status(200).json("The post has been disliked");
    }
  } catch (err) {
    console.error("Error in like route:", err);
    res.status(500).json({ message: "Failed to update like" });
  }
});

// Get a post (public)
router.get("/:id", async (req, res) => {
  try {
    const post = await Post.findById(req.params.id).populate(
      "userId",
      "username profilePicture"
    );
    res.status(200).json(post);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch post" });
  }
});

module.exports = router;
