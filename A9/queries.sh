#!/bin/sh
#export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib

sqlplus64 "nsaniyat/05163393@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle12c.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl12c)))" <<EOF

SET PAGESIZE 100
SET LINESIZE 200

-- =============================================
-- BASIC TABLE QUERIES
-- =============================================

SELECT * FROM Dentist d 
LEFT JOIN DentistSpecialization ds ON d.DentistID = ds.DentistID 
LEFT JOIN Specialization s ON ds.SpecializationID = s.SpecializationID;

SELECT * FROM Staff;

SELECT * FROM Patient p 
LEFT JOIN InsuranceProvider ip ON p.InsuranceID = ip.InsuranceID;

SELECT * FROM Appointment;

SELECT * FROM Treatment t 
JOIN Appointment a ON t.AppointmentID = a.AppointmentID;

SELECT * FROM Prescription p 
JOIN Appointment a ON p.AppointmentID = a.AppointmentID;

SELECT * FROM Bills;

SELECT * FROM BillItems;

-- =============================================
-- UPDATED SELECT QUERIES
-- =============================================

-- 1. Dentist: Show all dentists sorted by specialization and last name
SELECT d.DentistID, d.FirstName, d.LastName, 
       LISTAGG(s.Name, ', ') WITHIN GROUP (ORDER BY s.Name) as Specializations,
       d.Email
FROM Dentist d
LEFT JOIN DentistSpecialization ds ON d.DentistID = ds.DentistID
LEFT JOIN Specialization s ON ds.SpecializationID = s.SpecializationID
GROUP BY d.DentistID, d.FirstName, d.LastName, d.Email
ORDER BY Specializations, d.LastName;

-- 2. Patient: Count patients by insurance provider using GROUP BY
SELECT ip.Name as ProviderName, COUNT(*) as NumberOfPatients
FROM Patient p
JOIN InsuranceProvider ip ON p.InsuranceID = ip.InsuranceID
GROUP BY ip.Name
ORDER BY NumberOfPatients DESC;

-- 3. Staff: Show distinct staff JobRoles available in the clinic
SELECT DISTINCT JobRole
FROM Staff
ORDER BY JobRole;

-- 4. Appointment: Find scheduled appointments ordered by date and time
SELECT a.AppointmentID, p.PatientID, d.DentistID, 
       TO_CHAR(a.AppointmentDateTime, 'YYYY-MM-DD HH24:MI') as AppointmentDateTime,
       a.Reason, a.Status
FROM Appointment a
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Dentist d ON a.DentistID = d.DentistID
WHERE a.Status = 'Scheduled'
ORDER BY a.AppointmentDateTime;

-- 5. Treatment: Calculate average TreatmentCost by treatment Type using GROUP BY
SELECT t.TreatmentType, 
       ROUND(AVG(t.TreatmentCost), 2) as AverageTreatmentCost, 
       COUNT(*) as NumberOfTreatments
FROM Treatment t
GROUP BY t.TreatmentType
ORDER BY AverageTreatmentCost DESC;

-- 6. Prescription: Show prescriptions ordered by most recent date
SELECT p.PrescriptionID, 
       pat.FirstName || ' ' || pat.LastName as PatientName, 
       d.FirstName || ' ' || d.LastName as DentistName, 
       p.MedicationName, p.Dosage, p.DateIssued
FROM Prescription p
JOIN Appointment a ON p.AppointmentID = a.AppointmentID
JOIN Patient pat ON a.PatientID = pat.PatientID
JOIN Dentist d ON a.DentistID = d.DentistID
ORDER BY p.DateIssued DESC;

-- 7. Bills: Group bills by payment status and show summary statistics
SELECT 
    b.PaymentStatus,
    COUNT(*) as NumberOfBills,
    SUM(b.TotalAmount) as TotalAmountDue,
    SUM(b.AmountPaid) as TotalAmountPaid,
    SUM(b.TotalAmount - b.AmountPaid) as OutstandingBalance
FROM Bills b
GROUP BY b.PaymentStatus
ORDER BY NumberOfBills DESC;

