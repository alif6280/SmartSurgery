package com.surgery.servlet;

import com.surgery.dao.SurgeryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

/**
 * AJAX endpoint for real-time conflict detection
 * GET /checkConflict?otId=&surgeonId=&patientId=&date=&time=&duration=
 */
@WebServlet("/checkConflict")
public class ConflictCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.getWriter().write("{\"error\":\"Not logged in\"}");
            return;
        }

        PrintWriter out = resp.getWriter();

        try {
            String otIdStr      = req.getParameter("otId");
            String surgeonIdStr = req.getParameter("surgeonId");
            String patientIdStr = req.getParameter("patientId");
            String date         = req.getParameter("date");
            String time         = req.getParameter("time");
            String durationStr  = req.getParameter("duration");

            // Validate required fields
            if (otIdStr == null || date == null || time == null || durationStr == null
                    || otIdStr.isEmpty() || date.isEmpty() || time.isEmpty() || durationStr.isEmpty()) {
                out.write("{\"status\":\"incomplete\"}");
                return;
            }

            int otId      = Integer.parseInt(otIdStr);
            int duration  = Integer.parseInt(durationStr);
            int surgeonId = (surgeonIdStr != null && !surgeonIdStr.isEmpty()) ? Integer.parseInt(surgeonIdStr) : 0;
            int patientId = (patientIdStr != null && !patientIdStr.isEmpty()) ? Integer.parseInt(patientIdStr) : 0;

            SurgeryDAO dao = new SurgeryDAO();

            // OT Conflict
            boolean otConflict = dao.isOTConflict(otId, date, time, duration);

            // Surgeon Conflict
            boolean surgeonConflict = false;
            if (surgeonId > 0) {
                surgeonConflict = dao.isSurgeonConflict(surgeonId, date, time, duration);
            }

            // Patient Conflict
            boolean patientConflict = false;
            if (patientId > 0) {
                patientConflict = dao.isPatientConflict(patientId, date, time, duration);
            }

            // Build response
            StringBuilder json = new StringBuilder("{");
            json.append("\"status\":\"checked\",");
            json.append("\"otConflict\":").append(otConflict).append(",");
            json.append("\"surgeonConflict\":").append(surgeonConflict).append(",");
            json.append("\"patientConflict\":").append(patientConflict).append(",");

            boolean anyConflict = otConflict || surgeonConflict || patientConflict;

            if (!anyConflict) {
                json.append("\"safe\":true,");
                json.append("\"message\":\"No conflicts detected. OT, surgeon and patient are all available.\"");
            } else {
                json.append("\"safe\":false,");
                StringBuilder msg = new StringBuilder();
                if (otConflict)      msg.append("OT is already booked at this time. ");
                if (surgeonConflict) msg.append("Surgeon has another surgery at this time. ");
                if (patientConflict) msg.append("Patient already has a surgery scheduled at this time.");
                json.append("\"message\":\"").append(msg.toString().trim()).append("\"");
            }

            json.append("}");
            out.write(json.toString());

        } catch (NumberFormatException e) {
            out.write("{\"error\":\"Invalid input\"}");
        } catch (SQLException e) {
            out.write("{\"error\":\"Database error: " + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}