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
      const allUsers = await User.find({ _id: { $ne: req.body.userId } });
      const sender = await User.findOne({ _id: req.body.userId });
      for (let user of allUsers) {
        const notif = new Notification({
          userId: user._id,
          type: "new_post",
          senderId: sender._id,
          message: `${sender.username} made a new post.`,
          referenceId: post._id,
        });
        await notif.save();
      }

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
        const post = await Post.findById(req.params.id);
        const user = await User.findOne({ _id: req.body.userId });
        if (!post.likes.includes(req.body.userId)){
            await post.updateOne({$push:{likes:req.body.userId}});
            if (post.userId._id.toString() !== req.body.userId) {
              await Notification.create({
                userId: post.userId._id,
                senderId: req.body.userId,
                type: "like",
                referenceId: post._id,
                message: `${user.username} liked your post`,
              });
            }
            res.status(200).json("The post has been liked")
        }else{
            await post.updateOne({$pull:{likes:req.body.userId}});
            res.status(200).json("The post has been disliked");
        }
    }catch(err){
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
      const posts = await Post.find().populate('userId', 'username email profilePicture')// Sort by creation date, newest first
      .populate("comments"); // <-- add this!
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
      const posts = await Post.find({ userId: req.params.id }).populate('userId').populate('comments');
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


module.exports = router;