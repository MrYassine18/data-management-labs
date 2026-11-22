USE rlms;

-- Task 1
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

SELECT m.modelId, m.commercialName, availableUnits(m.modelId) AS availableUnits
FROM EquipmentModel m;

-- Task 2
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

-- valid
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;
CALL RestockLab(1, 1, 10, @newQty);
SELECT @newQty AS newQuantity;

-- rejected
CALL RestockLab(1, 1, 0, @newQty);

-- rejected
CALL RestockLab(2, 2, 10, @newQty);

-- Task 7

-- Task 7 (a)
ALTER TABLE Consumable RENAME COLUMN name TO designation;

-- Task 7 (b)
CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT
    s.labId,
    l.name AS labName,
    s.consId,
    c.designation AS consumableName,
    c.unitOfMeasure,
    s.quantityOnHand,
    c.reorderThreshold,
    s.technicalPid,
    s.monitoringSince AS monitoringStartDate,
    CASE
        WHEN s.quantityOnHand <= c.reorderThreshold
            THEN 'LOW'
        ELSE 'OK'
    END AS stockLevel
FROM Stocks s
JOIN Laboratory l ON s.labId = l.labId
JOIN Consumable c ON s.consId = c.consId;

-- Task 7 (d)
ALTER TABLE Consumable RENAME COLUMN designation TO name;

CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT
    s.labId,
    l.name AS labName,
    s.consId,
    c.name AS consumableName,
    c.unitOfMeasure,
    s.quantityOnHand,
    c.reorderThreshold,
    s.technicalPid,
    s.monitoringSince AS monitoringStartDate,
    CASE
        WHEN s.quantityOnHand <= c.reorderThreshold
            THEN 'LOW'
        ELSE 'OK'
    END AS stockLevel
FROM Stocks s
JOIN Laboratory l ON s.labId = l.labId
JOIN Consumable c ON s.consId = c.consId;
