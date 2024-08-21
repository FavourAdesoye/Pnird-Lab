const StudiesModel = require('../models/studies')
class StudiesService{ 
    static async registerEvent(post_id, user_id, date_time, image_url, caption, titlepost){ 
        try{ 
            const createEvent = new StudiesModel({post_id, user_id, date_time, image_url, caption, titlepost });
            return await createEvent.save();
        }catch(err){ 
            throw err;
        }
    }
}  

module.exports = StudiesService;