const express = require("express");
const { sendOtp, verifyUserOtp } = require("../controllers/otp-ctrl");
const router = express.Router();

router.post("/send-otp", sendOtp);

router.post("/verify-otp", verifyUserOtp);

module.exports = router;
