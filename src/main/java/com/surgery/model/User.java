package com.surgery.model;

import java.sql.Timestamp;

/**
 * User Model Class (for authentication)
 */
public class User {

    private int id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String role;        // ADMIN, DOCTOR, NURSE
    private boolean isActive;
    private Timestamp createdAt;

    public User() {}

    public User(String username, String fullName, String role) {
        this.username = username;
        this.fullName = fullName;
        this.role = role;
        this.isActive = true;
    }

    // ─── Getters & Setters ─────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
