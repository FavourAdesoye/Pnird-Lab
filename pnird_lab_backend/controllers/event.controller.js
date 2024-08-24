const {register} = require('module');
const EventService = require('../services/event.services'); 

exports.register = async(req, res, next) => { 
    try{ 
        const {caption, titlepost, date_time} = req.body; 
        
        let image_url = '';  
        if(req.file){ 
            image_url = req.file.path;
        }

        const successRes = await EventService.registerEvent(image_url, caption, titlepost, date_time);  
        console.log('Recieved data:',req.body);

        res.json({status: true, success: "Event Registered Successfully"});
    } catch(error){  
        console.error("Error", error.message);
         next(error);
    }
}   

exports.getAllEvents = async (req,res,next) => {
    try{ 
        const events = await EventService.getAllEvents(); 
        res.json(events);
    } catch(error) { 
        console.error("Error", error.message); 
        next(error);
    }
}



