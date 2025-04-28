const router = require("express").Router();
const EventsModel = require("../models/events");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");

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
      // Notify all users (optional)
      const users = await User.find(); // or filter by role or interest

for (let user of users) {
  if (user._id !== creatorId) {
    const notif = new Notification({
      userId: user._id,
      type: "study", // or "event"
      senderId: creatorId,
      message: `New study/event posted: ${title}`,
    });
    await notif.save();
  }
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