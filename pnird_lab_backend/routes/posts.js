const router = require("express").Router();
const Post = require("../models/Post");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const User = require("../models/User");
const Notification = require("../models/notifications");
//create a post with an image upload

router.post('/upload', upload.single('image'), async (req, res) => {
    try {
      const { img, userId, description } = req.body;
      console.log('Request body:', req.body);  // Log the incoming body
      console.log('Uploaded file:', req.file);
      // Upload image to Cloudinary
      let finalImageUrl;
  
      if (img) {
        // Web: Use the provided Cloudinary URL
        finalImageUrl = img;
      } else if (req.file) {
        // Mobile: Upload file to Cloudinary
        const result = await cloudinary.uploader.upload(req.file.path);
        finalImageUrl = result.secure_url;
  
        // Optional: Clean up the uploaded file from the server
        const fs = require("fs");
        fs.unlinkSync(req.file.path);
      } else {
        // Neither image_url nor file provided
        return res.status(400).json({ message: "No image provided" });
      }
      // Create new post
      let post = new Post({
        userId,
        description,
        img: finalImageUrl, // Store the URL of the uploaded image
        cloudinary_id: req.file ? result.public_id : null, // Only set if image was uploaded to Cloudinary
        likes: req.body.likes || [],
        createdAt: new Date(),
        updatedAt: new Date()
      });
      await post.save();
      res.json(post);
    }  
      catch(err){
        console.error("Error details:", err);
        res.status(500).json({ error: err.message });
  }
});
//like a post / dislike 
router.put("/:id/like", async(req,res)=>{
    try{
        const post = await Post.findById(req.params.id).populate('userId');
        const likerId = req.body.userId;
        const postAuthorId = post.userId._id || post.userId;
        
        if (!post.likes.includes(likerId)){
            await post.updateOne({$push:{likes:likerId}});
            
            // Create notification for post author (don't notify if user likes their own post)
            if (postAuthorId.toString() !== likerId) {
                const liker = await User.findById(likerId);
                const likerName = liker ? liker.username : "Someone";
                
                const notif = new Notification({
                    userId: postAuthorId,
                    type: "like",
                    senderId: likerId,
                    message: `${likerName} liked your post.`,
                    referenceId: post._id,
                });
                await notif.save();
                
                // Emit Socket.IO notification if io is available
                const io = req.app.get('io');
                if (io) {
                    const connectedUsers = req.app.get('connectedUsers');
                    const authorSocketId = connectedUsers ? connectedUsers.get(postAuthorId.toString()) : null;
                    if (authorSocketId) {
                        io.to(authorSocketId).emit("new_notification", {
                            _id: notif._id.toString(),
                            userId: postAuthorId.toString(),
                            type: "like",
                            senderId: likerId.toString(),
                            message: `${likerName} liked your post.`,
                            referenceId: post._id.toString(),
                            isRead: false,
                            createdAt: notif.createdAt ? new Date(notif.createdAt).toISOString() : new Date().toISOString(),
                        });
                    }
                }
            }
            
            res.status(200).json("The post has been liked")
        }else{
            await post.updateOne({$pull:{likes:likerId}});
            res.status(200).json("The post has been disliked");
        }
    }catch(err){
        console.error("Error in like route:", err);
        res.status(500).json(err);
    }
});
//get a post
router.get("/:id", async(req,res)=> {
    try{
        const post = await Post.findById(req.params.id);
        res.status(200).json(post);
    }catch(err){
        res.status(500).json(err);
    }
});

// Get all posts
router.get("/", async (req, res) => {
    try {
      const posts = await Post.find()
      .sort({ createdAt: -1 }) // Sort by creation date, newest first
      .populate('userId', 'username email profilePicture')
      .populate("comments");
      res.status(200).json(posts);
    } catch (err) {
      res.status(500).json(err);
    }
  });
//

// Get posts for a specific user using firebase id
router.get("/user/:userId", async (req, res) => {
  try{ 
  const uid = req.params.userId;
  const user = await User.findOne({ firebaseUID: uid });
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  //find user id  
 
  const id = user.id;   

  const userPosts = await Post.find({ userId: id }).sort({ createdAt: -1 }); // <-- add this!;
  if (!userPosts.length) {
    return res.status(200).json({ message: "No posts available for this user" });
  }
  res.status(200).json(userPosts);
}   catch (err) {
  console.error("Error fetching user posts:", err);
  res.status(500).json({ 
    error: "Failed to fetch user posts", 
    details: err.message 
  });
}
});


// GET posts by regular MongoDB userId
router.get("/user/id/:id", async (req, res) => {
    try {
      const posts = await Post.find({ userId: req.params.id })
      .sort({ createdAt: -1 }) // Sort by creation date, newest first
      .populate('userId')
      .populate('comments');
      if (!posts) {
            return res.status(404).json({ message: "No posts found for this user" });
        }
        res.status(200).json(posts);
    } catch (error) {
        console.error("Error fetching user posts:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

module.exports = router;