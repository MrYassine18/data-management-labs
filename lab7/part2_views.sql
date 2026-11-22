CREATE DATABASE Lab7;
USE Lab7;

-- ========== People ==========
CREATE TABLE Person (
    pid INT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,  -- assumption stated in report
    affiliation VARCHAR(150) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE
);

CREATE TABLE Student (
    pid INT PRIMARY KEY,
    program VARCHAR(20) NOT NULL,
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE
);

CREATE TABLE Employee (
    pid INT PRIMARY KEY,
    phone VARCHAR(30) NOT NULL,
    office VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    supervisorPid INT,
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE,
    FOREIGN KEY (supervisorPid) REFERENCES Employee(pid) ON DELETE SET NULL
);

CREATE TABLE Academic (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE
);

CREATE TABLE Administrative (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE
);

CREATE TABLE Technical (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE
);

CREATE TABLE Faculty (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Academic(pid) ON DELETE CASCADE
);

CREATE TABLE Advises (
    academicPid INT NOT NULL,
    studentPid INT NOT NULL,
    PRIMARY KEY (academicPid, studentPid),
    FOREIGN KEY (academicPid) REFERENCES Academic(pid),
    FOREIGN KEY (studentPid) REFERENCES Student(pid) ON DELETE CASCADE
);

-- ========== Laboratories, Projects, and Budgets ==========
CREATE TABLE Laboratory (
    labId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    building VARCHAR(100) NOT NULL,
    roomNumber VARCHAR(50) NOT NULL,
    discipline VARCHAR(150) NOT NULL,
    supervisorPid INT NOT NULL,
    FOREIGN KEY (supervisorPid) REFERENCES Faculty(pid)
);

CREATE TABLE Attached (
    pid INT NOT NULL,
    labId INT NOT NULL,
    PRIMARY KEY (pid, labId),
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE CASCADE
);

CREATE TABLE ResearchProject (
    code VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Proposed'
);

CREATE TABLE Participates (
    pid INT NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    role VARCHAR(30) NOT NULL,
    PRIMARY KEY (pid, projectCode),
    FOREIGN KEY (pid) REFERENCES Person(pid),
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code) ON DELETE CASCADE
);

CREATE TABLE Budget (
    budgetLine VARCHAR(50) PRIMARY KEY,
    amountGranted DECIMAL(12,2) NOT NULL,
    amountDisbursed DECIMAL(12,2) NOT NULL DEFAULT 0,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    managerPid INT NOT NULL,
    FOREIGN KEY (managerPid) REFERENCES Academic(pid)
);

CREATE TABLE FundsPrj (
    budgetLine VARCHAR(50) NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    PRIMARY KEY (budgetLine, projectCode),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine),
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code) ON DELETE CASCADE
);

CREATE TABLE FundsLab (
    budgetLine VARCHAR(50) NOT NULL,
    labId INT NOT NULL,
    PRIMARY KEY (budgetLine, labId),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE CASCADE
);

-- ========== Equipment and Certifications ==========
CREATE TABLE EquipmentModel (
    modelId INT PRIMARY KEY,
    commercialName VARCHAR(150) NOT NULL,
    manufacturer VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    requiredEnvironment VARCHAR(200) NOT NULL,
    trainingMandatory BOOLEAN NOT NULL
);

CREATE TABLE EquipmentUnit (
    serialNo VARCHAR(100) PRIMARY KEY,
    acquisitionDate DATE NOT NULL,
    purchaseCost DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'InService',
    portable BOOLEAN NOT NULL,
    modelId INT NOT NULL,
    labId INT NOT NULL,
    FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);

CREATE TABLE Certification (
    code VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    issuingAuthority VARCHAR(150) NOT NULL,
    validityPeriod INT NOT NULL,
    safetyLevel VARCHAR(100) NOT NULL
);

CREATE TABLE Requires (
    modelId INT NOT NULL,
    certCode VARCHAR(50) NOT NULL,
    PRIMARY KEY (modelId, certCode),
    FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId) ON DELETE CASCADE,
    FOREIGN KEY (certCode) REFERENCES Certification(code)
);

CREATE TABLE Holds (
    pid INT NOT NULL,
    certCode VARCHAR(50) NOT NULL,
    issueDate DATE NOT NULL,
    expirationDate DATE NOT NULL,
    grade VARCHAR(50),
    PRIMARY KEY (pid, certCode),
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE,
    FOREIGN KEY (certCode) REFERENCES Certification(code)
);

