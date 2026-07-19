package com.hospital.dao;

import com.hospital.model.Pharmacist;
import com.hospital.util.DBConnection;

import java.sql.*;

public class PharmacistDAO {
    public Pharmacist findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM pharmacists WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) return null;
                Pharmacist p = new Pharmacist();
                p.setPharmacistId(rs.getInt("pharmacist_id"));
                p.setFullName(rs.getString("full_name"));
                p.setUsername(rs.getString("username"));
                p.setPassword(rs.getString("password"));
                p.setEmail(rs.getString("email"));
                p.setPhoneNumber(rs.getString("phone_number"));
                return p;
            }
        }
    }
}