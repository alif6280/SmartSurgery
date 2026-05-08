package com.surgery.servlet;

import com.surgery.dao.OperationTheaterDAO;
import com.surgery.dao.SurgeryDAO;
import com.surgery.model.OperationTheater;
import com.surgery.model.Surgery;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/ot")
public class OTServlet extends HttpServlet {

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
            OperationTheaterDAO dao = new OperationTheaterDAO();

            // Auto-complete sterilizations on every page load
            dao.autoCompleteSteriizations();

            switch (action) {
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.deleteOT(id);
                    resp.sendRedirect(req.getContextPath() + "/ot?msg=deleted");
                    break;
                }
                case "toggle": {
                    int id      = Integer.parseInt(req.getParameter("id"));
                    String current = req.getParameter("status");
                    String next;
                    if      ("AVAILABLE".equals(current))    next = "OCCUPIED";
                    else if ("OCCUPIED".equals(current))     next = "STERILIZING";
                    else if ("STERILIZING".equals(current))  next = "AVAILABLE";
                    else                                     next = "AVAILABLE";
                    if ("STERILIZING".equals(next)) {
                        dao.startSterilization(id);
                    } else {
                        dao.updateOTStatus(id, next);
                    }
                    resp.sendRedirect(req.getContextPath() + "/ot");
                    break;
                }
                case "sterilize": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.startSterilization(id);
                    resp.sendRedirect(req.getContextPath() + "/ot?msg=sterilizing");
                    break;
                }
                case "sterilize_done": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.finishSterilization(id);
                    resp.sendRedirect(req.getContextPath() + "/ot?msg=available");
                    break;
                }
                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    OperationTheater ot = dao.getOTById(id);
                    req.setAttribute("editOT", ot);
                    loadList(req, dao);
                    req.getRequestDispatcher("/pages/ot.jsp").forward(req, resp);
                    break;
                }
                default: {
                    loadList(req, dao);
                    req.getRequestDispatcher("/pages/ot.jsp").forward(req, resp);
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

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            OperationTheaterDAO dao = new OperationTheaterDAO();

            switch (action) {
                case "add": {
                    OperationTheater ot = new OperationTheater();
                    ot.setOtNumber(req.getParameter("otNumber"));
                    ot.setOtName(req.getParameter("otName"));
                    ot.setOtType(req.getParameter("otType"));
                    ot.setStatus("AVAILABLE");
                    ot.setEquipmentList(req.getParameter("equipmentList"));
                    String sterilMin = req.getParameter("sterilizationMinutes");
                    ot.setSterilizationMinutes(sterilMin != null && !sterilMin.isEmpty()
                            ? Integer.parseInt(sterilMin) : 30);
                    dao.insertOT(ot);
                    resp.sendRedirect(req.getContextPath() + "/ot?msg=added");
                    break;
                }
                case "edit": {
                    OperationTheater ot = new OperationTheater();
                    ot.setId(Integer.parseInt(req.getParameter("id")));
                    ot.setOtName(req.getParameter("otName"));
                    ot.setOtType(req.getParameter("otType"));
                    ot.setStatus(req.getParameter("status"));
                    ot.setEquipmentList(req.getParameter("equipmentList"));
                    String sterilMin = req.getParameter("sterilizationMinutes");
                    ot.setSterilizationMinutes(sterilMin != null && !sterilMin.isEmpty()
                            ? Integer.parseInt(sterilMin) : 30);
                    dao.updateOT(ot);
                    resp.sendRedirect(req.getContextPath() + "/ot?msg=updated");
                    break;
                }
                default:
                    resp.sendRedirect(req.getContextPath() + "/ot");
            }
        } catch (SQLException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/pages/error.jsp").forward(req, resp);
        }
    }

    // ─── Load all data for JSP ──────────────────────────────
    private void loadList(HttpServletRequest req, OperationTheaterDAO dao) throws SQLException {
        List<OperationTheater> ots = dao.getAllOTs();

        long available    = ots.stream().filter(o -> "AVAILABLE".equals(o.getStatus())).count();
        long occupied     = ots.stream().filter(o -> "OCCUPIED".equals(o.getStatus())).count();
        long maintenance  = ots.stream().filter(o -> "MAINTENANCE".equals(o.getStatus())).count();
        long sterilizing  = ots.stream().filter(o -> "STERILIZING".equals(o.getStatus())).count();

        req.setAttribute("ots",           ots);
        req.setAttribute("availCount",    available);
        req.setAttribute("occupCount",    occupied);
        req.setAttribute("maintCount",    maintenance);
        req.setAttribute("sterilCount",   sterilizing);
        req.setAttribute("nextOtNumber",  dao.getNextOTNumber());

        // Today's surgeries grouped by OT id
        try {
            SurgeryDAO surgeryDAO = new SurgeryDAO();
            List<Surgery> todaySurgeries = surgeryDAO.getTodaySurgeries();

            Map<Integer, List<Surgery>> scheduleMap = new HashMap<>();
            for (Surgery s : todaySurgeries) {
                scheduleMap.computeIfAbsent(s.getOtId(), k -> new ArrayList<>()).add(s);
            }
            req.setAttribute("scheduleMap",    scheduleMap);
            req.setAttribute("todaySurgeries", todaySurgeries);
        } catch (Exception e) {
            req.setAttribute("scheduleMap", new HashMap<>());
        }

        // Utilization maps
        try {
            Map<Integer, Integer> utilizationMap    = dao.getTodayUtilizationMap();
            Map<Integer, Integer> surgeryMinutesMap = dao.getTodaySurgeryMinutesMap();
            req.setAttribute("utilizationMap",    utilizationMap);
            req.setAttribute("surgeryMinutesMap", surgeryMinutesMap);
        } catch (Exception e) {
            req.setAttribute("utilizationMap",    new HashMap<>());
            req.setAttribute("surgeryMinutesMap", new HashMap<>());
        }
    }
}