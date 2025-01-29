const db = require("../config/db")
const nodemailer = require("nodemailer")

// Nodemailer Transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "21bk1a05c3@stpetershyd.com",
    pass: "njbn gqju sedt nnhu",
  },
})

// API to Send Announcements
const sendPublicAnnouncement = async (req, res) => {
  const { organization_id, subject, mail_content, sms_content, cc, bcc, created_user_id } = req.body

  try {
    // Verify if the organization exists and is of type organization (user_type = 1)
    const [org] = await db
      .promise()
      .query("SELECT tid FROM tmd_users WHERE tid = ? AND user_type = 1", [organization_id])

    if (org.length === 0) {
      return res.status(400).json({ message: "Invalid organization ID" })
    }

    if (!organization_id || !subject || !mail_content || !created_user_id) {
      return res.status(400).json({ message: "All required fields must be provided." })
    }

    console.log(`Initiating announcements for organization: ${organization_id}`)

    // Call the MySQL Procedure
    const [result] = await db
      .promise()
      .query(`CALL SendPublicAnnouncement(?, ?, ?, ?, ?, ?, ?, @resultMessage);`, [
        organization_id,
        subject,
        mail_content,
        sms_content,
        cc,
        bcc,
        created_user_id,
      ])

    // Fetch result message
    const [procedureResult] = await db.promise().query(`SELECT @resultMessage AS message;`)
    const message = procedureResult[0].message

    if (message !== "Announcements stored successfully.") {
      console.error(`Failed to store announcements: ${message}`)
      return res.status(400).json({ message })
    }

    console.log("Announcements stored successfully. Sending emails...")

    // Fetch email details
    const [announcements] = await db.promise().query(
      `SELECT email_id, cc, bcc, subject, mail_content 
         FROM tmd_public_announcements 
         WHERE organization_id = ? AND mail_sent_status = 0`,
      [organization_id],
    )

    for (const announcement of announcements) {
      const mailOptions = {
        from: "21bk1a05c3@stpetershyd.com",
        to: announcement.email_id,
        cc: announcement.cc || undefined,
        bcc: announcement.bcc || undefined,
        subject: announcement.subject,
        html: announcement.mail_content,
      }

      try {
        await transporter.sendMail(mailOptions)
        console.log(`Email sent to: ${announcement.email_id}`)

        // Update mail_sent_status
        await db.promise().query(
          `UPDATE public_announcements 
             SET mail_sent_status = 1, 
                 updated_date = NOW(), 
                 updated_user_id = ? 
             WHERE email_id = ? AND organization_id = ?`,
          [created_user_id, announcement.email_id, organization_id],
        )
      } catch (emailError) {
        console.error(`Failed to send email to ${announcement.email_id}:`, emailError)
      }
    }

    return res.status(200).json({ message: "Announcements sent successfully." })
  } catch (error) {
    console.error("Error in sendPublicAnnouncement:", error)
    return res.status(500).json({ message: "Internal server error." })
  }
}

module.exports = { sendPublicAnnouncement }

