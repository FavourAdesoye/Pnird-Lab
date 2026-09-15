const admin = require("firebase-admin");
const User = require("../models/User");

/**
 * Verifies Firebase ID token and attaches:
 * - req.user: decoded Firebase token (uid, email, ...)
 * - req.mongoUser: Mongo User document for that firebaseUID
 */
const firebaseAuthMiddleware = async (req, res, next) => {
  const authorization = req.headers.authorization || "";
  const token = authorization.startsWith("Bearer ")
    ? authorization.slice(7).trim()
    : authorization.trim();

  if (!token) {
    return res.status(401).json({ message: "No token provided." });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;

    const mongoUser = await User.findOne({ firebaseUID: decodedToken.uid });
    if (!mongoUser) {
      return res.status(404).json({ message: "User account not found." });
    }

    req.mongoUser = mongoUser;
    return next();
  } catch (_error) {
    return res.status(403).json({ message: "Failed to authenticate token." });
  }
};

/** Requires authenticated staff role */
const requireStaff = (req, res, next) => {
  if (!req.mongoUser || req.mongoUser.role !== "staff") {
    return res.status(403).json({ message: "Staff access required." });
  }
  return next();
};

/**
 * Ensures the authenticated user owns the Mongo userId in params/body.
 * @param {string} source - "params" | "body"
 * @param {string} key - field name (default "userId")
 */
const requireSelf =
  (source = "params", key = "userId") =>
  (req, res, next) => {
    if (!req.mongoUser) {
      return res.status(401).json({ message: "Unauthorized." });
    }

    const claimedId = String(req[source]?.[key] || "").trim();
    const actualId = String(req.mongoUser._id);

    if (!claimedId || claimedId !== actualId) {
      return res.status(403).json({ message: "You can only access your own data." });
    }

    return next();
  };

/** Ensures param firebaseUID matches the authenticated token */
const requireSelfFirebaseUid = (paramKey = "firebaseUID") => (req, res, next) => {
  if (!req.user?.uid) {
    return res.status(401).json({ message: "Unauthorized." });
  }

  const claimed = String(req.params[paramKey] || "").trim();
  if (!claimed || claimed !== req.user.uid) {
    return res.status(403).json({ message: "You can only access your own data." });
  }

  return next();
};

module.exports = firebaseAuthMiddleware;
module.exports.requireStaff = requireStaff;
module.exports.requireSelf = requireSelf;
module.exports.requireSelfFirebaseUid = requireSelfFirebaseUid;
