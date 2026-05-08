package com.surgery.servlet;

import com.surgery.dao.*;
import com.surgery.model.*;
import com.surgery.util.RiskCalculator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.surgery.dao.OperationTheaterDAO;

import java.io.IOException;
import java.sql.*;
import java.util.List;

@WebServlet("/surgeries")
public class SurgeryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            SurgeryDAO surgeryDAO = new SurgeryDAO();
            PatientDAO patientDAO = new PatientDAO();
            SurgeonDAO surgeonDAO = new SurgeonDAO();

            switch (action) {
                case "list" -> {
                    List<Surgery> surgeries = surgeryDAO.getAllSurgeries();
                    req.setAttribute("surgeries", surgeries);
                    req.getRequestDispatcher("/pages/surgeries.jsp").forward(req, resp);
                }
                case "schedule" -> {
                    req.setAttribute("patients", patientDAO.getAllPatients());
                    req.setAttribute("surgeons", surgeonDAO.getAvailableSurgeons());

                    // OT list pass করুন (নতুন)
                    OperationTheaterDAO otDAO = new OperationTheaterDAO();
                    req.setAttribute("ots", otDAO.getAllOTs());

                    req.getRequestDispatcher("/pages/schedule-form.jsp").forward(req, resp);
                }
                case "updateStatus" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    String status = req.getParameter("status");
                    surgeryDAO.updateStatus(id, status);
                    resp.sendRedirect(req.getContextPath() + "/surgeries?msg=updated");
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            int patientId = Integer.parseInt(req.getParameter("patientId"));
            int surgeonId = Integer.parseInt(req.getParameter("surgeonId"));
            int otId      = Integer.parseInt(req.getParameter("otId"));
            String date   = req.getParameter("scheduledDate");
            String time   = req.getParameter("scheduledTime");
            int duration  = Integer.parseInt(req.getParameter("estimatedDuration"));

            // Conflict check
            SurgeryDAO surgeryDAO = new SurgeryDAO();
            boolean otConflict      = surgeryDAO.isOTConflict(otId, date, time, duration);
            boolean surgeonConflict = surgeryDAO.isSurgeonConflict(surgeonId, date, time, duration);
            boolean patientConflict = surgeryDAO.isPatientConflict(patientId, date, time, duration);

            if (otConflict || surgeonConflict || patientConflict) {
                String errMsg;
                if (otConflict)           errMsg = "⚠️ OT Conflict! This OT is already booked at this time.";
                else if (surgeonConflict) errMsg = "⚠️ Surgeon Conflict! This surgeon has another surgery at this time.";
                else                      errMsg = "⚠️ Patient Conflict! This patient already has a surgery scheduled at this time.";

                req.setAttribute("error", errMsg);
                PatientDAO patientDAO = new PatientDAO();
                SurgeonDAO surgeonDAO = new SurgeonDAO();
                OperationTheaterDAO otDAO = new OperationTheaterDAO();
                req.setAttribute("patients", patientDAO.getAllPatients());
                req.setAttribute("surgeons", surgeonDAO.getAllSurgeons());
                req.setAttribute("ots", otDAO.getAllOTs());
                req.getRequestDispatcher("/pages/schedule-form.jsp").forward(req, resp);
                return;
            }

            PatientDAO patientDAO = new PatientDAO();
            Patient patient = patientDAO.getPatientById(patientId);
            String category = req.getParameter("surgeryCategory");
            String priority = RiskCalculator.getPriorityRecommendation(patient.getRiskScore(), category);

            // Get user id from session
            HttpSession session = req.getSession(false);
            int userId = (int) session.getAttribute("userId");

            Surgery s = new Surgery();
            s.setSurgeryRef(surgeryDAO.generateSurgeryRef());
            s.setPatientId(patientId);
            s.setSurgeonId(surgeonId);
            s.setOtId(otId);
            s.setSurgeryType(req.getParameter("surgeryType"));
            s.setSurgeryCategory(category);
            s.setPriorityLevel(priority);
            s.setScheduledDate(Date.valueOf(date));
            s.setScheduledTime(Time.valueOf(time + ":00"));
            s.setEstimatedDuration(duration);
            s.setPreOpNotes(req.getParameter("preOpNotes"));
            s.setCreatedBy(userId);

            surgeryDAO.insertSurgery(s);
            resp.sendRedirect(req.getContextPath() + "/surgeries?msg=scheduled");

        } catch (SQLException e) {
            req.setAttribute("error", "Scheduling failed: " + e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }
}