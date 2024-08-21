const profileModel = require('../models/profile')
class profileService{ 
    static async registerEvent(post_id, user_id, date_time, image_url, caption, titlepost){ 
        try{ 
            const createEvent = new profileModel({post_id, user_id, date_time, image_url, caption, titlepost });
            return await createEvent.save();
        }catch(err){ 
            throw err;
        }
    }
}  

module.exports = profileService;
