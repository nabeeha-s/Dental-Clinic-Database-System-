-- DROP old objects (safe for re-run)
DROP TABLE BillItems CASCADE CONSTRAINTS;
DROP TABLE Bills CASCADE CONSTRAINTS;
DROP TABLE Prescription CASCADE CONSTRAINTS;
DROP TABLE Treatment CASCADE CONSTRAINTS;
DROP TABLE Appointment CASCADE CONSTRAINTS;
DROP TABLE PatientAllergy CASCADE CONSTRAINTS;
DROP TABLE Allergy CASCADE CONSTRAINTS;
DROP TABLE MedicalRecord CASCADE CONSTRAINTS;
DROP TABLE DentistSpecialization CASCADE CONSTRAINTS;
DROP TABLE InsuranceProvider CASCADE CONSTRAINTS;
DROP TABLE Patient CASCADE CONSTRAINTS;
DROP TABLE Dentist CASCADE CONSTRAINTS;
DROP TABLE Specialization CASCADE CONSTRAINTS;
DROP TABLE Staff CASCADE CONSTRAINTS;

-- Sequences (Oracle) for automatic PK generation
CREATE SEQUENCE seq_dentist START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_patient START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_staff START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_appointment START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_treatment START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_prescription START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_bill START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_billitem START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_specialization START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_insurance START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_allergy START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_medrec START WITH 1 INCREMENT BY 1 NOCACHE;

--------------------------------------------------------------------------------
-- Lookup tables and multi-valued attribute tables (normalize repeating attrs)
--------------------------------------------------------------------------------
CREATE TABLE Specialization (
  SpecializationID NUMBER PRIMARY KEY,
  Name VARCHAR2(50) UNIQUE NOT NULL
);

--  CREATE Dentist BEFORE DentistSpecialization
CREATE TABLE Dentist (
    DentistID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    CONSTRAINT uq_dentist_email UNIQUE (Email)
);

--  Now DentistSpecialization can reference Dentist
CREATE TABLE DentistSpecialization (
  DentistID NUMBER NOT NULL,
  SpecializationID NUMBER NOT NULL,
  PRIMARY KEY (DentistID, SpecializationID),
  FOREIGN KEY (DentistID) REFERENCES Dentist(DentistID) ON DELETE CASCADE,
  FOREIGN KEY (SpecializationID) REFERENCES Specialization(SpecializationID) ON DELETE CASCADE
);

CREATE TABLE InsuranceProvider (
  InsuranceID NUMBER PRIMARY KEY,
  Name VARCHAR2(100) UNIQUE NOT NULL
);

CREATE TABLE Allergy (
  AllergyID NUMBER PRIMARY KEY,
  Name VARCHAR2(100) UNIQUE NOT NULL
);

-- Rest of your tables in this order:
CREATE TABLE Staff (
    StaffID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    JobRole VARCHAR2(50) NOT NULL,
    CONSTRAINT uq_staff_email UNIQUE (Email)
);

CREATE TABLE Patient (
    PatientID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    DateOfBirth DATE,
    Address VARCHAR2(4000),
    InsuranceID NUMBER,
    CONSTRAINT uq_patient_email UNIQUE (Email),
    FOREIGN KEY (InsuranceID) REFERENCES InsuranceProvider(InsuranceID)
);

CREATE TABLE PatientAllergy (
  PatientID NUMBER NOT NULL,
  AllergyID NUMBER NOT NULL,
  PRIMARY KEY (PatientID, AllergyID),
  FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE,
  FOREIGN KEY (AllergyID) REFERENCES Allergy(AllergyID) ON DELETE CASCADE
);

CREATE TABLE MedicalRecord (
  MedicalRecordID NUMBER PRIMARY KEY,
  PatientID NUMBER NOT NULL,
  RecordDate DATE DEFAULT SYSDATE,
  ConditionTitle VARCHAR2(150),
  Details VARCHAR2(1000),
  FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE
);

