const express = require("express");
const { createComment, getCommentsByEntity, addReply } = require("../controllers/comment.controller");
const router = express.Router();


router.post('/:entityType/:entityId', createComment);

router.get('/:entityType/:entityId', getCommentsByEntity);

router.post('/:entityType/:commentId/reply', addReply);

module.exports = router;