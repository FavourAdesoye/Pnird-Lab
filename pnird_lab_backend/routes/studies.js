const router = require("express").Router();
const StudiesModel = require("../models/studies");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const Comment = require("../models/comment");
const BroadcastNotification = require("../models/broadcast_notifications");
const User = require("../models/User");



//create a new study with an image upload

router.post("/createstudy", upload.single("image"), async (req, res) => {
    try {
      const { description, titlepost, image_url, allowScheduling, allowComments } = req.body;
  
      // Validate required fields
      if (!description || !titlepost) {
        return res.status(400).json({ message: "Missing required fields" });
      }
  
      let finalImageUrl;
  
      if (image_url) {
        // Web: Use the provided Cloudinary URL
        finalImageUrl = image_url;
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
  
      // Create new study
      const newStudy = new StudiesModel({
        titlepost,
        description,
        image_url: finalImageUrl,
        allowScheduling: allowScheduling || false,
        allowComments: allowComments || false,
      });
  
      // Save to database
      const savedStudy = await newStudy.save();
      
      // Get creator info for broadcast - try to get from request or find a staff user
      let creatorId = req.body.userId || req.body.creatorId;
      if (!creatorId) {
        // Try to find a staff user to use as sender
        const staffUser = await User.findOne({ role: "staff" });
        creatorId = staffUser ? staffUser._id : null;
      }
      
      // Create ONE broadcast notification instead of N individual notifications
      try {
        const broadcast = new BroadcastNotification({
          type: "study",
          referenceId: savedStudy._id,
          title: titlepost,
          message: `A new study "${titlepost}" has been posted.`,
          senderId: creatorId || undefined,
        });
        await broadcast.save();
        
        // Emit Socket.IO broadcast to all connected users
        const io = req.app.get('io');
        if (io) {
          io.emit("new_broadcast", {
            _id: broadcast._id.toString(),
            type: "study",
            referenceId: savedStudy._id.toString(),
            title: titlepost,
            message: `A new study "${titlepost}" has been posted.`,
            senderId: creatorId ? creatorId.toString() : null,
            createdAt: broadcast.createdAt ? new Date(broadcast.createdAt).toISOString() : new Date().toISOString(),
          });
        }
      } catch (broadcastError) {
        console.error("Error creating study broadcast:", broadcastError);
        // Don't fail the request if broadcast fails
      }
      
      res.status(201).json(savedStudy);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error", error: err.message });
    }
  });

// Fetch all studies
router.get('/', async (req, res) => {
    try {
        const studies = await StudiesModel.find().sort({ createdAt: -1 }); // Newest first
        res.status(200).json(studies);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching studies', error: error.message });
    }
});

// Fetch a single study by ID
router.get('/:id', async (req, res) => {
    try {
        const study = await StudiesModel.findById(req.params.id);
        if (!study) {
            return res.status(404).json({ message: 'Study not found' });
        }
        res.status(200).json(study);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching study', error: error.message });
    }
});

// Update a study
router.put('/:id', async (req, res) => {
    try {
        const {date_time, image_url, description, titlepost } = req.body;

        const updatedStudy = await StudiesModel.findByIdAndUpdate(
            req.params.id,
            {date_time, image_url, description, titlepost },
            { new: true } // Return the updated document
        );

        if (!updatedStudy) {
            return res.status(404).json({ message: 'Study not found' });
        }

        res.status(200).json({ message: 'Study updated successfully', study: updatedStudy });
    } catch (error) {
        res.status(500).json({ message: 'Error updating study', error: error.message });
    }
});

// Delete a study
router.delete('/:id', async (req, res) => {
    try {
        const deletedStudy = await StudiesModel.findByIdAndDelete(req.params.id);

        if (!deletedStudy) {
            return res.status(404).json({ message: 'Study not found' });
        }

        res.status(200).json({ message: 'Study deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting study', error: error.message });
    }
});
//leaving a comment
router.post("/studies/:id/comments", async (req, res) => {
    try {
      const { comment } = req.body;
      const study = await StudiesModel.findById(req.params.id);
      if (!study) {
        return res.status(404).json({ message: "Study not found" });
      }
  
      if (!study.allowComments) {
        return res.status(400).json({ message: "Comments are not allowed for this study." });
      }
  
      // Add the comment logic here (e.g., saving it to the database or embedding in the study)
      res.status(200).json({ message: "Comment added successfully" });
    } catch (err) {
      res.status(500).json({ message: "Server error", error: err.message });
    }
  });
  

module.exports = router;