CREATE TABLE Appointment (
    AppointmentID NUMBER PRIMARY KEY,
    PatientID NUMBER NOT NULL,
    DentistID NUMBER NOT NULL,
    AppointmentDateTime TIMESTAMP NOT NULL,
    Reason VARCHAR2(400),
    Status VARCHAR2(30) DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled','Completed','Cancelled','No-Show')),
    CreatedByStaffID NUMBER,
    CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DentistID) REFERENCES Dentist(DentistID),
    FOREIGN KEY (CreatedByStaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Treatment (
    TreatmentID NUMBER PRIMARY KEY,
    AppointmentID NUMBER NOT NULL,
    TreatmentType VARCHAR2(100) NOT NULL,
    TreatmentDescription VARCHAR2(1000),
    TreatmentCost NUMBER(10,2) NOT NULL CHECK (TreatmentCost >= 0),
    Notes VARCHAR2(1000),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE CASCADE
);

CREATE TABLE Prescription (
    PrescriptionID NUMBER PRIMARY KEY,
    AppointmentID NUMBER,
    MedicationName VARCHAR2(200) NOT NULL,
    Dosage VARCHAR2(100) NOT NULL,
    DateIssued DATE DEFAULT SYSDATE,
    Instructions VARCHAR2(1000),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE SET NULL
);

CREATE TABLE Bills (
    BillID NUMBER PRIMARY KEY,
    PatientID NUMBER NOT NULL,
    AppointmentID NUMBER,
    BillDate DATE DEFAULT SYSDATE,
    TotalAmount NUMBER(12,2) DEFAULT 0 CHECK (TotalAmount >= 0),
    AmountPaid NUMBER(12,2) DEFAULT 0 CHECK (AmountPaid >= 0),
    PaymentStatus VARCHAR2(20) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending','Partial','Paid','Overdue')),
    PaidDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

CREATE TABLE BillItems (
    BillItemID NUMBER PRIMARY KEY,
    BillID NUMBER NOT NULL,
    TreatmentID NUMBER,
    Description VARCHAR2(400),
    Amount NUMBER(12,2) NOT NULL CHECK (Amount >= 0),
    FOREIGN KEY (BillID) REFERENCES Bills(BillID) ON DELETE CASCADE,
    FOREIGN KEY (TreatmentID) REFERENCES Treatment(TreatmentID) ON DELETE SET NULL
);
--------------------------------------------------------------------------------
-- Sample lookup data (specializations, insurance, allergies)
--------------------------------------------------------------------------------
INSERT INTO Specialization (SpecializationID, Name) VALUES (seq_specialization.NEXTVAL, 'Orthodontist');
INSERT INTO Specialization (SpecializationID, Name) VALUES (seq_specialization.NEXTVAL, 'Endodontist');
INSERT INTO Specialization (SpecializationID, Name) VALUES (seq_specialization.NEXTVAL, 'Pediatric Dentist');

INSERT INTO InsuranceProvider (InsuranceID, Name) VALUES (seq_insurance.NEXTVAL, 'Blue Cross');
INSERT INTO InsuranceProvider (InsuranceID, Name) VALUES (seq_insurance.NEXTVAL, 'Green Shield');
INSERT INTO InsuranceProvider (InsuranceID, Name) VALUES (seq_insurance.NEXTVAL, 'Manulife');
INSERT INTO InsuranceProvider (InsuranceID, Name) VALUES (seq_insurance.NEXTVAL, 'Sun Life');

INSERT INTO Allergy (AllergyID, Name) VALUES (seq_allergy.NEXTVAL, 'Penicillin');
INSERT INTO Allergy (AllergyID, Name) VALUES (seq_allergy.NEXTVAL, 'Peanuts');

--------------------------------------------------------------------------------
-- Sample core data (dentists, staff, patients, appointments, treatments, prescriptions, bills)
-- NOTE: use sequences to populate PKs
--------------------------------------------------------------------------------
-- Dentists
INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email)
VALUES (seq_dentist.NEXTVAL, 'Daniela', 'Wytte', '111-111-1111', 'dani@example.com');

INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email)
VALUES (seq_dentist.NEXTVAL, 'Amir', 'Khan', '444-444-4444', 'amir.khan@example.com');

INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email)
VALUES (seq_dentist.NEXTVAL, 'Sophia', 'Nguyen', '555-555-5555', 'sophia.nguyen@example.com');

-- Assign specializations (many-to-many)
-- Note: we query IDs by name to be explicit.
INSERT INTO DentistSpecialization (DentistID, SpecializationID)
VALUES (1, (SELECT SpecializationID FROM Specialization WHERE Name = 'Orthodontist'));

