const User = require("../models/User");

function checkRole(role) {
  return async (req, res, next) => {
    try {
      // Only trust authenticated Firebase token — never client-supplied firebaseUID
      const firebaseUID = req.user?.uid;
      if (!firebaseUID) {
        return res.status(401).json({ message: "Unauthorized." });
      }

      const user = req.mongoUser
        || (await User.findOne({ firebaseUID }).select("role").lean());

      if (!user) {
        return res.status(404).json({ message: "User not found." });
      }

      if (user.role === role || (role === "admin" && user.role === "staff")) {
        return next();
      }

      return res.status(403).json({ message: "Access denied." });
    } catch (_error) {
      return res.status(500).json({ message: "Error verifying user role." });
    }
  };
}

module.exports = checkRole;
