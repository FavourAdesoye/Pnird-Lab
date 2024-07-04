const mongoose = require("mongoose")

const UserSchema = new mongoose.Schema({
    username:{
        type: String,
        require: true,
        max: 20, 
        unique: true
    }, 

    email:{
        type: String,
        required:true,
    },
    password:{
        type: String,
        required: true,
        min:8,
    }, 
    profilePicture:{
        type:String,
        default: ""
    },

   isAdmin: {
    type: Boolean,
    default: false,
   }
},
{timestamps:true}
);

module.exports = mongoose.model("User", UserSchema)