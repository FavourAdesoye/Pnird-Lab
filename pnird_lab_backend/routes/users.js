const router = require("express").Router();
const User = require("../models/User");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");

//UPDATE USER
router.put("/:id", async(req,res) => {
    if (req.body.userId === req.params.id || req.user.isAdmin){

    }else{
        return res.status(403).json("you can only update your account")
    };
})
//DELETE USER

//GET A USER

//post an image

router.post('/upload', upload.single('image'), async (req, res) => {
    try{
    const result = await cloudinary.uploader.upload(req.file.path); 

    let user = new User({
        username: req.body.username,
        email: req.body.email,
        password: req.body.password,
        profilePicture: result.secure_url, // Store the URL of the uploaded image
        cloudinary_id: result.public_id, // Store the Cloudinary public ID for later use
        isAdmin: req.body.isAdmin || false
    });

    //Save User
    await user.save();
    res.json(user);
  
  }
    catch(err){
        console.log(err);
    }  
});




module.exports = router