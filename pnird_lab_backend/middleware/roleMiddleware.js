const User = require("../models/User");

function checkRole(role) {
    return (req, res, next) => {
      User.findOne({ firebaseUID: req.body.firebaseUID })
        .then(user => {
          if (user && user.role === role) next();
          else res.status(403).send("Access denied.");
        })
        .catch(() => res.status(500).send("Error verifying user role."));
    };
  }
  module.exports = checkRole;
  
  