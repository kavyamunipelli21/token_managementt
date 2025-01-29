const express = require("express");
const { createBooking } = require("../controllers/booking-ctrl");

const router = express.Router();

// Route to create a booking
router.post("/create", createBooking);

module.exports = router;
