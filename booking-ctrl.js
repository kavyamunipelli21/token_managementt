const db = require("../config/db");
const createBooking = async (req, res) => {
  const {
    booking_user_id,
    first_name,
    last_name,
    email_id,
    mobile_isd,
    mobile_number,
    service_id,
    slot_id,
    id_number,
    otp,
    created_user_id,
  } = req.body;

  try {
    if (!booking_user_id || !first_name || !last_name || !email_id || !mobile_isd || !mobile_number || !service_id || !slot_id || !id_number || !otp || !created_user_id) {
      return res.status(400).json({ message: "All required fields must be provided." });
    }

    console.log(`Attempting to create booking for slot_id: ${slot_id}, service_id: ${service_id}`);

    // Call the stored procedure
    const [result] = await db
      .promise()
      .query(`CALL CreateBooking(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @resultMessage, @generatedToken);`, [
        booking_user_id,
        first_name,
        last_name,
        email_id,
        mobile_isd,
        mobile_number,
        service_id,
        slot_id,
        id_number,
        otp,
        created_user_id,
      ]);

    // Retrieve result message and token
    const [bookingResult] = await db.promise().query(`SELECT @resultMessage AS message, @generatedToken AS token;`);

    const message = bookingResult[0].message;

    if (message !== "Booking created successfully.") {
      console.error(`Booking creation failed: ${message}`);
      return res.status(400).json({ message });
    }

    console.log(`Booking created successfully. Token: ${bookingResult[0].token}`);
    return res.status(201).json({
      message: bookingResult[0].message,
      token: bookingResult[0].token,
    });
  } catch (error) {
    console.error("Error in createBooking:", error);
    if (error.sqlState === "45000") {
      return res.status(400).json({ message: error.message });
    }
    return res.status(500).json({ message: "Internal server error." });
  }
};

module.exports = { createBooking };
