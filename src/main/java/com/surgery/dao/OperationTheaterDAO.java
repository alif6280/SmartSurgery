package com.surgery.dao;

import com.surgery.model.OperationTheater;
import com.surgery.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OperationTheaterDAO {

    // ─── GET ALL ───────────────────────────────────────────
    public List<OperationTheater> getAllOTs() throws SQLException {
        List<OperationTheater> list = new ArrayList<>();
        String sql = "SELECT * FROM operation_theaters ORDER BY ot_number";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // ─── GET AVAILABLE ─────────────────────────────────────
    public List<OperationTheater> getAvailableOTs() throws SQLException {
        List<OperationTheater> list = new ArrayList<>();
        String sql = "SELECT * FROM operation_theaters WHERE status = 'AVAILABLE' ORDER BY ot_number";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // ─── GET BY ID ─────────────────────────────────────────
    public OperationTheater getOTById(int id) throws SQLException {
        String sql = "SELECT * FROM operation_theaters WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        }
        return null;
    }

    // ─── INSERT ────────────────────────────────────────────
    public boolean insertOT(OperationTheater ot) throws SQLException {
        String sql = "INSERT INTO operation_theaters (ot_number, ot_name, ot_type, status, equipment_list, sterilization_minutes) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ot.getOtNumber());
            ps.setString(2, ot.getOtName());
            ps.setString(3, ot.getOtType());
            ps.setString(4, "AVAILABLE");
            ps.setString(5, ot.getEquipmentList());
            ps.setInt(6, ot.getSterilizationMinutes() > 0 ? ot.getSterilizationMinutes() : 30);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── UPDATE ────────────────────────────────────────────
    public boolean updateOT(OperationTheater ot) throws SQLException {
        String sql = "UPDATE operation_theaters SET ot_name=?, ot_type=?, status=?, equipment_list=?, sterilization_minutes=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ot.getOtName());
            ps.setString(2, ot.getOtType());
            ps.setString(3, ot.getStatus());
            ps.setString(4, ot.getEquipmentList());
            ps.setInt(5, ot.getSterilizationMinutes() > 0 ? ot.getSterilizationMinutes() : 30);
            ps.setInt(6, ot.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // ─── DELETE ────────────────────────────────────────────
    public boolean deleteOT(int id) throws SQLException {
        String sql = "DELETE FROM operation_theaters WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── UPDATE STATUS ─────────────────────────────────────
    public boolean updateOTStatus(int id, String status) throws SQLException {
        String sql = "UPDATE operation_theaters SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── START STERILIZATION ───────────────────────────────
    // Called when surgery completes: set status=STERILIZING, record timestamp
    public boolean startSterilization(int id) throws SQLException {
        String sql = "UPDATE operation_theaters SET status='STERILIZING', last_sterilized=NOW() WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── FINISH STERILIZATION ──────────────────────────────
    // Called manually or by auto-check: set status=AVAILABLE
    public boolean finishSterilization(int id) throws SQLException {
        String sql = "UPDATE operation_theaters SET status='AVAILABLE' WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── AUTO-CHECK STERILIZATION COMPLETE ─────────────────
    // Check all STERILIZING OTs — if time elapsed >= sterilization_minutes, mark AVAILABLE
    public int autoCompleteSteriizations() throws SQLException {
        String sql = """
            UPDATE operation_theaters
            SET status = 'AVAILABLE'
            WHERE status = 'STERILIZING'
              AND last_sterilized IS NOT NULL
              AND TIMESTAMPDIFF(MINUTE, last_sterilized, NOW()) >= sterilization_minutes
            """;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            return st.executeUpdate(sql);
        }
    }

    // ─── UTILIZATION: today's surgery count per OT ─────────
    public java.util.Map<Integer, Integer> getTodayUtilizationMap() throws SQLException {
        java.util.Map<Integer, Integer> map = new java.util.HashMap<>();
        String sql = """
            SELECT ot_id, COUNT(*) AS cnt
            FROM surgeries
            WHERE scheduled_date = CURDATE()
              AND status NOT IN ('CANCELLED')
            GROUP BY ot_id
            """;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getInt("ot_id"), rs.getInt("cnt"));
            }
        }
        return map;
    }

    // ─── UTILIZATION: today's total surgery minutes per OT ─
    public java.util.Map<Integer, Integer> getTodaySurgeryMinutesMap() throws SQLException {
        java.util.Map<Integer, Integer> map = new java.util.HashMap<>();
        String sql = """
            SELECT ot_id, SUM(estimated_duration) AS total_min
            FROM surgeries
            WHERE scheduled_date = CURDATE()
              AND status NOT IN ('CANCELLED')
            GROUP BY ot_id
            """;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getInt("ot_id"), rs.getInt("total_min"));
            }
        }
        return map;
    }

    // ─── NEXT OT NUMBER ────────────────────────────────────
    public String getNextOTNumber() throws SQLException {
        String sql = "SELECT ot_number FROM operation_theaters ORDER BY ot_number DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                String last = rs.getString("ot_number");
                int num = Integer.parseInt(last.replaceAll("[^0-9]", ""));
                return String.format("OT-%02d", num + 1);
            }
        }
        return "OT-01";
    }

    // ─── COUNT ─────────────────────────────────────────────
    public int getAvailableOTCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM operation_theaters WHERE status = 'AVAILABLE'";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ─── MAP ROW ───────────────────────────────────────────
    private OperationTheater mapRow(ResultSet rs) throws SQLException {
        OperationTheater ot = new OperationTheater();
        ot.setId(rs.getInt("id"));
        ot.setOtNumber(rs.getString("ot_number"));
        ot.setOtName(rs.getString("ot_name"));
        ot.setOtType(rs.getString("ot_type"));
        ot.setStatus(rs.getString("status"));
        ot.setEquipmentList(rs.getString("equipment_list"));
        ot.setLastSterilized(rs.getTimestamp("last_sterilized"));
        ot.setSterilizationMinutes(rs.getInt("sterilization_minutes"));
        ot.setCreatedAt(rs.getTimestamp("created_at"));
        return ot;
    }
}