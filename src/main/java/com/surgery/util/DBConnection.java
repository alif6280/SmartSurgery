package com.surgery.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Connection Utility
 * Manages MySQL connection for the Surgery System
 */
public class DBConnection {

    // ⚠️ Change these values to match your MySQL setup
    private static final String URL  = "jdbc:mysql://localhost:3306/surgery_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";       // Your MySQL username
    private static final String PASS = "admin1234";       // Your MySQL password

    private static Connection connection = null;

    // Load MySQL driver once when class loads
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found: " + e.getMessage());
        }
    }

    /**
     * Get database connection (creates one if not exists)
     */
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                connection = DriverManager.getConnection(URL, USER, PASS);
                System.out.println("✅ Database connected successfully.");
            } catch (SQLException e) {
                System.err.println("❌ DB Connection failed: " + e.getMessage());
                throw e;
            }
        }
        return connection;
    }

    /**
     * Close the database connection
     */
    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}
