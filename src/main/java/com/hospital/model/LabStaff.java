package com.hospital.model;

public class LabStaff {
    private int labId;
    private String fullName;
    private String username;
    private String password;
    private String email;
    private String phoneNumber;

    public LabStaff() {}

    public int getLabId() { return labId; }
    public void setLabId(int labId) { this.labId = labId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}