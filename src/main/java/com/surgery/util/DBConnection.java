package com.surgery.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String host = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
    private static final String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";
    private static final String db = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "surgery_db";
    private static final String USER = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
    private static final String PASS = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "admin1234";

    private static final String URL = "jdbc:mysql://" + host + ":" + port + "/" + db
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

    private static Connection connection = null;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found: " + e.getMessage());
        }
    }

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