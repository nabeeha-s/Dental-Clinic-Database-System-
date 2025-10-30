DROP TABLE Bills CASCADE CONSTRAINTS;
DROP TABLE Treatment CASCADE CONSTRAINTS;
DROP TABLE Prescription CASCADE CONSTRAINTS;
DROP TABLE Appointment CASCADE CONSTRAINTS;
DROP TABLE Dentist CASCADE CONSTRAINTS;
DROP TABLE Patient CASCADE CONSTRAINTS;
DROP TABLE Staff CASCADE CONSTRAINTS;

CREATE TABLE Dentist (
    DentistID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(12) NOT NULL,
    Email VARCHAR2(100) NOT NULL,
    Specialization VARCHAR2(25) NOT NULL
);

CREATE TABLE Patient (
    PatientID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(15) NOT NULL,
    Email VARCHAR2(100),
    DateOfBirth DATE,
    Address VARCHAR2(255),
    MedicalHistory VARCHAR2(255) NOT NULL,
    InsuranceProvider VARCHAR2(100),
    Allergies VARCHAR2(255)
);

CREATE TABLE Staff (
    StaffID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(12) NOT NULL,
    Email VARCHAR2(100) NOT NULL,
    JobRole VARCHAR2(25) NOT NULL
);

CREATE TABLE Appointment (
    AppointmentID NUMBER PRIMARY KEY,
    PatientID NUMBER,
    DentistID NUMBER,
    Appointment_Time VARCHAR2(5) NOT NULL,
    Appointment_Date DATE,
    Reason VARCHAR2(255),
    Status VARCHAR2(20) DEFAULT 'Scheduled',
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DentistID) REFERENCES Dentist(DentistID)
);

CREATE TABLE Treatment (
    TreatmentNum NUMBER PRIMARY KEY,
    AppointmentID NUMBER,
    PatientID NUMBER,
    DentistID NUMBER, 
    TreatmentType VARCHAR2(25) NOT NULL,
    TreatmentDescription VARCHAR2(255),
    TreatmentCost NUMBER(10,2) NOT NULL,
    Notes VARCHAR2(255),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DentistID) REFERENCES Dentist(DentistID)
);

CREATE TABLE Prescription (
    PrescriptionNum NUMBER PRIMARY KEY,
    PatientID NUMBER,
    DentistID NUMBER, 
    MedicationName VARCHAR2(100) NOT NULL,
    Dosage VARCHAR2(100) NOT NULL,
    DateIssued DATE,
    Instructions VARCHAR2(255),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DentistID) REFERENCES Dentist(DentistID)
);

CREATE TABLE Bills (
    BillID NUMBER PRIMARY KEY,
    PatientID NUMBER,
    AppointmentID NUMBER,
    AmountDue NUMBER(10,2),
    AmountPaid NUMBER(10,2) DEFAULT 0,
    PaymentStatus VARCHAR2(20) DEFAULT 'Pending',
    PaidDate DATE, 
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

-- example data using separate INSERT statements for each row
INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email, Specialization)
VALUES (1, 'Daniela', 'Wytte', '111-111-1111', 'dani@example.com', 'Orthodontist');

INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email, Specialization)
VALUES (2, 'Amir', 'Khan', '444-444-4444', 'amir.khan@example.com', 'Endodontist');

INSERT INTO Dentist (DentistID, FirstName, LastName, Phone, Email, Specialization)
VALUES (3, 'Sophia', 'Nguyen', '555-555-5555', 'sophia.nguyen@example.com', 'Pediatric Dentist');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (1, 'Sarah', 'Connor', '222-222-2222', 's.connor@clinic.com', 'Hygienist');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (2, 'Harry', 'Potter', '222-222-2222', 'h.potter@example.com', 'Receptionist');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (3, 'Luna', 'Lovegood', '666-666-6666', 'luna.l@example.com', 'Assistant');

INSERT INTO Staff (StaffID, FirstName, LastName, Phone, Email, JobRole)
VALUES (4, 'Ron', 'Weasley', '777-777-7777', 'ron.w@example.com', 'Manager');

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, MedicalHistory, InsuranceProvider, Allergies)
VALUES (1, 'Jane', 'Smith', '111-111-1111', 'jane.smith@example.com', DATE '1990-05-15', '123 Jane St, Toronto, ON', 'None', 'Blue Cross', 'Penicillin');

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, MedicalHistory, InsuranceProvider, Allergies)
VALUES (2, 'John', 'Doe', '333-333-3333', 'john.doe@example.com', DATE '1985-08-20', '456 Main St, Toronto, ON', 'Hypertension', 'Green Shield', 'None');

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, MedicalHistory, InsuranceProvider, Allergies)
VALUES (3, 'Penelope', 'Smith', '333-333-3333', 'penelope.smith@example.com', DATE '1990-05-15', '123 Church St, Toronto, ON', 'None', 'Red Cross', 'Penicillin');

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, MedicalHistory, InsuranceProvider, Allergies)
VALUES (4, 'Mark', 'Davies', '888-888-8888', 'mark.d@example.com', DATE '1982-03-10', '456 King St, Toronto, ON', 'Diabetes', 'Sun Life', 'None');

INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email, DateOfBirth, Address, MedicalHistory, InsuranceProvider, Allergies)
VALUES (5, 'Aisha', 'Kaur', '999-999-9999', 'aisha.k@example.com', DATE '2000-07-19', '789 Queen St, Toronto, ON', 'Asthma', 'Manulife', 'Peanuts');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (1, 1, 1, '9:00', DATE '2024-09-25', 'Routine Checkup', 'Completed');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (2, 2, 2, '10:30', DATE '2024-10-02', 'Tooth Extraction', 'Scheduled');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (3, 3, 3, '14:00', DATE '2024-10-03', 'Consultation', 'Cancelled');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (4, 3, 1, '9:00', DATE '2025-09-25', 'Routine Checkup', 'Completed');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (5, 4, 2, '11:30', DATE '2025-10-01', 'Root Canal', 'Scheduled');

INSERT INTO Appointment (AppointmentID, PatientID, DentistID, Appointment_Time, Appointment_Date, Reason, Status)
VALUES (6, 5, 3, '15:00', DATE '2025-10-05', 'Cavity Filling', 'Cancelled');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (1, 1, 1, 1, 'Cleaning', 'Routine dental cleaning and polish', 150.00, 'No issues found');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (2, 2, 2, 2, 'Extraction', 'Wisdom tooth removal', 300.00, 'Prescribed pain medication');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (3, 3, 3, 3, 'Consultation', 'Initial dental examination', 75.00, 'Recommended cleaning');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (4, 4, 3, 1, 'Cleaning', 'Routine dental cleaning and polish', 150.00, 'No issues found');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (5, 5, 4, 2, 'Root Canal', 'Treatment for infected tooth pulp', 900.00, 'Follow-up in 2 weeks');

INSERT INTO Treatment (TreatmentNum, AppointmentID, PatientID, DentistID, TreatmentType, TreatmentDescription, TreatmentCost, Notes)
VALUES (6, 6, 5, 3, 'Filling', 'Composite resin filling applied', 200.00, 'Patient advised to avoid sweets');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (1, 1, 1, 'Amoxicillin', '500mg', DATE '2024-09-25', 'Take twice daily for 7 days');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (2, 2, 2, 'Ibuprofen', '400mg', DATE '2024-10-02', 'Take as needed for pain');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (3, 3, 3, 'Paracetamol', '500mg', DATE '2024-10-03', 'Take every 6 hours if needed');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (4, 3, 1, 'Amoxicillin', '500mg', DATE '2025-09-25', 'Take twice daily for 7 days');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (5, 4, 2, 'Ibuprofen', '400mg', DATE '2025-10-01', 'Take as needed for pain');

INSERT INTO Prescription (PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued, Instructions)
VALUES (6, 5, 3, 'Paracetamol', '500mg', DATE '2025-10-05', 'Take every 6 hours if needed');

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (1, 1, 1, 150.00, 150.00, 'Paid', DATE '2024-09-25');

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (2, 2, 2, 300.00, 150.00, 'Partial', DATE '2024-10-02');

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (3, 3, 3, 75.00, 0.00, 'Pending', NULL);

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (4, 3, 4, 150.00, 150.00, 'Paid', DATE '2025-09-25');

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (5, 4, 5, 900.00, 0.00, 'Pending', NULL);

INSERT INTO Bills (BillID, PatientID, AppointmentID, AmountDue, AmountPaid, PaymentStatus, PaidDate)
VALUES (6, 5, 6, 200.00, 200.00, 'Paid', DATE '2025-10-05');

SELECT * FROM Dentist;
SELECT * FROM Staff;
SELECT * FROM Patient;
SELECT * FROM Appointment;
SELECT * FROM Treatment;
SELECT * FROM Prescription;
SELECT * FROM Bills;

-- 1. Dentist: Show all dentists sorted by specialization and last name
SELECT DentistID, FirstName, LastName, Specialization, Email
FROM Dentist
ORDER BY Specialization, LastName;

-- 2. Patient: Count patients by insurance provider using GROUP BY
SELECT InsuranceProvider, COUNT(*) as NumberOfPatients
FROM Patient
GROUP BY InsuranceProvider
ORDER BY NumberOfPatients DESC;

-- 3. Staff: Show distinct staff JobRoles available in the clinic
SELECT DISTINCT JobRole
FROM Staff
ORDER BY JobRole;

-- 4. Appointment: Find scheduled appointments ordered by date and time
SELECT AppointmentID, PatientID, DentistID, Appointment_Date, Appointment_Time, Reason
FROM Appointment
WHERE Status = 'Scheduled'
ORDER BY Appointment_Date, Appointment_Time;