-- ========== Reservations ==========
CREATE TABLE Reservation (
    resId INT PRIMARY KEY,
    submissionTS TIMESTAMP NOT NULL,
    plannedStart TIMESTAMP NOT NULL,
    plannedEnd TIMESTAMP NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    madeByPid INT NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    approverPid INT,
    FOREIGN KEY (madeByPid) REFERENCES Person(pid),
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code),
    FOREIGN KEY (approverPid) REFERENCES Person(pid) ON DELETE SET NULL
);

CREATE TABLE Reserves (
    resId INT NOT NULL,
    serialNo VARCHAR(100) NOT NULL,
    PRIMARY KEY (resId, serialNo),
    FOREIGN KEY (resId) REFERENCES Reservation(resId) ON DELETE CASCADE,
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo)
);

-- ========== Maintenance and Calibration ==========
CREATE TABLE Maintenance (
    serialNo VARCHAR(100) NOT NULL,
    startTS TIMESTAMP NOT NULL,
    endTS TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,
    description VARCHAR(255) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    outcome VARCHAR(30) NOT NULL,
    technicalPid INT NOT NULL,
    PRIMARY KEY (serialNo, startTS),
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE,
    FOREIGN KEY (technicalPid) REFERENCES Technical(pid)
);

CREATE TABLE CalibrationRecord (
    serialNo VARCHAR(100) NOT NULL,
    calibDate DATE NOT NULL,
    calibrationType VARCHAR(100) NOT NULL,
    result VARCHAR(20) NOT NULL,
    nextDueDate DATE NOT NULL,
    remarks VARCHAR(255),
    PRIMARY KEY (serialNo, calibDate),
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE
);

-- ========== Consumables, Suppliers, and Stock ==========
CREATE TABLE Consumable (
    consId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    unitOfMeasure VARCHAR(50) NOT NULL,
    hazardLevel VARCHAR(100) NOT NULL,
    reorderThreshold DECIMAL(12,2) NOT NULL
);

CREATE TABLE Supplier (
    suppId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    contactEmail VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL
);

