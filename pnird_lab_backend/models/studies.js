const mongoose = require("mongoose");  

const StudiesSchema = new mongoose.Schema({ 
    image_url : { 
        type : String, 
        required: true
    } ,
    cloudinary_id:{
        type: String
    },
    description : { 
        type: String, 
        required: false
    } ,

    titlepost : { 
        type: String, 
        required: true
    },
    allowScheduling: {
        type: Boolean,
        default: false, // Default to not allowing scheduling
    },
    allowComments: {
        type: Boolean,
        default: false, // Default to not allowing comments
    },
    comments: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Comment", // Reference to the Comment model
     }],

},

{timestamps: true}
);


module.exports = mongoose.model("StudiesModel", StudiesSchema);