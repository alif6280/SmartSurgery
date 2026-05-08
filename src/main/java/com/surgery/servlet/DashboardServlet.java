package com.surgery.servlet;

import com.surgery.dao.*;
import com.surgery.model.Surgery;
import com.surgery.model.OperationTheater;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            PatientDAO patientDAO = new PatientDAO();
            SurgeonDAO surgeonDAO = new SurgeonDAO();
            SurgeryDAO surgeryDAO = new SurgeryDAO();
            OperationTheaterDAO otDAO = new OperationTheaterDAO(); // ← NEW

            // Statistics
            req.setAttribute("totalPatients",  patientDAO.getTotalPatients());
            req.setAttribute("highRiskCount",  patientDAO.getHighRiskCount());
            req.setAttribute("totalSurgeons",  surgeonDAO.getTotalSurgeons());
            req.setAttribute("scheduledCount", surgeryDAO.getTotalScheduled());
            req.setAttribute("todayCount",     surgeryDAO.getTodayCount());

            // Today's surgeries
            List<Surgery> todaySurgeries = surgeryDAO.getTodaySurgeries();
            req.setAttribute("todaySurgeries", todaySurgeries);

            // All patients (for search)
            req.setAttribute("patients", patientDAO.getAllPatients());

            // Operation Theaters — dashboard OT status fix ← NEW
            List<OperationTheater> otList = otDAO.getAllOTs();
            req.setAttribute("operationTheaters", otList);
            req.setAttribute("surgeons", surgeonDAO.getAllSurgeons());

            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Error loading dashboard: " + e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }
}