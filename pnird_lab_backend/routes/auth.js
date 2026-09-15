const router = require("express").Router();
const { createRateLimiter } = require("../middleware/rateLimit");

router.use(
  createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 20,
    message: "Too many auth attempts. Please try again later.",
  })
);

// Legacy Mongo password auth is disabled. Use Firebase + /api/users/register|getUserRole.
router.all("*", (_req, res) => {
  return res.status(410).json({
    message:
      "Legacy password authentication is disabled. Use Firebase Auth and /api/users endpoints.",
  });
});

module.exports = router;
