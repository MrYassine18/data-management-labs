CREATE TABLE Person (
pid INT PRIMARY KEY ,
firstName VARCHAR (100) NOT NULL ,
lastName VARCHAR (100) NOT NULL ,
email VARCHAR (150) NOT NULL UNIQUE ,
-- a ssu mp ti on stated in
report
a f f i l i a t i o n VARCHAR (150) NOT NULL ,
startDate DATE NOT NULL ,
endDate DATE
) ;

 --- Q1 : 
SELECT CONCAT(P.firstName, ' ',P.lastName) AS employee,
       CONCAT(Ps.firstName, ' ', Ps.lastName) AS supervisor
FROM  Employee E 
JOIN Person P ON P.pid = E.pid
LEFT JOIN Employee Ep ON E.supervisorPid = Ep.pid
LEFT JOIN Person Ps ON Ps.pid = Ep.pid;
 ---Q2
SELECT R.restId,
    CONCAT(P.firstName, ' ' ,P.lastName) AS approver
FROM Reservation R 
LEFT JOIN Person P ON P.pid = R.approverPid;
---Q3
SELECT U1.serialNo,U2.serialNo
FROM EquipmentUnit AS U1
JOIN EquipmentUnit AS U2 ON U1.modelId = U2.modelId 
AND U1.labId != U2.labId AND U1.serialNo < U2.serialNo;
---Q4 
SELECT M.commercialName, COUNT(U.modelId) AS units
FROM EquipmentModel M
LEFT JOIN EquipmentUnit U ON U.modelId = M.modelId
GROUP BY M.modelId, M.commercialName;
---Q5
SELECT U.serialNo , U.purchaseCost
FROM Laboratory L 
JOIN EquimentUnit U ON L.labId = U.labId 
WHERE U.purchaseCost = (
    SELECT MAX(U2.purchaseCost)
    FROM EquipmentUnit U2
    WHERE U2.labId = L.labId
);
---Q6
SELECT S.labId, L.name, SUM(S.quantityOnHand) AS totalQty
FROM Stocks S 
JOIN Laboratory L ON L.labId = S.labId
GROUP BY S.labId, L.name
HAVING SUM(S.quantityOnHand) > (
    SELECT AVG(T.total)
    FROM (
        SELECT SUM(quantityOnHand) AS total
        from Stocks 
        GROUP BY labId
    ) AS T  
);
-- Q7
SELECT C.consId, C.name
FROM Consumable C
JOIN Stocks S ON S.consId = C.consId
GROUP BY C.consId, C.name
HAVING COUNT(DISTINCT S.labId) = (SELECT COUNT(*) FROM Laboratory);