INSERT INTO DentistSpecialization (DentistID, SpecializationID)
VALUES (2, (SELECT SpecializationID FROM Specialization WHERE Name = 'Endodontist'));

INSERT INTO DentistSpecialization (DentistID, SpecializationID)
VALUES (3, (SELECT SpecializationID FROM Specialization WHERE Name = 'Pediatric Dentist'));

-- Staff
INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (seq_staff.NEXTVAL, 'Sarah', 'Connor', '222-222-2222', 's.connor@clinic.com', 'Hygienist');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (seq_staff.NEXTVAL, 'Harry', 'Potter', '222-222-2222', 'h.potter@example.com', 'Receptionist');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (seq_staff.NEXTVAL, 'Luna', 'Lovegood', '666-666-6666', 'luna.l@example.com', 'Assistant');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (seq_staff.NEXTVAL, 'Ron', 'Weasley', '777-777-7777', 'ron.w@example.com', 'Manager');

-- Patients (attach insurance)
INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, InsuranceID)
VALUES (seq_patient.NEXTVAL, 'Jane', 'Smith', '111-111-1111', 'jane.smith@example.com', DATE '1990-05-15', '123 Jane St, Toronto, ON', (SELECT InsuranceID FROM InsuranceProvider WHERE Name = 'Blue Cross'));

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, InsuranceID)
VALUES (seq_patient.NEXTVAL, 'John', 'Doe', '333-333-3333', 'john.doe@example.com', DATE '1985-08-20', '456 Main St, Toronto, ON', (SELECT InsuranceID FROM InsuranceProvider WHERE Name = 'Green Shield'));

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, InsuranceID)
VALUES (seq_patient.NEXTVAL, 'Penelope', 'Smith', '333-333-3333', 'penelope.smith@example.com', DATE '1990-05-15', '123 Church St, Toronto, ON', (SELECT InsuranceID FROM InsuranceProvider WHERE Name = 'Red Cross' /* if missing, create or use any */));

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, InsuranceID)
VALUES (seq_patient.NEXTVAL, 'Mark', 'Davies', '888-888-8888', 'mark.d@example.com', DATE '1982-03-10', '456 King St, Toronto, ON', (SELECT InsuranceID FROM InsuranceProvider WHERE Name = 'Sun Life'));

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, InsuranceID)
VALUES (seq_patient.NEXTVAL, 'Aisha', 'Kaur', '999-999-9999', 'aisha.k@example.com', DATE '2000-07-19', '789 Queen St, Toronto, ON', (SELECT InsuranceID FROM InsuranceProvider WHERE Name = 'Manulife'));

-- Patient allergies via junction
INSERT INTO PatientAllergy (PatientID, AllergyID) VALUES (1, (SELECT AllergyID FROM Allergy WHERE Name = 'Penicillin'));
INSERT INTO PatientAllergy (PatientID, AllergyID) VALUES (5, (SELECT AllergyID FROM Allergy WHERE Name = 'Peanuts'));

-- Medical records example (normalized)
INSERT INTO MedicalRecord (MedicalRecordID, PatientID, RecordDate, ConditionTitle, Details)
VALUES (seq_medrec.NEXTVAL, 2, DATE '2020-06-01', 'Hypertension', 'Diagnosed, on medication');

INSERT INTO MedicalRecord (MedicalRecordID, PatientID, RecordDate, ConditionTitle, Details)
VALUES (seq_medrec.NEXTVAL, 5, DATE '2018-03-10', 'Asthma', 'Uses inhaler as needed');

-- Appointments (use TIMESTAMP)
INSERT INTO Appointment (AppointmentID, PatientID, DentistID, AppointmentDateTime, Reason, Status, CreatedByStaffID)
VALUES (seq_appointment.NEXTVAL, 1, 1, TO_TIMESTAMP('2024-09-25 09:00:00','YYYY-MM-DD HH24:MI:SS'), 'Routine Checkup', 'Completed', 2);

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, AppointmentDateTime, Reason, Status, CreatedByStaffID)
VALUES (seq_appointment.NEXTVAL, 2, 2, TO_TIMESTAMP('2024-10-02 10:30:00','YYYY-MM-DD HH24:MI:SS'), 'Tooth Extraction', 'Scheduled', 2);

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, AppointmentDateTime, Reason, Status, CreatedByStaffID)
VALUES (seq_appointment.NEXTVAL, 3, 3, TO_TIMESTAMP('2024-10-03 14:00:00','YYYY-MM-DD HH24:MI:SS'), 'Consultation', 'Cancelled', 2);

