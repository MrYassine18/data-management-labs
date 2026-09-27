CREATE DATABASE RLMS;
USE RLMS;


-- ENTITIES
CREATE TABLE Person(
    pid INT,
    firstName VARCHAR(20),
    lastName VARCHAR(20),
    email VARCHAR(30),
    affiliation VARCHAR(20),
    startDate DATE,
    endDate DATE,
    PRIMARY KEY(pid)
);

-- ISA TABLE and recursive relation
CREATE TABLE Employee(
    employee_id INT,
    phone VARCHAR(20),
    office VARCHAR(20),
    supervisor_id INT,
    PRIMARY KEY(employee_id),
    Foreign Key (supervisor_id) REFERENCES Employee(employee_id)
    ON DELETE NO ACTION,
    Foreign Key (employee_id) REFERENCES Person (pid) ON DELETE CASCADE
);
-- Employee ISA 
CREATE TABLE academic(
    academic_id INT PRIMARY KEY,
    Foreign Key (academic_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);
--ISA OF ACADEMIC 
CREATE TABLE faculty(
    fac_id INT PRIMARY KEY,
    -- no sure if I have to add position attribute (following the lab1 solution)
    position VARCHAR(50),
    Foreign Key (fac_id) REFERENCES academic(academic_id) ON DELETE CASCADE
);
CREATE TABLE non_academic(
    nonAcad_id INT PRIMARY KEY,
    Foreign Key (nonAcad_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);
-- ISA OF NON-ACADEMIC
CREATE TABLE Administrative (
    admin_id INT PRIMARY KEY,
    position VARCHAR(50),
    FOREIGN KEY (admin_id) REFERENCES Employee(nonAcad_id) ON DELETE CASCADE
);

CREATE TABLE Technical (
    technical_id INT PRIMARY KEY,
    position VARCHAR(50),
    FOREIGN KEY (technical_id) REFERENCES Employee(nonAcad_id) ON DELETE CASCADE
);
--STUDENT TABLE (ISA-PERSON) 
CREATE Table Student(
    student_id INT,
    program VARCHAR(50),
    academic_advice_id INT,
    PRIMARY KEY  (student_id), 
    Foreign Key  (student_id) REFERENCES Person (pid) ON DELETE CASCADE,
    Foreign Key (academic_advice_id) REFERENCES academic(academic_id) ON DELETE NO ACTION
);

-- RELATIONS
-- Laboratory.
-- The supervisor is a Faculty member
CREATE TABLE Laboratory(
    labId INT,
    name VARCHAR(20),
    building VARCHAR(50),
    roomNumber INT,
    discipline VARCHAR(20),
    supervises_id INT,
    PRIMARY KEY(labId),
    Foreign Key (supervises_id) REFERENCES faculty(fac_id) ON DELETE NO ACTION
    
); 

CREATE TABLE Advices (
    academic_id INT,
    student_id INT,
    PRIMARY KEY (academic_id, student_id),
    FOREIGN KEY (academic_id)
        REFERENCES Academic(academic_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id)
        REFERENCES Student(student_id) ON DELETE CASCADE
);
-- ATTACHED RELATION 
CREATE TABLE Attached(
    labid INT,
    person_id INT,
    PRIMARY KEY (labid, person_id),
    Foreign Key (labid) REFERENCES laboratory(labId) ON DELETE CASCADE,
    Foreign Key (person_id) REFERENCES Person(pid) ON DELETE CASCADE

);



-- EQ1, EQ2
CREATE TABLE EquipmentModel
(
  modelId INT,
  commercialName VARCHAR(100),
  manufacturer VARCHAR(100),
  category VARCHAR(50),
  requiredEnvironment VARCHAR(100),
  trainingMandatory INT,   
  PRIMARY KEY (modelId)
);

-- EQ3-EQ6
-- InstanceOf and LocatedIn are 1-M with total participation
-- so we merged them here (modelId, labId NOT NULL)
-- labId = current lab only, no history (EQ4)
CREATE TABLE EquipmentUnit
(
  serialNo VARCHAR(50),
  acquisitionDate DATE,
  purchaseCost FLOAT,
  status VARCHAR(20),
  portable INT,            
  instance_of INT NOT NULL,
  locatedIn INT NOT NULL,
  PRIMARY KEY (serialNo),
  FOREIGN KEY (instance_of) REFERENCES EquipmentModel(modelId)
  ON DELETE NO ACTION,
  FOREIGN KEY (locatedIN) REFERENCES Laboratory(labId)
  ON DELETE NO ACTION
);

-- CE2
CREATE TABLE Certification
(
  code VARCHAR(20),
  title VARCHAR(150),
  issuingAuthority VARCHAR(100),
  validityPeriod INT,      
  safetyLevel INT,
  PRIMARY KEY (code)
);

-- CE3-CE5 (M-M)
-- key (pid, code) -> only the latest award is kept
CREATE TABLE Holds
(
  pid INT,
  code VARCHAR(20),
  issueDate DATE,
  expirationDate DATE,
  grade VARCHAR(20),
  PRIMARY KEY (pid, code),
  FOREIGN KEY (pid) REFERENCES Person(pid),
  FOREIGN KEY (code) REFERENCES Certification(code)
);

-- CE1, CE6 (M-M)
CREATE TABLE Requires
(
  modelId INT,
  code VARCHAR(20),
  PRIMARY KEY (modelId, code),
  FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId),
  FOREIGN KEY (code) REFERENCES Certification(code)
);

-- MA1-MA3
-- weak entity (owner EquipmentUnit), DoneBy merged as doneBy
CREATE TABLE Maintenance
(
  serialNo VARCHAR(50) NOT NULL,
  startTS DATE NOT NULL,
  endTS DATE,
  type VARCHAR(20),
  description VARCHAR(500),
  cost FLOAT,
  outcome VARCHAR(20),
  doneBy INT NOT NULL,
  PRIMARY KEY (serialNo, startTS),
  FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo)
  ON DELETE CASCADE,
  FOREIGN KEY (doneBy) REFERENCES Technical(technical_id)  
  ON DELETE NO ACTION
);

