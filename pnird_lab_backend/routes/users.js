const router = require("express").Router();
const User = require("../models/User");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const admin = require('firebase-admin')
const checkRole = require('../middleware/roleMiddleware');
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { profile } = require("console");

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
        bio:req.body.bio,
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

// Helper function to suggest alternative usernames
async function suggestUsernames(baseUsername) {
  const suggestions = [];
  const base = baseUsername.toLowerCase().replace(/\s+/g, '');
  
  // Try variations
  for (let i = 1; i <= 5; i++) {
    const suggestion = `${base}${i}`;
    const exists = await User.findOne({ username: suggestion });
    if (!exists) {
      suggestions.push(suggestion);
      if (suggestions.length >= 3) break;
    }
  }
  
  return suggestions;
}

router.post('/register', async(req,res) => {
    const { username, email, firebaseUID, role } = req.body;

  try {
    console.log('Registration attempt:', { username, email, firebaseUID, role });
    
    // Validate required fields
    if (!username || !email || !firebaseUID || !role) {
      return res.status(400).json({ 
        message: 'Missing required fields: username, email, firebaseUID, and role are required' 
      });
    }

    // Verify the Firebase UID exists
    try {
      const userRecord = await admin.auth().getUser(firebaseUID);
      if (userRecord.email !== email.trim().toLowerCase()) {
        return res.status(400).json({ 
          message: 'Firebase UID does not match the provided email' 
        });
      }
    } catch (firebaseError) {
      return res.status(400).json({ 
        message: 'Invalid Firebase UID' 
      });
    }

    // Check for existing username
    const existingUsername = await User.findOne({ username: username.trim() });
    if (existingUsername) {
      const suggestions = await suggestUsernames(username);
      return res.status(400).json({ 
        message: `Username '${username}' is already taken. Please choose a different username.`,
        suggestions: suggestions
      });
    }

    // Check for existing email
    const existingEmail = await User.findOne({ email: email.trim().toLowerCase() });
    if (existingEmail) {
      return res.status(400).json({ 
        message: `Email '${email}' is already registered. Please use a different email or try logging in.` 
      });
    }

    // Check for existing Firebase UID
    const existingFirebaseUID = await User.findOne({ firebaseUID });
    if (existingFirebaseUID) {
      return res.status(400).json({ 
        message: 'This Firebase account is already registered' 
      });
    }

    // Validate role
    if (!['staff', 'community'].includes(role)) {
      return res.status(400).json({ 
        message: 'Invalid role. Must be either "staff" or "community"' 
      });
    }

    // Create user in MongoDB
    const user = new User({ 
      username: username.trim(), 
      email: email.trim().toLowerCase(), 
      firebaseUID, 
      role 
    });
    
    await user.save();
    console.log('User registered successfully:', user._id);
    
    res.status(201).json({ 
      message: 'User registered successfully',
      userId: user._id,
      username: user.username,
      email: user.email,
      role: user.role,
      firebaseUID: user.firebaseUID
    });
  } catch (err) {
    console.error('Registration error:', err);
    
    // Handle specific MongoDB errors
    if (err.code === 11000) {
      const field = Object.keys(err.keyPattern)[0];
      const value = err.keyValue[field];
      
      return res.status(400).json({ 
        message: `Registration failed: ${field} '${value}' is already taken. Please try again.` 
      });
    }
    
    // Handle validation errors
    if (err.name === 'ValidationError') {
      const errors = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors
      });
    }
    
    // Generic error
    res.status(500).json({ 
      message: 'Registration failed. Please try again.',
      error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
  }
});

// Cleanup endpoint to remove orphaned MongoDB records
router.post('/cleanup-orphaned', async (req, res) => {
  try {
    // Find users without corresponding Firebase accounts
    // This is a helper endpoint for cleanup
    const users = await User.find({});
    let cleanedCount = 0;
    
    for (const user of users) {
      try {
        // Try to verify the Firebase UID exists
        await admin.auth().getUser(user.firebaseUID);
      } catch (error) {
        // If Firebase user doesn't exist, delete MongoDB record
        await User.findByIdAndDelete(user._id);
        cleanedCount++;
        console.log(`Cleaned up orphaned user: ${user.username}`);
      }
    }
    
    res.status(200).json({ 
      message: `Cleanup completed. Removed ${cleanedCount} orphaned records.` 
    });
  } catch (err) {
    console.error('Cleanup error:', err);
    res.status(500).json({ 
      message: 'Cleanup failed',
      error: err.message 
    });
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
      const firebaseUID = decodedToken.uid;
  
      //Find user by Firebase UID
      let user = await User.findOne({ firebaseUID });
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      // Example: Check if the user has a 'staff' role

      // (Assumes you store roles in Firebase custom claims or another database)
      if (decodedToken.role === 'staff') {
        return res.status(200).json({ message: 'Login successful', firebaseUID: user.firebaseUID, userId:user._id, username:user.username, email: user.email });
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

// Community Route: Only accessible by users with community role
  router.get('/community-data', firebaseAuthMiddleware, checkRole('community'), (req, res) => {
    res.status(200).json({ message: 'Welcome, Community Member!' });
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
    return res.status(200).json({ userId: user._id.toString(),
      username: user.username,
      profilePicture: user.profilePicture,
      role: user.role });
  } catch (error) {
    console.error("Error fetching user role:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// GET user by regular MongoDB userId
router.get("/id/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Get user by username
router.get("/username/:username", async (req, res) => {
  try {
    const user = await User.findOne({ username: req.params.username });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    console.error("Error fetching user by username:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Check email verification status
router.get('/email-verification-status/:firebaseUID', async (req, res) => {
  try {
    const { firebaseUID } = req.params;
    
    // Get user from Firebase
    const userRecord = await admin.auth().getUser(firebaseUID);
    
    res.status(200).json({
      emailVerified: userRecord.emailVerified,
      email: userRecord.email
    });
  } catch (error) {
    console.error('Error checking email verification:', error);
    res.status(500).json({ message: 'Failed to check verification status' });
  }
});

// Resend email verification
router.post('/resend-verification', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }
    
    // Generate new verification link
    const link = await admin.auth().generateEmailVerificationLink(email.trim().toLowerCase());
    
    // In production, send this link via email service
    console.log('New verification link generated:', link);
    
    res.status(200).json({ 
      message: 'Verification email sent',
      verificationLink: link // For testing purposes
    });
  } catch (error) {
    console.error('Error resending verification:', error);
    res.status(500).json({ message: 'Failed to resend verification email' });
  }
});

module.exports = router
