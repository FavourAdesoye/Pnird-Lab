const router = require('express').Router();  
const StudiesController = require('../controllers/studies.controller');

router.post('/studyregistration', StudiesController.register);  

//temporary get route for testing 
router.get('/studyregistration', (req,res) => { 
    res.send("Registration GET route working")
});

module.exports = router;