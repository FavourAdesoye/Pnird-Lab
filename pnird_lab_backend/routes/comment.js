const express = require("express");
const { createComment, getCommentsByPost, addReply } = require("../controllers/comment.controller");
const router = express.Router();


router.post('/:postId/createComment', createComment);

router.get('/:postId/getComments', getCommentsByPost);

router.post('/:commentId/replies', addReply);

module.exports = router;