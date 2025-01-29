const express = require("express");
const { addService, addWorkingHours, addHoliday } = require("../controllers/service-ctrl");

const router = express.Router();

router.post("/add", addService);

router.post("/working-hours", addWorkingHours);

router.post("/holidays", addHoliday);

module.exports = router;




