const mongoose = require("mongoose");
const express = require("express");
const dotenv = require("dotenv");  
const bodyParser = require("body-parser"); 
const eventRouter = require('./routers/event.route'); 

dotenv.config(); 

const app = express();

const Port = process.env.PORT || 5000; 

mongoose.connect(process.env.MONGO_URL).then(() => console.log("DB Connection successful") ).catch((err) => { 
    console.log("error");
}); 
 
//parsing the json  
app.use(bodyParser.urlencoded({extended: false})); 
app.use(bodyParser.json()); 
app.use('/uploads', express.static('uploads')) 
app.use(express.json()); 

//handling events posts
app.use('/eventregistration', eventRouter) 

//
app.listen(Port, () => {  
    console.log(`Server Listening on Port http://localhost:${Port}`)
}); 

 
