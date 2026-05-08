package com.surgery.servlet;

import com.surgery.model.User;
import com.surgery.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

/**
 * Login Servlet — Smart Surgery Scheduling & Risk Analysis System
 * Features: attempt tracking, account lockout, remember me cookie, session management
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final int MAX_ATTEMPTS    = 5;             // max failed attempts before lockout
    private static final int LOCKOUT_MINUTES = 15;            // lockout duration in minutes
    private static final int SESSION_TIMEOUT = 30 * 60;       // session timeout: 30 minutes
    private static final int COOKIE_AGE      = 7 * 24 * 3600; // remember me: 7 days

    // ─────────────────────────────────────────────────────────────────────────
    // GET — Show login page
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Already logged in → redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Pre-fill username if "remember me" cookie exists
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

    // ─────────────────────────────────────────────────────────────────────────
    // POST — Process login form
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username   = req.getParameter("username");
        String password   = req.getParameter("password");
        String rememberMe = req.getParameter("rememberMe"); // "on" if checked

        HttpSession session = req.getSession(true);

        // ── Lockout check ──────────────────────────────────────────────────
        Integer attempts    = (Integer) session.getAttribute("loginAttempts");
        Long    lockedUntil = (Long)    session.getAttribute("lockedUntil");
        if (attempts == null) attempts = 0;

        // Still locked out?
        if (lockedUntil != null && System.currentTimeMillis() < lockedUntil) {
            long remaining = (lockedUntil - System.currentTimeMillis()) / 60000 + 1;
            req.setAttribute("error",
                    "Account temporarily locked. Try again in " + remaining + " minute(s).");
            req.setAttribute("locked", true);
            session.setAttribute("loginAttempts", attempts);
            req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
            return;
        }

        // Lockout expired — reset counters
        if (lockedUntil != null && System.currentTimeMillis() >= lockedUntil) {
            session.removeAttribute("loginAttempts");
            session.removeAttribute("lockedUntil");
            attempts = 0;
        }

        // ── Authenticate ───────────────────────────────────────────────────
        try {
            User user = authenticate(username, password);

            if (user != null) {
                // ✅ Login success — reset attempt counter
                session.removeAttribute("loginAttempts");
                session.removeAttribute("lockedUntil");

                // Store user in session
                session.setAttribute("user",     user);
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role",     user.getRole());
                session.setAttribute("fullName", user.getFullName());
                session.setAttribute("userId",   user.getId());
                session.setMaxInactiveInterval(SESSION_TIMEOUT);

                // Handle "remember me" cookie
                if ("on".equals(rememberMe)) {
                    Cookie cookie = new Cookie("rememberedUser", username);
                    cookie.setMaxAge(COOKIE_AGE);
                    cookie.setPath(req.getContextPath() + "/");
                    cookie.setHttpOnly(true); // not accessible via JavaScript
                    resp.addCookie(cookie);
                } else {
                    // Clear any existing remember-me cookie
                    Cookie cookie = new Cookie("rememberedUser", "");
                    cookie.setMaxAge(0);
                    cookie.setPath(req.getContextPath() + "/");
                    resp.addCookie(cookie);
                }

                resp.sendRedirect(req.getContextPath() + "/dashboard");

            } else {
                // ❌ Login failed — increment attempt counter
                attempts++;
                session.setAttribute("loginAttempts", attempts);

                if (attempts >= MAX_ATTEMPTS) {
                    // Lock the account
                    long lockUntil = System.currentTimeMillis() + (LOCKOUT_MINUTES * 60 * 1000L);
                    session.setAttribute("lockedUntil", lockUntil);
                    req.setAttribute("error",
                            "Too many failed attempts. Account locked for " + LOCKOUT_MINUTES + " minutes.");
                    req.setAttribute("locked", true);
                } else {
                    int left = MAX_ATTEMPTS - attempts;
                    req.setAttribute("error",
                            "Invalid username or password! " + left + " attempt(s) remaining.");
                }

                req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Database error. Please try again later.");
            req.getRequestDispatcher("/pages/login.jsp").forward(req, resp);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DB Authentication
    // ─────────────────────────────────────────────────────────────────────────
    private User authenticate(String username, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND is_active = TRUE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password); // TODO: use BCrypt in production → BCrypt.checkpw(password, hash)

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