-- Treatments (refer to Appointment only)
INSERT INTO Treatment (TreatmentID, AppointmentID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (seq_treatment.NEXTVAL, 1, 'Cleaning', 'Routine dental cleaning and polish', 150.00, 'No issues found');

INSERT INTO Treatment (TreatmentID, AppointmentID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (seq_treatment.NEXTVAL, 2, 'Extraction', 'Wisdom tooth removal', 300.00, 'Prescribed pain medication');

INSERT INTO Treatment (TreatmentID, AppointmentID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (seq_treatment.NEXTVAL, 3, 'Consultation', 'Initial dental examination', 75.00, 'Recommended cleaning');

-- Prescriptions (linked to appointment)
INSERT INTO Prescription (PrescriptionID, AppointmentID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (seq_prescription.NEXTVAL, 1, 'Amoxicillin', '500mg', DATE '2024-09-25', 'Take twice daily for 7 days');

INSERT INTO Prescription (PrescriptionID, AppointmentID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (seq_prescription.NEXTVAL, 2, 'Ibuprofen', '400mg', DATE '2024-10-02', 'Take as needed for pain');

-- Bills and bill items (one bill aggregates line items)
INSERT INTO Bills (BillID, PatientID, AppointmentID, BillDate, TotalAmount, AmountPaid, PaymentStatus, PaidDate)
VALUES (seq_bill.NEXTVAL, 1, 1, DATE '2024-09-25', 150.00, 150.00, 'Paid', DATE '2024-09-25');

-- create bill items tying treatment to bill
INSERT INTO BillItems (BillItemID, BillID, TreatmentID, Description, Amount)
VALUES (seq_billitem.NEXTVAL, 1, 1, 'Cleaning fee', 150.00);

INSERT INTO Bills (BillID, PatientID, AppointmentID, BillDate, TotalAmount, AmountPaid, PaymentStatus)
VALUES (seq_bill.NEXTVAL, 2, 2, DATE '2024-10-02', 300.00, 150.00, 'Partial');

INSERT INTO BillItems (BillItemID, BillID, TreatmentID, Description, Amount)
VALUES (seq_billitem.NEXTVAL, 2, 2, 'Extraction fee', 300.00);

--------------------------------------------------------------------------------
-- Views (updated to work with normalized schema)
--------------------------------------------------------------------------------
-- Appointment overview with readable dentist/patient names and specialization(s)
CREATE OR REPLACE VIEW vw_appointment_overview AS
SELECT
  a.AppointmentID,
  a.AppointmentDateTime,
  a.Status,
  a.Reason,
  p.PatientID,
  (p.FirstName || ' ' || p.LastName) AS PatientName,
  d.DentistID,
  (d.FirstName || ' ' || d.LastName) AS DentistName,
  LISTAGG(s.Name, ', ') WITHIN GROUP (ORDER BY s.Name) AS Specializations
FROM Appointment a
JOIN Patient p ON p.PatientID = a.PatientID
JOIN Dentist d ON d.DentistID = a.DentistID
LEFT JOIN DentistSpecialization ds ON ds.DentistID = d.DentistID
LEFT JOIN Specialization s ON s.SpecializationID = ds.SpecializationID
GROUP BY a.AppointmentID, a.AppointmentDateTime, a.Status, a.Reason, p.PatientID, p.FirstName, p.LastName, d.DentistID, d.FirstName, d.LastName;

-- Patient balance view that sums bill amounts and payments
CREATE OR REPLACE VIEW vw_patient_balance AS 
SELECT
  p.PatientID,
  (p.FirstName || ' ' || p.LastName) AS PatientName,
  NVL(SUM(b.TotalAmount), 0) AS TotalAmountBilled,
  NVL(SUM(b.AmountPaid), 0) AS TotalAmountPaid,
  NVL(SUM(b.TotalAmount - b.AmountPaid), 0) AS OutstandingBalance
FROM Patient p
LEFT JOIN Bills b ON p.PatientID = b.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName;

-- Dentist summary: total appointments and revenue collected
CREATE OR REPLACE VIEW vw_dentist_summary AS
SELECT
  d.DentistID,
  (d.FirstName || ' ' || d.LastName) AS DentistName,
  LISTAGG(s.Name, ', ') WITHIN GROUP (ORDER BY s.Name) AS Specializations,
  NVL((SELECT COUNT(*) FROM Appointment a WHERE a.DentistID = d.DentistID), 0) AS TotalAppointments,
  NVL((SELECT SUM(b.AmountPaid)
       FROM Appointment a
       LEFT JOIN Bills b ON b.AppointmentID = a.AppointmentID
       WHERE a.DentistID = d.DentistID), 0) AS TotalCollected
FROM Dentist d
LEFT JOIN DentistSpecialization ds ON ds.DentistID = d.DentistID
LEFT JOIN Specialization s ON s.SpecializationID = ds.SpecializationID
GROUP BY d.DentistID, d.FirstName, d.LastName;

--------------------------------------------------------------------------------
-- Example advanced report queries (short notes)
--------------------------------------------------------------------------------
-- 1) Appointments scheduled soon (use TIMESTAMP arithmetic)
-- Special case: consider clinic timezone when comparing TIMESTAMPs
SELECT AppointmentID, AppointmentDateTime, PatientID, DentistID, Reason, Status
FROM Appointment
WHERE Status = 'Scheduled' AND AppointmentDateTime > SYSTIMESTAMP
ORDER BY AppointmentDateTime;

-- 2) Revenue by dentist (actual collected)
SELECT DentistID, DentistName, TotalCollected
FROM vw_dentist_summary
ORDER BY TotalCollected DESC;

-- 3) Patients owing money (from view)
SELECT PatientID, PatientName, OutstandingBalance
FROM vw_patient_balance
WHERE OutstandingBalance > 0
ORDER BY OutstandingBalance DESC;

-- 4) Most common treatments (counts)
SELECT TreatmentType, COUNT(*) AS NumberOfTreatments, ROUND(AVG(TreatmentCost),2) AS AvgCost
FROM Treatment
GROUP BY TreatmentType
ORDER BY NumberOfTreatments DESC;

-- 5) Flexible report: bill aging (days since bill)
SELECT b.BillID, b.PatientID, (SYSDATE - b.BillDate) AS DaysSinceBill, b.TotalAmount, b.AmountPaid, b.PaymentStatus
FROM Bills b
ORDER BY DaysSinceBill DESC;

