CREATE DATABASE TokenManagement;
USE TokenManagement;

CREATE TABLE tmm_time_Zone (
    tid INT(11) AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    tz_offset VARCHAR(20) NOT NULL
);

INSERT INTO tmm_time_Zone (title, tz_offset)
VALUES 
    ('UTC', '+5:30:00');
    
SELECT * FROM tmm_time_Zone;

CREATE TABLE tmm_booking_status (
    tid INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL
);

INSERT INTO tmm_booking_status (title)
VALUES 
    ('Pending'),
    ('Booked'),
    ('Completed'),
    ('Cancelled'),
    ('No Show');

SELECT * FROM tmm_booking_status;


CREATE TABLE tmd_users (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL UNIQUE,
    mobile_isd VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(20) NOT NULL,
    password VARCHAR(250) NOT NULL,
    user_type INT(11) NOT NULL CHECK (user_type IN (0, 1)),
    organization_name VARCHAR(150),
    organization_profile TEXT,
    image LONGTEXT,
    time_zone_id INT(11),
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    id_required INT(1) NOT NULL CHECK (id_required IN (0, 1))
);

CREATE TABLE tmd_org_services (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT(20) NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    image LONGTEXT,
    status INT(11) NOT NULL CHECK (status IN (0, 1)),
    token_prefix VARCHAR(20) NOT NULL,
    token_suffix VARCHAR(20),
    slot_timing INT(11) NOT NULL CHECK (slot_timing IN (30, 60)),
    no_of_slots INT(11) NOT NULL,
    max_seats_for_each_slot BIGINT(20) NOT NULL,
    reset_every_day TINYINT(4) NOT NULL CHECK (reset_every_day IN (0, 1)),
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid)
);

