const router = require("express").Router();
const User = require("../models/User");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const admin = require('firebase-admin')
const checkRole = require('../middleware/roleMiddleware');
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");

//UPDATE USER
router.put("/:id", async(req,res) => {
    if (req.body.userId === req.params.id || req.user?.isAdmin) {
        try {
          const updatedUser = await User.findByIdAndUpdate(req.params.id, {
            $set: req.body,
          }, { new: true });
          res.status(200).json(updatedUser);
        } catch (error) {
          res.status(500).json("Error updating user.");
        }
      } else {
        res.status(403).json("You can only update your account.");
      }
});
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

router.post('/users', async (req, res) => {
  const { userId, fullName, mobileNumber } = req.body;

  const newUser = new User({ userId, fullName, mobileNumber });
  await newUser.save();

  res.status(200).send('User saved successfully');
});

router.post('/register', async(req,res) => {
    const { username, email, firebaseUID, role } = req.body;

  try {
    // Check if user already exists
    let user = await User.findOne({ firebaseUID });
    if (user) return res.status(400).json({ message: 'User already registered' });

    // Create new user in MongoDB
    user = new User({ username, email, firebaseUID, role });
    await user.save();
    res.status(200).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/login', async (req, res) => {
    const idToken = req.headers.authorization?.split(' ')[1];
  
    if (!idToken) {
      return res.status(401).json({ message: 'Unauthorized: No token provided' });
    }
  
    try {
      // Verify the ID token with Firebase Admin SDK
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(idToken);
      const userId = decodedToken.uid;
      const userEmail = decodedToken.email;
  
      // Example: Check if the user has a 'staff' role
      // (Assumes you store roles in Firebase custom claims or another database)
      if (decodedToken.role === 'staff') {
        return res.status(200).json({ message: 'Login successful', userId, userEmail });
      } else {
        return res.status(403).json({ message: 'Access denied: Not a staff member' });
      }
    } catch (error) {
      console.error('Error verifying token:', error);
      return res.status(401).json({ message: 'Unauthorized: Invalid token' });
    }
  });
// GET Route: Retrieve User by Firebase UID
router.get('/:firebaseUID', async (req, res) => {
    try {
      const user = await User.findOne({ firebaseUID: req.params.firebaseUID });
      if (!user) return res.status(404).send("User not found.");
      res.status(200).json(user);
    } catch (error) {
      res.status(500).send("Error fetching user data.");
    }
  });

// Admin Route: Only accessible by users with admin role  
  router.get('/admin-data', firebaseAuthMiddleware, checkRole('admin'), (req, res) => {
    res.status(200).json({ message: 'Welcome, Admin!' });
  });

// Student Route: Only accessible by users with student role
  router.get('/student-data', firebaseAuthMiddleware, checkRole('student'), (req, res) => {
    res.status(200).json({ message: 'Welcome, Student!' });
  }); 

  // Route to retrieve user role
router.post("/getUserRole", async (req, res) => {
  const { uid } = req.body;
  

  try {
    // Find user by Firebase UID
    const user = await User.findOne({ firebaseUID: uid });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Return user's role
    res.json({ role: user.role });
  } catch (error) {
    console.error("Error fetching user role:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});
module.exports = router