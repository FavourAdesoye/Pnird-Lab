const mongoose = require("mongoose");  

const eventSchema = new mongoose.Schema({ 
    image_url : { 
        type : String, 
        required: true
    } ,

    description : { 
        type: String, 
        required: true
    } ,

    titlepost : { 
        type: String, 
        required: true
    } ,

    dateofevent: { 
        type: Date, 
        required: true, 
    },
    month:{
        type: String,
        required:true
    },
    timeofEvent:{
        type: String,
        default: "No time specified"
    },
    location:{
        type: String,
        required: true
    }

},
{timestamps: true}
) 

const EventsModel = mongoose.model('Event', eventSchema) 

module.exports = EventsModel;