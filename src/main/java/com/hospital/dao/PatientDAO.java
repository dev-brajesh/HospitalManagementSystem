package com.hospital.dao;

import com.hospital.model.Patient;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PatientDAO {

    /**
     * Returns true if a patient already exists with this username or email.
     */
    public boolean usernameOrEmailExists(String username, String email) throws SQLException {
        String sql = "SELECT patient_id FROM patients WHERE username = ? OR email = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, email);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inserts a new patient record. Returns true if the insert affected a row.
     */
    public boolean insertPatient(Patient patient) throws SQLException {
        String sql = "INSERT INTO patients " +
                "(first_name, last_name, date_of_birth, gender, blood_group, phone_number, " +
                "email, address, emergency_contact_number, username, password) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, patient.getFirstName());
            stmt.setString(2, patient.getLastName());
            stmt.setString(3, patient.getDateOfBirth());
            stmt.setString(4, patient.getGender());
            stmt.setString(5, patient.getBloodGroup());
            stmt.setString(6, patient.getPhoneNumber());
            stmt.setString(7, patient.getEmail());
            stmt.setString(8, patient.getAddress());
            stmt.setString(9, patient.getEmergencyContactNumber());
            stmt.setString(10, patient.getUsername());
            stmt.setString(11, patient.getPassword());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    /**
     * Looks up a patient by username. Used for login. Returns null if not found.
     */
    public Patient findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM patients WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);

            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Patient patient = new Patient();
                patient.setPatientId(rs.getInt("patient_id"));
                patient.setFirstName(rs.getString("first_name"));
                patient.setLastName(rs.getString("last_name"));
                patient.setDateOfBirth(rs.getString("date_of_birth"));
                patient.setGender(rs.getString("gender"));
                patient.setBloodGroup(rs.getString("blood_group"));
                patient.setPhoneNumber(rs.getString("phone_number"));
                patient.setEmail(rs.getString("email"));
                patient.setAddress(rs.getString("address"));
                patient.setEmergencyContactNumber(rs.getString("emergency_contact_number"));
                patient.setUsername(rs.getString("username"));
                patient.setPassword(rs.getString("password"));
                return patient;
            }
        }
    }
}