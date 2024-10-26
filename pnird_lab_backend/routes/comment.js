const express = require("express");
const { createComment, getCommentsByPost } = require("../controllers/comment.controller");
const router = express.Router();


router.post('/:postId/createComment', createComment);

router.get('/:postId/getComments', getCommentsByPost);

// router.post('/:postId/comments/:commentId/reply', addReply);

module.exports = router;