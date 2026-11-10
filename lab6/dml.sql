USE rlms;

INSERT INTO Person VALUES
(1, 'Karim', 'Alaoui', 'karim.alaoui@um6p.ma', 'UM6P College of Computing', '2019-09-01', NULL),
(2, 'Salma', 'Bennani', 'salma.bennani@um6p.ma', 'UM6P College of Computing', '2020-02-01', NULL),
(3, 'Omar', 'Tazi', 'omar.tazi@um6p.ma', 'UM6P College of Computing', '2023-10-01', NULL),
(4, 'Youssef', 'Idrissi', 'youssef.idrissi@um6p.ma', 'UM6P Technical Services', '2018-01-15', NULL),
(5, 'Nadia', 'Chraibi', 'nadia.chraibi@um6p.ma', 'UM6P Technical Services', '2021-03-01', NULL),
(6, 'Hamza', 'Berrada', 'hamza.berrada@um6p.ma', 'UM6P Administration', '2017-09-01', NULL),
(7, 'Imane', 'El Fassi', 'imane.elfassi@um6p.ma', 'UM6P College of Computing', '2024-09-01', NULL),
(8, 'Reda', 'Mansouri', 'reda.mansouri@um6p.ma', 'UM6P College of Computing', '2024-09-01', NULL),
(9, 'Laila', 'Kabbaj', 'laila.kabbaj@um6p.ma', 'UM6P College of Computing', '2025-09-01', NULL),
(10, 'Anas', 'Lahlou', 'anas.lahlou@gmail.com', 'Visiting University', '2025-01-10', '2026-06-30');

INSERT INTO Student VALUES
(7, 'Computer Engineering'),
(8, 'Computer Engineering'),
(9, 'Data Science'),
(10, 'Physics');

INSERT INTO Employee VALUES
(1, '0524000001', 'B-101', 'Professor', NULL),
(2, '0524000002', 'B-102', 'Professor', NULL),
(3, '0524000003', 'B-210', 'Postdoc', 1),
(4, '0524000004', 'L-001', 'Technician', 1),
(5, '0524000005', 'L-002', 'Technician', 2),
(6, '0524000006', 'A-010', 'Secretary', 2);

INSERT INTO Academic VALUES (1), (2), (3);
INSERT INTO Faculty VALUES (1), (2);
INSERT INTO Technical VALUES (4), (5);
INSERT INTO Administrative VALUES (6);

INSERT INTO Building VALUES
(1, 'Riad5', 'UM6P Campus, Benguerir'),
(2, 'Building B', 'UM6P Campus, Benguerir');

INSERT INTO Laboratory VALUES
(1, 'Physics Laboratory', 'Physics', 1, 1),
(2, 'Chemistry Laboratory', 'Chemistry', 2, 2),
(3, 'Vision Laboratory', 'Computer Science', 2, 2);

INSERT INTO ResearchProject VALUES
(1, 'Quantum Sensing', '2025-01-01', NULL, 'Active'),
(2, 'Water Quality Monitoring', '2025-06-01', NULL, 'Active'),
(3, 'Legacy Spectroscopy Study', '2023-01-01', '2025-12-31', 'Cancelled'),
(4, 'Solar Cell Efficiency', '2026-09-01', NULL, 'Active');

INSERT INTO ParticipatesIn VALUES
(1, 1, 'Principal Investigator'),
(3, 1, 'Researcher'),
(7, 1, 'Assistant'),
(2, 2, 'Principal Investigator'),
(8, 2, 'Assistant'),
(3, 3, 'Researcher'),
(9, 4, 'Assistant');

INSERT INTO Budget VALUES
(1, 'Physics Grant', 500000.00, 1),
(2, 'Chemistry Grant', 300000.00, 3),
(3, 'Joint Research Fund', 200000.00, 3);

INSERT INTO FundsLab VALUES
(1, 1, 200000.00),
(2, 2, 150000.00),
(3, 3, 50000.00);

