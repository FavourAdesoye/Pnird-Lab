const router = require('express').Router();  
const ProfileController = require('../controllers/profile.controller')

router.post('/profileregistration',ProfileController.register);  

//temporary get route for testing 
router.get('/profileregistration', (req,res) => { 
    res.send("Registration GET route working")
});

module.exports = router;