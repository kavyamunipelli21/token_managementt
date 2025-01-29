const express = require("express");
const { generateSlots, fetchSlots } = require("../controllers/slot-ctrl");

const router = express.Router();

router.post("/generate", generateSlots);

router.post("/fetch", fetchSlots);

module.exports = router;