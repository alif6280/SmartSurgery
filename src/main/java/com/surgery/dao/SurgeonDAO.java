package com.surgery.dao;

import com.surgery.model.Surgeon;
import com.surgery.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SurgeonDAO {

    public List<Surgeon> getAllSurgeons() throws SQLException {
        List<Surgeon> list = new ArrayList<>();
        String sql = "SELECT * FROM surgeons ORDER BY CAST(SUBSTRING(surgeon_id, 11) AS UNSIGNED)";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<Surgeon> getAvailableSurgeons() throws SQLException {
        List<Surgeon> list = new ArrayList<>();
        String sql = "SELECT * FROM surgeons WHERE is_available = TRUE ORDER BY CAST(SUBSTRING(surgeon_id, 11) AS UNSIGNED)";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public Surgeon getSurgeonById(int id) throws SQLException {
        String sql = "SELECT * FROM surgeons WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        }
        return null;
    }

    public boolean insertSurgeon(Surgeon s) throws SQLException {
        String sql = """
            INSERT INTO surgeons (surgeon_id, full_name, specialization, qualification,
                experience_years, contact_number, email, max_surgeries_per_day, gender)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getSurgeonId());
            ps.setString(2, s.getFullName());
            ps.setString(3, s.getSpecialization());
            ps.setString(4, s.getQualification());
            ps.setInt(5,    s.getExperienceYears());
            ps.setString(6, s.getContactNumber());
            ps.setString(7, s.getEmail());
            ps.setInt(8,    s.getMaxSurgeriesPerDay());
            ps.setString(9, s.getGender() != null ? s.getGender() : "MALE");
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateSurgeon(Surgeon s) throws SQLException {
        String sql = """
            UPDATE surgeons SET full_name=?, specialization=?, qualification=?,
                experience_years=?, contact_number=?, email=?, max_surgeries_per_day=?, gender=?
            WHERE id=?
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getFullName());
            ps.setString(2, s.getSpecialization());
            ps.setString(3, s.getQualification());
            ps.setInt(4,    s.getExperienceYears());
            ps.setString(5, s.getContactNumber());
            ps.setString(6, s.getEmail());
            ps.setInt(7,    s.getMaxSurgeriesPerDay());
            ps.setString(8, s.getGender() != null ? s.getGender() : "MALE");
            ps.setInt(9,    s.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteSurgeon(int id) throws SQLException {
        String sql = "DELETE FROM surgeons WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleAvailability(int id) throws SQLException {
        String sql = "UPDATE surgeons SET is_available = NOT is_available WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public int getTotalSurgeons() throws SQLException {
        String sql = "SELECT COUNT(*) FROM surgeons WHERE is_available = TRUE";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private Surgeon mapRow(ResultSet rs) throws SQLException {
        Surgeon s = new Surgeon();
        s.setId(rs.getInt("id"));
        s.setSurgeonId(rs.getString("surgeon_id"));
        s.setFullName(rs.getString("full_name"));
        s.setSpecialization(rs.getString("specialization"));
        s.setQualification(rs.getString("qualification"));
        s.setExperienceYears(rs.getInt("experience_years"));
        s.setContactNumber(rs.getString("contact_number"));
        s.setEmail(rs.getString("email"));
        s.setAvailable(rs.getBoolean("is_available"));
        s.setMaxSurgeriesPerDay(rs.getInt("max_surgeries_per_day"));
        s.setGender(rs.getString("gender"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
