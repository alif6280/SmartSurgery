package com.surgery.dao;

import com.surgery.model.Patient;
import com.surgery.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {

    // ─── CREATE ───────────────────────────────────────────────

    public boolean insertPatient(Patient p) throws SQLException {
        String sql = """
            INSERT INTO patients (patient_id, full_name, age, gender, blood_group,
                contact_number, address, has_diabetes, has_hypertension,
                has_heart_disease, has_kidney_disease, is_smoker, bmi,
                asa_grade, medical_history, allergies, risk_score, risk_level,
                labs_done, ecg_done, consent_signed, anaesthesia_done, npo_done)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1,   p.getPatientId());
            ps.setString(2,   p.getFullName());
            ps.setInt(3,      p.getAge());
            ps.setString(4,   p.getGender());
            ps.setString(5,   p.getBloodGroup());
            ps.setString(6,   p.getContactNumber());
            ps.setString(7,   p.getAddress());
            ps.setBoolean(8,  p.isHasDiabetes());
            ps.setBoolean(9,  p.isHasHypertension());
            ps.setBoolean(10, p.isHasHeartDisease());
            ps.setBoolean(11, p.isHasKidneyDisease());
            ps.setBoolean(12, p.isSmoker());
            ps.setDouble(13,  p.getBmi());
            ps.setInt(14,     p.getAsaGrade());
            ps.setString(15,  p.getMedicalHistory());
            ps.setString(16,  p.getAllergies());
            ps.setDouble(17,  p.getRiskScore());
            ps.setString(18,  p.getRiskLevel());
            ps.setBoolean(19, p.isLabsDone());
            ps.setBoolean(20, p.isEcgDone());
            ps.setBoolean(21, p.isConsentSigned());
            ps.setBoolean(22, p.isAnaesthesiaDone());
            ps.setBoolean(23, p.isNpoDone());

            return ps.executeUpdate() > 0;
        }
    }

    // ─── READ ALL (latest surgery status + surgeon + OT সহ) ───

    public List<Patient> getAllPatients() throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = """
            SELECT p.*,
                s.status          AS last_surgery_status,
                s.scheduled_date  AS last_surgery_date,
                u.full_name       AS assigned_surgeon,
                s.ot_room         AS ot_room
            FROM patients p
            LEFT JOIN surgeries s ON s.id = (
                SELECT id FROM surgeries
                WHERE patient_id = p.id
                ORDER BY
                    CASE status
                        WHEN 'IN_PROGRESS' THEN 1
                        WHEN 'SCHEDULED'   THEN 2
                        WHEN 'COMPLETED'   THEN 3
                        WHEN 'CANCELLED'   THEN 4
                        ELSE 5
                    END,
                    scheduled_date DESC
                LIMIT 1
            )
            LEFT JOIN users u ON u.id = s.surgeon_id AND u.role = 'DOCTOR'
            ORDER BY p.registered_at DESC
            """;

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                Patient p = mapRow(rs);
                p.setLastSurgeryStatus(rs.getString("last_surgery_status"));
                p.setLastSurgeryDate(rs.getDate("last_surgery_date"));
                p.setAssignedSurgeon(rs.getString("assigned_surgeon"));
                p.setOtRoom(rs.getString("ot_room"));
                list.add(p);
            }
        }
        return list;
    }

    // ─── READ BY ID ───────────────────────────────────────────

    public Patient getPatientById(int id) throws SQLException {
        String sql = """
            SELECT p.*,
                s.status          AS last_surgery_status,
                s.scheduled_date  AS last_surgery_date,
                u.full_name       AS assigned_surgeon,
                s.ot_room         AS ot_room
            FROM patients p
            LEFT JOIN surgeries s ON s.id = (
                SELECT id FROM surgeries
                WHERE patient_id = p.id
                ORDER BY
                    CASE status
                        WHEN 'IN_PROGRESS' THEN 1
                        WHEN 'SCHEDULED'   THEN 2
                        WHEN 'COMPLETED'   THEN 3
                        WHEN 'CANCELLED'   THEN 4
                        ELSE 5
                    END,
                    scheduled_date DESC
                LIMIT 1
            )
            LEFT JOIN users u ON u.id = s.surgeon_id AND u.role = 'DOCTOR'
            WHERE p.id = ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Patient p = mapRow(rs);
                    p.setLastSurgeryStatus(rs.getString("last_surgery_status"));
                    p.setLastSurgeryDate(rs.getDate("last_surgery_date"));
                    p.setAssignedSurgeon(rs.getString("assigned_surgeon"));
                    p.setOtRoom(rs.getString("ot_room"));
                    return p;
                }
            }
        }
        return null;
    }

    // ─── UPDATE ───────────────────────────────────────────────

    public boolean updatePatient(Patient p) throws SQLException {
        String sql = """
            UPDATE patients SET
                full_name=?, age=?, gender=?, blood_group=?,
                contact_number=?, address=?, has_diabetes=?, has_hypertension=?,
                has_heart_disease=?, has_kidney_disease=?, is_smoker=?, bmi=?,
                asa_grade=?, medical_history=?, allergies=?, risk_score=?, risk_level=?,
                labs_done=?, ecg_done=?, consent_signed=?, anaesthesia_done=?, npo_done=?,
                last_updated=CURRENT_TIMESTAMP
            WHERE id=?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1,   p.getFullName());
            ps.setInt(2,      p.getAge());
            ps.setString(3,   p.getGender());
            ps.setString(4,   p.getBloodGroup());
            ps.setString(5,   p.getContactNumber());
            ps.setString(6,   p.getAddress());
            ps.setBoolean(7,  p.isHasDiabetes());
            ps.setBoolean(8,  p.isHasHypertension());
            ps.setBoolean(9,  p.isHasHeartDisease());
            ps.setBoolean(10, p.isHasKidneyDisease());
            ps.setBoolean(11, p.isSmoker());
            ps.setDouble(12,  p.getBmi());
            ps.setInt(13,     p.getAsaGrade());
            ps.setString(14,  p.getMedicalHistory());
            ps.setString(15,  p.getAllergies());
            ps.setDouble(16,  p.getRiskScore());
            ps.setString(17,  p.getRiskLevel());
            ps.setBoolean(18, p.isLabsDone());
            ps.setBoolean(19, p.isEcgDone());
            ps.setBoolean(20, p.isConsentSigned());
            ps.setBoolean(21, p.isAnaesthesiaDone());
            ps.setBoolean(22, p.isNpoDone());
            ps.setInt(23,     p.getId());

            return ps.executeUpdate() > 0;
        }
    }

    // ─── UPDATE Pre-op Checklist only ────────────────────────
    // Servlet থেকে শুধু checklist update করতে এই method ব্যবহার করুন

    public boolean updatePreopChecklist(int patientId, boolean labs, boolean ecg,
                                        boolean consent, boolean anaesthesia, boolean npo)
            throws SQLException {
        String sql = """
            UPDATE patients SET
                labs_done=?, ecg_done=?, consent_signed=?,
                anaesthesia_done=?, npo_done=?,
                last_updated=CURRENT_TIMESTAMP
            WHERE id=?
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, labs);
            ps.setBoolean(2, ecg);
            ps.setBoolean(3, consent);
            ps.setBoolean(4, anaesthesia);
            ps.setBoolean(5, npo);
            ps.setInt(6, patientId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── DELETE ───────────────────────────────────────────────

    public boolean deletePatient(int id) throws SQLException {
        String checkSql = """
            SELECT COUNT(*) FROM surgeries
            WHERE patient_id = ?
            AND status NOT IN ('COMPLETED', 'CANCELLED')
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new SQLException("❌ Cannot delete! Patient has active/scheduled surgeries.");
            }
        }

        String deleteSurgeries = """
            DELETE FROM surgeries WHERE patient_id = ?
            AND status IN ('COMPLETED', 'CANCELLED')
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(deleteSurgeries)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }

        String sql = "DELETE FROM patients WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── COUNT ────────────────────────────────────────────────

    public int getTotalPatients() throws SQLException {
        String sql = "SELECT COUNT(*) FROM patients";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
    public String generateNextPatientId() throws SQLException {
        String sql = """
        SELECT COALESCE(MAX(CAST(SUBSTRING(patient_id, 5) AS UNSIGNED)), 0) + 1
        FROM patients
        """;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                return String.format("PAT-%03d", rs.getInt(1));
            }
        }
        return "PAT-001";
    }

    public int getHighRiskCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM patients WHERE risk_level IN ('HIGH','CRITICAL')";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ─── HELPER: mapRow ───────────────────────────────────────

    private Patient mapRow(ResultSet rs) throws SQLException {
        Patient p = new Patient();
        p.setId(rs.getInt("id"));
        p.setPatientId(rs.getString("patient_id"));
        p.setFullName(rs.getString("full_name"));
        p.setAge(rs.getInt("age"));
        p.setGender(rs.getString("gender"));
        p.setBloodGroup(rs.getString("blood_group"));
        p.setContactNumber(rs.getString("contact_number"));
        p.setAddress(rs.getString("address"));
        p.setHasDiabetes(rs.getBoolean("has_diabetes"));
        p.setHasHypertension(rs.getBoolean("has_hypertension"));
        p.setHasHeartDisease(rs.getBoolean("has_heart_disease"));
        p.setHasKidneyDisease(rs.getBoolean("has_kidney_disease"));
        p.setSmoker(rs.getBoolean("is_smoker"));
        p.setBmi(rs.getDouble("bmi"));
        p.setAsaGrade(rs.getInt("asa_grade"));
        p.setMedicalHistory(rs.getString("medical_history"));
        p.setAllergies(rs.getString("allergies"));
        p.setRiskScore(rs.getDouble("risk_score"));
        p.setRiskLevel(rs.getString("risk_level"));
        p.setRegisteredAt(rs.getTimestamp("registered_at"));
        // NEW fields
        p.setLabsDone(rs.getBoolean("labs_done"));
        p.setEcgDone(rs.getBoolean("ecg_done"));
        p.setConsentSigned(rs.getBoolean("consent_signed"));
        p.setAnaesthesiaDone(rs.getBoolean("anaesthesia_done"));
        p.setNpoDone(rs.getBoolean("npo_done"));
        p.setLastUpdated(rs.getTimestamp("last_updated"));
        return p;
    }
}