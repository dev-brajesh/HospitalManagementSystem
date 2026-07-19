package com.hospital.dao;

import com.hospital.model.Visit;
import com.hospital.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VisitDAO {

    /** Standard consultation fee charged before doctor allocation (flowchart step 3). */
    public static final BigDecimal DEFAULT_CONSULTATION_FEE = new BigDecimal("500.00");

    private final VisitStageLogDAO stageLogDAO = new VisitStageLogDAO();

    public int createVisit(int patientId, String patientName, String contactNumber, String symptoms) throws SQLException {
        String insertSql = "INSERT INTO visits " +
                "(patient_id, patient_name, contact_number, symptoms, language, status, visit_date, " +
                "consultation_fee, consultation_paid, lab_fee, lab_paid, medicine_paid, medicine_dispensed) " +
                "VALUES (?, ?, ?, ?, 'en', 'REGISTRATION', CURDATE(), ?, 0, 0, 0, 0, 0)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, patientId);
            stmt.setString(2, patientName);
            stmt.setString(3, contactNumber);
            stmt.setString(4, symptoms);
            stmt.setBigDecimal(5, DEFAULT_CONSULTATION_FEE);

            int rows = stmt.executeUpdate();
            if (rows == 0) return -1;

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (!keys.next()) return -1;
                int newId = keys.getInt(1);
                setVisitNumber(conn, newId);
                stageLogDAO.logTransition(newId, null, "REGISTRATION");
                return newId;
            }
        }
    }

    private void setVisitNumber(Connection conn, int visitId) throws SQLException {
        String visitNumber = "V" + String.format("%05d", visitId);
        String sql = "UPDATE visits SET visit_number = ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, visitNumber);
            stmt.setInt(2, visitId);
            stmt.executeUpdate();
        }
    }

    public Visit findActiveVisitForPatient(int patientId) throws SQLException {
        String sql = "SELECT * FROM visits WHERE patient_id = ? AND status != 'DONE' " +
                "ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) return null;
                return mapRow(rs);
            }
        }
    }

    public Visit findById(int visitId) throws SQLException {
        String sql = "SELECT * FROM visits WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, visitId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) return null;
                return mapRow(rs);
            }
        }
    }

    /** Reception queue: only patients not yet assigned a doctor (assigning-but-unpaid stays out of this list). */
    public List<Visit> findUnassignedRegistrations() throws SQLException {
        String sql = "SELECT * FROM visits WHERE status = 'REGISTRATION' AND assigned_doctor_id IS NULL ORDER BY id ASC";
        List<Visit> visits = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) visits.add(mapRow(rs));
        }
        return visits;
    }

    public List<Visit> findVisitsByStatus(String status) throws SQLException {
        String sql = "SELECT * FROM visits WHERE status = ? ORDER BY id ASC";
        List<Visit> visits = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) visits.add(mapRow(rs));
            }
        }
        return visits;
    }

    public List<Visit> findVisitsByDoctorAndStatus(int doctorId, String status) throws SQLException {
        String sql = "SELECT * FROM visits WHERE assigned_doctor_id = ? AND status = ? ORDER BY id ASC";
        List<Visit> visits = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) visits.add(mapRow(rs));
            }
        }
        return visits;
    }

    /** Generic queue-position count for stages with one shared queue (reception/lab/pharmacy). */
    public int countPatientsAhead(String status, int visitId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visits WHERE status = ? AND id < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, visitId);
            try (ResultSet rs = stmt.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /** Doctor-scoped count — fixes the bug where DOCTOR-stage wait time counted every doctor's patients. */
    public int countPatientsAheadForDoctor(int doctorId, int visitId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visits WHERE status = 'DOCTOR' AND assigned_doctor_id = ? AND id < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            stmt.setInt(2, visitId);
            try (ResultSet rs = stmt.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public int getAverageStageDurationMinutes(String stage) throws SQLException {
        return stageLogDAO.getAverageDurationMinutes(stage);
    }

    /** Reception: assigns a doctor and sets the consultation fee.
     * Does NOT advance the visit status — reception assigns the doctor while the visit remains in REGISTRATION.
     * The patient will be shown the consultation fee and asked to pay; payment flips the visit to DOCTOR.
     */
    public boolean assignDoctor(int visitId, int doctorId, String department, java.math.BigDecimal consultationFee) throws SQLException {
        String sql = "UPDATE visits SET assigned_doctor_id = ?, department = ?, consultation_fee = ? " +
                "WHERE id = ? AND status = 'REGISTRATION' AND assigned_doctor_id IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            stmt.setString(2, department);
            stmt.setBigDecimal(3, consultationFee);
            stmt.setInt(4, visitId);
            boolean ok = stmt.executeUpdate() > 0;
            // No status transition here; stage log is reserved for actual stage changes.
            return ok;
        }
    }

    /** Doctor: writes diagnosis and branches. No fee gate on this edge (matches the diagram). */
    public boolean completeConsultation(int visitId, String diagnosis, String labTestName, BigDecimal labFee, String nextStatus) throws SQLException {
        String sql = "UPDATE visits SET diagnosis = ?, lab_test_name = ?, lab_fee = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, diagnosis);
            stmt.setString(2, labTestName);
            stmt.setBigDecimal(3, labFee);
            stmt.setString(4, nextStatus);
            stmt.setInt(5, visitId);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) stageLogDAO.logTransition(visitId, "DOCTOR", nextStatus);
            return ok;
        }
    }

    /** Lab: records result + moves to LAB_PAYMENT (out of the lab queue, waiting on the patient to pay). */
    public boolean completeLabTest(int visitId, String labResultText) throws SQLException {
        String sql = "UPDATE visits SET lab_result_text = ?, lab_paid = 0, status = 'LAB_PAYMENT' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, labResultText);
            stmt.setInt(2, visitId);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) stageLogDAO.logTransition(visitId, "LAB", "LAB_PAYMENT");
            return ok;
        }
    }

    /** Pharmacy: records cost + dispenses, moves to PHARMACY_PAYMENT (waiting on the patient to pay before DONE). */
    public boolean dispenseMedicine(int visitId, BigDecimal totalCost) throws SQLException {
        String sql = "UPDATE visits SET pharmacy_total_cost = ?, medicine_paid = 0, medicine_dispensed = 1, status = 'PHARMACY_PAYMENT' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, totalCost);
            stmt.setInt(2, visitId);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) stageLogDAO.logTransition(visitId, "PHARMACY", "PHARMACY_PAYMENT");
            return ok;
        }
    }

    /**
     * The "payment portal" action. feeType is "consultation" | "lab" | "medicine".
     * Each case double-checks the visit is actually in the matching pending state before flipping it,
     * so a stale/duplicate click can't double-advance a visit.
     */
    public boolean payFee(int visitId, String feeType) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            switch (feeType) {
                case "consultation": {
                    // Mark consultation as paid. If a doctor is already assigned, move the visit to DOCTOR.
                    String paySql = "UPDATE visits SET consultation_paid = 1 WHERE id = ? AND status = 'REGISTRATION' AND consultation_paid = 0";
                    try (PreparedStatement payStmt = conn.prepareStatement(paySql)) {
                        payStmt.setInt(1, visitId);
                        int updated = payStmt.executeUpdate();
                        if (updated == 0) return false;
                    }

                    // If a doctor was assigned, promote to DOCTOR stage so it appears in doctor's queue.
                    String promoteSql = "UPDATE visits SET status = 'DOCTOR' WHERE id = ? AND status = 'REGISTRATION' AND assigned_doctor_id IS NOT NULL";
                    try (PreparedStatement promoStmt = conn.prepareStatement(promoteSql)) {
                        promoStmt.setInt(1, visitId);
                        int promoted = promoStmt.executeUpdate();
                        if (promoted > 0) stageLogDAO.logTransition(visitId, "REGISTRATION", "DOCTOR");
                    }

                    return true;
                }
                case "lab": {
                    String sql = "UPDATE visits SET lab_paid = 1, status = 'PHARMACY' WHERE id = ? AND status = 'LAB_PAYMENT'";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, visitId);
                        boolean ok = stmt.executeUpdate() > 0;
                        if (ok) stageLogDAO.logTransition(visitId, "LAB_PAYMENT", "PHARMACY");
                        return ok;
                    }
                }
                case "medicine": {
                    String sql = "UPDATE visits SET medicine_paid = 1, status = 'DONE' WHERE id = ? AND status = 'PHARMACY_PAYMENT'";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, visitId);
                        boolean ok = stmt.executeUpdate() > 0;
                        if (ok) stageLogDAO.logTransition(visitId, "PHARMACY_PAYMENT", "DONE");
                        return ok;
                    }
                }
                default:
                    return false;
            }
        }
    }

    private Visit mapRow(ResultSet rs) throws SQLException {
        Visit v = new Visit();
        v.setId(rs.getInt("id"));
        v.setVisitNumber(rs.getString("visit_number"));
        v.setVisitDate(String.valueOf(rs.getDate("visit_date")));
        v.setPatientId(rs.getInt("patient_id"));
        v.setPatientName(rs.getString("patient_name"));
        v.setContactNumber(rs.getString("contact_number"));
        v.setSymptoms(rs.getString("symptoms"));
        v.setLanguage(rs.getString("language"));
        v.setStatus(rs.getString("status"));

        int doctorId = rs.getInt("assigned_doctor_id");
        v.setAssignedDoctorId(rs.wasNull() ? null : doctorId);

        v.setDepartment(rs.getString("department"));
        v.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        v.setConsultationPaid(rs.getBoolean("consultation_paid"));
        v.setDiagnosis(rs.getString("diagnosis"));
        v.setLabTestCode(rs.getString("lab_test_code"));
        v.setLabTestName(rs.getString("lab_test_name"));
        v.setLabFee(rs.getBigDecimal("lab_fee"));
        v.setLabPaid(rs.getBoolean("lab_paid"));
        v.setLabResultText(rs.getString("lab_result_text"));
        v.setPharmacyTotalCost(rs.getBigDecimal("pharmacy_total_cost"));
        v.setMedicinePaid(rs.getBoolean("medicine_paid"));
        v.setMedicineDispensed(rs.getBoolean("medicine_dispensed"));
        v.setEmergencyContactName(rs.getString("emergency_contact_name"));
        v.setEmergencyContactPhone(rs.getString("emergency_contact_phone"));
        v.setClinicalNotes(rs.getString("clinical_notes"));
        return v;
    }
}