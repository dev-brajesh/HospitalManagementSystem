package com.hospital.model;

public class Prescription {
    private int prescriptionId;
    private int visitId;
    private String medicineName;
    private String dose;
    private boolean morning;
    private boolean afternoon;
    private boolean evening;
    private int days;

    public Prescription() {}

    public int getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(int prescriptionId) { this.prescriptionId = prescriptionId; }
    public int getVisitId() { return visitId; }
    public void setVisitId(int visitId) { this.visitId = visitId; }
    public String getMedicineName() { return medicineName; }
    public void setMedicineName(String medicineName) { this.medicineName = medicineName; }
    public String getDose() { return dose; }
    public void setDose(String dose) { this.dose = dose; }
    public boolean isMorning() { return morning; }
    public void setMorning(boolean morning) { this.morning = morning; }
    public boolean isAfternoon() { return afternoon; }
    public void setAfternoon(boolean afternoon) { this.afternoon = afternoon; }
    public boolean isEvening() { return evening; }
    public void setEvening(boolean evening) { this.evening = evening; }
    public int getDays() { return days; }
    public void setDays(int days) { this.days = days; }
}