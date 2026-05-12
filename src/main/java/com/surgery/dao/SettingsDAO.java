package com.surgery.dao;

import com.surgery.model.Settings;
import com.surgery.util.DBConnection;

import java.sql.*;
import java.util.Map;

public class SettingsDAO {

    public Settings loadAll() throws SQLException {
        Settings settings = new Settings();
        String sql = "SELECT setting_key, setting_value FROM system_settings";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                settings.set(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        }
        return settings;
    }

    public boolean saveCategory(Map<String, String> params, String category) throws SQLException {
        String insertSql = "INSERT INTO system_settings (setting_key, setting_value, category) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE setting_value = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                ps.setString(1, entry.getKey());
                ps.setString(2, entry.getValue());
                ps.setString(3, category);
                ps.setString(4, entry.getValue());
                ps.addBatch();
            }
            ps.executeBatch();
            return true;
        }
    }

    public boolean saveKey(String key, String value) throws SQLException {
        String sql = "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.setString(3, value);
            return ps.executeUpdate() > 0;
        }
    }
}