package com.surgery.dao;

import com.surgery.model.Surgery;
import com.surgery.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SurgeryDAO {

    // ================= INSERT =================
    public boolean insertSurgery(Surgery s) throws SQLException {
        String sql = """
            INSERT INTO surgeries (surgery_ref, patient_id, surgeon_id, ot_id,
                surgery_type, surgery_category, priority_level, scheduled_date,
                scheduled_time, estimated_duration, status, pre_op_notes, created_by)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'SCHEDULED', ?, ?)
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, s.getSurgeryRef());
            ps.setInt(2, s.getPatientId());
            ps.setInt(3, s.getSurgeonId());
            ps.setInt(4, s.getOtId());
            ps.setString(5, s.getSurgeryType());
            ps.setString(6, s.getSurgeryCategory());
            ps.setString(7, s.getPriorityLevel());
            ps.setDate(8, s.getScheduledDate());
            ps.setTime(9, s.getScheduledTime());
            ps.setInt(10, s.getEstimatedDuration());
            ps.setString(11, s.getPreOpNotes());
            ps.setInt(12, s.getCreatedBy());

            return ps.executeUpdate() > 0;
        }
    }

    // ================= GET ALL =================
    public List<Surgery> getAllSurgeries() throws SQLException {
        List<Surgery> list = new ArrayList<>();

        String sql = """
            SELECT s.*, p.full_name AS patient_name, p.risk_level AS patient_risk,
                   sr.full_name AS surgeon_name,
                   ot.ot_number, ot.ot_name
            FROM surgeries s
            JOIN patients p ON s.patient_id = p.id
            JOIN surgeons sr ON s.surgeon_id = sr.id
            JOIN operation_theaters ot ON s.ot_id = ot.id
                            ORDER BY
                s.scheduled_date DESC, s.scheduled_time DESC
            """;

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(mapRowJoined(rs));
            }
        }
        return list;
    }

    // ================= TODAY SURGERIES =================
    public List<Surgery> getTodaySurgeries() throws SQLException {
        List<Surgery> list = new ArrayList<>();

        String sql = """
            SELECT s.*, p.full_name AS patient_name, p.risk_level AS patient_risk,
                   sr.full_name AS surgeon_name,
                   ot.ot_number, ot.ot_name
            FROM surgeries s
            JOIN patients p ON s.patient_id = p.id
            JOIN surgeons sr ON s.surgeon_id = sr.id
            JOIN operation_theaters ot ON s.ot_id = ot.id
            WHERE s.scheduled_date = CURDATE()
            ORDER BY s.scheduled_time
            """;

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(mapRowJoined(rs));
            }
        }
        return list;
    }

    // ================= STATUS UPDATE =================
    public boolean updateStatus(int id, String status) throws SQLException {

        String getSql = "SELECT surgeon_id, ot_id FROM surgeries WHERE id = ?";
        int surgeonId = 0, otId = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(getSql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                surgeonId = rs.getInt("surgeon_id");
                otId = rs.getInt("ot_id");
            }
        }

        String sql = "UPDATE surgeries SET status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }

        // ===== STATUS LOGIC =====
        if ("IN_PROGRESS".equals(status)) {

            try (Connection conn = DBConnection.getConnection()) {

                PreparedStatement ps1 = conn.prepareStatement(
                        "UPDATE surgeons SET is_available = FALSE WHERE id = ?");
                ps1.setInt(1, surgeonId);
                ps1.executeUpdate();

                PreparedStatement ps2 = conn.prepareStatement(
                        "UPDATE operation_theaters SET status = 'OCCUPIED' WHERE id = ?");
                ps2.setInt(1, otId);
                ps2.executeUpdate();
            }
        }

        if ("COMPLETED".equals(status) || "CANCELLED".equals(status)) {

            try (Connection conn = DBConnection.getConnection()) {

                PreparedStatement ps1 = conn.prepareStatement(
                        "UPDATE surgeons SET is_available = TRUE WHERE id = ?");
                ps1.setInt(1, surgeonId);
                ps1.executeUpdate();

                PreparedStatement ps2 = conn.prepareStatement(
                        "UPDATE operation_theaters SET status = 'AVAILABLE' WHERE id = ?");
                ps2.setInt(1, otId);
                ps2.executeUpdate();
            }
        }

        return true;
    }

    // ================= CONFLICT CHECK (FIXED) =================
    public boolean isOTConflict(int otId, String date, String time, int durationMinutes) throws SQLException {

        String sql = """
            SELECT COUNT(*) FROM surgeries
            WHERE ot_id = ?
              AND scheduled_date = ?
              AND status NOT IN ('CANCELLED', 'COMPLETED')
              AND (
                    scheduled_time < ADDTIME(?, SEC_TO_TIME(? * 60))
                    AND
                    ADDTIME(scheduled_time, SEC_TO_TIME(estimated_duration * 60)) > ?
              )
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, otId);
            ps.setString(2, date);
            ps.setString(3, time);
            ps.setInt(4, durationMinutes);
            ps.setString(5, time);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }

    // ================= COUNT =================
    public int getTotalScheduled() throws SQLException {
        String sql = "SELECT COUNT(*) FROM surgeries WHERE status = 'SCHEDULED'";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getTodayCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM surgeries WHERE scheduled_date = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public boolean isSurgeonConflict(int surgeonId, String date, String time, int durationMinutes) throws SQLException {

        String sql = """
        SELECT COUNT(*) FROM surgeries
        WHERE surgeon_id = ?
          AND scheduled_date = ?
          AND status NOT IN ('CANCELLED', 'COMPLETED')
          AND (
                scheduled_time < ADDTIME(?, SEC_TO_TIME(? * 60))
                AND
                ADDTIME(scheduled_time, SEC_TO_TIME(estimated_duration * 60)) > ?
          )
        """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, surgeonId);
            ps.setString(2, date);
            ps.setString(3, time);
            ps.setInt(4, durationMinutes);
            ps.setString(5, time);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }
    // ── SurgeryDAO.java তে isSurgeonConflict() এর পরে এই method টা যোগ করুন ──

    public boolean isPatientConflict(int patientId, String date, String time, int durationMinutes) throws SQLException {
        String sql = """
        SELECT COUNT(*) FROM surgeries
        WHERE patient_id = ?
          AND scheduled_date = ?
          AND status NOT IN ('CANCELLED', 'COMPLETED')
          AND (
                scheduled_time < ADDTIME(?, SEC_TO_TIME(? * 60))
                AND
                ADDTIME(scheduled_time, SEC_TO_TIME(estimated_duration * 60)) > ?
          )
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setString(2, date);
            ps.setString(3, time);
            ps.setInt(4, durationMinutes);
            ps.setString(5, time);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }

    // ================= REF =================
    public String generateSurgeryRef() throws SQLException {
        String sql = "SELECT MAX(id) FROM surgeries";

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                int maxId = rs.getInt(1) + 1;
                return String.format("SRY-%d-%03d",
                        java.time.Year.now().getValue(), maxId);
            }
        }
        return "SRY-" + java.time.Year.now().getValue() + "-001";
    }

    // ================= MAPPER =================
    private Surgery mapRowJoined(ResultSet rs) throws SQLException {
        Surgery s = new Surgery();

        s.setId(rs.getInt("id"));
        s.setSurgeryRef(rs.getString("surgery_ref"));
        s.setPatientId(rs.getInt("patient_id"));
        s.setSurgeonId(rs.getInt("surgeon_id"));
        s.setOtId(rs.getInt("ot_id"));
        s.setSurgeryType(rs.getString("surgery_type"));
        s.setSurgeryCategory(rs.getString("surgery_category"));
        s.setPriorityLevel(rs.getString("priority_level"));
        s.setScheduledDate(rs.getDate("scheduled_date"));
        s.setScheduledTime(rs.getTime("scheduled_time"));
        s.setEstimatedDuration(rs.getInt("estimated_duration"));
        s.setStatus(rs.getString("status"));
        s.setPreOpNotes(rs.getString("pre_op_notes"));
        s.setCreatedAt(rs.getTimestamp("created_at"));

        s.setPatientName(rs.getString("patient_name"));
        s.setPatientRiskLevel(rs.getString("patient_risk"));
        s.setSurgeonName(rs.getString("surgeon_name"));
        s.setOtNumber(rs.getString("ot_number"));
        s.setOtName(rs.getString("ot_name"));

        return s;
    }
}