CREATE TABLE tmd_working_hours (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT(20) NOT NULL,
    service_id BIGINT(20) NOT NULL,
    week_day INT(11) NOT NULL CHECK (week_day BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (service_id) REFERENCES tmd_org_services(tid)
);

CREATE TABLE tmd_service_holidays (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT(20) NOT NULL,
    service_id BIGINT(20) NOT NULL,
    holiday_date DATE NOT NULL,
    holiday_desc VARCHAR(100),
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (service_id) REFERENCES tmd_org_services(tid)
);

CREATE TABLE tmd_slot_generation (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT(20) NOT NULL,
    service_id BIGINT(20) NOT NULL,
    slot_date DATE NOT NULL,
    slot_date_time DATETIME NOT NULL,
    status INT(11) NOT NULL CHECK (status IN (0, 1, 2)),
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (service_id) REFERENCES tmd_org_services(tid)
);

CREATE TABLE tmd_Appointment_booking (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    booking_user_id BIGINT(20) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL,
    mobile_isd VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(20) NOT NULL,
    organization_id BIGINT(20) NOT NULL,
    service_id BIGINT(20) NOT NULL,
    slot_date_time DATETIME NOT NULL,
    token VARCHAR(100) NOT NULL,
    token_seq INT(11) NOT NULL,
    status INT(11) NOT NULL,
    idnumber VARCHAR(20),
    otp VARCHAR(20),
    is_otp_verified TINYINT(4) NOT NULL CHECK (is_otp_verified IN (0, 1)),
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_user_id BIGINT(20),
    updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_user_id BIGINT(20),
    FOREIGN KEY (booking_user_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (service_id) REFERENCES tmd_org_services(tid),
    FOREIGN KEY (status) REFERENCES tmm_booking_status(tid)
);

CREATE TABLE tmd_public_announcements (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT(20) NOT NULL,
    user_id BIGINT(20) NOT NULL,
    email_id VARCHAR(150),
    cc VARCHAR(500),
    bcc VARCHAR(500),
    subject VARCHAR(500),
    mail_content MEDIUMTEXT,
    mobile_isd VARCHAR(20),
    mobile_number VARCHAR(20),
    sms_content VARCHAR(1000),
    mail_sent_status TINYINT(4),
    sms_sent_status TINYINT(4),
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_user_id BIGINT(20),
    updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_user_id BIGINT(20),
    FOREIGN KEY (organization_id) REFERENCES tmd_users(tid),
    FOREIGN KEY (user_id) REFERENCES tmd_users(tid)
);

CREATE TABLE tmd_otp_table (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    email_id VARCHAR(150) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    status INT(1) NOT NULL CHECK (status IN (0, 1)),
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_number VARCHAR(20)
);

CREATE TABLE tmd_login_sessions (
    tid BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT(20) NOT NULL,
    org_unique_id VARCHAR(100) NOT NULL,
    login_date_time DATETIME NOT NULL,
    logout_date_time DATETIME,
    status INT(1) NOT NULL CHECK (status IN (1, 2)),
    FOREIGN KEY (user_id) REFERENCES tmd_users(tid)
);


SELECT * FROM tmd_users;
SELECT * FROM tmd_otp_table;
SELECT * FROM tmd_login_sessions;
SELECT * FROM tmd_org_services;
SELECT * FROM tmd_working_hours;
SELECT * FROM tmd_service_holidays;
SELECT * FROM tmd_slot_generation;
SELECT * FROM tmd_Appointment_booking;
SELECT * FROM tmd_public_announcements



                                                      -- SIGNUP/REGISTER
DELIMITER //
CREATE PROCEDURE RegisterUser(
    IN firstName VARCHAR(100),
    IN lastName VARCHAR(100),
    IN emailId VARCHAR(150),
    IN mobileIsd VARCHAR(20),
    IN mobileNumber VARCHAR(20),
    IN hashedPassword VARCHAR(250),
    IN userType INT,
    IN organizationName VARCHAR(150),
    IN organizationProfile TEXT,
    IN image LONGTEXT,
    IN timeZoneId INT,
    IN idRequired INT,
    OUT resultMessage VARCHAR(255),
    OUT generatedIdNumber VARCHAR(100)
)
BEGIN
    DECLARE emailExists INT;
    DECLARE idNumber VARCHAR(100);

    -- Check if the email already exists
    SELECT COUNT(*) INTO emailExists
    FROM tmd_users
    WHERE email_id = emailId;

    IF emailExists > 0 THEN
        SET resultMessage = 'Email already exists.';
        SET generatedIdNumber = NULL;
    ELSE
        -- Generate ID number based on user type
        IF userType = 0 THEN
            SET idNumber = CONCAT('USER', UUID());
        ELSEIF userType = 1 THEN
            SET idNumber = CONCAT('ORG', UUID());
        ELSE
            SET resultMessage = 'Invalid user type.';
            SET generatedIdNumber = NULL;
           
        END IF;

        -- Insert the user into the database without the ID number
        INSERT INTO tmd_users (
            first_name, last_name, email_id, mobile_isd, mobile_number,
            password, user_type, organization_name, organization_profile,
            image, time_zone_id, id_required
        )
        VALUES (
            firstName, lastName, emailId, mobileIsd, mobileNumber,
            hashedPassword, userType, organizationName, organizationProfile,
            image, timeZoneId, idRequired
        );

        SET resultMessage = 'User registered successfully.';
        SET generatedIdNumber = idNumber; 
    END IF;
END //
DELIMITER ;

												-- GENERATE OTP
DELIMITER $$
CREATE PROCEDURE GenerateOtp(IN email_id VARCHAR(255), IN id_number VARCHAR(255))
BEGIN
    DECLARE otp VARCHAR(6);

    SET otp = FLOOR(100000 + RAND() * 900000);

    -- Insert OTP into the database
    INSERT INTO tmd_otp_table (email_id, otp, id_number, status)
    VALUES (email_id, otp, id_number, 0);

    -- Return the OTP
    SELECT otp AS generatedOtp;
END $$
DELIMITER ;

                                                    -- VERIFY OTP
DELIMITER $$
CREATE PROCEDURE VerifyOtp(IN input_email_id VARCHAR(255), IN input_otp VARCHAR(6), IN input_id_number VARCHAR(255))
BEGIN
    DECLARE otp_status INT;

    -- Check if the OTP is valid and not expired
    SELECT status INTO otp_status
    FROM tmd_otp_table
    WHERE email_id = input_email_id 
      AND otp = input_otp 
      AND id_number = input_id_number
      AND status = 0 
      AND created_date > (NOW() - INTERVAL 10 MINUTE)
    LIMIT 1;

    IF otp_status = 0 THEN
        -- Update the status to 1 (verified)
        UPDATE tmd_otp_table 
        SET status = 1
        WHERE email_id = input_email_id 
          AND otp = input_otp 
          AND id_number = input_id_number;

        -- success message
        SELECT 'OTP verified successfully.' AS message;
    ELSE
        -- failure message
        SELECT 'Invalid OTP, ID number, or OTP expired.' AS message;
    END IF;
END $$
DELIMITER ;

													 -- LOGIN
DELIMITER //
CREATE PROCEDURE LoginUser(
    IN emailId VARCHAR(150),
    IN password VARCHAR(250),
    OUT resultMessage VARCHAR(255),
    OUT userId INT
)
BEGIN
    DECLARE hashedPassword VARCHAR(250);

    -- Fetch user and password hash
    SELECT tid, password INTO userId, hashedPassword
    FROM tmd_users
    WHERE email_id = emailId;

    IF userId IS NULL THEN
        SET resultMessage = 'Invalid email or password.';
    ELSE
        -- Compare passwords
        IF hashedPassword != password THEN
            SET resultMessage = 'Invalid email or password.';
            SET userId = NULL;
        ELSE
            -- Log login session
            INSERT INTO tmd_login_sessions (user_id, org_unique_id, login_date_time, status)
            VALUES (userId, UUID(), NOW(), 1);

            SET resultMessage = 'Login successful.';
        END IF;
    END IF;
END;
//
DELIMITER ;

                                                            -- LOGOUT
														
DELIMITER //
CREATE PROCEDURE LogoutUser(
    IN userId INT,
    OUT resultMessage VARCHAR(255)
)
BEGIN
    -- Update the login session's status and logout time
    UPDATE tmd_login_sessions
    SET logout_date_time = NOW(), status = 2
    WHERE user_id = userId AND status = 1;

    -- Check if the session was updated
    IF ROW_COUNT() > 0 THEN
        SET resultMessage = 'Logout successful.';
    ELSE
        SET resultMessage = 'No active session found or user is already logged out.';
    END IF;
END;
//
DELIMITER ;

                                                -- ADD SERVICES 
DELIMITER //
CREATE PROCEDURE AddService(
    IN organizationId INT,
    IN title VARCHAR(150),
    IN description TEXT,
    IN image LONGTEXT,
    IN tokenPrefix VARCHAR(20),
    IN tokenSuffix VARCHAR(20),
    IN slotTiming INT,
    IN noOfSlots INT,
    IN maxSeatsForEachSlot INT,
    IN resetEveryDay TINYINT(1),
    OUT resultMessage VARCHAR(255)
)
BEGIN
    DECLARE userType INT;

    -- Check if the user is an organization
    SELECT user_type INTO userType
    FROM tmd_users
    WHERE tid = organizationId;

    IF userType IS NULL OR userType != 1 THEN
        SET resultMessage = 'Only organizations can add services.';
    ELSE
        -- Insert the service into the database
        INSERT INTO tmd_org_services (
            organization_id, title, description, image,
            status, token_prefix, token_suffix, slot_timing,
            no_of_slots, max_seats_for_each_slot, reset_every_day
        )
        VALUES (
            organizationId, title, description, image,
            1, tokenPrefix, tokenSuffix, slotTiming,
            noOfSlots, maxSeatsForEachSlot, resetEveryDay
        );

        SET resultMessage = 'Service added successfully.';
    END IF;
END //
DELIMITER ;

                                            -- ADDING WORKING HOURS 
DELIMITER $$
CREATE PROCEDURE AddWorkingHours(
    IN org_id INT,
    IN service_id INT,
    IN week_day INT,
    IN start_time TIME,
    IN end_time TIME,
    OUT resultMessage VARCHAR(255)
)
BEGIN
    -- Ensuring the service belongs to the organization
    IF EXISTS (
        SELECT 1 FROM tmd_org_services
        WHERE tid = service_id AND organization_id = org_id
    ) THEN
        -- Insert working hours
        INSERT INTO tmd_working_hours (organization_id, service_id, week_day, start_time, end_time)
        VALUES (org_id, service_id, week_day, start_time, end_time);
        SET resultMessage = 'Working hours added successfully.';
    ELSE
        SET resultMessage = 'Service not found or does not belong to the organization.';
    END IF;
END $$
DELIMITER ;

                                                -- ADDING HOLIDAYS
DELIMITER $$
CREATE PROCEDURE AddHoliday(
    IN org_id INT,
    IN service_id INT,
    IN holiday_date DATE,
    IN holiday_desc TEXT,
    OUT resultMessage VARCHAR(255)
)
BEGIN
    -- Ensuring the service belongs to the organization
    IF EXISTS (
        SELECT 1 FROM tmd_org_services
        WHERE tid = service_id AND organization_id = org_id
    ) THEN
        -- Insert holiday
        INSERT INTO tmd_service_holidays (organization_id, service_id, holiday_date, holiday_desc)
        VALUES (org_id, service_id, holiday_date, holiday_desc);
        SET resultMessage = 'Holiday added successfully.';
    ELSE
        SET resultMessage = 'Service not found or does not belong to the organization.';
    END IF;
END $$
DELIMITER ;

                                         -- GENERATE SLOTS 
DELIMITER //
CREATE PROCEDURE GenerateSlots(
    IN p_service_id INT,
    IN p_slot_date DATE
)
BEGIN
    DECLARE v_organization_id INT;
    DECLARE v_slot_timing INT;
    DECLARE v_start_time TIME;
    DECLARE v_end_time TIME;
    DECLARE v_week_day INT;
    DECLARE v_slot_datetime DATETIME;
    DECLARE v_existing_slots INT;

    -- Get organization ID
    SELECT organization_id INTO v_organization_id
    FROM tmd_org_services
    WHERE tid = p_service_id;

    IF v_organization_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Service not found or organization ID is missing.';
    END IF;

    -- Check if it's a working day
    SET v_week_day = DAYOFWEEK(p_slot_date);
    SELECT start_time, end_time INTO v_start_time, v_end_time
    FROM tmd_working_hours
    WHERE service_id = p_service_id AND week_day = v_week_day;

    IF v_start_time IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Selected date is not a working day for this service.';
    END IF;

    -- Check if it's a holiday
    IF EXISTS (SELECT 1 FROM tmd_service_holidays WHERE service_id = p_service_id AND holiday_date = p_slot_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Selected date is a holiday for this service.';
    END IF;

    -- Get slot timing
    SELECT slot_timing INTO v_slot_timing
    FROM tmd_org_services
    WHERE tid = p_service_id;

    -- Check if slots already exist
    SELECT COUNT(*) INTO v_existing_slots
    FROM tmd_slot_generation
    WHERE service_id = p_service_id AND slot_date = p_slot_date;

    IF v_existing_slots > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Slots already exist for the selected date.';
    END IF;

    -- Generate and insert slots
    SET v_slot_datetime = TIMESTAMP(p_slot_date, v_start_time);
    WHILE v_slot_datetime < TIMESTAMP(p_slot_date, v_end_time) DO
        INSERT INTO tmd_slot_generation (organization_id, service_id, slot_date, slot_date_time, status)
        VALUES (v_organization_id, p_service_id, p_slot_date, v_slot_datetime, 1);
        
        SET v_slot_datetime = DATE_ADD(v_slot_datetime, INTERVAL v_slot_timing MINUTE);
    END WHILE;

    SELECT 'Slots generated successfully.' AS message;
END //
DELIMITER ;


                                                             -- FETCH SLOTS
DELIMITER //
CREATE PROCEDURE FetchSlots(
    IN p_service_id INT,
    IN p_slot_date DATE
)
BEGIN
    SELECT 
        tid AS slot_id, 
        service_id, 
        slot_date, 
        CONVERT_TZ(slot_date_time, '+00:00', '+05:30') AS slot_date_time, 
        status
    FROM tmd_slot_generation
    WHERE service_id = p_service_id AND slot_date = p_slot_date;
END //
DELIMITER ;

                                     -- SERVICE BOOKING
DELIMITER $$

CREATE PROCEDURE CreateBooking(
    IN booking_user_id INT,
    IN first_name VARCHAR(100),
    IN last_name VARCHAR(100),
    IN email_id VARCHAR(150),
    IN mobile_isd VARCHAR(20),
    IN mobile_number VARCHAR(20),
    IN service_id INT,
    IN slot_id INT,
    IN id_number VARCHAR(100),
    IN input_otp VARCHAR(6),
    IN created_user_id INT,
    OUT resultMessage VARCHAR(255),
    OUT generatedToken VARCHAR(100)
)
BEGIN
    DECLARE organization_id INT;
    DECLARE slot_date_time DATETIME;
    DECLARE token_prefix VARCHAR(20);
    DECLARE token_suffix VARCHAR(20);
    DECLARE token_seq INT;
    DECLARE otp_status INT;
    DECLARE slot_status INT;
    DECLARE pending_status INT DEFAULT 1; -- Get the 'Pending' status ID

    -- Get the 'Pending' status from master table
    SELECT tid INTO pending_status FROM tmm_booking_status WHERE title = 'Pending' LIMIT 1;

    -- Verify OTP
    SELECT otp.status INTO otp_status
    FROM tmd_otp_table otp
    WHERE otp.email_id = email_id 
      AND otp.otp = input_otp 
      AND otp.id_number = id_number
      AND otp.status = 0 
      AND otp.created_date > (NOW() - INTERVAL 10 MINUTE)
    LIMIT 1;

    IF otp_status IS NULL THEN
        SET resultMessage = 'Invalid or expired OTP.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = resultMessage;
    END IF;

    -- Mark OTP as verified
    UPDATE tmd_otp_table otp
    SET otp.status = 1
    WHERE otp.email_id = email_id 
      AND otp.otp = input_otp 
      AND otp.id_number = id_number;

    -- Checking slot availability
    SELECT sg.organization_id, sg.slot_date_time, sg.status 
    INTO organization_id, slot_date_time, slot_status
    FROM tmd_slot_generation sg
    WHERE sg.tid = slot_id AND sg.service_id = service_id;

    IF organization_id IS NULL THEN
        SET resultMessage = CONCAT('Invalid slot or service. Slot ID: ', slot_id, ', Service ID: ', service_id);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = resultMessage;
    END IF;

    IF slot_status != 1 THEN
        SET resultMessage = CONCAT('Slot is not available. Slot ID: ', slot_id, ', Status: ', slot_status);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = resultMessage;
    END IF;

    -- Generate token details
    SELECT os.token_prefix, os.token_suffix 
    INTO token_prefix, token_suffix
    FROM tmd_org_services os
    WHERE os.tid = service_id;

    SELECT COUNT(*) + 1 INTO token_seq
    FROM tmd_Appointment_booking
    WHERE service_id = service_id;

    SET generatedToken = CONCAT(token_prefix, '-', token_suffix, '-', token_seq);

    -- Create booking with status = 'Pending'
    INSERT INTO tmd_Appointment_booking (
        booking_user_id, first_name, last_name, email_id, mobile_isd,
        mobile_number, organization_id, service_id, slot_date_time,
        token, token_seq, status, idnumber, otp, is_otp_verified, created_date, created_user_id
    )
    VALUES (
        booking_user_id, first_name, last_name, email_id, mobile_isd,
        mobile_number, organization_id, service_id, slot_date_time,
        generatedToken, token_seq, pending_status, id_number, input_otp, 1, NOW(), created_user_id
    );

    -- Mark slot as booked
    UPDATE tmd_slot_generation sg
    SET sg.status = 2
    WHERE sg.tid = slot_id;

    SET resultMessage = 'Booking created successfully.';
END $$
DELIMITER ;

-- EVENT FOR HANDLING BOOKING PROCESS
DELIMITER $$
CREATE EVENT UpdateBookingStatus
ON SCHEDULE EVERY 10 MINUTE DO
BEGIN
    DECLARE booked_status INT;
    DECLARE completed_status INT;
    DECLARE no_show_status INT;

    -- Get status values dynamically
    SELECT tid INTO booked_status FROM tmm_booking_status WHERE title = 'Booked' LIMIT 1;
    SELECT tid INTO completed_status FROM tmm_booking_status WHERE title = 'Completed' LIMIT 1;
    SELECT tid INTO no_show_status FROM tmm_booking_status WHERE title = 'No Show' LIMIT 1;

    -- Change status from 'Pending' to 'Booked' when slot time approaches
    UPDATE tmd_Appointment_booking
    SET status = booked_status
    WHERE status = (SELECT tid FROM tmm_booking_status WHERE title = 'Pending')
      AND slot_date_time <= NOW() + INTERVAL 5 MINUTE;

    -- Change status from 'Booked' to 'Completed' when the appointment is over
    UPDATE tmd_Appointment_booking
    SET status = completed_status
    WHERE status = booked_status
      AND slot_date_time < NOW() - INTERVAL 30 MINUTE;

    -- Change status from 'Booked' to 'No Show' if not attended
    UPDATE tmd_Appointment_booking
    SET status = no_show_status
    WHERE status = booked_status
      AND slot_date_time < NOW() - INTERVAL 1 HOUR;
END $$
DELIMITER ;


                                               -- PUBLIC ANNOUNCEMENTS 
DELIMITER $$
CREATE PROCEDURE SendPublicAnnouncement(
    IN p_organization_id BIGINT(20),
    IN p_subject VARCHAR(500),
    IN p_mail_content MEDIUMTEXT,
    IN p_sms_content VARCHAR(1000),
    IN p_cc VARCHAR(500),
    IN p_bcc VARCHAR(500),
    IN p_created_user_id BIGINT(20),
    OUT resultMessage VARCHAR(255)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_user_id BIGINT(20);
    DECLARE v_email_id VARCHAR(150);
    DECLARE v_mobile_isd VARCHAR(20);
    DECLARE v_mobile_number VARCHAR(20);

    -- Cursor to get users under the given organization
    DECLARE user_cursor CURSOR FOR 
    SELECT tid, email_id, mobile_isd, mobile_number 
    FROM tmd_users 
    WHERE user_type = 0; -- Get all public users

    -- Declare handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open Cursor
    OPEN user_cursor;

    read_loop: LOOP
        FETCH user_cursor INTO v_user_id, v_email_id, v_mobile_isd, v_mobile_number;
        IF done THEN 
            LEAVE read_loop;
        END IF;

        -- Insert into Public Announcements table
        INSERT INTO tmd_public_announcements (
            organization_id, user_id, email_id, cc, bcc, subject, mail_content, 
            mobile_isd, mobile_number, sms_content, mail_sent_status, sms_sent_status, 
            created_date, created_user_id
        )
        VALUES (
            p_organization_id, v_user_id, v_email_id, p_cc, p_bcc, p_subject, p_mail_content, 
            v_mobile_isd, v_mobile_number, p_sms_content, 0, 0, 
            NOW(), p_created_user_id
        );
    END LOOP;

    CLOSE user_cursor;

    SET resultMessage = 'Announcements stored successfully.';
END $$
DELIMITER ;








