const {error} = require("console");
const express = require("express");
const app = express();
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const { default: helmet } = require("helmet");
const morgan = require("morgan");
const userRoute = require("./routes/users")
const postRoute = require("./routes/posts");
const authRoute = require("./routes/auth");
const cors = require('cors');
const bodyParser = require("body-parser"); 
const eventRouter = require('./routers/event.route'); 
dotenv.config();


mongoose.
connect(process.env.MONGO_URL

).then(()=>console.log("DB Connection Successful!")).catch((error) =>{
    console.log(error);
})
// Enable all CORS requests
app.use(cors());
//Middleware
app.use(express.json());
app.use(express.urlencoded({
    extended: true
}));
app.use(helmet());
app.use(morgan("common"));

app.use("/api/posts", postRoute);
app.use("/api/users", userRoute)
app.use("/api/auth", authRoute);


app.get("/", (req,res)=>{
    res.send("welcome to pnirdlab")
});
app.listen(Port, ()=>{
    console.log(`Backend server is runninnng on port ${Port}!`);
});

const Port = process.env.PORT || 5000; 

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

 
