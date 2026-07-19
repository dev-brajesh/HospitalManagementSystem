package com.hospital.dao;

import com.hospital.model.LabStaff;
import com.hospital.util.DBConnection;

import java.sql.*;

public class LabStaffDAO {
    public LabStaff findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM lab_staff WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) return null;
                LabStaff l = new LabStaff();
                l.setLabId(rs.getInt("lab_id"));
                l.setFullName(rs.getString("full_name"));
                l.setUsername(rs.getString("username"));
                l.setPassword(rs.getString("password"));
                l.setEmail(rs.getString("email"));
                l.setPhoneNumber(rs.getString("phone_number"));
                return l;
            }
        }
    }
}