package com.hospital.dao;

import com.hospital.model.Prescription;
import com.hospital.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PrescriptionDAO {

    public boolean insertPrescription(Prescription p) throws SQLException {
        String sql = "INSERT INTO prescriptions (visit_id, medicine_name, dose, morning, afternoon, evening, days) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, p.getVisitId());
            stmt.setString(2, p.getMedicineName());
            stmt.setString(3, p.getDose());
            stmt.setBoolean(4, p.isMorning());
            stmt.setBoolean(5, p.isAfternoon());
            stmt.setBoolean(6, p.isEvening());
            stmt.setInt(7, p.getDays());
            return stmt.executeUpdate() > 0;
        }
    }

    /** Clears any previous prescriptions for this visit before re-saving (guards against duplicate rows on retry). */
    public void deleteByVisitId(int visitId) throws SQLException {
        String sql = "DELETE FROM prescriptions WHERE visit_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, visitId);
            stmt.executeUpdate();
        }
    }

    public List<Prescription> findByVisitId(int visitId) throws SQLException {
        String sql = "SELECT * FROM prescriptions WHERE visit_id = ? ORDER BY prescription_id ASC";
        List<Prescription> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, visitId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Prescription p = new Prescription();
                    p.setPrescriptionId(rs.getInt("prescription_id"));
                    p.setVisitId(rs.getInt("visit_id"));
                    p.setMedicineName(rs.getString("medicine_name"));
                    p.setDose(rs.getString("dose"));
                    p.setMorning(rs.getBoolean("morning"));
                    p.setAfternoon(rs.getBoolean("afternoon"));
                    p.setEvening(rs.getBoolean("evening"));
                    p.setDays(rs.getInt("days"));
                    list.add(p);
                }
            }
        }
        return list;
    }
}