package com.surgery.servlet;

import com.surgery.dao.SurgeryDAO;
import com.surgery.dao.SurgeonDAO;
import com.surgery.model.Surgeon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

/**
 * AJAX endpoint — returns surgeon availability for a given date/time/duration
 * GET /surgeonAvailability?date=&time=&duration=
 * Returns JSON array: [{ id, name, specialization, available: true/false }]
 */
@WebServlet("/surgeonAvailability")
public class SurgeonAvailabilityServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.getWriter().write("[]");
            return;
        }

        PrintWriter out = resp.getWriter();

        try {
            String date       = req.getParameter("date");
            String time       = req.getParameter("time");
            String durationStr= req.getParameter("duration");

            if (date == null || time == null || durationStr == null
                    || date.isEmpty() || time.isEmpty() || durationStr.isEmpty()) {
                out.write("[]");
                return;
            }

            int duration = Integer.parseInt(durationStr);

            SurgeonDAO surgeonDAO = new SurgeonDAO();
            SurgeryDAO surgeryDAO = new SurgeryDAO();

            List<Surgeon> allSurgeons = surgeonDAO.getAllSurgeons();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < allSurgeons.size(); i++) {
                Surgeon s = allSurgeons.get(i);
                boolean hasConflict = surgeryDAO.isSurgeonConflict(s.getId(), date, time, duration);
                boolean isAvailable = s.isAvailable() && !hasConflict;

                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(s.getId()).append(",");
                json.append("\"name\":\"").append(s.getFullName().replace("\"", "'")).append("\",");
                json.append("\"specialization\":\"").append(s.getSpecialization().replace("\"", "'")).append("\",");
                json.append("\"available\":").append(isAvailable).append(",");
                json.append("\"reason\":\"").append(
                        !s.isAvailable() ? "Marked unavailable" :
                                hasConflict ? "Busy at this time" : ""
                ).append("\"");
                json.append("}");
            }
            json.append("]");
            out.write(json.toString());

        } catch (NumberFormatException e) {
            out.write("[]");
        } catch (SQLException e) {
            out.write("[]");
        }
    }
}