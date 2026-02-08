const router = require("express").Router();
const mongoose = require("mongoose");
const admin = require("firebase-admin");

const User = require("../models/User");
const cloudinary = require("../utils/cloudinary");
const upload = require("../utils/multer");
const checkRole = require("../middleware/roleMiddleware");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { createRateLimiter } = require("../middleware/rateLimit");

const publicUserFields = "username email profilePicture bio role firebaseUID createdAt updatedAt";
const maintenanceKey = process.env.ADMIN_MAINTENANCE_KEY;

function sanitizeUserResponse(userDoc) {
  if (!userDoc) {
    return null;
  }
  return {
    _id: String(userDoc._id),
    username: userDoc.username,
    email: userDoc.email,
    profilePicture: userDoc.profilePicture || "",
    bio: userDoc.bio || "",
    role: userDoc.role,
    firebaseUID: userDoc.firebaseUID,
    createdAt: userDoc.createdAt,
    updatedAt: userDoc.updatedAt,
  };
}

function isValidObjectId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

function getBearerToken(req) {
  const authorization = req.headers.authorization || "";
  if (!authorization.startsWith("Bearer ")) {
    return null;
  }
  return authorization.slice(7).trim();
}

async function suggestUsernames(baseUsername) {
  const suggestions = [];
  const base = String(baseUsername || "")
    .toLowerCase()
    .replace(/\s+/g, "");

  for (let i = 1; i <= 5; i += 1) {
    const suggestion = `${base}${i}`;
    const exists = await User.findOne({ username: suggestion }).select("_id").lean();
    if (!exists) {
      suggestions.push(suggestion);
      if (suggestions.length >= 3) {
        break;
      }
    }
  }

  return suggestions;
}

router.use(
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 150,
    message: "Too many user requests. Please try again later.",
  })
);

router.put("/:id", async (req, res) => {
  const { id } = req.params;
  if (!isValidObjectId(id)) {
    return res.status(400).json({ message: "Invalid user id" });
  }

  if (req.body.userId !== id && !req.user?.isAdmin) {
    return res.status(403).json({ message: "You can only update your own account." });
  }

  const allowedFields = ["username", "bio", "profilePicture"];
  const updates = {};
  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      updates[field] = req.body[field];
    }
  }

  try {
    const updatedUser = await User.findByIdAndUpdate(id, { $set: updates }, { new: true })
      .select(publicUserFields)
      .lean();
    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }
    return res.status(200).json(sanitizeUserResponse(updatedUser));
  } catch (error) {
    console.error("User update error:", error.message);
    return res.status(500).json({ message: "Error updating user." });
  }
});

router.post("/upload", upload.single("image"), async (req, res) => {
  if (!req.file?.path) {
    return res.status(400).json({ message: "Image file is required" });
  }

  try {
    const result = await cloudinary.uploader.upload(req.file.path);

    const user = new User({
      username: req.body.username,
      email: req.body.email,
      password: req.body.password,
      profilePicture: result.secure_url,
      bio: req.body.bio,
      cloudinary_id: result.public_id,
      role: req.body.role === "staff" ? "staff" : "community",
      firebaseUID: req.body.firebaseUID,
    });

    const savedUser = await user.save();
    return res.status(201).json(sanitizeUserResponse(savedUser));
  } catch (error) {
    console.error("User upload registration error:", error.message);
    return res.status(500).json({ message: "Failed to create user from upload" });
  }
});

router.post("/register", async (req, res) => {
  const username = String(req.body.username || "").trim();
  const email = String(req.body.email || "").trim().toLowerCase();
  const firebaseUID = String(req.body.firebaseUID || "").trim();
  const role = String(req.body.role || "").trim();

  try {
    if (!username || !email || !firebaseUID || !role) {
      return res.status(400).json({
        message: "Missing required fields: username, email, firebaseUID, and role are required",
      });
    }

    if (!["staff", "community"].includes(role)) {
      return res.status(400).json({ message: 'Invalid role. Must be either "staff" or "community"' });
    }

    try {
      const userRecord = await admin.auth().getUser(firebaseUID);
      if ((userRecord.email || "").toLowerCase() !== email) {
        return res.status(400).json({ message: "Firebase UID does not match the provided email" });
      }
    } catch (_firebaseError) {
      return res.status(400).json({ message: "Invalid Firebase UID" });
    }

    const [existingUsername, existingEmail, existingFirebaseUID] = await Promise.all([
      User.findOne({ username }).select("_id").lean(),
      User.findOne({ email }).select("_id").lean(),
      User.findOne({ firebaseUID }).select("_id").lean(),
    ]);

    if (existingUsername) {
      const suggestions = await suggestUsernames(username);
      return res.status(409).json({
        message: `Username '${username}' is already taken. Please choose a different username.`,
        suggestions,
      });
    }

    if (existingEmail) {
      return res.status(409).json({
        message: `Email '${email}' is already registered. Please use a different email or try logging in.`,
      });
    }

    if (existingFirebaseUID) {
      return res.status(409).json({ message: "This Firebase account is already registered" });
    }

    const user = new User({ username, email, firebaseUID, role });
    const savedUser = await user.save();

    return res.status(201).json({
      message: "User registered successfully",
      user: sanitizeUserResponse(savedUser),
    });
  } catch (error) {
    console.error("Registration error:", error.message);
    if (error.code === 11000) {
      return res.status(409).json({ message: "Registration failed: duplicate field value" });
    }
    return res.status(500).json({ message: "Registration failed. Please try again." });
  }
});

