const router = require("express").Router();
const EventsModel = require("../models/events");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const User = require("../models/User");
const Notification = require("../models/notifications");
//create a new event with an image upload
router.post("/createevent", upload.single("image"), async (req, res) => {
  try {
    const {
      description,
      titlepost,
      image_url,
      dateofevent,
      timeofevent,
      month,
      location,
      userId
    } = req.body;

    // Validate required fields (adjust as per your schema)
    if (!titlepost || !description || !dateofevent || !month || !location) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    let finalImageUrl;
    if (image_url) {
      finalImageUrl = image_url;
    } else if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path);
      finalImageUrl = result.secure_url;
      const fs = require("fs");
      try { fs.unlinkSync(req.file.path); } catch (_) {}
    } else {
      return res.status(400).json({ message: "No image provided" });
    }

    const newEvent = new EventsModel({
      titlepost,
      description,
      image_url: finalImageUrl,
      dateofevent,
      timeofevent,
      month,
      location,
      creatorId: userId || null
    });

    const savedEvent = await newEvent.save();
    if (!savedEvent) {
      return res.status(500).json({ message: "Failed to save event." });
    }

    // Notifications (non-blocking for success)
    if (userId) {
  try {
    const sender = await User.findById(userId);
    if (!sender) {
      console.warn("Sender not found for userId:", userId);
    } else {
      const others = await User.find({ _id: { $ne: userId } });
      await Promise.all(
        others.map(u =>
          new Notification({
            userId: u._id,
            type: "event",
            senderId: sender._id, // Only accessed if sender is valid
            message: `New Event posted: ${titlepost}`,
            referenceId: savedEvent._id,
          }).save()
        )
      );
    }
  } catch (notifErr) {
    console.error("Notification error:", notifErr);
  }
} else {
  console.warn("No userId provided in request (skipping notifications).");
}

    return res.status(201).json(savedEvent);
  } catch (err) {
    console.error("createevent error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
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