-- 5. Treatment: Calculate average TreatmentCost by treatment TreatmentType using GROUP BY
SELECT TreatmentType, ROUND(AVG(TreatmentCost), 2) as AverageTreatmentCost, COUNT(*) as NumberOfTreatments
FROM Treatment
GROUP BY TreatmentType
ORDER BY AverageTreatmentCost DESC;

-- 6. Prescription: Show prescriptions ordered by most recent date
SELECT PrescriptionNum, PatientID, DentistID, MedicationName, Dosage, DateIssued
FROM Prescription
ORDER BY DateIssued DESC;

-- 7. Bills: Group bills by payment status and show summary statistics
SELECT PaymentStatus, COUNT(*) as NumberOfBills, SUM(AmountDue) as TotalAmountDue
FROM Bills
GROUP BY PaymentStatus
ORDER BY NumberOfBills DESC;

-- 8. Patient: Find patients with specific allergies using WHERE clause
SELECT PatientID, FirstName, LastName, Allergies, MedicalHistory
FROM Patient
WHERE Allergies IS NOT NULL AND Allergies != 'None'
ORDER BY LastName, FirstName;
--Part 2
-- View 1: appointent overview
CREATE OR REPLACE VIEW vw_appointment_overview AS
SELECT
  a.AppointmentID,
  a.Appointment_Date,
  a.Appointment_Time,
  a.Status,
  a.Reason,
  p.PatientID,
  (p.FirstName || ' ' || p.LastName) AS PatientName,
  d.DentistID,
  (d.FirstName || ' ' || d.LastName) AS DentistName
FROM 
Appointment a
JOIN Patient p ON p.PatientID = a.PatientID
JOIN Dentist d ON d.DentistID = a.DentistID;

--View 2: show vw__patient_balance
CREATE OR REPLACE VIEW vw_patient_balance AS 
SELECT
  p.PatientID,
  (p.FirstName || ' ' || p.LastName) AS PatientName,
 NVL(SUM(b.AmountDue), 0) AS TotalAmountDue,
    NVL(SUM(b.AmountPaid), 0) AS TotalAmountPaid,
    NVL(SUM(b.AmountDue - b.AmountPaid), 0) AS OutstandingBalance
    FROM
 Patient p
 LEFT JOIN Bills b ON p.PatientID = b.PatientID
GROUP BY 
    p.PatientID, p.FirstName, p.LastName;

--View 3: vw_dentist_summary
CREATE OR REPLACE VIEW vw_dentist_summary AS
SELECT
  d.DentistID,
  (d.FirstName || ' ' || d.LastName) AS DentistName,
  d.Specialization,
  NVL((SELECT COUNT(*) FROM Appointment a WHERE a.DentistID = d.DentistID), 0) AS TotalAppointments,
  NVL((SELECT SUM(b.AmountPaid)
       FROM Appointment a
       LEFT JOIN Bills b ON b.AppointmentID = a.AppointmentID
       WHERE a.DentistID = d.DentistID), 0) AS TotalCollected
FROM 
Dentist d;

--Queries
--1.Show all the appointments with dentist and patient names
SELECT
  AppointmentID,
  TO_CHAR(Appointment_Date, 'YYYY-MM-DD') AS ApptDate,
  Appointment_Time,
  PatientName,
  DentistName,
  Status
FROM
   vw_appointment_overview
ORDER BY
   Appointment_Date, Appointment_Time;

--2.Total money earned by each dentist
SELECT
  DentistID,
  DentistName,
  Specialization,
  TotalAppointments,
  TotalCollected
FROM 
   vw_dentist_summary
ORDER BY 
    TotalCollected DESC;

--3.Patients who still own money
SELECT
  PatientID,
  PatientName,
  OutstandingBalance
FROM vw_patient_balance
WHERE OutstandingBalance > 0
ORDER BY OutstandingBalance DESC, PatientName;

--4.Most common treatment
SELECT 
    TreatmentType, 
    COUNT(*) AS NumberOfTreatments
FROM 
    Treatment
GROUP BY 
    TreatmentType
HAVING 
    COUNT(*) >= 1
ORDER BY 
    NumberOfTreatments DESC, TreatmentType;

--5.Display unique dentist specializations 
SELECT DISTINCT 
    Specialization
FROM 
    Dentist
ORDER BY 
    Specialization;

--6.Three tables joined
SELECT
  a.AppointmentID,
  TO_CHAR(a.Appointment_Date, 'YYYY-MM-DD') AS ApptDate,
  a.Appointment_Time,
  (d.FirstName || ' ' || d.LastName) AS DentistName,
  d.Specialization,
  NVL(b.AmountDue, 0) - NVL(b.AmountPaid, 0) AS Balance
FROM 
     Appointment a
      JOIN Dentist d ON d.DentistID = a.DentistID
      LEFT JOIN Bills b ON b.AppointmentID = a.AppointmentID
ORDER BY 
   a.Appointment_Date, a.Appointment_Time;