-- CA1-CA4
-- weak entity (owner EquipmentUnit), no performer stored
CREATE TABLE CalibrationRecord
(
  serialNo VARCHAR(50) NOT NULL,
  calibDate DATE NOT NULL,
  calibrationType VARCHAR(50),
  result VARCHAR(20),
  nextDueDate DATE,
  remarks VARCHAR(500),
  PRIMARY KEY (serialNo, calibDate),
  FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo)
  ON DELETE CASCADE
);


CREATE TABLE ResearchProject (
    code_ VARCHAR(20) PRIMARY KEY NOT NULL,
    title varchar(20),
    strat_date DATE,
    end_date DATE,
    statut VARCHAR(20)
);

CREATE TABLE Participates (
    pid INT NOT NULL,
    code_ VARCHAR(20) NOT NULL,
    role_ VARCHAR(20),
    PRIMARY KEY (pid, code_),                       
    FOREIGN KEY (pid) REFERENCES Person(pid),
    FOREIGN KEY (code_) REFERENCES ResearchProject(code_)
);

/*
A budget is managed by exactly one academic employee, so we will add to each budget the id of its manager
*/
CREATE TABLE Budget_manages (
    budgetLine VARCHAR(20) PRIMARY KEY NOT NULL,
    amount_granted FLOAT NOT NULL,
    amount_disbused FLOAT NOT NULL,
    start_date DATE,
    end_date DATE,
    manager_academic_id INT NOT NULL,               
    FOREIGN KEY (manager_academic_id) REFERENCES academic(academic_id)
    ON DELETE NO ACTION
);

CREATE TABLE FundsPrj (
    budgetLine VARCHAR(20),
    code_ VARCHAR(20),
    PRIMARY KEY (budgetLine, code_),                
    FOREIGN KEY (budgetLine) REFERENCES Budget_manages(budgetLine),
    FOREIGN KEY (code_) REFERENCES ResearchProject(code_)
);

CREATE TABLE FundsLab (
    budgetLine VARCHAR(20),
    labId INT,
    PRIMARY KEY (budgetLine, labId),                
    FOREIGN KEY (budgetLine) REFERENCES Budget_manages(budgetLine),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);

-- Reservation is a strong entity (resId alone identifies it); MadeBy and For
-- are many-to-one relationships from Reservation and are modeled as plain FKs.
CREATE TABLE Reservation (
    resId INT NOT NULL,
    sub_timestamp DATE,
    start_time DATE,
    end_time DATE,
    purpose VARCHAR(100),
    status_ VARCHAR(50),
    made_by_pid INT NOT NULL,                       
    for_project_code VARCHAR(20) NOT NULL,
    approver INT,
    PRIMARY KEY (resId),                           
    FOREIGN KEY (made_by_pid) REFERENCES Person(pid),
    FOREIGN KEY (for_project_code) REFERENCES ResearchProject(code_),
    FOREIGN KEY (approver) REFERENCES Person(pid)
);

CREATE TABLE Reserves (
    resId INT NOT NULL,
    serialNo VARCHAR(50) NOT NULL,                  
    PRIMARY KEY (resId, serialNo),                  
    FOREIGN KEY (resId) REFERENCES Reservation(resId),
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo)  
    ON DELETE NO ACTION
);


--Consumable entity
CREATE TABLE Consumable (
    consId INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unitOfMeasure VARCHAR(50),
    hazardLevel VARCHAR(50),
    reorderThreshold INT
);

--Supplier
CREATE TABLE Supplier (
    suppId INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contactEmail VARCHAR(100),
    phone VARCHAR(20)
);

--Stocks relation & Monitors aggregation
CREATE TABLE Stocks (
    labId INT,
    consId INT,
    quantityOnHand INT,
    lastRestockDate DATE,
    storageCondition VARCHAR(100),
    Monitor_id INT NOT NULL,                           
    monitoringSince DATE,
    PRIMARY KEY (labId, consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (Monitor_id) REFERENCES Technical(technical_id)  
);

--Supplies ternary relationship
CREATE TABLE Supplies (
    suppId INT,
    consId INT,
    labId INT,
    unitPrice FLOAT,
    PRIMARY KEY (suppId, consId, labId),
    FOREIGN KEY (suppId) REFERENCES Supplier(suppId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);

CREATE TABLE Consumes (
    resId INT,
    consId INT,
    quantityUsed INT,
    PRIMARY KEY (resId, consId),
    FOREIGN KEY (resId) REFERENCES Reservation(resId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId)
);