INSERT INTO FundsProject VALUES
(1, 1, 120000.00),
(2, 2, 100000.00),
(3, 1, 60000.00),
(3, 4, 40000.00);

INSERT INTO EquipmentModel VALUES
(1, 'Olympus BX53', 'Olympus', 'Optical Microscope'),
(2, 'Zeiss Axio Imager', 'Zeiss', 'Optical Microscope'),
(3, 'Fluke 1524', 'Fluke', 'Thermometer'),
(4, 'Keithley 2450', 'Keithley', 'Source Meter');

INSERT INTO EquipmentUnit VALUES
(1, 'SN-OM-001', '2022-03-15', 12000.00, 1, 1),
(2, 'SN-OM-002', '2023-05-20', 18500.00, 2, 1),
(3, 'SN-TH-001', '2022-03-15', 1500.00, 3, 1),
(4, 'SN-TH-002', '2024-01-10', 1650.00, 3, 1),
(5, 'SN-OM-003', '2023-09-01', 12500.00, 1, 2),
(6, 'SN-TH-003', '2023-09-01', 1500.00, 3, 2),
(7, 'SN-OM-004', '2024-06-30', 18500.00, 2, 3);

INSERT INTO Certification VALUES
(1, 'Laser Safety'),
(2, 'Microscopy Training'),
(3, 'Cleanroom Access');

INSERT INTO Holds VALUES
(1, 1, '2021-05-01'),
(1, 2, '2021-06-01'),
(3, 2, '2024-01-15'),
(7, 2, '2025-02-10'),
(8, 1, '2025-03-05'),
(8, 2, '2025-03-20'),
(2, 3, '2022-11-11');

INSERT INTO Requires VALUES
(1, 2),
(2, 1),
(2, 2);

INSERT INTO Reservation VALUES
(1, '2026-11-05 09:00:00', '2026-11-05 13:00:00', 'Approved', 1, 1, 2),
(2, DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 4 HOUR, 'Approved', 7, 1, 1),
(3, '2026-11-20 10:00:00', '2026-11-20 12:00:00', 'Pending', 3, 3, NULL),
(4, '2026-11-12 14:00:00', '2026-11-12 16:00:00', 'Rejected', 8, 2, 2),
(5, '2026-10-15 09:00:00', '2026-10-15 11:00:00', 'Cancelled', 1, 1, NULL),
(6, '2026-10-01 08:00:00', '2026-10-01 12:00:00', 'Completed', 8, 2, 2),
(7, '2026-11-25 09:00:00', '2026-11-25 17:00:00', 'Pending', 8, 2, NULL);

INSERT INTO Reserves VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 5),
(4, 6),
(5, 1),
(6, 5),
(6, 6),
(7, 2);

INSERT INTO Maintenance VALUES
(1, 1, '2026-03-10', 'Annual cleaning', 4),
(1, 2, '2026-09-12', 'Lens replacement', 5),
(3, 1, '2026-04-02', 'Sensor check', 4),
(5, 1, '2026-05-18', 'Annual cleaning', 5);

INSERT INTO CalibrationRecord VALUES
(3, 1, '2026-04-03', 'Within tolerance', 4),
(4, 1, '2026-04-03', 'Offset corrected', 5),
(6, 1, '2026-07-21', 'Within tolerance', 4);

INSERT INTO Consumable VALUES
(1, 'Ethanol', 'L'),
(2, 'Liquid Nitrogen', 'L'),
(3, 'Microscope Slides', 'box'),
(4, 'Distilled Water', 'L');

INSERT INTO Supplier VALUES
(1, 'ChemSupply Maroc', '0522111111'),
(2, 'LabWorld', '0522222222'),
(3, 'SciPro', '0522333333'),
(4, 'Test Supplier', '0000000000');

