package com.surgery.util;

import com.surgery.model.Patient;

/**
 * Surgery Risk Analysis Calculator
 * Calculates patient risk score based on multiple health factors
 * 
 * Risk Score: 0-100
 * LOW:      0-25
 * MEDIUM:  26-50
 * HIGH:    51-75
 * CRITICAL: 76-100
 */
public class RiskCalculator {

    // Risk level thresholds
    public static final double LOW_THRESHOLD      = 25.0;
    public static final double MEDIUM_THRESHOLD   = 50.0;
    public static final double HIGH_THRESHOLD     = 75.0;

    /**
     * Calculate risk score for a patient
     * @param patient Patient object with all health data
     * @return risk score (0-100)
     */
    public static double calculateRiskScore(Patient patient) {
        double score = 0.0;

        // 1. Age factor (max 20 points)
        score += calculateAgeScore(patient.getAge());

        // 2. ASA Grade factor (max 30 points)
        score += calculateASAScore(patient.getAsaGrade());

        // 3. Comorbidities (max 35 points)
        score += calculateComorbiditiesScore(patient);

        // 4. BMI factor (max 10 points)
        score += calculateBMIScore(patient.getBmi());

        // 5. Smoking (max 5 points)
        if (patient.isSmoker()) score += 5.0;

        // Cap at 100
        return Math.min(score, 100.0);
    }

    /**
     * Age risk scoring
     */
    private static double calculateAgeScore(int age) {
        if (age < 18)       return 5.0;   // Pediatric — some risk
        if (age <= 40)      return 0.0;   // Young adult — minimal risk
        if (age <= 55)      return 5.0;   // Middle age
        if (age <= 65)      return 10.0;  // Senior
        if (age <= 75)      return 15.0;  // Elderly
        return 20.0;                       // Very elderly
    }

    /**
     * ASA (American Society of Anesthesiologists) Grade scoring
     * Grade 1: Normal healthy patient
     * Grade 2: Mild systemic disease
     * Grade 3: Severe systemic disease
     * Grade 4: Life-threatening systemic disease
     * Grade 5: Moribund patient
     */
    private static double calculateASAScore(int asaGrade) {
        return switch (asaGrade) {
            case 1 -> 0.0;
            case 2 -> 7.5;
            case 3 -> 15.0;
            case 4 -> 25.0;
            case 5 -> 30.0;
            default -> 0.0;
        };
    }

    /**
     * Comorbidities scoring (underlying conditions)
     */
    private static double calculateComorbiditiesScore(Patient patient) {
        double score = 0.0;
        if (patient.isHasDiabetes())      score += 10.0;
        if (patient.isHasHypertension())  score += 8.0;
        if (patient.isHasHeartDisease())  score += 15.0;
        if (patient.isHasKidneyDisease()) score += 10.0;  // adjust max still caps at 35
        return Math.min(score, 35.0);
    }

    /**
     * BMI risk scoring
     * Normal BMI: 18.5 - 24.9
     */
    private static double calculateBMIScore(double bmi) {
        if (bmi <= 0)          return 0.0;  // No BMI data
        if (bmi < 18.5)        return 5.0;  // Underweight
        if (bmi <= 24.9)       return 0.0;  // Normal
        if (bmi <= 29.9)       return 3.0;  // Overweight
        if (bmi <= 34.9)       return 7.0;  // Obese Class I
        return 10.0;                         // Obese Class II+
    }

    /**
     * Get risk level label from score
     */
    public static String getRiskLevel(double score) {
        if (score <= LOW_THRESHOLD)    return "LOW";
        if (score <= MEDIUM_THRESHOLD) return "MEDIUM";
        if (score <= HIGH_THRESHOLD)   return "HIGH";
        return "CRITICAL";
    }

    /**
     * Get CSS class for risk level (used in UI)
     */
    public static String getRiskCSSClass(String riskLevel) {
        return switch (riskLevel) {
            case "LOW"      -> "risk-low";
            case "MEDIUM"   -> "risk-medium";
            case "HIGH"     -> "risk-high";
            case "CRITICAL" -> "risk-critical";
            default         -> "risk-low";
        };
    }

    /**
     * Get priority recommendation based on risk
     */
    public static String getPriorityRecommendation(double riskScore, String surgeryCategory) {
        if ("EMERGENCY".equals(surgeryCategory)) return "CRITICAL";
        if (riskScore > HIGH_THRESHOLD)          return "HIGH";
        if (riskScore > MEDIUM_THRESHOLD)        return "MEDIUM";
        if ("URGENT".equals(surgeryCategory))    return "HIGH";
        return "LOW";
    }
}
