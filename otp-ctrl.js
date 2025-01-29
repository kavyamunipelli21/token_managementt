const nodemailer = require("nodemailer");
const db = require("../config/db");

// send otp
const sendOtp = async (req, res) => {
  const { email_id, id_number } = req.body;

  try {
    if (!email_id || !id_number) {
      return res.status(400).json({ message: "Email and ID number are required." });
    }

    console.log("Calling GenerateOtp stored procedure...");
    const [rows] = await db.promise().query(
      `CALL GenerateOtp(?, ?);`,
      [email_id, id_number]
    );

    console.log("OTP generated:", rows); 

    const otp = rows[0][0].generatedOtp; 

    if (!otp) {
      return res.status(400).json({ message: "Failed to generate OTP." });
    }

    // Save OTP in the database
    const saveOtpQuery = `
      INSERT INTO tmd_otp_table (email_id, otp, id_number, status)
      VALUES (?, ?, ?, 0)
    `;
    const values = [email_id, otp, id_number];
    await db.promise().query(saveOtpQuery, values);

    // Send OTP via email
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "21bk1a05c3@stpetershyd.com",  
        pass: "njbn gqju sedt nnhu",      
      },
    });

    const mailOptions = {
      from: "21bk1a05c3@stpetershyd.com",  
      to: email_id,                     
      subject: "Your OTP for Registration",
      text: `Your OTP is: ${otp}`,      
    };

    await transporter.sendMail(mailOptions);

    return res.status(200).json({ message: "OTP sent successfully to your email." });
  } catch (error) {
    console.error(error.message);
    return res.status(500).json({ message: "Failed to send OTP." });
  }
};

//verify otp
const verifyUserOtp = async (req, res) => {
  const { email_id, otp, id_number } = req.body;

  try {
    if (!email_id || !otp || !id_number) {
      return res.status(400).json({ message: "Email, OTP, and ID number are required." });
    }

    console.log("Calling VerifyOtp stored procedure...");
    const [results] = await db.promise().query(
      `CALL VerifyOtp(?, ?, ?);`,
      [email_id, otp, id_number]
    );

    console.log("Stored procedure results:", results); 

    if (results && results[0] && results[0][0]) {
      const { message } = results[0][0];

      if (message === "OTP verified successfully.") {
        return res.status(200).json({ message });
      } else {
        return res.status(400).json({ message });
      }
    } else {
      return res.status(500).json({ message: "Failed to retrieve verification result." });
    }
  } catch (error) {
    console.error("Error in verifyUserOtp:", error.message);
    return res.status(500).json({ message: "Failed to verify OTP." });
  }
};

module.exports = { sendOtp,verifyUserOtp };
