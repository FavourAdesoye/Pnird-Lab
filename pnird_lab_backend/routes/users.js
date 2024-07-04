const router = require("express").Router();
const User = require("../models/User");

//UPDATE USER
router.put("/:id", async(req,res) => {
    if (req.body.userId === req.params.id || req.user.isAdmin){

    }else{
        return res.status(403).json("you can only update your account")
    };
})
//DELETE USER

//GET A USER



module.exports = router