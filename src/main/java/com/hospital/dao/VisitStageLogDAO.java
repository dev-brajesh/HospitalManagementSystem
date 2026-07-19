package com.hospital.dao;

import com.hospital.util.DBConnection;

import java.sql.*;

public class VisitStageLogDAO {

    /** Closes the log row for the stage being left (if any) and opens one for the new stage. */
    public void logTransition(int visitId, String fromStage, String toStage) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (fromStage != null) {
                closeOpenStage(conn, visitId, fromStage);
            }
            openStage(conn, visitId, toStage);
        }
    }

    private void closeOpenStage(Connection conn, int visitId, String stage) throws SQLException {
        String sql = "UPDATE visit_stage_log SET exited_at = NOW() " +
                "WHERE visit_id = ? AND stage = ? AND exited_at IS NULL";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, visitId);
            stmt.setString(2, stage);
            stmt.executeUpdate();
        }
    }

    private void openStage(Connection conn, int visitId, String stage) throws SQLException {
        String sql = "INSERT INTO visit_stage_log (visit_id, stage, entered_at) VALUES (?, ?, NOW())";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, visitId);
            stmt.setString(2, stage);
            stmt.executeUpdate();
        }
    }

    /** Average minutes patients have historically spent in a stage. Falls back to 10 until there's history. */
    public int getAverageDurationMinutes(String stage) throws SQLException {
        String sql = "SELECT AVG(TIMESTAMPDIFF(MINUTE, entered_at, exited_at)) AS avg_minutes " +
                "FROM visit_stage_log WHERE stage = ? AND exited_at IS NOT NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, stage);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int avg = rs.getInt("avg_minutes");
                    if (!rs.wasNull() && avg > 0) return avg;
                }
            }
        }
        return 10;
    }
}