CREATE TABLE Supplies (
    suppId INT NOT NULL,
    consId INT NOT NULL,
    labId INT NOT NULL,
    unitPrice DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (suppId, consId, labId),
    FOREIGN KEY (suppId) REFERENCES Supplier(suppId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);

CREATE TABLE Stocks (
    labId INT NOT NULL,
    consId INT NOT NULL,
    quantityOnHand DECIMAL(12,2) NOT NULL,
    lastRestockDate DATE NOT NULL,
    storageCondition VARCHAR(150),
    technicalPid INT NOT NULL,
    monitoringSince DATE NOT NULL,
    PRIMARY KEY (labId, consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (technicalPid) REFERENCES Technical(pid)
);

CREATE TABLE Consumes (
    resId INT NOT NULL,
    labId INT NOT NULL,
    consId INT NOT NULL,
    quantityUsed DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (resId, labId, consId),
    FOREIGN KEY (resId) REFERENCES Reservation(resId) ON DELETE CASCADE,
    FOREIGN KEY (labId, consId) REFERENCES Stocks(labId, consId)
);

INSERT INTO Person VALUES
(1, 'Omar', 'Alaoui', 'omar.alaoui@um6p.ma', 'UM6P', '2018-01-08', NULL),
(2, 'Karim', 'Bennani', 'karim.bennani@um6p.ma', 'UM6P', '2019-09-01', NULL),
(3, 'Salma', 'Idrissi', 'salma.idrissi@um6p.ma', 'UM6P', '2020-02-01', NULL),
(4, 'Nadia', 'Tazi', 'nadia.tazi@inria.fr', 'INRIA', '2023-10-01', '2026-09-30'),
(5, 'Amal', 'Chraibi', 'amal.chraibi@um6p.ma', 'UM6P', '2021-03-15', NULL),
(6, 'Youssef', 'Berrada', 'youssef.berrada@um6p.ma', 'UM6P', '2022-01-10', NULL),
(7, 'Hind', 'Senhaji', 'hind.senhaji@um6p.ma', 'UM6P', '2020-06-01', NULL),
(8, 'Mehdi', 'Ouazzani', 'mehdi.ouazzani@um6p.ma', 'UM6P', '2024-09-01', NULL),
(9, 'Firdawse', 'Zniber', 'firdawse.zniber@um6p.ma', 'UM6P', '2025-09-01', NULL),
(10, 'Ali', 'Rguibi', 'ali.rguibi@um6p.ma', 'UM6P', '2026-09-01', NULL);

INSERT INTO Student VALUES (8, 'PhD'), (9, 'MSc'), (10, 'BSc');

INSERT INTO Employee VALUES
(1, '0601', 'A-100', 'dean', NULL),
(2, '0602', 'B-201', 'faculty', 1),
(3, '0603', 'B-202', 'faculty', 1),
(4, '0604', 'B-210', 'postdoc', 2),
(5, '0605', 'A-101', 'secretary', 1),
(6, '0606', 'C-001', 'technician', 2),
(7, '0607', 'C-002', 'lab manager', 3);

INSERT INTO Academic VALUES (1), (2), (3), (4);
INSERT INTO Administrative VALUES (5);
INSERT INTO Technical VALUES (6), (7);
INSERT INTO Faculty VALUES (2), (3);

INSERT INTO Advises VALUES (2, 8), (3, 9), (2, 10);

INSERT INTO Laboratory VALUES
(1, 'Physics Laboratory', 'Riad5', 'R5-110', 'Physics', 2),
(2, 'Data Systems Lab', 'Riad5', 'R5-210', 'Data Management', 2),
(3, 'BioLab', 'Sciences Building', 'SB-010', 'Biochemistry', 3);

INSERT INTO Attached VALUES
(2, 1), (8, 1), (6, 1), (3, 2), (9, 2), (8, 2), (4, 2), (7, 3);

INSERT INTO ResearchProject VALUES
('P1', 'Vector Search at Scale', '2026-01-01', '2027-12-31', 'Active'),
('P2', 'Green HPC', '2026-06-01', '2028-05-31', 'Proposed'),
('P3', 'Legacy Archive Migration', '2025-01-01', '2026-06-30', 'Cancelled');

INSERT INTO Participates VALUES
(2, 'P1', 'PI'), (3, 'P1', 'Co-PI'), (8, 'P1', 'Collaborator'),
(6, 'P1', 'Collaborator'),
(3, 'P2', 'PI'), (9, 'P2', 'Collaborator'),
(2, 'P3', 'PI'), (9, 'P3', 'Collaborator');

INSERT INTO Budget VALUES
('B1', 500000.00, 120000.00, '2026-01-01', '2027-12-31', 2),
('B2', 200000.00, 0.00, '2026-06-01', '2028-05-31', 4);

INSERT INTO FundsPrj VALUES ('B1', 'P1'), ('B2', 'P2'), ('B1', 'P3');
INSERT INTO FundsLab VALUES ('B1', 1), ('B1', 2), ('B2', 3);

INSERT INTO EquipmentModel VALUES
(1, 'BX53', 'Olympus', 'Optical Microscope', 'vibration-free bench', FALSE),
(2, 'Fluke 1524', 'Fluke', 'Thermometer', 'temperature-controlled room', TRUE),
(3, 'Prusa XL', 'Prusa Research', '3D Printer', 'ventilated room', TRUE),
(4, 'Spectro X', 'Agilent', 'Spectrometer', 'vibration-free bench', FALSE);

INSERT INTO EquipmentUnit VALUES
('U1', '2025-02-01', 15000.00, 'InService', FALSE, 1, 1),
('U2', '2025-02-01', 15500.00, 'InService', FALSE, 1, 1),
('U3', '2025-07-10', 32000.00, 'InService', FALSE, 2, 1),
('U4', '2026-01-15', 33500.00, 'InService', FALSE, 2, 2),
('U5', '2024-11-20', 3500.00, 'InService', TRUE, 3, 3),
('U6', '2023-05-02', 14000.00, 'UnderMaintenance', FALSE, 1, 2),
('U7', '2026-03-01', 16000.00, 'InService', FALSE, 1, 1);

INSERT INTO Certification VALUES
('C1', 'Laboratory Instrument Safety', 'UM6P Safety Office', 24, 'Level 2'),
('C2', 'Thermal Calibration Procedures', 'Fluke Academy', 12, 'Level 1');

INSERT INTO Requires VALUES (2, 'C1'), (2, 'C2'), (3, 'C1');

INSERT INTO Holds VALUES
(2, 'C1', '2025-01-10', '2027-01-10', 'A'),
(2, 'C2', '2026-02-01', '2027-02-01', NULL),
(8, 'C1', '2025-06-15', '2027-06-15', 'B'),
(6, 'C2', '2024-09-01', '2025-09-01', NULL);

INSERT INTO Reservation VALUES
(1, '2026-10-20 09:00:00', '2026-10-30 09:00:00', '2026-11-02 18:00:00', 'Microscopy imaging session', 'Approved', 8, 'P1', 3),
(2, '2026-10-22 10:00:00', '2026-11-10 08:00:00', '2026-11-12 18:00:00', 'Thermal benchmark run', 'Pending', 2, 'P1', NULL),
(3, '2026-10-23 11:00:00', '2026-11-15 08:00:00', '2026-11-16 18:00:00', 'Archive scan', 'Pending', 9, 'P3', NULL),
(4, '2026-09-01 08:30:00', '2026-09-10 08:00:00', '2026-09-14 18:00:00', 'Calibration experiments', 'Approved', 2, 'P1', 3),
(5, '2026-09-05 14:00:00', '2026-09-20 08:00:00', '2026-09-21 18:00:00', 'Ad-hoc test', 'Rejected', 8, 'P1', 3),
(6, '2026-08-01 09:00:00', '2026-08-10 08:00:00', '2026-08-12 18:00:00', 'Prototype print', 'Completed', 6, 'P1', NULL);

INSERT INTO Reserves VALUES
(1, 'U1'), (1, 'U5'),
(2, 'U3'),
(3, 'U2'),
(4, 'U3'), (4, 'U4'),
(5, 'U2'),
(6, 'U5');

INSERT INTO Maintenance VALUES
('U6', '2026-10-01 09:00:00', '2026-10-01 17:00:00', 'Corrective', 'Stage motor failure', 1200.00, 'FollowUpRequired', 6),
('U1', '2026-04-12 09:00:00', '2026-04-12 12:00:00', 'Preventive', 'Lens cleaning', 150.00, 'Resolved', 7);

INSERT INTO CalibrationRecord VALUES
('U3', '2026-03-01', 'thermal sensors', 'Pass', '2026-09-01', NULL),
('U3', '2026-09-05', 'thermal sensors', 'Adjusted', '2027-03-05', 'drift corrected'),
('U5', '2026-06-15', 'axis alignment', 'Pass', '2026-12-15', NULL);

INSERT INTO Consumable VALUES
(1, 'Nitrile Gloves', 'box', 'Low', 10.00),
(2, 'Thermal Paste', 'tube', 'Low', 5.00),
(3, 'Reagent X', 'bottle', 'High', 3.00);

INSERT INTO Supplier VALUES
(1, 'LabSupply Maroc', 'contact@labsupply.ma', '0522-111-222'),
(2, 'SciChem SARL', 'sales@scichem.ma', '0522-333-444');

INSERT INTO Supplies VALUES
(1, 1, 1, 45.00),
(2, 1, 1, 42.50),
(1, 1, 3, 50.00),
(2, 2, 1, 30.00),
(1, 3, 3, 120.00);  -- arrangement with no stock of Reagent X in BioLab (CO5)

INSERT INTO Stocks VALUES
(1, 1, 25.00, '2026-10-01', NULL, 6, '2026-01-15'),
(2, 1, 8.00, '2026-09-20', 'dry cabinet', 6, '2026-02-01'),
(3, 1, 30.00, '2026-10-05', NULL, 7, '2026-03-01'),
(1, 2, 12.00, '2026-08-11', 'room temperature', 7, '2026-04-01');

INSERT INTO Consumes VALUES
(1, 1, 1, 4.00),
(1, 1, 2, 2.00),
(4, 1, 2, 1.00);

-- Operation 1: new person and subtype record
INSERT INTO Person VALUES
(11, 'Zineb', 'El Fassi', 'zineb.elfassi@um6p.ma', 'UM6P', '2026-10-01', NULL);
INSERT INTO Student VALUES (11, 'BEng');

-- Operation 2: new equipment unit
INSERT INTO EquipmentUnit VALUES
('U8', '2026-10-20', 15800.00, 'InService', FALSE, 1, 2);

-- Operation 3: new reservation with a Reserves tuple (status defaults to 'Pending')
INSERT INTO Reservation
    (resId, submissionTS, plannedStart, plannedEnd, purpose, madeByPid, projectCode)
VALUES
    (7, '2026-10-27 10:00:00', '2026-12-01 09:00:00', '2026-12-02 18:00:00',
     'Course project runs', 11, 'P1');
INSERT INTO Reserves VALUES (7, 'U8');

-- Operation 4: approval recording the approver
UPDATE Reservation
SET status = 'Approved', approverPid = 3
WHERE resId = 2;

-- Operation 5: stock quantity update
UPDATE Stocks
SET quantityOnHand = quantityOnHand + 50, lastRestockDate = '2026-10-27'
WHERE labId = 1 AND consId = 1;

-- Operation 6: consumption by an approved reservation
INSERT INTO Consumes VALUES (4, 3, 1, 2.00);

-- Operation 7: nested UPDATE (cancel pending reservations of cancelled projects)
UPDATE Reservation
SET status = 'Cancelled'
WHERE status = 'Pending'
  AND projectCode IN (SELECT code FROM ResearchProject
                      WHERE status = 'Cancelled');

-- Operation 8: deletion preserving referential integrity
DELETE FROM Supplies WHERE suppId = 2 AND consId = 2 AND labId = 1;

-- Query 1
SELECT pid, firstName, lastName, email FROM Person ORDER BY lastName, firstName;

-- Query 2
SELECT DISTINCT discipline FROM Laboratory;

-- Query 3
SELECT pid, firstName, lastName, email FROM Person WHERE email LIKE '%@um6p.ma';

-- Query 4
SELECT pid, firstName, lastName FROM Person WHERE endDate IS NULL;

-- Query 5
SELECT * FROM Reservation
WHERE plannedStart BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';

-- Query 6
SELECT CONCAT(p.firstName, ' ', p.lastName) AS participant, r.title, pa.role
FROM Participates pa
JOIN Person p ON p.pid = pa.pid
JOIN ResearchProject r ON r.code = pa.projectCode;

-- Query 7
SELECT b.budgetLine, CONCAT(p.firstName, ' ', p.lastName) AS manager
FROM Budget b JOIN Person p ON p.pid = b.managerPid;

-- Query 8
SELECT r.resId, CONCAT(p.firstName, ' ', p.lastName) AS madeBy, pr.title
FROM Reservation r
JOIN Person p ON p.pid = r.madeByPid
JOIN ResearchProject pr ON pr.code = r.projectCode;

-- Query 9
SELECT rs.resId, u.serialNo, m.commercialName, l.name AS labName
FROM Reserves rs
JOIN EquipmentUnit u ON u.serialNo = rs.serialNo
JOIN EquipmentModel m ON m.modelId = u.modelId
JOIN Laboratory l ON l.labId = u.labId;

-- Query 10
SELECT r.resId, CONCAT(p.firstName, ' ', p.lastName) AS approver
FROM Reservation r JOIN Person p ON p.pid = r.approverPid
WHERE r.status = 'Approved';

-- Query 11
SELECT l.name AS labName, c.name AS consumable, s.quantityOnHand,
       CONCAT(p.firstName, ' ', p.lastName) AS monitor
FROM Stocks s
JOIN Laboratory l ON l.labId = s.labId
JOIN Consumable c ON c.consId = s.consId
JOIN Person p ON p.pid = s.technicalPid;

-- Query 12
SELECT labId, COUNT(*) AS nUnits FROM EquipmentUnit GROUP BY labId;

-- Query 13
SELECT consId, SUM(quantityUsed) AS totalUsed FROM Consumes GROUP BY consId;

-- Query 14
SELECT l.name, COUNT(*) AS nUnits
FROM EquipmentUnit u JOIN Laboratory l ON l.labId = u.labId
GROUP BY l.labId, l.name
HAVING COUNT(*) > 3;

-- Query 15
SELECT pr.title, SUM(b.amountGranted) AS totalGranted
FROM ResearchProject pr
JOIN FundsPrj f ON f.projectCode = pr.code
JOIN Budget b ON b.budgetLine = f.budgetLine
GROUP BY pr.code, pr.title;

-- Query 16
SELECT l.name, m.category, COUNT(*) AS nUnits, AVG(u.purchaseCost) AS avgCost
FROM EquipmentUnit u
JOIN Laboratory l ON l.labId = u.labId
JOIN EquipmentModel m ON m.modelId = u.modelId
GROUP BY l.labId, l.name, m.category;

-- Query 17
SELECT s.suppId, sup.name, COUNT(DISTINCT s.consId) AS nConsumables
FROM Supplies s JOIN Supplier sup ON sup.suppId = s.suppId
GROUP BY s.suppId, sup.name;

-- Query 18
SELECT l.name AS labName, c.name AS consumable, MIN(s.unitPrice) AS bestPrice
FROM Supplies s
JOIN Laboratory l ON l.labId = s.labId
JOIN Consumable c ON c.consId = s.consId
GROUP BY s.labId, l.name, s.consId, c.name;

-- Query 19
SELECT r.resId, CONCAT(p.firstName, ' ', p.lastName) AS madeBy,
       SUM(co.quantityUsed) AS totalUsed
FROM Consumes co
JOIN Reservation r ON r.resId = co.resId
JOIN Person p ON p.pid = r.madeByPid
GROUP BY r.resId, p.firstName, p.lastName;

-- Query 20 (INTERSECT requires MySQL >= 8.0.31)
SELECT p.pid, p.firstName, p.lastName
FROM Person p JOIN Laboratory l ON l.supervisorPid = p.pid
INTERSECT
SELECT p.pid, p.firstName, p.lastName
FROM Person p JOIN Budget b ON b.managerPid = p.pid;

-- Query 21
SELECT pid FROM Person
EXCEPT
SELECT madeByPid FROM Reservation;

-- Query 22
SELECT u.serialNo FROM EquipmentUnit u
WHERE NOT EXISTS (SELECT 1 FROM Reserves rs WHERE rs.serialNo = u.serialNo);

-- Query 23
SELECT serialNo, purchaseCost FROM EquipmentUnit
WHERE purchaseCost >= ALL (SELECT purchaseCost FROM EquipmentUnit);

-- Query 24 (relational division with double NOT EXISTS)
SELECT m.modelId, m.commercialName, p.pid,
       CONCAT(p.firstName, ' ', p.lastName) AS qualifiedPerson
FROM EquipmentModel m CROSS JOIN Person p
WHERE EXISTS (SELECT 1 FROM Requires rq WHERE rq.modelId = m.modelId)
  AND NOT EXISTS (
      SELECT 1 FROM Requires rq
      WHERE rq.modelId = m.modelId
        AND NOT EXISTS (SELECT 1 FROM Holds h
                        WHERE h.pid = p.pid AND h.certCode = rq.certCode));
                        
/*functions 1 and 2*/
DROP FUNCTION IF EXISTS availableUnits;

DELIMITER //
CREATE FUNCTION availableUnits(mId INT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE n INT;
    SELECT COUNT(*) INTO n
    FROM EquipmentUnit
    WHERE modelId = mId AND status = 'InService';
    RETURN n;
END//
DELIMITER ;

/*Demonstration: every model with its number of available units*/
SELECT m.modelId, m.commercialName, availableUnits(m.modelId) AS availableUnits
FROM EquipmentModel m;



DROP PROCEDURE IF EXISTS RestockLab;

DELIMITER //
CREATE PROCEDURE RestockLab(
    IN  p_labId INT,
    IN  p_consId INT,
    IN  p_qty DECIMAL(12,2),
    OUT newQuantity DECIMAL(12,2))
BEGIN
    IF p_qty IS NULL OR p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RestockLab: qty must be strictly positive';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Stocks
                   WHERE labId = p_labId AND consId = p_consId) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RestockLab: no stock occurrence for this laboratory and consumable';
    END IF;

    UPDATE Stocks
    SET quantityOnHand = quantityOnHand + p_qty,
        lastRestockDate = CURDATE()
    WHERE labId = p_labId AND consId = p_consId;

    SELECT quantityOnHand INTO newQuantity
    FROM Stocks
    WHERE labId = p_labId AND consId = p_consId;
END//
DELIMITER ;

/*exa,ple*/
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;  
CALL RestockLab(1, 1, 10, @newQty);
SELECT @newQty AS newQuantity;       
                               
