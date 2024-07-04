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
dotenv.config();

const Port = process.env.PORT|| 3000;

mongoose.
connect(process.env.MONGO_URL

).then(()=>console.log("DB Connection Successful!")).catch((error) =>{
    console.log(error);
})

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
    res.send("welcome")
});
app.listen(Port, ()=>{
    console.log(`Backend server is runninnng on port ${Port}!`);
});