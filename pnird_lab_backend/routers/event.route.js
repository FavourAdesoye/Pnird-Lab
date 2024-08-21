const express = require('express');
const router = express.Router();
const EventController = require('../controllers/event.controller')
const upload = require('../middleware/upload') 


router.post('/', upload.single('image_url'), EventController.register);  

//temporary get route for testing 
router.get('/eventregistration', (req,res) => { 
    res.send("Registration GET route working")
}); 

//Route to get all events 
router.get('/events', EventController.getAllEvents);

module.exports = router;