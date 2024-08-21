const { register } = require('module');
const StudiesService = require('../services/studies.services'); 

exports.register = async(req, res, next) => { 
    try{ 
        const {post_id, user_id, date_time, image_url, caption, titlepost} = req.body; 

        const successRes = await StudiesService.registerEvent(post_id, user_id, date_time, image_url, caption, titlepost); 

        res.json({status: true, success: "Study Post Registered Successfully"});
    } catch(error){ 
         next(error);
    }
}  
