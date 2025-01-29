const express = require("express");
const {  sendPublicAnnouncement  } = require("../controllers/announcement-ctrl");
const router = express.Router();

router.post("/send", sendPublicAnnouncement );

module.exports = router;
