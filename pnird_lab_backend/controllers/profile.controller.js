const { register } = require('module');
const profileService = require('../services/profile.services'); 

exports.register = async(req, res, next) => { 
    try{ 
        const {post_id, user_id, date_time, image_url, caption, titlepost} = req.body; 

        const successRes = await profileService.registerEvent(post_id, user_id, date_time, image_url, caption, titlepost); 

        res.json({status: true, success: "Profile Post Registered Successfully"});
    } catch(error){ 
         next(error);
    }
}  



