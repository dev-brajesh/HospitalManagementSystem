package com.hospital.dao;

import com.hospital.model.Receptionist;
import com.hospital.util.DBConnection;

import java.sql.*;

public class ReceptionistDAO {
    public Receptionist findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM receptionists WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) return null;
                Receptionist r = new Receptionist();
                r.setReceptionistId(rs.getInt("receptionist_id"));
                r.setFullName(rs.getString("full_name"));
                r.setUsername(rs.getString("username"));
                r.setPassword(rs.getString("password"));
                r.setEmail(rs.getString("email"));
                r.setPhoneNumber(rs.getString("phone_number"));
                return r;
            }
        }
    }
}