router.post("/cleanup-orphaned", async (req, res) => {
  const requestKey = String(req.headers["x-admin-maintenance-key"] || "");
  if (!maintenanceKey || requestKey !== maintenanceKey) {
    return res.status(403).json({ message: "Forbidden" });
  }

  try {
    const users = await User.find({}).select("firebaseUID username");
    let cleanedCount = 0;

    for (const user of users) {
      try {
        await admin.auth().getUser(user.firebaseUID);
      } catch (_error) {
        await User.findByIdAndDelete(user._id);
        cleanedCount += 1;
      }
    }

    return res.status(200).json({
      message: `Cleanup completed. Removed ${cleanedCount} orphaned records.`,
    });
  } catch (error) {
    console.error("Cleanup error:", error.message);
    return res.status(500).json({ message: "Cleanup failed" });
  }
});

router.post("/login", async (req, res) => {
  const idToken = getBearerToken(req);
  if (!idToken) {
    return res.status(401).json({ message: "Unauthorized: No token provided" });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const firebaseUID = decodedToken.uid;
    const user = await User.findOne({ firebaseUID }).select(publicUserFields).lean();

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({
      message: "Login successful",
      user: sanitizeUserResponse(user),
    });
  } catch (error) {
    console.error("Error verifying token:", error.message);
    return res.status(401).json({ message: "Unauthorized: Invalid token" });
  }
});

router.get("/admin-data", firebaseAuthMiddleware, checkRole("admin"), (_req, res) => {
  res.status(200).json({ message: "Welcome, Admin!" });
});

router.get("/community-data", firebaseAuthMiddleware, checkRole("community"), (_req, res) => {
  res.status(200).json({ message: "Welcome, Community Member!" });
});

router.post("/getUserRole", async (req, res) => {
  const uid = String(req.body.uid || "").trim();
  if (!uid) {
    return res.status(400).json({ message: "uid is required" });
  }

  try {
    const user = await User.findOne({ firebaseUID: uid }).select("username profilePicture role").lean();
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({
      userId: String(user._id),
      username: user.username,
      profilePicture: user.profilePicture || "",
      role: user.role,
    });
  } catch (error) {
    console.error("Error fetching user role:", error.message);
    return res.status(500).json({ message: "Internal server error" });
  }
});

router.get("/id/:id", async (req, res) => {
  const { id } = req.params;
  if (!isValidObjectId(id)) {
    return res.status(400).json({ message: "Invalid user id" });
  }

  try {
    const user = await User.findById(id).select(publicUserFields).lean();
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    return res.status(200).json(sanitizeUserResponse(user));
  } catch (error) {
    console.error("Error fetching user:", error.message);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

router.get("/username/:username", async (req, res) => {
  const username = String(req.params.username || "").trim();
  try {
    const user = await User.findOne({ username }).select(publicUserFields).lean();
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    return res.status(200).json(sanitizeUserResponse(user));
  } catch (error) {
    console.error("Error fetching user by username:", error.message);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

router.get("/email-verification-status/:firebaseUID", async (req, res) => {
  try {
    const userRecord = await admin.auth().getUser(req.params.firebaseUID);
    return res.status(200).json({
      emailVerified: userRecord.emailVerified,
      email: userRecord.email,
    });
  } catch (error) {
    console.error("Error checking email verification:", error.message);
    return res.status(500).json({ message: "Failed to check verification status" });
  }
});

router.post("/resend-verification", async (req, res) => {
  try {
    const email = String(req.body.email || "").trim().toLowerCase();
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    await admin.auth().generateEmailVerificationLink(email);
    return res.status(200).json({ message: "Verification email request accepted" });
  } catch (error) {
    console.error("Error resending verification:", error.message);
    return res.status(500).json({ message: "Failed to resend verification email" });
  }
});

router.get("/:firebaseUID", async (req, res) => {
  const firebaseUID = String(req.params.firebaseUID || "").trim();
  try {
    const user = await User.findOne({ firebaseUID }).select(publicUserFields).lean();
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    return res.status(200).json(sanitizeUserResponse(user));
  } catch (error) {
    console.error("Error fetching user by firebaseUID:", error.message);
    return res.status(500).json({ message: "Error fetching user data." });
  }
});

module.exports = router;
