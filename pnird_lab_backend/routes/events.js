const router = require("express").Router();
const EventsModel = require("../models/events");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const BroadcastNotification = require("../models/broadcast_notifications");
const User = require("../models/User");

//create a new event with an image upload
router.post("/createevent", upload.single("image"), async (req, res) => {
    try {
      const { description, titlepost, image_url, dateofevent, timeofevent, month, location} = req.body;
  
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
      const newEvent = new EventsModel({
        titlepost,
        description,
        image_url: finalImageUrl,
        dateofevent,
        timeofevent,
        month,
        location
      });
  
      // Save to database
      const savedEvent = await newEvent.save();
      
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
          type: "event",
          referenceId: savedEvent._id,
          title: titlepost,
          message: `A new event "${titlepost}" has been posted.`,
          senderId: creatorId || undefined,
        });
        await broadcast.save();
        
        // Emit Socket.IO broadcast to all connected users
        const io = req.app.get('io');
        if (io) {
          io.emit("new_broadcast", {
            _id: broadcast._id.toString(),
            type: "event",
            referenceId: savedEvent._id.toString(),
            title: titlepost,
            message: `A new event "${titlepost}" has been posted.`,
            senderId: creatorId ? creatorId.toString() : null,
            createdAt: broadcast.createdAt ? new Date(broadcast.createdAt).toISOString() : new Date().toISOString(),
          });
        }
      } catch (broadcastError) {
        console.error("Error creating event broadcast:", broadcastError);
        // Don't fail the request if broadcast fails
      }
      
      res.status(201).json(savedEvent);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error", error: err.message });
    }
  });

// Fetch all studies
router.get('/events', async (req, res) => {
    try {
        const events = await EventsModel.find();
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching events', error: error.message });
    }
});

// Get event by month
router.get('/event/:month', async (req, res) => {
    const {month} = req.params
    try {
        const events = await EventsModel.find({month});
        if (!events) {
            return ({ message: 'No events for this month' });
        }
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching Event', error: error.message });
    }
});

// Update an event
router.put('/event/:id', async (req, res) => {
    const { id } = req.params;
  try {
    const updatedEvent = await EventsModel.findByIdAndUpdate(id, req.body, { new: true });
    res.json(updatedEvent);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete an event
router.delete('/event/:id', async (req, res) => {
    const { id } = req.params;
  try {
    await EventsModel.findByIdAndDelete(id);
    res.json({ message: "Event deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// //leaving a comment
// router.post("/studies/:id/comments", async (req, res) => {
//     try {
//       const { comment } = req.body;
//       const study = await StudiesModel.findById(req.params.id);
//       if (!study) {
//         return res.status(404).json({ message: "Study not found" });
//       }
  
//       if (!study.allowComments) {
//         return res.status(400).json({ message: "Comments are not allowed for this study." });
//       }
  
//       // Add the comment logic here (e.g., saving it to the database or embedding in the study)
//       res.status(200).json({ message: "Comment added successfully" });
//     } catch (err) {
//       res.status(500).json({ message: "Server error", error: err.message });
//     }
//   });
  

module.exports = router;