-- 8. Patient: Find patients with specific allergies using WHERE clause
SELECT p.PatientID, p.FirstName, p.LastName, a.Name as Allergy
FROM Patient p
JOIN PatientAllergy pa ON p.PatientID = pa.PatientID
JOIN Allergy a ON pa.AllergyID = a.AllergyID
WHERE a.Name IS NOT NULL
ORDER BY p.LastName, p.FirstName;

-- =============================================
-- UPDATED QUERIES USING VIEWS
-- =============================================

-- 1. Show all the appointments with dentist and patient names
SELECT
  AppointmentID,
  TO_CHAR(AppointmentDateTime, 'YYYY-MM-DD HH24:MI') AS AppointmentDateTime,
  PatientName,
  DentistName,
  Specializations,
  Status
FROM vw_appointment_overview
ORDER BY AppointmentDateTime;

-- 2. Total money earned by each dentist
SELECT
  DentistID,
  DentistName,
  Specializations,
  TotalAppointments,
  TotalCollected
FROM vw_dentist_summary
ORDER BY TotalCollected DESC;

-- 3. Patients who still own money
SELECT
  PatientID,
  PatientName,
  OutstandingBalance
FROM vw_patient_balance
WHERE OutstandingBalance > 0
ORDER BY OutstandingBalance DESC, PatientName;

-- 4. Most common treatment
SELECT 
    TreatmentType, 
    COUNT(*) AS NumberOfTreatments
FROM Treatment
GROUP BY TreatmentType
HAVING COUNT(*) >= 1
ORDER BY NumberOfTreatments DESC, TreatmentType;

-- 5. Display unique dentist specializations 
SELECT DISTINCT Name as SpecializationName
FROM Specialization
ORDER BY SpecializationName;

-- 6. Three tables joined with normalized structure
SELECT
  a.AppointmentID,
  TO_CHAR(a.AppointmentDateTime, 'YYYY-MM-DD HH24:MI') AS AppointmentDateTime,
  (d.FirstName || ' ' || d.LastName) AS DentistName,
  LISTAGG(s.Name, ', ') WITHIN GROUP (ORDER BY s.Name) AS Specializations,
  NVL(b.TotalAmount, 0) - NVL(b.AmountPaid, 0) AS Balance
FROM Appointment a
JOIN Dentist d ON d.DentistID = a.DentistID
LEFT JOIN DentistSpecialization ds ON d.DentistID = ds.DentistID
LEFT JOIN Specialization s ON ds.SpecializationID = s.SpecializationID
LEFT JOIN Bills b ON b.AppointmentID = a.AppointmentID
GROUP BY a.AppointmentID, a.AppointmentDateTime, d.DentistID, d.FirstName, d.LastName, b.TotalAmount, b.AmountPaid
ORDER BY a.AppointmentDateTime;

-- =============================================
-- ADDITIONAL QUERIES FOR NORMALIZED SCHEMA
-- =============================================

-- Show medical records for patients
SELECT 
    p.PatientID,
    p.FirstName || ' ' || p.LastName as PatientName,
    mr.ConditionTitle,
    mr.Details,
    mr.RecordDate
FROM Patient p
JOIN MedicalRecord mr ON p.PatientID = mr.PatientID
ORDER BY p.LastName, mr.RecordDate DESC;

-- Show bill details with line items
SELECT 
    b.BillID,
    p.FirstName || ' ' || p.LastName as PatientName,
    bi.Description,
    bi.Amount,
    b.TotalAmount,
    b.AmountPaid,
    b.PaymentStatus
FROM Bills b
JOIN Patient p ON b.PatientID = p.PatientID
LEFT JOIN BillItems bi ON b.BillID = bi.BillID
ORDER BY b.BillID;

-- Dentists and their multiple specializations
SELECT 
    d.DentistID,
    d.FirstName || ' ' || d.LastName as DentistName,
    LISTAGG(s.Name, ', ') WITHIN GROUP (ORDER BY s.Name) as AllSpecializations
FROM Dentist d
LEFT JOIN DentistSpecialization ds ON d.DentistID = ds.DentistID
LEFT JOIN Specialization s ON ds.SpecializationID = s.SpecializationID
GROUP BY d.DentistID, d.FirstName, d.LastName
ORDER BY d.LastName;

EXIT;
EOF