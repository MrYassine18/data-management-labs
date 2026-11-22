USE rlms;

DROP TRIGGER IF EXISTS trg_participates_bi;
DROP TRIGGER IF EXISTS trg_participates_bu;
DROP PROCEDURE IF EXISTS check_participation;
DROP TRIGGER IF EXISTS trg_reserves_no_overlap_bi;
DROP TRIGGER IF EXISTS trg_reservation_no_overlap_bu;
DROP TRIGGER IF EXISTS trg_reserves_certification_bi;

DELIMITER //

-- Task 1
CREATE PROCEDURE check_participation(
    IN p_pid INT,
    IN p_code VARCHAR(50),
    IN p_role VARCHAR(30),
    IN p_old_pid INT,
    IN p_old_code VARCHAR(50))
BEGIN
    IF EXISTS (SELECT 1 FROM Administrative WHERE pid = p_pid) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Administrative staff cannot participate in research projects';
    END IF;

    IF p_role IN ('PI', 'Co-PI')
       AND NOT EXISTS (SELECT 1 FROM Academic WHERE pid = p_pid) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A PI or Co-PI must be an academic';
    END IF;

    IF p_role = 'PI' AND EXISTS (
        SELECT 1 FROM Participates
        WHERE projectCode = p_code
          AND role = 'PI'
          AND (p_old_pid IS NULL OR pid <> p_old_pid OR projectCode <> p_old_code)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This project already has a PI';
    END IF;

    IF p_role = 'Co-PI' AND EXISTS (
        SELECT 1 FROM Participates
        WHERE projectCode = p_code
          AND role = 'Co-PI'
          AND (p_old_pid IS NULL OR pid <> p_old_pid OR projectCode <> p_old_code)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This project already has a Co-PI';
    END IF;
END //

CREATE TRIGGER trg_participates_bi
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
    CALL check_participation(NEW.pid, NEW.projectCode, NEW.role, NULL, NULL);
END //

CREATE TRIGGER trg_participates_bu
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
    CALL check_participation(NEW.pid, NEW.projectCode, NEW.role, OLD.pid, OLD.projectCode);
END //

-- Task 2

-- Task 2a
CREATE TRIGGER trg_reserves_no_overlap_bi
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Reservation newR
        JOIN Reserves rs     ON rs.serialNo = NEW.serialNo
        JOIN Reservation oldR ON oldR.resId = rs.resId
        WHERE newR.resId = NEW.resId
          AND newR.status = 'Approved'
          AND oldR.status = 'Approved'
          AND oldR.resId <> NEW.resId
          AND newR.plannedStart < oldR.plannedEnd
          AND newR.plannedEnd > oldR.plannedStart) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Double booking: this unit is already in an overlapping approved reservation';
    END IF;
END //

-- Task 2b
CREATE TRIGGER trg_reservation_no_overlap_bu
BEFORE UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved' AND EXISTS (
        SELECT 1
        FROM Reserves mine
        JOIN Reserves other   ON other.serialNo = mine.serialNo
        JOIN Reservation oldR ON oldR.resId = other.resId
        WHERE mine.resId = NEW.resId
          AND other.resId <> NEW.resId
          AND oldR.status = 'Approved'
          AND NEW.plannedStart < oldR.plannedEnd
          AND NEW.plannedEnd > oldR.plannedStart) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Double booking: a unit of this reservation is in an overlapping approved reservation';
    END IF;
END //

-- Task 3
CREATE TRIGGER trg_reserves_certification_bi
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
    DECLARE missingCert VARCHAR(50);
    DECLARE msg VARCHAR(128);

    SET missingCert = (
        SELECT rq.certCode
        FROM Reservation r
        JOIN EquipmentUnit u ON u.serialNo = NEW.serialNo
        JOIN Requires rq     ON rq.modelId = u.modelId
        WHERE r.resId = NEW.resId
          AND NOT EXISTS (
              SELECT 1 FROM Holds h
              WHERE h.pid = r.madeByPid
                AND h.certCode = rq.certCode
                AND h.expirationDate >= DATE(r.plannedStart))
        LIMIT 1);

    IF missingCert IS NOT NULL THEN
        SET msg = CONCAT('Certification ', missingCert, ' missing or expired for unit ',
                         NEW.serialNo, ' (reservation ', NEW.resId, ')');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END //

DELIMITER ;

-- rejected
INSERT INTO Participates VALUES (5, 'P2', 'Collaborator');

