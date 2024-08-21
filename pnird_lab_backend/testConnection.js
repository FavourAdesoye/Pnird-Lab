const mongoose = require("mongoose");
const dotenv = require("dotenv");

dotenv.config();

mongoose.connect(process.env.MONGO_URL, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => {
        console.log("DB Connection successful");
        mongoose.connection.close();
    })
    .catch((err) => {
        console.error("DB Connection error:", err);
    });