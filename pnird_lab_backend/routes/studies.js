const router = require("express").Router();
const StudiesModel = require("../models/studies");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const BroadcastNotification = require("../models/broadcast_notifications");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { requireStaff } = firebaseAuthMiddleware;

// Create a new study — staff only
router.post(
  "/createstudy",
  firebaseAuthMiddleware,
  requireStaff,
  upload.single("image"),
  async (req, res) => {
    try {
      const { description, titlepost, image_url, allowScheduling, allowComments, formLink } =
        req.body;

      if (!description || !titlepost) {
        return res.status(400).json({ message: "Missing required fields" });
      }

      let finalImageUrl;

      if (image_url) {
        finalImageUrl = image_url;
      } else if (req.file) {
        const result = await cloudinary.uploader.upload(req.file.path);
        finalImageUrl = result.secure_url;

        const fs = require("fs");
        fs.unlinkSync(req.file.path);
      } else {
        return res.status(400).json({ message: "No image provided" });
      }

      const newStudy = new StudiesModel({
        titlepost,
        description,
        image_url: finalImageUrl,
        allowScheduling: allowScheduling || false,
        allowComments: allowComments || false,
        formLink: formLink || null,
      });

      const savedStudy = await newStudy.save();
      const creatorId = req.mongoUser._id;

      try {
        const broadcast = new BroadcastNotification({
          type: "study",
          referenceId: savedStudy._id,
          title: titlepost,
          message: `A new study "${titlepost}" has been posted.`,
          senderId: creatorId || undefined,
        });
        await broadcast.save();

        const io = req.app.get("io");
        if (io) {
          io.emit("new_broadcast", {
            _id: broadcast._id.toString(),
            type: "study",
            referenceId: savedStudy._id.toString(),
            title: titlepost,
            message: `A new study "${titlepost}" has been posted.`,
            senderId: creatorId ? creatorId.toString() : null,
            createdAt: broadcast.createdAt
              ? new Date(broadcast.createdAt).toISOString()
              : new Date().toISOString(),
          });
        }
      } catch (broadcastError) {
        console.error("Error creating study broadcast:", broadcastError);
      }

      res.status(201).json(savedStudy);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error", error: err.message });
    }
  }
);

// Fetch all studies (public)
router.get("/", async (req, res) => {
  try {
    const studies = await StudiesModel.find().sort({ createdAt: -1 });
    res.status(200).json(studies);
  } catch (error) {
    res.status(500).json({ message: "Error fetching studies", error: error.message });
  }
});

// Fetch a single study by ID (public)
router.get("/:id", async (req, res) => {
  try {
    const study = await StudiesModel.findById(req.params.id);
    if (!study) {
      return res.status(404).json({ message: "Study not found" });
    }
    res.status(200).json(study);
  } catch (error) {
    res.status(500).json({ message: "Error fetching study", error: error.message });
  }
});

// Update a study — staff only
router.put("/:id", firebaseAuthMiddleware, requireStaff, async (req, res) => {
  try {
    const allowed = {};
    for (const field of ["image_url", "description", "titlepost", "formLink"]) {
      if (req.body[field] !== undefined) {
        allowed[field] = req.body[field];
      }
    }

    const updatedStudy = await StudiesModel.findByIdAndUpdate(
      req.params.id,
      allowed,
      { new: true }
    );

    if (!updatedStudy) {
      return res.status(404).json({ message: "Study not found" });
    }

    res.status(200).json({ message: "Study updated successfully", study: updatedStudy });
  } catch (error) {
    res.status(500).json({ message: "Error updating study", error: error.message });
  }
});

// Delete a study — staff only
router.delete("/:id", firebaseAuthMiddleware, requireStaff, async (req, res) => {
  try {
    const deletedStudy = await StudiesModel.findByIdAndDelete(req.params.id);

    if (!deletedStudy) {
      return res.status(404).json({ message: "Study not found" });
    }

    res.status(200).json({ message: "Study deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting study", error: error.message });
  }
});

router.post("/studies/:id/comments", firebaseAuthMiddleware, async (req, res) => {
  try {
    const { comment } = req.body;
    const study = await StudiesModel.findById(req.params.id);
    if (!study) {
      return res.status(404).json({ message: "Study not found" });
    }

    if (!study.allowComments) {
      return res.status(400).json({ message: "Comments are not allowed for this study." });
    }

    res.status(200).json({ message: "Comment added successfully" });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

module.exports = router;
