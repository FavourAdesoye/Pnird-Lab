const mongoose = require("mongoose");
const { type } = require("os");

const UserSchema = new mongoose.Schema({
    username:{
        type: String,
        required: true,
        max: 20, 
        unique: true
    }, 

    email:{
        type: String,
        required: true,
        unique: true,
    },
    password:{
        type: String,
        min: 8,
    }, 
    profilePicture:{
        type: String,
        default: ""
    },
    bio:{
        type: String,
        default: ""
    },
    role: {
        type: String,
        required: true,
        enum: ["staff", "student"]
    },

    cloudinary_id:{
        type: String
    },
    firebaseUID: {
        type: String,
        required: true,
        unique: true
    }
},
{timestamps: true}
);

module.exports = mongoose.model("User", UserSchema)