INSERT INTO Stocks VALUES
(1, 1, 10, 5, 4, '2026-01-15'),
(1, 3, 40, 10, 4, '2026-01-15'),
(2, 1, 3, 5, 5, '2026-02-01'),
(2, 4, 100, 20, 5, '2026-02-01'),
(3, 2, 12, 8, 4, '2026-03-01');

INSERT INTO Supplies VALUES
(1, 1, 1, 25.00),
(2, 1, 1, 22.50),
(1, 2, 1, 24.00),
(2, 1, 3, 8.00),
(3, 1, 3, 7.50),
(1, 2, 4, 2.00),
(3, 3, 2, 60.00),
(2, 3, 2, 58.00),
(1, 1, 2, 55.00);

INSERT INTO Consumes VALUES
(1, 1, 1, 2),
(1, 1, 3, 10),
(2, 1, 1, 1),
(6, 2, 4, 15),
(6, 2, 1, 1);

INSERT INTO Person VALUES
(11, 'Meryem', 'Alami', 'meryem.alami@um6p.ma', 'UM6P College of Computing', '2026-11-01', NULL);
INSERT INTO Student VALUES (11, 'Computer Engineering');

INSERT INTO EquipmentUnit VALUES
(8, 'SN-OM-005', '2026-11-02', 13000.00, 1, 3);

INSERT INTO Reservation (resId, plannedStart, plannedEnd, madeByPid, projId)
VALUES (8, '2026-12-02 14:00:00', '2026-12-02 17:00:00', 11, 4);
INSERT INTO Reserves VALUES (8, 8);

UPDATE Reservation
SET status = 'Approved', approvedByPid = 2
WHERE resId = 7;

UPDATE Stocks
SET quantity = quantity + 20
WHERE labId = 2 AND consId = 1;

INSERT INTO Consumes VALUES (7, 2, 4, 5);

UPDATE Reservation
SET status = 'Cancelled'
WHERE status = 'Pending'
AND projId IN (SELECT projId FROM ResearchProject WHERE status = 'Cancelled');

DELETE FROM Supplier WHERE supplierId = 4;

SELECT pid, firstName, lastName, email
FROM Person
ORDER BY lastName, firstName;

SELECT DISTINCT discipline
FROM Laboratory;

SELECT pid, firstName, lastName, email
FROM Person
WHERE email LIKE '%@um6p.ma';

SELECT pid, firstName, lastName
FROM Person
WHERE endDate IS NULL;

SELECT resId, plannedStart, plannedEnd, status
FROM Reservation
WHERE plannedStart BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';

SELECT CONCAT(p.firstName, ' ', p.lastName) AS fullName, r.title, pi.role
FROM ParticipatesIn pi
JOIN Person p ON p.pid = pi.pid
JOIN ResearchProject r ON r.projId = pi.projId;

SELECT b.budgetId, b.name, CONCAT(p.firstName, ' ', p.lastName) AS manager
FROM Budget b
JOIN Academic a ON a.pid = b.managerPid
JOIN Person p ON p.pid = a.pid;

SELECT res.resId, CONCAT(p.firstName, ' ', p.lastName) AS madeBy, rp.title
FROM Reservation res
JOIN Person p ON p.pid = res.madeByPid
JOIN ResearchProject rp ON rp.projId = res.projId;

SELECT rs.resId, u.serialNumber, m.commercialName, l.name AS laboratory
FROM Reserves rs
JOIN EquipmentUnit u ON u.unitId = rs.unitId
JOIN EquipmentModel m ON m.modelId = u.modelId
JOIN Laboratory l ON l.labId = u.labId
ORDER BY rs.resId;

SELECT res.resId, res.plannedStart, CONCAT(p.firstName, ' ', p.lastName) AS approvedBy
FROM Reservation res
JOIN Person p ON p.pid = res.approvedByPid
WHERE res.status = 'Approved';

SELECT l.name AS laboratory, c.name AS consumable, s.quantity,
       CONCAT(p.firstName, ' ', p.lastName) AS monitoredBy