-- rejected
INSERT INTO Participates VALUES (6, 'P2', 'Co-PI');

-- rejected
INSERT INTO Participates VALUES (4, 'P1', 'PI');

-- rejected
INSERT INTO Participates VALUES (4, 'P1', 'Co-PI');

-- valid
INSERT INTO Participates VALUES (4, 'P2', 'Co-PI');

-- valid
UPDATE Participates SET role = 'PI' WHERE pid = 3 AND projectCode = 'P2';

-- rejected
UPDATE Participates SET role = 'PI' WHERE pid = 3 AND projectCode = 'P1';

SELECT * FROM Participates ORDER BY projectCode, role;

-- valid
INSERT INTO Reserves VALUES (2, 'U4');

-- rejected
INSERT INTO Reserves VALUES (1, 'U3');

INSERT INTO Reservation VALUES
 (8, '2026-11-22 10:00:00', '2027-03-01 09:00:00', '2027-03-02 18:00:00',
  'Thermal run 2027', 'Pending', 2, 'P1', NULL);

-- rejected
INSERT INTO Reserves VALUES (8, 'U4');

-- valid
INSERT INTO Reserves VALUES (8, 'U7');

SELECT * FROM Reserves ORDER BY resId, serialNo;

INSERT INTO Reservation VALUES
 (9, '2026-11-01 10:00:00', '2026-11-11 08:00:00', '2026-11-11 18:00:00',
  'Extra thermal test', 'Approved', 2, 'P1', 3);

-- rejected
INSERT INTO Reserves VALUES (9, 'U3');

-- valid
INSERT INTO Reserves VALUES (1, 'U7');

-- rejected
UPDATE Reservation
SET plannedStart = '2026-11-11 08:00:00', plannedEnd = '2026-11-11 18:00:00'
WHERE resId = 4;

-- valid
UPDATE Reservation
SET plannedStart = '2026-09-15 08:00:00', plannedEnd = '2026-09-16 18:00:00'
WHERE resId = 4;

-- valid
UPDATE Reservation SET purpose = 'Thermal benchmark run (extended)' WHERE resId = 2;

INSERT INTO Reservation VALUES
 (10, '2026-11-20 09:00:00', '2026-12-01 12:00:00', '2026-12-01 18:00:00',
  'Microscope demo', 'Approved', 2, 'P1', 3);

-- valid
INSERT INTO Reserves VALUES (10, 'U8');

-- rejected
UPDATE Reservation SET status = 'Approved', approverPid = 3 WHERE resId = 7;

SELECT resId, plannedStart, plannedEnd, status FROM Reservation ORDER BY resId;
SELECT * FROM Reserves ORDER BY resId, serialNo;

-- Task 4
DROP TRIGGER IF EXISTS trg_before_insert_consumes;
DROP TRIGGER IF EXISTS trg_after_insert_consumes;
DROP TRIGGER IF EXISTS trg_after_insert_maintenance;
DROP TRIGGER IF EXISTS trg_after_update_maintenance;
DROP TRIGGER IF EXISTS trg_before_insert_student;
DROP TRIGGER IF EXISTS trg_before_insert_employee;
DROP TRIGGER IF EXISTS trg_before_insert_faculty;
DROP TRIGGER IF EXISTS trg_before_insert_administrative;
DROP TRIGGER IF EXISTS trg_before_update_employee_supervisor;
DROP TRIGGER IF EXISTS trg_before_insert_dean;
DROP TRIGGER IF EXISTS trg_before_update_dean;

DELIMITER $$

CREATE TRIGGER trg_before_insert_consumes
BEFORE INSERT ON Consumes
FOR EACH ROW
BEGIN
    DECLARE v_stock DECIMAL(12,2) DEFAULT NULL;

    IF NEW.quantityUsed <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The used quantity must be positive.';
    END IF;

    SET v_stock = (SELECT quantityOnHand
                   FROM Stocks
                   WHERE labId = NEW.labId
                     AND consId = NEW.consId);

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This consumable is not stocked by this lab.';
    END IF;

    IF NEW.quantityUsed > v_stock THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock available.';
    END IF;
END$$

CREATE TRIGGER trg_after_insert_consumes
AFTER INSERT ON Consumes
FOR EACH ROW
BEGIN
    UPDATE Stocks
    SET quantityOnHand = quantityOnHand - NEW.quantityUsed
    WHERE labId = NEW.labId
      AND consId = NEW.consId;
