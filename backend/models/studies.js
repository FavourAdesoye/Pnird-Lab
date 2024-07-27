const mongoose = require("mongoose");  
const index = require('../index')

const {Schema } = mongoose; 

const StudiesSchema = new Schema({ 
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

const StudiesModel = mongoose.model('studies', StudiesSchema) 

module.exports = SudiesModel;