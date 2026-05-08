package com.surgery.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Patient {

    private int id;
    private String patientId;
    private String fullName;
    private int age;
    private String gender;
    private String bloodGroup;
    private String contactNumber;
    private String address;

    // Risk factors
    private boolean hasDiabetes;
    private boolean hasHypertension;
    private boolean hasHeartDisease;
    private boolean hasKidneyDisease;
    private boolean isSmoker;
    private double bmi;
    private int asaGrade;
    private String medicalHistory;
    private String allergies;

    // Calculated
    private double riskScore;
    private String riskLevel;
    private Timestamp registeredAt;

    // Surgery status (joined from surgeries table)
    private String lastSurgeryStatus;   // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, null
    private Date lastSurgeryDate;       // scheduled_date of latest surgery

    // ── NEW: Assigned surgeon & OT Room (joined from surgeries) ──
    private String assignedSurgeon;     // surgeon name of latest surgery
    private String otRoom;              // OT room of latest surgery

    // ── NEW: Pre-op Checklist ────────────────────────────────────
    private boolean labsDone;
    private boolean ecgDone;
    private boolean consentSigned;
    private boolean anaesthesiaDone;
    private boolean npoDone;

    // ── NEW: Last updated timestamp ──────────────────────────────
    private Timestamp lastUpdated;

    // ─── Constructors ───────────────────────────────────────

    public Patient() {}

    public Patient(String patientId, String fullName, int age, String gender) {
        this.patientId = patientId;
        this.fullName  = fullName;
        this.age       = age;
        this.gender    = gender;
    }

    // ─── Getters & Setters ──────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public boolean isHasDiabetes() { return hasDiabetes; }
    public void setHasDiabetes(boolean hasDiabetes) { this.hasDiabetes = hasDiabetes; }

    public boolean isHasHypertension() { return hasHypertension; }
    public void setHasHypertension(boolean hasHypertension) { this.hasHypertension = hasHypertension; }

    public boolean isHasHeartDisease() { return hasHeartDisease; }
    public void setHasHeartDisease(boolean hasHeartDisease) { this.hasHeartDisease = hasHeartDisease; }

    public boolean isHasKidneyDisease() { return hasKidneyDisease; }
    public void setHasKidneyDisease(boolean hasKidneyDisease) { this.hasKidneyDisease = hasKidneyDisease; }

    public boolean isSmoker() { return isSmoker; }
    public void setSmoker(boolean smoker) { isSmoker = smoker; }

    public double getBmi() { return bmi; }
    public void setBmi(double bmi) { this.bmi = bmi; }

    public int getAsaGrade() { return asaGrade; }
    public void setAsaGrade(int asaGrade) { this.asaGrade = asaGrade; }

    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }

    public String getAllergies() { return allergies; }
    public void setAllergies(String allergies) { this.allergies = allergies; }

    public double getRiskScore() { return riskScore; }
    public void setRiskScore(double riskScore) { this.riskScore = riskScore; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public Timestamp getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(Timestamp registeredAt) { this.registeredAt = registeredAt; }

    public String getLastSurgeryStatus() { return lastSurgeryStatus; }
    public void setLastSurgeryStatus(String lastSurgeryStatus) { this.lastSurgeryStatus = lastSurgeryStatus; }

    public Date getLastSurgeryDate() { return lastSurgeryDate; }
    public void setLastSurgeryDate(Date lastSurgeryDate) { this.lastSurgeryDate = lastSurgeryDate; }

    // ── NEW getters/setters ──────────────────────────────────

    public String getAssignedSurgeon() { return assignedSurgeon; }
    public void setAssignedSurgeon(String assignedSurgeon) { this.assignedSurgeon = assignedSurgeon; }

    public String getOtRoom() { return otRoom; }
    public void setOtRoom(String otRoom) { this.otRoom = otRoom; }

    public boolean isLabsDone() { return labsDone; }
    public void setLabsDone(boolean labsDone) { this.labsDone = labsDone; }

    public boolean isEcgDone() { return ecgDone; }
    public void setEcgDone(boolean ecgDone) { this.ecgDone = ecgDone; }

    public boolean isConsentSigned() { return consentSigned; }
    public void setConsentSigned(boolean consentSigned) { this.consentSigned = consentSigned; }

    public boolean isAnaesthesiaDone() { return anaesthesiaDone; }
    public void setAnaesthesiaDone(boolean anaesthesiaDone) { this.anaesthesiaDone = anaesthesiaDone; }

    public boolean isNpoDone() { return npoDone; }
    public void setNpoDone(boolean npoDone) { this.npoDone = npoDone; }

    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }

    @Override
    public String toString() {
        return "Patient{id=" + id + ", name='" + fullName + "', riskLevel='" + riskLevel + "'}";
    }
}