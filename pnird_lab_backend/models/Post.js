const mongoose = require("mongoose");

const PostSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // Reference to the User model
            required: true
        },
        description:{
            type: String,
        },
        img:{
            type:String
        },
        cloudinary_id:{
            type: String
        },
        likes:{
            type:Array,
            default: [],
        },
        createdAt:{
            type: Date,
            default: Date.now
        },
        updatedAt:{
            type: Date,
            default: Date.now
        }

    },
    {timestamps: true}
);

module.exports = mongoose.model("Post", PostSchema);