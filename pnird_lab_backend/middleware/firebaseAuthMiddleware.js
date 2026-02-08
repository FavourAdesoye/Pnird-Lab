// middleware/firebaseAuthMiddleware.js
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// Make sure to replace 'your-firebase-adminsdk.json' with the path to your Firebase service account key JSON file


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
    return next();
  } catch (_error) {
    return res.status(403).json({ message: "Failed to authenticate token." });
  }
};

module.exports = firebaseAuthMiddleware;
