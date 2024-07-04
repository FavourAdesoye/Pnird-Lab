const express=require("express")
const router = require("express").Router();
const Post = require("../models/Post")
//create a post

router.post("/", async (req,res)=>{
    const newPost  = new Post(req.body)
    try{
        const savedPost = await newPost.save();
        res.status(200).json(savedPost);
    }catch(err){
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
      const posts = await Post.find().sort({ createdAt: -1 }); // Sort by creation date, newest first
      res.status(200).json(posts);
    } catch (err) {
      res.status(500).json(err);
    }
  });
  

module.exports = router;