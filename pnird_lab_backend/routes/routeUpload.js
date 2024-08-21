const express = require('express');
const router = express.Router();
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const User = require("..models/User")

 router.post('/upload', upload.single('image'), async (req, res) => {
  try{
    const result = await cloudinary.uploader.upload(req.file.path); 

    let user = new User({
      name: req.body.username,
      cloudinary_id: result.public_id,
    });

    //Save User
    await user.save();
    res.json(user);
  
  }
    catch(err){
        console.log(err);
    }  
});

module.exports = router;