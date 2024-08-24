const mongoose = require("mongoose");  
const index = require('../index')

const {Schema } = mongoose; 

const profileSchema = new Schema({ 
    post_id :{ 
        type : String ,
        required: true,  
        unique: true,
    },  

    user_id : { 
        type: String ,
        required: true
    }, 

    date_time : { 
        type: String, 
        required: true
    },

    image_url : { 
        type : String, 
        required: true
    } ,

    caption : { 
        type: String, 
        required: false
    } ,

    titlepost : { 
        type: String, 
        required: true
    }

}) 

const profileModel = mongoose.model('profile', profileSchema) 

module.exports = profileModel;