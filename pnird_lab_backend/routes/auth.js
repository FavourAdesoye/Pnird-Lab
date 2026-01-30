const router = require("express").Router();
const User = require("../models/User");

//Register
router.post("/register", async(req, res) => {
   const newUser = new User({
    username: req.body.username,
    email: req.body.email,
    password: req.body.password || 'default_password',
    profilePicture: req.body.profilePicture || '',
    role: req.body.role || 'community',
    firebaseUID: req.body.firebaseUID || '',
    isAdmin: req.body.isAdmin || false
   });

   try{
    const user = await newUser.save();
    res.status(200).json({
        message: "Registration successful",
        user: {
            id: user._id,
            username: user.username,
            email: user.email,
            role: user.role
        }
    });
   } catch(err){
    console.log(err);
    res.status(500).json({error: err.message});
   }
});

//Login
router.post("/login", async(req, res) => {
   try{
    const user = await User.findOne({email: req.body.email});
    if(!user){
        return res.status(400).json("Wrong credentials!");
    }

    // For now, just return success since we're using local auth
    // In production, you'd verify the password here
    res.status(200).json({
        message: "Login successful",
        user: {
            id: user._id,
            username: user.username,
            email: user.email,
            role: user.role || (user.isAdmin ? 'staff' : 'community')
        }
    });
   } catch(err){
    console.log(err);
    res.status(500).json("Internal server error");
   }
});

module.exports = router;