FROM Stocks s
JOIN Laboratory l ON l.labId = s.labId
JOIN Consumable c ON c.consId = s.consId
JOIN Technical t ON t.pid = s.monitorPid
JOIN Person p ON p.pid = t.pid;

SELECT l.name, COUNT(u.unitId) AS nbUnits
FROM Laboratory l
LEFT JOIN EquipmentUnit u ON u.labId = l.labId
GROUP BY l.labId, l.name;

SELECT c.name, COALESCE(SUM(cs.quantityUsed), 0) AS totalUsed
FROM Consumable c
LEFT JOIN Consumes cs ON cs.consId = c.consId
GROUP BY c.consId, c.name;

SELECT l.name, COUNT(*) AS nbUnits
FROM Laboratory l
JOIN EquipmentUnit u ON u.labId = l.labId
GROUP BY l.labId, l.name
HAVING COUNT(*) > 3;

SELECT rp.title, COALESCE(SUM(fp.amountGranted), 0) AS totalGranted
FROM ResearchProject rp
LEFT JOIN FundsProject fp ON fp.projId = rp.projId
GROUP BY rp.projId, rp.title;

SELECT l.name AS laboratory, m.category, COUNT(*) AS nbUnits, AVG(u.purchaseCost) AS avgCost
FROM EquipmentUnit u
JOIN Laboratory l ON l.labId = u.labId
JOIN EquipmentModel m ON m.modelId = u.modelId
GROUP BY l.labId, l.name, m.category;

SELECT s.name, COUNT(DISTINCT sp.consId) AS nbConsumables
FROM Supplier s
LEFT JOIN Supplies sp ON sp.supplierId = s.supplierId
GROUP BY s.supplierId, s.name;

SELECT l.name AS laboratory, c.name AS consumable, MIN(sp.unitPrice) AS lowestPrice
FROM Supplies sp
JOIN Laboratory l ON l.labId = sp.labId
JOIN Consumable c ON c.consId = sp.consId
GROUP BY l.labId, l.name, c.consId, c.name;

SELECT res.resId, CONCAT(p.firstName, ' ', p.lastName) AS madeBy, SUM(cs.quantityUsed) AS totalUsed
FROM Reservation res
JOIN Person p ON p.pid = res.madeByPid
JOIN Consumes cs ON cs.resId = res.resId
GROUP BY res.resId, p.firstName, p.lastName;

SELECT p.pid, CONCAT(p.firstName, ' ', p.lastName) AS fullName
FROM Person p
JOIN Laboratory l ON l.supervisorPid = p.pid
INTERSECT
SELECT p.pid, CONCAT(p.firstName, ' ', p.lastName) AS fullName
FROM Person p
JOIN Budget b ON b.managerPid = p.pid;

SELECT pid, firstName, lastName
FROM Person
WHERE pid NOT IN (SELECT madeByPid FROM Reservation);

SELECT u.unitId, u.serialNumber
FROM EquipmentUnit u
WHERE NOT EXISTS (SELECT * FROM Reserves rs WHERE rs.unitId = u.unitId);

SELECT unitId, serialNumber, purchaseCost
FROM EquipmentUnit
WHERE purchaseCost >= ALL (SELECT purchaseCost FROM EquipmentUnit);

SELECT m.modelId, m.commercialName, p.pid, CONCAT(p.firstName, ' ', p.lastName) AS fullName
FROM EquipmentModel m, Person p
WHERE EXISTS (SELECT * FROM Requires r WHERE r.modelId = m.modelId)
AND NOT EXISTS (
    SELECT * FROM Requires r
    WHERE r.modelId = m.modelId
    AND NOT EXISTS (
        SELECT * FROM Holds h
        WHERE h.pid = p.pid AND h.certId = r.certId
    )
)
ORDER BY m.modelId, p.pid;
