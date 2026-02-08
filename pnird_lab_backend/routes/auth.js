const crypto = require("crypto");
const router = require("express").Router();
const User = require("../models/User");
const { createRateLimiter } = require("../middleware/rateLimit");

function hashPassword(password, salt = crypto.randomBytes(16).toString("hex")) {
  const hash = crypto.scryptSync(password, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

function verifyPassword(password, storedPassword) {
  if (!storedPassword || !storedPassword.includes(":")) {
    return false;
  }
  const [salt, storedHash] = storedPassword.split(":");
  const calculatedHash = crypto.scryptSync(password, salt, 64).toString("hex");
  return crypto.timingSafeEqual(Buffer.from(storedHash, "hex"), Buffer.from(calculatedHash, "hex"));
}

router.use(
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 20,
    message: "Too many auth attempts. Please try again later.",
  })
);

router.post("/register", async (req, res) => {
  try {
    const username = String(req.body.username || "").trim();
    const email = String(req.body.email || "").trim().toLowerCase();
    const password = String(req.body.password || "");

    if (!username || !email || password.length < 8) {
      return res.status(400).json({
        message: "username, email, and password (min 8 chars) are required",
      });
    }

    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
    }

    const newUser = new User({
      username,
      email,
      password: hashPassword(password),
      profilePicture: req.body.profilePicture || "",
      role: req.body.role === "staff" ? "staff" : "community",
      firebaseUID: req.body.firebaseUID || `legacy-${crypto.randomUUID()}`,
    });

    const user = await newUser.save();
    return res.status(201).json({
      message: "Registration successful",
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Auth register error:", error.message);
    return res.status(500).json({ message: "Registration failed" });
  }
});

router.post("/login", async (req, res) => {
  try {
    const email = String(req.body.email || "").trim().toLowerCase();
    const password = String(req.body.password || "");

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const user = await User.findOne({ email });
    if (!user || !verifyPassword(password, user.password)) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    return res.status(200).json({
      message: "Login successful",
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role || "community",
      },
    });
  } catch (error) {
    console.error("Auth login error:", error.message);
    return res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = router;
