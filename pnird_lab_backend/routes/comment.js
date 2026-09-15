const express = require("express");
const { createComment, getCommentsByEntity, addReply } = require("../controllers/comment.controller");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const router = express.Router();

// Public read
router.get("/:entityType/:entityId", getCommentsByEntity);

// Authenticated write — identity comes from token, not body
router.post("/:entityType/:entityId", firebaseAuthMiddleware, createComment);
router.post("/:entityType/:commentId/reply", firebaseAuthMiddleware, addReply);

module.exports = router;
