
USE rlms;
-- D1: Student.program
ALTER TABLE Student
  ADD CONSTRAINT chk_student_program CHECK (program IN ('PhD','MSc','BSc','BEng'));

UPDATE Student SET program = 'Postdoc' WHERE pid = 8;

-- D2: Employee.position
ALTER TABLE Employee
  ADD CONSTRAINT chk_employee_position
  CHECK (position IN ('dean','faculty','postdoc','secretary','technician','lab manager'));

UPDATE Employee SET position = 'janitor' WHERE pid = 6;

-- D3: ResearchProject.status
ALTER TABLE ResearchProject
  ADD CONSTRAINT chk_project_status CHECK (status IN ('Proposed','Active','Suspended','Completed','Cancelled'));

UPDATE ResearchProject SET status = 'Paused' WHERE code = 'P1';

-- D4: Participates.role
ALTER TABLE Participates
  ADD CONSTRAINT chk_participates_role CHECK (role IN ('PI','Co-PI','Collaborator'));

UPDATE Participates SET role = 'Observer' WHERE pid = 8 AND projectCode = 'P1';

-- D5: EquipmentUnit.status
ALTER TABLE EquipmentUnit
  ADD CONSTRAINT chk_unit_status CHECK (status IN ('InService','UnderMaintenance','OutOfService','Retired'));

UPDATE EquipmentUnit SET status = 'Broken' WHERE serialNo = 'U1';

-- D6: Reservation.status
ALTER TABLE Reservation
  ADD CONSTRAINT chk_reservation_status
  CHECK (status IN ('Pending','Approved','Rejected','Completed','Cancelled'));

UPDATE Reservation SET status = 'Postponed' WHERE resId = 1;

-- D7: Maintenance.type
ALTER TABLE Maintenance
  ADD CONSTRAINT chk_maintenance_type CHECK (type IN ('Corrective','Preventive'));

UPDATE Maintenance SET type = 'Cosmetic' WHERE serialNo = 'U1';

-- D8: Maintenance.outcome
ALTER TABLE Maintenance
  ADD CONSTRAINT chk_maintenance_outcome CHECK (outcome IN ('FollowUpRequired','Resolved'));
UPDATE Maintenance SET outcome = 'Unknown' WHERE serialNo = 'U1';

--- D9: CalibratonRecord.result
ALTER TABLE CalibrationRecord
  ADD CONSTRAINT chk_calibration_result CHECK (result IN ('Pass','Fail','Adjusted'));

UPDATE CalibrationRecord SET result = 'Maybe' WHERE serialNo = 'U5';



-- S1: Budget.amountGranted >= 0
ALTER TABLE Budget ADD CONSTRAINT chk_budget_granted CHECK (amountGranted >= 0);

UPDATE Budget SET amountGranted = -1 WHERE budgetLine = 'B1';

-- S2: Budget.amountDisbursed >= 0
ALTER TABLE Budget ADD CONSTRAINT chk_budget_disbursed CHECK (amountDisbursed >= 0);

UPDATE Budget SET amountDisbursed = -50 WHERE budgetLine = 'B1';

-- S3: EquipmentUnit.purchaseCost >= 0
ALTER TABLE EquipmentUnit ADD CONSTRAINT chk_unit_cost CHECK (purchaseCost >= 0);
UPDATE EquipmentUnit SET purchaseCost = -100 WHERE serialNo = 'U1';

-- S4: Maintenance.cost >= 0
ALTER TABLE Maintenance ADD CONSTRAINT chk_maintenance_cost CHECK (cost >= 0);
UPDATE Maintenance SET cost = -10 WHERE serialNo = 'U1';

-- S5: Supplies.unitPrice >= 0
ALTER TABLE Supplies ADD CONSTRAINT chk_supplies_price CHECK (unitPrice >= 0);
UPDATE Supplies SET unitPrice = -5 WHERE suppId = 1 AND consId = 1 AND labId = 1;

-- S6: Stocks.quantityOnHand >= 0
ALTER TABLE Stocks ADD CONSTRAINT chk_stocks_quantity CHECK (quantityOnHand >= 0);
UPDATE Stocks SET quantityOnHand = -1 WHERE labId = 1 AND consId = 1;

-- S7: Consumable.reorderThreshold >= 0
ALTER TABLE Consumable ADD CONSTRAINT chk_consumable_threshold CHECK (reorderThreshold >= 0);
UPDATE Consumable SET reorderThreshold = -3 WHERE consId = 1;

-- S8: Consumes.quantityUsed > 0 (strictly positive)
ALTER TABLE Consumes ADD CONSTRAINT chk_consumes_quantity CHECK (quantityUsed > 0);
UPDATE Consumes SET quantityUsed = 0 WHERE resId = 1 AND labId = 1 AND consId = 1;


-- T1: Reservation.plannedEnd 
ALTER TABLE Reservation
  ADD CONSTRAINT chk_reservation_dates CHECK (plannedEnd > plannedStart);
UPDATE Reservation SET plannedEnd = '2026-10-29 09:00:00' WHERE resId = 1;

-- T2: Maintenance.endTS 
ALTER TABLE Maintenance
  ADD CONSTRAINT chk_maintenance_dates CHECK (endTS >= startTS);
UPDATE Maintenance SET endTS = '2026-04-12 08:00:00' WHERE serialNo = 'U1';