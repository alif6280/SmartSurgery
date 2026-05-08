package com.surgery.servlet;

import com.surgery.dao.SurgeonDAO;
import com.surgery.model.Surgeon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/surgeons")
public class SurgeonServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            SurgeonDAO dao = new SurgeonDAO();

            switch (action) {
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.deleteSurgeon(id);
                    resp.sendRedirect(req.getContextPath() + "/surgeons?msg=deleted");
                    break;
                }
                case "toggle": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.toggleAvailability(id);
                    resp.sendRedirect(req.getContextPath() + "/surgeons");
                    break;
                }
                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Surgeon s = dao.getSurgeonById(id);
                    req.setAttribute("editSurgeon", s);
                    List<Surgeon> surgeons = dao.getAllSurgeons();
                    req.setAttribute("surgeons", surgeons);
                    req.getRequestDispatcher("/pages/surgeons.jsp").forward(req, resp);
                    break;
                }
                default: {
                    List<Surgeon> surgeons = dao.getAllSurgeons();
                    req.setAttribute("surgeons", surgeons);
                    req.getRequestDispatcher("/pages/surgeons.jsp").forward(req, resp);
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

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            SurgeonDAO dao = new SurgeonDAO();

            switch (action) {
                case "add": {
                    Surgeon s = new Surgeon();
                    s.setSurgeonId(req.getParameter("surgeonId"));
                    s.setFullName(req.getParameter("fullName"));
                    s.setSpecialization(req.getParameter("specialization"));
                    s.setQualification(req.getParameter("qualification"));
                    s.setExperienceYears(Integer.parseInt(req.getParameter("experienceYears")));
                    s.setContactNumber(req.getParameter("contactNumber"));
                    s.setEmail(req.getParameter("email"));
                    s.setMaxSurgeriesPerDay(Integer.parseInt(req.getParameter("maxSurgeriesPerDay")));
                    // ── gender ──
                    String gender = req.getParameter("gender");
                    s.setGender(gender != null && !gender.isEmpty() ? gender : "MALE");
                    dao.insertSurgeon(s);
                    resp.sendRedirect(req.getContextPath() + "/surgeons?msg=added");
                    break;
                }
                case "edit": {
                    Surgeon s = new Surgeon();
                    s.setId(Integer.parseInt(req.getParameter("id")));
                    s.setFullName(req.getParameter("fullName"));
                    s.setSpecialization(req.getParameter("specialization"));
                    s.setQualification(req.getParameter("qualification"));
                    s.setExperienceYears(Integer.parseInt(req.getParameter("experienceYears")));
                    s.setContactNumber(req.getParameter("contactNumber"));
                    s.setEmail(req.getParameter("email"));
                    s.setMaxSurgeriesPerDay(Integer.parseInt(req.getParameter("maxSurgeriesPerDay")));
                    // ── gender ──
                    String gender = req.getParameter("gender");
                    s.setGender(gender != null && !gender.isEmpty() ? gender : "MALE");
                    dao.updateSurgeon(s);
                    resp.sendRedirect(req.getContextPath() + "/surgeons?msg=updated");
                    break;
                }
                default:
                    resp.sendRedirect(req.getContextPath() + "/surgeons");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }
}