--------------------------------------------------------------------------------
-- normalization / special cases
--------------------------------------------------------------------------------
-- 1) Multi-valued attributes (Allergies, Specializations, MedicalHistory) were moved
--    into separate tables (PatientAllergy, DentistSpecialization, MedicalRecord) to
--    satisfy 3NF and avoid repeating groups or comma-separated fields.
--
-- 2) Treatment no longer stores PatientID or DentistID directly; those are
--    inferred via the Appointment referenced by Treatment.AppointmentID — this
--    avoids update anomalies (BCNF/3NF).
--
-- 3) Bills are separated into Bills (header) + BillItems (lines) so multiple
--    treatments/fees can be billed on a single invoice; BillItems link to Treatment.
--
-- 4) AppointmentDateTime uses TIMESTAMP to make sorting, range queries, and
--    time arithmetic straightforward and atomic.
--
-- 5) Advanced reports: aggregation queries should use the normalized joins above.
--    Consider materialized views or pre-aggregated summary tables for very large data
--    (e.g., vw_dentist_summary could be materialized for performance).

-- SELECT * queries
SELECT * FROM Specialization ORDER BY SpecializationID;
SELECT * FROM InsuranceProvider ORDER BY InsuranceID;
SELECT * FROM Allergy ORDER BY AllergyID;

SELECT * FROM Dentist ORDER BY DentistID;
SELECT * FROM Staff ORDER BY StaffID;
SELECT * FROM Patient ORDER BY PatientID;

SELECT * FROM vw_patient_balance ORDER BY OutstandingBalance DESC;
