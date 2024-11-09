// middleware/firebaseAuthMiddleware.js
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// Make sure to replace 'your-firebase-adminsdk.json' with the path to your Firebase service account key JSON file


const firebaseAuthMiddleware = async (req, res, next) => {
  const authToken = req.headers.authorization;

  if (!authToken) {
    return res.status(401).json({ message: "No token provided." });
  }

  try {
    // Verify the Firebase token
    const decodedToken = await admin.auth().verifyIdToken(authToken);
    req.user = decodedToken; // Populate req.user with decoded token info

    next();
  } catch (error) {
    res.status(403).json({ message: "Failed to authenticate token." });
  }
};

module.exports = firebaseAuthMiddleware;
