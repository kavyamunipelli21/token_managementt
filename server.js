require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");

const userRoutes = require("./routes/user-route");
const otpRoutes = require("./routes/otp-route");
const serviceRoutes = require("./routes/service-route");
const slotRoutes = require("./routes/slot-route");         
const bookingRoutes = require("./routes/booking-route");
const announcementRoutes = require("./routes/announcement-route");
const app = express();

app.use(express.json());
app.use(bodyParser.json()); 

// Routes
app.use("/api/users", userRoutes);         
app.use("/api/otp", otpRoutes);            
app.use("/api/services", serviceRoutes);  
app.use("/api/slot", slotRoutes);          
app.use("/api/bookings", bookingRoutes);
app.use("/api/announcement", announcementRoutes);

// Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
