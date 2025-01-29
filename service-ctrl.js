const db = require("../config/db");

// Adding a new service
const addService = async (req, res) => {
  const {
    organization_id,
    title,
    description,
    image,
    token_prefix,
    token_suffix,
    slot_timing,
    no_of_slots,
    max_seats_for_each_slot,
    reset_every_day,
  } = req.body;

  try {
    if (
      !organization_id ||
      !title ||
      !token_prefix ||
      !slot_timing ||
      !no_of_slots ||
      !max_seats_for_each_slot ||
      reset_every_day === undefined
    ) {
      return res.status(400).json({ message: "All required fields must be provided." });
    }

    // Call the stored procedure
    const [result] = await db.promise().query(
      `CALL AddService(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @resultMessage);`,
      [
        organization_id,
        title,
        description || null,
        image || null,
        token_prefix,
        token_suffix || null,
        slot_timing,
        no_of_slots,
        max_seats_for_each_slot,
        reset_every_day,
      ]
    );

    const [response] = await db.promise().query(`SELECT @resultMessage AS message;`);
    const message = response[0].message;

    if (message !== "Service added successfully.") {
      return res.status(400).json({ message });
    }

    return res.status(201).json({ message });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

// Adding Working hours 
const addWorkingHours = async (req, res) => {
  const { organization_id, service_id, week_day, start_time, end_time } = req.body;

  try {
    if (!organization_id || !service_id || !week_day || !start_time || !end_time) {
      return res.status(400).json({ message: "All required fields must be provided." });
    }

    // Call stored procedure
    await db
      .promise()
      .query(`CALL AddWorkingHours(?, ?, ?, ?, ?, @resultMessage);`, [
        organization_id,
        service_id,
        week_day,
        start_time,
        end_time,
      ]);

    const [result] = await db.promise().query(`SELECT @resultMessage AS message;`);
    const message = result[0].message;

    return res.status(200).json({ message });
  } catch (error) {
    console.error("Error in addWorkingHours:", error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

// Adding Holidays
const addHoliday = async (req, res) => {
  const { organization_id, service_id, holiday_date, holiday_desc } = req.body;

  try {
    if (!organization_id || !service_id || !holiday_date) {
      return res.status(400).json({ message: "All required fields must be provided." });
    }

    // Call stored procedure
    await db
      .promise()
      .query(`CALL AddHoliday(?, ?, ?, ?, @resultMessage);`, [
        organization_id,
        service_id,
        holiday_date,
        holiday_desc || null,
      ]);

    const [result] = await db.promise().query(`SELECT @resultMessage AS message;`);
    const message = result[0].message;

    return res.status(200).json({ message });
  } catch (error) {
    console.error("Error in addHoliday:", error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

module.exports = { addService, addWorkingHours, addHoliday };
