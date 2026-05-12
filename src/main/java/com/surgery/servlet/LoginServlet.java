package com.surgery.servlet;

import com.surgery.model.User;
import com.surgery.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final int MAX_ATTEMPTS    = 5;
    private static final int LOCKOUT_MINUTES = 15;
    private static final int SESSION_TIMEOUT = 30 * 60;
    private static final int COOKIE_AGE      = 7 * 24 * 3600;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("rememberedUser".equals(c.getName())) {
                    req.setAttribute("rememberedUsername", c.getValue());
                    break;
                }
            }
        }

        req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username   = req.getParameter("username");
        String password   = req.getParameter("password");
        String rememberMe = req.getParameter("rememberMe");

        HttpSession session = req.getSession(true);

        Integer attempts    = (Integer) session.getAttribute("loginAttempts");
        Long    lockedUntil = (Long)    session.getAttribute("lockedUntil");
        if (attempts == null) attempts = 0;

        if (lockedUntil != null && System.currentTimeMillis() < lockedUntil) {
            long remaining = (lockedUntil - System.currentTimeMillis()) / 60000 + 1;
            req.setAttribute("error", "Account temporarily locked. Try again in " + remaining + " minute(s).");
            req.setAttribute("locked", true);
            req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
            return;
        }

        if (lockedUntil != null && System.currentTimeMillis() >= lockedUntil) {
            session.removeAttribute("loginAttempts");
            session.removeAttribute("lockedUntil");
            attempts = 0;
        }

        String ipAddress  = req.getRemoteAddr();
        String userAgent  = req.getHeader("User-Agent");

        try {
            User user = authenticate(username, password);

            if (user != null) {
                session.removeAttribute("loginAttempts");
                session.removeAttribute("lockedUntil");

                session.setAttribute("user",      user);
                session.setAttribute("username",  user.getUsername());
                session.setAttribute("role",      user.getRole());
                session.setAttribute("fullName",  user.getFullName());
                session.setAttribute("userId",    user.getId());
                session.setAttribute("loginTime", System.currentTimeMillis());
                session.setAttribute("loginIp",   ipAddress);
                session.setMaxInactiveInterval(SESSION_TIMEOUT);

                // Save login history
                saveLoginHistory(username, ipAddress, userAgent, "SUCCESS");

                if ("on".equals(rememberMe)) {
                    Cookie cookie = new Cookie("rememberedUser", username);
                    cookie.setMaxAge(COOKIE_AGE);
                    cookie.setPath(req.getContextPath() + "/");
                    cookie.setHttpOnly(true);
                    resp.addCookie(cookie);
                } else {
                    Cookie cookie = new Cookie("rememberedUser", "");
                    cookie.setMaxAge(0);
                    cookie.setPath(req.getContextPath() + "/");
                    resp.addCookie(cookie);
                }

                resp.sendRedirect(req.getContextPath() + "/dashboard");

            } else {
                attempts++;
                session.setAttribute("loginAttempts", attempts);

                // Save failed login history
                saveLoginHistory(username, ipAddress, userAgent, "FAILED");

                if (attempts >= MAX_ATTEMPTS) {
                    long lockUntil = System.currentTimeMillis() + (LOCKOUT_MINUTES * 60 * 1000L);
                    session.setAttribute("lockedUntil", lockUntil);
                    req.setAttribute("error", "Too many failed attempts. Account locked for " + LOCKOUT_MINUTES + " minutes.");
                    req.setAttribute("locked", true);
                } else {
                    int left = MAX_ATTEMPTS - attempts;
                    req.setAttribute("error", "Invalid username or password! " + left + " attempt(s) remaining.");
                }

                req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Database error. Please try again later.");
            req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
        }
    }

    private void saveLoginHistory(String username, String ipAddress, String userAgent, String status) {
        String sql = "INSERT INTO login_history (username, ip_address, user_agent, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, ipAddress);
            ps.setString(3, userAgent != null && userAgent.length() > 255 ? userAgent.substring(0, 255) : userAgent);
            ps.setString(4, status);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private User authenticate(String username, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND is_active = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }
}