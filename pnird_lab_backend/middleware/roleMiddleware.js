const User = require("../models/User");

function checkRole(role) {
  return async (req, res, next) => {
    try {
      const firebaseUID = req.user?.uid || req.body.firebaseUID;
      if (!firebaseUID) {
        return res.status(401).send("Unauthorized.");
      }

      const user = await User.findOne({ firebaseUID }).select("role").lean();
      if (!user) {
        return res.status(404).send("User not found.");
      }

      if (user.role === role || (role === "admin" && user.role === "staff")) {
        return next();
      }

      return res.status(403).send("Access denied.");
    } catch (_error) {
      return res.status(500).send("Error verifying user role.");
    }
  };
}

module.exports = checkRole;
  
  
