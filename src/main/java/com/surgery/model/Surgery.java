package com.surgery.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Surgery Model Class
 * Represents a scheduled surgery
 */
public class Surgery {

    private int id;
    private String surgeryRef;
    private int patientId;
    private int surgeonId;
    private int otId;
    private String surgeryType;
    private String surgeryCategory;   // ELECTIVE, URGENT, EMERGENCY
    private String priorityLevel;     // LOW, MEDIUM, HIGH, CRITICAL
    private Date scheduledDate;
    private Time scheduledTime;
    private int estimatedDuration;    // in minutes
    private String status;            // SCHEDULED, IN_PROGRESS, COMPLETED, etc.
    private String preOpNotes;
    private String postOpNotes;
    private String complications;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined fields (for display purposes)
    private String patientName;
    private String patientRiskLevel;
    private String surgeonName;
    private String otNumber;
    private String otName;

    // ─── Constructors ─────────────────────────────────────

    public Surgery() {}

    // ─── Getters & Setters ────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSurgeryRef() { return surgeryRef; }
    public void setSurgeryRef(String surgeryRef) { this.surgeryRef = surgeryRef; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public int getSurgeonId() { return surgeonId; }
    public void setSurgeonId(int surgeonId) { this.surgeonId = surgeonId; }

    public int getOtId() { return otId; }
    public void setOtId(int otId) { this.otId = otId; }

    public String getSurgeryType() { return surgeryType; }
    public void setSurgeryType(String surgeryType) { this.surgeryType = surgeryType; }

    public String getSurgeryCategory() { return surgeryCategory; }
    public void setSurgeryCategory(String surgeryCategory) { this.surgeryCategory = surgeryCategory; }

    public String getPriorityLevel() { return priorityLevel; }
    public void setPriorityLevel(String priorityLevel) { this.priorityLevel = priorityLevel; }

    public Date getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(Date scheduledDate) { this.scheduledDate = scheduledDate; }

    public Time getScheduledTime() { return scheduledTime; }
    public void setScheduledTime(Time scheduledTime) { this.scheduledTime = scheduledTime; }

    public int getEstimatedDuration() { return estimatedDuration; }
    public void setEstimatedDuration(int estimatedDuration) { this.estimatedDuration = estimatedDuration; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPreOpNotes() { return preOpNotes; }
    public void setPreOpNotes(String preOpNotes) { this.preOpNotes = preOpNotes; }

    public String getPostOpNotes() { return postOpNotes; }
    public void setPostOpNotes(String postOpNotes) { this.postOpNotes = postOpNotes; }

    public String getComplications() { return complications; }
    public void setComplications(String complications) { this.complications = complications; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Joined display fields
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientRiskLevel() { return patientRiskLevel; }
    public void setPatientRiskLevel(String patientRiskLevel) { this.patientRiskLevel = patientRiskLevel; }

    public String getSurgeonName() { return surgeonName; }
    public void setSurgeonName(String surgeonName) { this.surgeonName = surgeonName; }

    public String getOtNumber() { return otNumber; }
    public void setOtNumber(String otNumber) { this.otNumber = otNumber; }

    public String getOtName() { return otName; }
    public void setOtName(String otName) { this.otName = otName; }

    // ─── Helper Methods ───────────────────────────────────

    /**
     * Returns patient name initials for avatar display
     * e.g. "Sumaiya" -> "S", "Muntashir Alif" -> "MA"
     */
    public String getPatientInitials() {
        if (patientName == null || patientName.trim().isEmpty()) return "?";
        String[] parts = patientName.trim().split("\\s+");
        if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
        return parts[0].substring(0, 1).toUpperCase()
                + parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
    public String getFormattedTime() {
        if (scheduledTime == null) return "";
        return scheduledTime.toLocalTime()
                .format(java.time.format.DateTimeFormatter.ofPattern("hh:mm a"));
    }
}
