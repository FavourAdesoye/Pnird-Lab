const EventsModel = require('../models/events')
class EventService{ 
    static async registerEvent(image_url, caption, titlepost, date_time){ 
        try{ 
            const createEvent = new EventsModel({image_url, caption, titlepost, date_time });
            return await createEvent.save();
        }catch(err){  
            console.error('Save error: ', err.message);
            throw err;
        }
    } 

    static async getAllEvents() { 
        try{ 
            return await EventsModel.find({}); 

        } catch(err){ 
            console.error('Fetch error:', err.message); 
            throw err;
        }
    }
}  

module.exports = EventService;