END$$

DELIMITER ;

-- valid
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 1, 1, 5);
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;

-- rejected
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 1, 2, 0);

-- rejected
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 2, 2, 1);

-- rejected
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 1, 2, 999999);

-- Task 5
DELIMITER $$

CREATE TRIGGER trg_after_insert_maintenance
AFTER INSERT ON Maintenance
FOR EACH ROW
BEGIN
    UPDATE EquipmentUnit
    SET status = 'UnderMaintenance'
    WHERE serialNo = NEW.serialNo;
END$$

CREATE TRIGGER trg_after_update_maintenance
AFTER UPDATE ON Maintenance
FOR EACH ROW
BEGIN
    IF (OLD.outcome IS NULL OR OLD.outcome <> 'Resolved')
       AND NEW.outcome = 'Resolved' THEN

        UPDATE EquipmentUnit
        SET status = 'InService'
        WHERE serialNo = NEW.serialNo;

    END IF;
END$$

DELIMITER ;

INSERT INTO Maintenance
    (serialNo, startTS, endTS, type, description, cost, outcome, technicalPid)
VALUES
    ('U2', '2026-11-20 09:00:00', '2026-11-20 14:00:00', 'Corrective',
     'Focus knob repair', 250.00, 'FollowUpRequired', 6);
SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U2';

UPDATE Maintenance
SET outcome = 'Resolved'
WHERE serialNo = 'U2' AND startTS = '2026-11-20 09:00:00';
SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U2';

-- Task 6a
DELIMITER $$

CREATE TRIGGER trg_before_insert_student
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Employee
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'A person cannot be both a student and an employee.';
    END IF;
END$$

CREATE TRIGGER trg_before_insert_employee
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Student
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'A person cannot be both an employee and a student.';
    END IF;
END$$

DELIMITER ;

-- Task 6b
DELIMITER $$

CREATE TRIGGER trg_before_insert_faculty
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Employee e
        WHERE e.pid = NEW.pid
          AND e.supervisorPid IN (
              SELECT pid
              FROM Employee
              WHERE position = 'dean'
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'A faculty member must report to the dean.';
    END IF;
END$$

CREATE TRIGGER trg_before_insert_administrative
BEFORE INSERT ON Administrative
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Employee e
        WHERE e.pid = NEW.pid
          AND e.supervisorPid IN (
              SELECT pid
              FROM Employee
              WHERE position = 'dean'
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'An administrative employee must report to the dean.';
    END IF;
END$$

CREATE TRIGGER trg_before_update_employee_supervisor
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF (EXISTS (
            SELECT 1 FROM Faculty
            WHERE pid = NEW.pid
        )
        OR EXISTS (
            SELECT 1 FROM Administrative
            WHERE pid = NEW.pid
        )) THEN

        IF NEW.supervisorPid IS NULL OR NOT EXISTS (
            SELECT 1
            FROM Employee
            WHERE pid = NEW.supervisorPid
              AND position = 'dean'
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Faculty and administrative employees must report to the dean.';
        END IF;
    END IF;
END$$

DELIMITER ;

-- Task 6c
DELIMITER $$

CREATE TRIGGER trg_before_insert_dean
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.position = 'dean'
       AND NEW.supervisorPid IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'The dean cannot have a supervisor.';
    END IF;
END$$

CREATE TRIGGER trg_before_update_dean
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.position = 'dean'
       AND NEW.supervisorPid IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'The dean cannot have a supervisor.';
    END IF;
END$$

DELIMITER ;

-- rejected
INSERT INTO Student VALUES (2, 'PhD');

-- rejected
INSERT INTO Employee VALUES (8, '0608', 'B-300', 'postdoc', 2);

INSERT INTO Person VALUES
 (12, 'Rachid', 'Amrani', 'rachid.amrani@um6p.ma', 'UM6P', '2026-11-01', NULL);
INSERT INTO Employee VALUES (12, '0612', 'B-220', 'faculty', 2);
INSERT INTO Academic VALUES (12);

-- rejected
INSERT INTO Faculty VALUES (12);

-- valid
UPDATE Employee SET supervisorPid = 1 WHERE pid = 12;
INSERT INTO Faculty VALUES (12);

-- rejected
UPDATE Employee SET supervisorPid = 3 WHERE pid = 2;

-- rejected
UPDATE Employee SET supervisorPid = 2 WHERE pid = 1;
