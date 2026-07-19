package com.hospital.model;

import java.math.BigDecimal;

public class Visit {
    private int id;
    private String visitNumber;
    private String visitDate;
    private int patientId;
    private String patientName;
    private String contactNumber;
    private String symptoms;
    private String language;
    private String status;              // REGISTRATION, DOCTOR, LAB, LAB_PAYMENT, PHARMACY, PHARMACY_PAYMENT, DONE
    private Integer assignedDoctorId;
    private String department;
    private BigDecimal consultationFee;
    private boolean consultationPaid;
    private String diagnosis;
    private String labTestCode;
    private String labTestName;
    private BigDecimal labFee;
    private boolean labPaid;
    private String labResultText;
    private BigDecimal pharmacyTotalCost;
    private boolean medicinePaid;
    private boolean medicineDispensed;
    private String emergencyContactName;
    private String emergencyContactPhone;
    private String clinicalNotes;

    public Visit() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getVisitNumber() { return visitNumber; }
    public void setVisitNumber(String visitNumber) { this.visitNumber = visitNumber; }
    public String getVisitDate() { return visitDate; }
    public void setVisitDate(String visitDate) { this.visitDate = visitDate; }
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getAssignedDoctorId() { return assignedDoctorId; }
    public void setAssignedDoctorId(Integer assignedDoctorId) { this.assignedDoctorId = assignedDoctorId; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public BigDecimal getConsultationFee() { return consultationFee; }
    public void setConsultationFee(BigDecimal consultationFee) { this.consultationFee = consultationFee; }
    public boolean isConsultationPaid() { return consultationPaid; }
    public void setConsultationPaid(boolean consultationPaid) { this.consultationPaid = consultationPaid; }
    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }
    public String getLabTestCode() { return labTestCode; }
    public void setLabTestCode(String labTestCode) { this.labTestCode = labTestCode; }
    public String getLabTestName() { return labTestName; }
    public void setLabTestName(String labTestName) { this.labTestName = labTestName; }
    public BigDecimal getLabFee() { return labFee; }
    public void setLabFee(BigDecimal labFee) { this.labFee = labFee; }
    public boolean isLabPaid() { return labPaid; }
    public void setLabPaid(boolean labPaid) { this.labPaid = labPaid; }
    public String getLabResultText() { return labResultText; }
    public void setLabResultText(String labResultText) { this.labResultText = labResultText; }
    public BigDecimal getPharmacyTotalCost() { return pharmacyTotalCost; }
    public void setPharmacyTotalCost(BigDecimal pharmacyTotalCost) { this.pharmacyTotalCost = pharmacyTotalCost; }
    public boolean isMedicinePaid() { return medicinePaid; }
    public void setMedicinePaid(boolean medicinePaid) { this.medicinePaid = medicinePaid; }
    public boolean isMedicineDispensed() { return medicineDispensed; }
    public void setMedicineDispensed(boolean medicineDispensed) { this.medicineDispensed = medicineDispensed; }
    public String getEmergencyContactName() { return emergencyContactName; }
    public void setEmergencyContactName(String emergencyContactName) { this.emergencyContactName = emergencyContactName; }
    public String getEmergencyContactPhone() { return emergencyContactPhone; }
    public void setEmergencyContactPhone(String emergencyContactPhone) { this.emergencyContactPhone = emergencyContactPhone; }
    public String getClinicalNotes() { return clinicalNotes; }
    public void setClinicalNotes(String clinicalNotes) { this.clinicalNotes = clinicalNotes; }
}