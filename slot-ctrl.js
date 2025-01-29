const db = require("../config/db")
const moment = require("moment-timezone")

//generate slots for the service 
const generateSlots = async (req, res) => {
  const { service_id, slot_date } = req.body

  if (!service_id || !slot_date) {
    return res.status(400).json({ message: "Service ID and slot date are required." })
  }

  try {
    const [results] = await db.promise().query("CALL GenerateSlots(?, ?)", [service_id, slot_date])

    return res.status(201).json({ message: results[0][0].message })
  } catch (error) {
    console.error("Error in generateSlots:", error)
    return res.status(500).json({ message: error.message || "Internal server error." })
  }
}

//fetch slots 
const fetchSlots = async (req, res) => {
  const { service_id, slot_date } = req.body

  if (!service_id || !slot_date) {
    return res.status(400).json({ message: "Service ID and slot date are required." })
  }

  try {
    const [results] = await db.promise().query("CALL FetchSlots(?, ?)", [service_id, slot_date])

    if (results[0].length === 0) {
      return res.status(404).json({ message: "No slots found for the selected date." })
    }

    return res.status(200).json(results[0])
  } catch (error) {
    console.error("Error in fetchSlots:", error)
    return res.status(500).json({ message: "Internal server error." })
  }
}

module.exports = { generateSlots, fetchSlots }

