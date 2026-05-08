package com.surgery.servlet;

import com.surgery.dao.PatientDAO;
import com.surgery.model.Patient;
import com.surgery.util.RiskCalculator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Patient Servlet - Handles patient CRUD + risk analysis + pre-op checklist
 */
@WebServlet("/patients")
public class PatientServlet extends HttpServlet {

    private final PatientDAO dao = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "list" -> {
                    List<Patient> patients = dao.getAllPatients();
                    req.setAttribute("patients", patients);
                    req.getRequestDispatcher("/pages/patients.jsp").forward(req, resp);
                }
                case "add" -> {
                    req.getRequestDispatcher("/pages/patient-form.jsp").forward(req, resp);
                }
                case "edit" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Patient p = dao.getPatientById(id);
                    req.setAttribute("patient", p);
                    req.getRequestDispatcher("/pages/patient-form.jsp").forward(req, resp);
                }
                case "delete" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.deletePatient(id);
                    resp.sendRedirect(req.getContextPath() + "/patients?msg=deleted");
                }
                case "view" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Patient p = dao.getPatientById(id);
                    req.setAttribute("patient", p);
                    req.getRequestDispatcher("/pages/patient-view.jsp").forward(req, resp);
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");

        try {
            // ── NEW: Pre-op checklist quick-update (from patient-view or card) ──
            if ("updatePreop".equals(action)) {
                int id          = Integer.parseInt(req.getParameter("id"));
                boolean labs    = "on".equals(req.getParameter("labsDone"));
                boolean ecg     = "on".equals(req.getParameter("ecgDone"));
                boolean consent = "on".equals(req.getParameter("consentSigned"));
                boolean anaes   = "on".equals(req.getParameter("anaesthesiaDone"));
                boolean npo     = "on".equals(req.getParameter("npoDone"));
                dao.updatePreopChecklist(id, labs, ecg, consent, anaes, npo);
                resp.sendRedirect(req.getContextPath() + "/patients?action=view&id=" + id + "&msg=preop_updated");
                return;
            }

            // ── Standard add / edit ──────────────────────────────────────────
            Patient p = buildPatientFromRequest(req);

            // Auto-calculate risk score
            double riskScore = RiskCalculator.calculateRiskScore(p);
            String riskLevel = RiskCalculator.getRiskLevel(riskScore);
            p.setRiskScore(riskScore);
            p.setRiskLevel(riskLevel);

            if ("add".equals(action)) {
                p.setPatientId(dao.generateNextPatientId());
                dao.insertPatient(p);
                resp.sendRedirect(req.getContextPath() + "/patients?msg=added");

            } else if ("edit".equals(action)) {
                p.setId(Integer.parseInt(req.getParameter("id")));
                dao.updatePatient(p);
                resp.sendRedirect(req.getContextPath() + "/patients?msg=updated");
            }

        } catch (SQLException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }

    // ─── Helper: Build patient from form ─────────────────────

    private Patient buildPatientFromRequest(HttpServletRequest req) {
        Patient p = new Patient();
        p.setFullName(req.getParameter("fullName"));
        p.setAge(Integer.parseInt(req.getParameter("age")));
        p.setGender(req.getParameter("gender"));
        p.setBloodGroup(req.getParameter("bloodGroup"));
        p.setContactNumber(req.getParameter("contactNumber"));
        p.setAddress(req.getParameter("address"));
        p.setHasDiabetes("on".equals(req.getParameter("hasDiabetes")));
        p.setHasHypertension("on".equals(req.getParameter("hasHypertension")));
        p.setHasHeartDisease("on".equals(req.getParameter("hasHeartDisease")));
        p.setHasKidneyDisease("on".equals(req.getParameter("hasKidneyDisease")));
        p.setSmoker("on".equals(req.getParameter("isSmoker")));

        String bmiStr = req.getParameter("bmi");
        p.setBmi(bmiStr != null && !bmiStr.isEmpty() ? Double.parseDouble(bmiStr) : 0.0);
        p.setAsaGrade(Integer.parseInt(req.getParameter("asaGrade")));
        p.setMedicalHistory(req.getParameter("medicalHistory"));
        p.setAllergies(req.getParameter("allergies"));

        // ── NEW: Pre-op checklist fields ──
        p.setLabsDone("on".equals(req.getParameter("labsDone")));
        p.setEcgDone("on".equals(req.getParameter("ecgDone")));
        p.setConsentSigned("on".equals(req.getParameter("consentSigned")));
        p.setAnaesthesiaDone("on".equals(req.getParameter("anaesthesiaDone")));
        p.setNpoDone("on".equals(req.getParameter("npoDone")));

        return p;
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }
}