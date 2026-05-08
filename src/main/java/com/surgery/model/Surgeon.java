package com.surgery.model;

import java.sql.Timestamp;

/**
 * Surgeon Model Class
 */
public class Surgeon {

    private int id;
    private String surgeonId;
    private String fullName;
    private String specialization;
    private String qualification;
    private int experienceYears;
    private String contactNumber;
    private String email;
    private boolean isAvailable;
    private int maxSurgeriesPerDay;
    private String gender; // "MALE" or "FEMALE"
    private Timestamp createdAt;

    // ─── Constructors ─────────────────────────

    public Surgeon() {}

    public Surgeon(String surgeonId, String fullName, String specialization) {
        this.surgeonId = surgeonId;
        this.fullName = fullName;
        this.specialization = specialization;
    }

    // ─── Getters & Setters ────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSurgeonId() { return surgeonId; }
    public void setSurgeonId(String surgeonId) { this.surgeonId = surgeonId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getQualification() { return qualification; }
    public void setQualification(String qualification) { this.qualification = qualification; }

    public int getExperienceYears() { return experienceYears; }
    public void setExperienceYears(int experienceYears) { this.experienceYears = experienceYears; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }

    public int getMaxSurgeriesPerDay() { return maxSurgeriesPerDay; }
    public void setMaxSurgeriesPerDay(int maxSurgeriesPerDay) { this.maxSurgeriesPerDay = maxSurgeriesPerDay; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ─── Helper Methods ───────────────────────

    /**
     * Returns true if surgeon is female
     */
    public boolean isFemale() {
        return "FEMALE".equalsIgnoreCase(gender);
    }

    /**
     * Returns surgeon initials for avatar display
     */
    public String getInitials() {
        if (fullName == null || fullName.trim().isEmpty()) return "?";
        String[] parts = fullName.trim().split("\\s+");
        java.util.List<String> meaningful = new java.util.ArrayList<>();
        for (String p : parts) {
            String clean = p.replaceAll("\\.", "");
            if (!clean.equalsIgnoreCase("Dr") &&
                    !clean.equalsIgnoreCase("Prof") &&
                    !clean.equalsIgnoreCase("Md") &&
                    !clean.equalsIgnoreCase("Mr") &&
                    !clean.equalsIgnoreCase("Mrs") &&
                    !clean.equalsIgnoreCase("Ms") &&
                    clean.length() > 0) {
                meaningful.add(clean);
            }
        }
        if (meaningful.isEmpty()) return parts[0].substring(0, 1).toUpperCase();
        if (meaningful.size() == 1) return meaningful.get(0).substring(0, 1).toUpperCase();
        return meaningful.get(0).substring(0, 1).toUpperCase()
                + meaningful.get(meaningful.size() - 1).substring(0, 1).toUpperCase();
    }

    /**
     * Returns specialization icon based on type
     */
    public String getSpecializationIcon() {
        if (specialization == null) return "🏥";
        String s = specialization.toLowerCase();
        if (s.contains("cardiac") || s.contains("heart")) return "❤️";
        if (s.contains("ortho")) return "🦴";
        if (s.contains("neuro") || s.contains("brain")) return "🧠";
        if (s.contains("plastic")) return "💄";
        if (s.contains("ent") || s.contains("ear")) return "👂";
        if (s.contains("eye") || s.contains("ophthal")) return "👁️";
        if (s.contains("urology") || s.contains("kidney")) return "🫘";
        if (s.contains("laparoscop")) return "🔬";
        if (s.contains("general")) return "⚕️";
        return "🏥";
    }
}
