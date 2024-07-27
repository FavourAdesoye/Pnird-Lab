const mongoose = require("mongoose");  
const index = require('../index')

const {Schema } = mongoose; 

const eventsSchema = new Schema({ 
    image_url : { 
        type : String, 
        required: true
    } ,

    caption : { 
        type: String, 
        required: true
    } ,

    titlepost : { 
        type: String, 
        required: true
    } ,

    date_time: { 
        type: Date, 
        required: true, 
        default: Date.now
    }

}) 

const EventsModel = mongoose.model('events', eventsSchema) 

module.exports = EventsModel;