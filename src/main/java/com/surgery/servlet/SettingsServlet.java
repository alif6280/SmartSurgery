package com.surgery.servlet;

import com.surgery.dao.SettingsDAO;
import com.surgery.dao.UserDAO;
import com.surgery.model.Settings;
import com.surgery.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {

    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Settings settings = new Settings();
        try {
            settings = settingsDAO.loadAll();
        } catch (Exception e) {
            e.printStackTrace();
        }

        String username = (String) session.getAttribute("username");
        List<Map<String, String>> loginHistory = loadLoginHistory(username);

        req.setAttribute("settings", settings);
        req.setAttribute("currentPage", "settings");
        req.setAttribute("loginHistory", loginHistory);
        req.getRequestDispatcher("/pages/settings.jsp").forward(req, resp);
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
        String msg = "saved";

        try {
            switch (action) {
                case "hospital":
                    saveCategory(req, "hospital");
                    break;
                case "system":
                    saveCategory(req, "system");
                    break;
                case "risk":
                    saveCategory(req, "risk");
                    break;
                case "notifications":
                    String[] notifKeys = {
                            "notif_critical_risk", "notif_surgery_reminder", "notif_ot_conflict",
                            "notif_surgeon_unavail", "notif_preop_incomplete",
                            "notif_daily_summary", "notif_sterilization"
                    };
                    for (String key : notifKeys) {
                        settingsDAO.saveKey(key, req.getParameter(key) != null ? "true" : "false");
                    }
                    break;
                case "security":
                    saveCategory(req, "security");
                    String[] toggleKeys = {"sec_login_notify", "sec_activity_log"};
                    for (String key : toggleKeys) {
                        settingsDAO.saveKey(key, req.getParameter(key) != null ? "true" : "false");
                    }
                    break;
                case "password":
                    String currentPass = req.getParameter("currentPassword");
                    String newPass     = req.getParameter("newPassword");
                    String confirmPass = req.getParameter("confirmPassword");
                    if (newPass == null || !newPass.equals(confirmPass)) {
                        msg = "pass_mismatch";
                    } else if (newPass.length() < 6) {
                        msg = "pass_weak";
                    } else {
                        String uname = (String) session.getAttribute("username");
                        if (uname != null && userDAO.verifyPassword(uname, currentPass)) {
                            userDAO.updatePassword(uname, newPass);
                            msg = "pass_saved";
                        } else {
                            msg = "pass_wrong";
                        }
                    }
                    break;
                case "profile":
                    String newFullName = req.getParameter("fullName");
                    if (newFullName != null && !newFullName.trim().isEmpty()) {
                        session.setAttribute("fullName", newFullName.trim());
                    }
                    break;
                default:
                    msg = "error";
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "error";
        }

        resp.sendRedirect(req.getContextPath() + "/settings?msg=" + msg + "&tab=" + action);
    }

    private List<Map<String, String>> loadLoginHistory(String username) {
        List<Map<String, String>> list = new ArrayList<>();
        if (username == null) return list;
        String sql = "SELECT login_time, ip_address, status FROM login_history WHERE username = ? ORDER BY login_time DESC LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("time",   rs.getString("login_time"));
                row.put("ip",     rs.getString("ip_address"));
                row.put("status", rs.getString("status"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void saveCategory(HttpServletRequest req, String category) throws Exception {
        Map<String, String> params = new HashMap<>();
        req.getParameterMap().forEach((k, v) -> {
            if (!"action".equals(k)) params.put(k, v[0]);
        });
        settingsDAO.saveCategory(params, category);
    }
}