package com.surgery.model;

import java.sql.Timestamp;

public class OperationTheater {

    private int id;
    private String otNumber;
    private String otName;
    private String otType;       // GENERAL, CARDIAC, NEURO, ORTHOPEDIC, EMERGENCY, LAPAROSCOPIC
    private String status;       // AVAILABLE, OCCUPIED, MAINTENANCE, STERILIZING
    private String equipmentList;
    private Timestamp lastSterilized;
    private int sterilizationMinutes; // how long sterilization takes
    private Timestamp createdAt;

    // ─── Constructors ──────────────────────
    public OperationTheater() {}

    public OperationTheater(String otNumber, String otName, String otType) {
        this.otNumber = otNumber;
        this.otName   = otName;
        this.otType   = otType;
        this.status   = "AVAILABLE";
        this.sterilizationMinutes = 30;
    }

    // ─── Getters & Setters ─────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getOtNumber() { return otNumber; }
    public void setOtNumber(String otNumber) { this.otNumber = otNumber; }

    public String getOtName() { return otName; }
    public void setOtName(String otName) { this.otName = otName; }

    public String getOtType() { return otType; }
    public void setOtType(String otType) { this.otType = otType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getEquipmentList() { return equipmentList; }
    public void setEquipmentList(String equipmentList) { this.equipmentList = equipmentList; }

    public Timestamp getLastSterilized() { return lastSterilized; }
    public void setLastSterilized(Timestamp lastSterilized) { this.lastSterilized = lastSterilized; }

    public int getSterilizationMinutes() { return sterilizationMinutes; }
    public void setSterilizationMinutes(int sterilizationMinutes) { this.sterilizationMinutes = sterilizationMinutes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isAvailable() { return "AVAILABLE".equals(this.status); }

    // ─── Helper: minutes since last sterilized ───
    public long getMinutesSinceLastSterilized() {
        if (lastSterilized == null) return -1;
        long diff = System.currentTimeMillis() - lastSterilized.getTime();
        return diff / (1000 * 60);
    }

    // ─── Helper: sterilization remaining minutes ───
    public long getSterilizationRemainingMinutes() {
        if (lastSterilized == null || !"STERILIZING".equals(status)) return 0;
        long elapsedMin = getMinutesSinceLastSterilized();
        long remaining  = sterilizationMinutes - elapsedMin;
        return Math.max(remaining, 0);
    }

    // ─── Helper: is sterilization done? ───
    public boolean isSterilizationComplete() {
        if (!"STERILIZING".equals(status)) return false;
        return getSterilizationRemainingMinutes() <= 0;
    }
}