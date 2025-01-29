const db = require("../config/db");
const bcrypt = require("bcrypt");

// Register a new user
const registerUser = async (req, res) => {
  const {
    first_name,
    last_name,
    email_id,
    mobile_isd,
    mobile_number,
    password,
    user_type,
    organization_name,
    organization_profile,
    image,
    time_zone_id,
    id_required,
  } = req.body;

  try {
    if (
      !first_name ||
      !last_name ||
      !email_id ||
      !mobile_isd ||
      !mobile_number ||
      !password ||
      user_type === undefined ||
      id_required === undefined
    ) {
      return res.status(400).json({ message: "All required fields must be provided." });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Call stored procedure
    const [result] = await db.promise().query(
      `CALL RegisterUser(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @resultMessage, @generatedIdNumber);`,
      [
        first_name,
        last_name,
        email_id,
        mobile_isd,
        mobile_number,
        hashedPassword,
        user_type,
        organization_name || null,
        organization_profile || null,
        image || null,
        time_zone_id || null,
        id_required,
      ]
    );

    const [response] = await db.promise().query(
      `SELECT @resultMessage AS message, @generatedIdNumber AS generatedId;`
    );

    const message = response[0].message;
    const generatedIdNumber = response[0].generatedId;

    if (message !== "User registered successfully.") {
      return res.status(400).json({ message });
    }

    // Return success message with generated id number
    return res.status(200).json({
      message,
      generatedIdNumber, 
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

// User login
const loginUser = async (req, res) => {
  const { email_id, password } = req.body;

  try {
    if (!email_id || !password) {
      return res.status(400).json({ message: "Email and password are required." });
    }

    // Call the login stored procedure
    const [user] = await db
      .promise()
      .query(`CALL LoginUser(?, ?, @resultMessage,@userId);`, [email_id, password]);

    const [result] = await db.promise().query(`SELECT @resultMessage AS message, @userId AS userId;`);
    const message = result[0].message;
    const userId = result[0].userId;

    if (message !== "Login successful.") {
      return res.status(401).json({ message });
    }

    return res.status(200).json({ message });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

// User logout
const logoutUser = async (req, res) => {
  const { user_id } = req.body;

  try {
    if (!user_id) {
      return res.status(400).json({ message: "User ID is required." });
    }

    // Call the logout stored procedure
    await db.promise().query(`CALL LogoutUser(?, @resultMessage);`, [user_id]);

    const [result] = await db.promise().query(`SELECT @resultMessage AS message;`);
    const message = result[0].message;

    return res.status(200).json({ message });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error." });
  }
};

module.exports = { registerUser, loginUser, logoutUser };
