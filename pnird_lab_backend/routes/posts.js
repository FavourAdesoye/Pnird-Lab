const router = require("express").Router();
const Post = require("../models/Post");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");

//create a post with an image upload

router.post('/upload', upload.single('image'), async (req, res) => {
    try {
      // Upload image to Cloudinary
      const result = await cloudinary.uploader.upload(req.file.path);
  
      // Create new post
      let post = new Post({
        userId: req.body.userId,
        description: req.body.description,
        img: result.secure_url, // Store the URL of the uploaded image
        cloudinary_id: result.public_id, // Store the Cloudinary public ID for later use
        likes: req.body.likes || [],
        createdAt: new Date(),
        updatedAt: new Date()
      });
      await post.save();
      res.json(post);
    }  
      catch(err){
        res.status(500).json(err)
    }
});

//like a post / dislike 
router.put("/:id/like", async(req,res)=>{
    try{
        const post = await Post.findById(req.params.id);
        if (!post.likes.includes(req.body.userId)){
            await post.updateOne({$push:{likes:req.body.userId}});
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
      const posts = await Post.find().populate('userId', 'username email profilePicture'); // Sort by creation date, newest first
      res.status(200).json(posts);
    } catch (err) {
      res.status(500).json(err);
    }
  });
  

module.exports = router;