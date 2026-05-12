<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    request.setAttribute("currentPage", "settings");
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    if (fullName == null) fullName = "User";
    if (role == null) role = "Staff";
    String[] np = fullName.trim().split(" ");
    String initials = np.length >= 2
        ? ("" + np[0].charAt(0) + np[1].charAt(0)).toUpperCase()
        : fullName.substring(0, Math.min(2, fullName.length())).toUpperCase();
    com.surgery.model.Settings s = (com.surgery.model.Settings) request.getAttribute("settings");
    if (s == null) s = new com.surgery.model.Settings();
    String activeTab = request.getParameter("tab") != null ? request.getParameter("tab") : "profile";
    String msg = request.getParameter("msg");

    Long loginTime = (Long) session.getAttribute("loginTime");
    String loginIp = (String) session.getAttribute("loginIp");
    if (loginIp == null) loginIp = request.getRemoteAddr();
    String loginTimeStr = "Unknown";
    if (loginTime != null) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
        loginTimeStr = sdf.format(new java.util.Date(loginTime));
    }
    long sessionTimeoutMs = session.getMaxInactiveInterval() * 1000L;
    long sessionStartMs = loginTime != null ? loginTime : System.currentTimeMillis();
    long remainingMs = sessionStartMs + sessionTimeoutMs - System.currentTimeMillis();
    if (remainingMs < 0) remainingMs = 0;

    java.util.List<java.util.Map<String, String>> loginHistory =
        (java.util.List<java.util.Map<String, String>>) request.getAttribute("loginHistory");
    if (loginHistory == null) loginHistory = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Settings — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:#f5f7f5}
        .shell{display:flex;height:100vh;overflow:hidden}
        .sb{width:220px;flex-shrink:0;background:linear-gradient(160deg,#0a3d2e 0%,#0d5c3a 55%,#0a4a2e 100%);display:flex;flex-direction:column;position:relative;overflow:hidden;transition:width 0.28s cubic-bezier(0.4,0,0.2,1);z-index:50;border-right:1px solid rgba(52,211,153,0.1)}
        .sb.col{width:62px}
        .sb::before{content:'';position:absolute;inset:0;background-image:radial-gradient(rgba(52,211,153,0.1) 1px,transparent 1px);background-size:22px 22px;pointer-events:none;z-index:0}
        .sb-tog{position:absolute;right:-10px;top:28px;width:20px;height:20px;background:#fff;border:1px solid #c8e0d0;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;z-index:999;box-shadow:0 2px 6px rgba(0,0,0,0.13)}
        .sb-tog svg{width:9px;height:9px;stroke:#059669;fill:none;stroke-width:2.5;transition:transform 0.28s}
        .sb.col .sb-tog svg{transform:rotate(180deg)}
        .sb-logo{padding:20px 14px 18px;border-bottom:1px solid rgba(52,211,153,0.12);display:flex;flex-direction:column;align-items:flex-start;position:relative;z-index:1;overflow:hidden;flex-shrink:0}
        .sb-ico{width:48px;height:48px;background:linear-gradient(135deg,#1a6b4a,#2d9e6b);border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:22px;margin-bottom:12px;position:relative;z-index:1}
        .sb-brand{overflow:hidden;transition:opacity 0.2s,max-height 0.28s;max-height:60px}
        .sb-brand .sb-n{font-size:13px;font-weight:800;color:#fff;letter-spacing:0.02em;line-height:1.25;text-transform:uppercase}
        .sb-brand .sb-s{font-size:10px;color:rgba(255,255,255,0.45);margin-top:4px}
        .sb.col .sb-logo{padding:14px 7px 12px;align-items:center}
        .sb.col .sb-ico{width:38px;height:38px;font-size:18px;margin-bottom:0}
        .sb.col .sb-brand{opacity:0;max-height:0;pointer-events:none}
        .sb-nav{flex:1;overflow-y:auto;overflow-x:hidden;position:relative;z-index:1;padding-bottom:8px}
        .sb-sec{padding:13px 14px 4px;font-size:8.5px;font-weight:700;color:rgba(255,255,255,0.2);text-transform:uppercase;letter-spacing:0.13em;white-space:nowrap;overflow:hidden}
        .sb.col .sb-sec{opacity:0}
        .sb-item{display:flex;align-items:center;gap:10px;padding:10px 13px;margin:2px 7px;border-radius:10px;font-size:12px;color:rgba(255,255,255,0.42);font-weight:500;cursor:pointer;transition:all 0.15s;text-decoration:none;white-space:nowrap;overflow:hidden;border:1px solid transparent}
        .sb-item:hover{background:rgba(255,255,255,0.07);color:rgba(255,255,255,0.78)}
        .sb-item.on{background:rgba(52,211,153,0.16);color:#6ee7b7;border-color:rgba(52,211,153,0.25)}
        .sb-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;flex-shrink:0}
        .sb-txt{transition:opacity 0.2s,max-width 0.28s;max-width:140px;overflow:hidden}
        .sb.col .sb-txt{opacity:0;max-width:0}
        .sb-dot{width:5px;height:5px;border-radius:50%;background:#34d399;margin-left:auto;animation:bl 2s infinite;flex-shrink:0}
        .sb.col .sb-dot{opacity:0}
        @keyframes bl{0%,100%{opacity:1}50%{opacity:0.2}}
        .sb-div{width:75%;height:1px;background:rgba(52,211,153,0.1);margin:6px auto;position:relative;z-index:1}
        .sb-bot{padding:10px 7px;border-top:1px solid rgba(52,211,153,0.1);position:relative;z-index:1;flex-shrink:0}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 11px;background:rgba(52,211,153,0.09);border:1px solid rgba(52,211,153,0.16);border-radius:10px;overflow:hidden}
        .sb-av{width:30px;height:30px;border-radius:50%;background:linear-gradient(135deg,#059669,#34d399);display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:800;color:#fff;flex-shrink:0}
        .sb-ui{overflow:hidden;white-space:nowrap;transition:opacity 0.2s,max-width 0.28s;flex:1;max-width:120px}
        .sb-un{font-size:11px;font-weight:600;color:rgba(255,255,255,0.88)}
        .sb-ur{font-size:9px;color:rgba(255,255,255,0.3);margin-top:1px}
        .sb.col .sb-ui{opacity:0;max-width:0}
        .sb-lo{opacity:0.28;cursor:pointer;flex-shrink:0;transition:opacity 0.15s;background:none;border:none}
        .sb-lo:hover{opacity:0.8}
        .sb-lo svg{width:13px;height:13px;stroke:#fff;fill:none;stroke-width:2}
        .sb.col .sb-lo{display:none}
        .area{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}
        .topbar{background:#fff;border-bottom:1px solid #e2e8e2;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
        .topbar-title{font-size:16px;font-weight:700;color:#0a1628}
        .topbar-sub{font-size:12px;color:#64748b;margin-top:2px}
        .live-clock{display:flex;align-items:center}
        .clock-display{background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:12px;padding:8px 16px;display:flex;flex-direction:column;align-items:center}
        .clock-time{font-size:18px;font-weight:800;color:#fff;letter-spacing:2px;font-family:monospace}
        .clock-date{font-size:9px;color:rgba(255,255,255,0.5);margin-top:1px;text-align:center}
        .page-body{flex:1;overflow-y:auto;overflow-x:hidden;padding:24px;background:#f5f7f5}
        .settings-layout{display:grid;grid-template-columns:220px 1fr;gap:24px;max-width:1100px;margin:0 auto}
        .settings-nav{display:flex;flex-direction:column;gap:4px;position:sticky;top:0}
        .settings-nav-item{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:10px;font-size:13px;font-weight:500;color:#5a7a90;cursor:pointer;transition:all 0.15s;border:none;background:transparent;width:100%;text-align:left;font-family:'Space Grotesk',sans-serif;text-decoration:none}
        .settings-nav-item:hover{background:#e2eaf2;color:#0a1628}
        .settings-nav-item.active{background:linear-gradient(135deg,rgba(0,122,99,0.12),rgba(0,122,99,0.06));color:#007a63;font-weight:600}
        .nav-divider{height:1px;background:#c8d8e8;margin:8px 0}
        .settings-content{display:flex;flex-direction:column;gap:20px}
        .settings-section{display:none}
        .settings-section.active{display:flex;flex-direction:column;gap:20px}
        .s-card{background:#fff;border:1px solid #c8d8e8;border-radius:16px;overflow:hidden}
        .s-card-header{padding:16px 20px;border-bottom:1px solid #c8d8e8;display:flex;align-items:center;gap:10px}
        .s-card-icon{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
        .s-card-icon.green{background:rgba(0,122,99,0.12)}.s-card-icon.blue{background:rgba(21,96,168,0.12)}.s-card-icon.orange{background:rgba(168,98,0,0.12)}.s-card-icon.red{background:rgba(168,0,40,0.12)}.s-card-icon.purple{background:rgba(109,40,217,0.12)}
        .s-card-title{font-size:14px;font-weight:700;color:#0a1628}
        .s-card-sub{font-size:12px;color:#5a7a90;margin-top:1px}
        .s-card-body{padding:20px}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px}
        .form-row.full{grid-template-columns:1fr}
        .form-group{display:flex;flex-direction:column;gap:6px}
        .form-label{font-size:11px;font-weight:700;color:#5a7a90;text-transform:uppercase;letter-spacing:0.04em}
        .form-control{background:#fff;border:1px solid #a0b8cc;border-radius:8px;padding:9px 13px;color:#0a1628;font-family:'Space Grotesk',sans-serif;font-size:13px;width:100%;outline:none;transition:border-color 0.18s}
        .form-control:focus{border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.12)}
        .form-hint{font-size:11px;color:#5a7a90;margin-top:3px}
        .avatar-section{display:flex;align-items:center;gap:20px;margin-bottom:20px;padding:16px;background:#f0f4f8;border-radius:12px;border:1px solid #c8d8e8}
        .avatar-circle{width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,#007a63,#1560a8);display:flex;align-items:center;justify-content:center;font-size:28px;font-weight:700;color:#fff;flex-shrink:0}
        .avatar-info h3{font-size:16px;font-weight:700;color:#0a1628}
        .avatar-info p{font-size:12px;color:#5a7a90;margin-top:2px}
        .role-badge{display:inline-block;font-size:10px;font-weight:700;background:rgba(0,122,99,0.10);color:#007a63;border:1px solid rgba(0,122,99,0.30);border-radius:999px;padding:2px 10px;margin-top:6px;text-transform:uppercase}
        .toggle-row{display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid #f0f4f8}
        .toggle-row:last-child{border-bottom:none;padding-bottom:0}
        .toggle-info h4{font-size:13px;font-weight:600;color:#0a1628}
        .toggle-info p{font-size:11px;color:#5a7a90;margin-top:2px}
        .toggle-switch{position:relative;width:44px;height:24px;flex-shrink:0}
        .toggle-switch input{opacity:0;width:0;height:0;position:absolute}
        .toggle-slider{position:absolute;cursor:pointer;top:0;left:0;right:0;bottom:0;background:#c8d8e8;border-radius:999px;transition:0.3s}
        .toggle-slider::before{content:'';position:absolute;height:18px;width:18px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:0.3s;box-shadow:0 1px 4px rgba(0,0,0,0.2)}
        .toggle-switch input:checked+.toggle-slider{background:#007a63}
        .toggle-switch input:checked+.toggle-slider::before{transform:translateX(20px)}
        .threshold-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:12px}
        .threshold-item{background:#f0f4f8;border-radius:10px;padding:12px;border:1px solid #c8d8e8}
        .threshold-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px}
        .threshold-label.low{color:#007a63}.threshold-label.medium{color:#a86200}.threshold-label.high{color:#c03a1a}.threshold-label.critical{color:#a80028}
        .threshold-input{width:100%;border:1px solid #a0b8cc;border-radius:6px;padding:6px 10px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;outline:none;background:#fff;color:#0a1628}
        .save-bar{display:flex;align-items:center;justify-content:flex-end;gap:10px;padding-top:16px;border-top:1px solid #c8d8e8;margin-top:4px}
        .btn{display:inline-flex;align-items:center;gap:6px;padding:9px 20px;border-radius:8px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;cursor:pointer;transition:all 0.18s;border:1px solid transparent;text-decoration:none}
        .btn-primary{background:#007a63;color:#fff;border-color:#007a63}
        .btn-primary:hover{background:#005f4d}
        .session-timer-card{background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:14px;padding:20px;display:flex;align-items:center;gap:16px;margin-bottom:16px}
        .timer-ring{position:relative;width:80px;height:80px;flex-shrink:0}
        .timer-ring svg{transform:rotate(-90deg)}
        .timer-ring-text{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center}
        .timer-ring-min{font-size:22px;font-weight:800;color:#fff;line-height:1}
        .timer-ring-lbl{font-size:9px;color:rgba(255,255,255,0.5);margin-top:2px}
        .timer-info h3{font-size:14px;font-weight:700;color:#fff;margin-bottom:4px}
        .timer-info p{font-size:12px;color:rgba(255,255,255,0.6)}
        .timer-badges{display:flex;gap:8px;margin-top:10px;flex-wrap:wrap}
        .timer-badge{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);border-radius:8px;padding:5px 10px;font-size:11px;color:rgba(255,255,255,0.8);display:flex;align-items:center;gap:5px}
        .timer-badge .dot{width:6px;height:6px;border-radius:50%;background:#34d399;animation:bl 2s infinite;flex-shrink:0}
        .security-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:16px}
        .sec-stat{background:#f0f4f8;border:1px solid #c8d8e8;border-radius:12px;padding:14px;text-align:center}
        .sec-stat-num{font-size:24px;font-weight:800;color:#0a1628}
        .sec-stat-lbl{font-size:11px;color:#5a7a90;margin-top:4px}
        .sec-stat-num.green{color:#007a63}.sec-stat-num.red{color:#dc2626}
        .history-table{width:100%;border-collapse:collapse;font-size:12px}
        .history-table th{padding:8px 12px;text-align:left;font-size:10px;font-weight:700;color:#5a7a90;text-transform:uppercase;letter-spacing:0.05em;border-bottom:2px solid #c8d8e8}
        .history-table td{padding:10px 12px;border-bottom:1px solid #f0f4f8;color:#0a1628}
        .history-table tr:last-child td{border-bottom:none}
        .history-table tr:hover td{background:#f8fbf8}
        .status-badge{display:inline-flex;padding:2px 8px;border-radius:5px;font-size:10px;font-weight:700}
        .status-success{background:#ecfdf5;color:#059669}.status-failed{background:#fff5f5;color:#dc2626}
        .danger-item{display:flex;align-items:center;justify-content:space-between;padding:14px;background:#fff5f5;border:1px solid #fecaca;border-radius:10px;margin-bottom:10px}
        .danger-item:last-child{margin-bottom:0}
        .danger-info h4{font-size:13px;font-weight:600;color:#991b1b}
        .danger-info p{font-size:11px;color:#b91c1c;margin-top:2px;opacity:0.8}
        .btn-danger-outline{padding:7px 16px;border-radius:8px;border:1px solid #fca5a5;background:#fff;color:#dc2626;font-size:12px;font-weight:600;cursor:pointer;font-family:'Space Grotesk',sans-serif}
        .about-logo{display:flex;align-items:center;gap:16px;padding:20px;background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:14px;margin-bottom:16px}
        .about-logo-icon{width:56px;height:56px;background:linear-gradient(135deg,#1a6b4a,#2d9e6b);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:26px;flex-shrink:0}
        .about-logo-text h2{font-size:16px;font-weight:800;color:#fff;text-transform:uppercase;letter-spacing:0.05em}
        .about-logo-text p{font-size:11px;color:rgba(255,255,255,0.55);margin-top:3px}
        .about-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .about-item{background:#f0f4f8;border-radius:10px;padding:12px 14px;border:1px solid #c8d8e8}
        .about-item-label{font-size:10px;font-weight:700;color:#5a7a90;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:4px}
        .about-item-value{font-size:13px;font-weight:600;color:#0a1628}
        .alert-msg{padding:10px 16px;border-radius:8px;font-size:13px;margin-bottom:16px;display:flex;align-items:center;gap:8px;border:1px solid}
        .alert-success{background:rgba(0,122,99,0.08);border-color:rgba(0,122,99,0.30);color:#007a63}
        .alert-error{background:rgba(168,0,40,0.08);border-color:rgba(168,0,40,0.30);color:#a80028}
        .toast{position:fixed;bottom:24px;right:24px;padding:12px 20px;border-radius:12px;font-size:13px;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(0,0,0,0.2);z-index:9999;transform:translateY(80px);opacity:0;transition:all 0.3s cubic-bezier(0.34,1.56,0.64,1)}
        .toast.show{transform:translateY(0);opacity:1}
        .toast.success{background:linear-gradient(135deg,#007a63,#005f4d);color:#fff}
        .toast.error{background:linear-gradient(135deg,#a80028,#7a001e);color:#fff}
    </style>
</head>
<body>
<div class="shell">

    <div class="sb" id="sb">
        <div class="sb-tog" onclick="document.getElementById('sb').classList.toggle('col')">
            <svg viewBox="0 0 24 24"><polyline points="15,18 9,12 15,6"/></svg>
        </div>
        <div class="sb-logo">
            <div class="sb-ico">🏥</div>
            <div class="sb-brand">
                <div class="sb-n">Smart Surgery<br>Scheduling</div>
                <div class="sb-s">Risk Analysis System</div>
            </div>
        </div>
        <div class="sb-nav">
            <div class="sb-sec">Main</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="sb-item">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                <span class="sb-txt">Dashboard</span>
            </a>
            <div class="sb-sec">Management</div>
            <a href="${pageContext.request.contextPath}/patients" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                <span class="sb-txt">Patients</span>
            </a>
            <a href="${pageContext.request.contextPath}/surgeries" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
                <span class="sb-txt">Surgeries</span>
            </a>
            <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="sb-item">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span class="sb-txt">Schedule Surgery</span>
            </a>
            <div class="sb-sec">Resources</div>
            <a href="${pageContext.request.contextPath}/surgeons" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M20 7H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><path d="M16 3H8l-2 4h12z"/></svg>
                <span class="sb-txt">Surgeons</span>
            </a>
            <a href="${pageContext.request.contextPath}/ot" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                <span class="sb-txt">Operation Theaters</span>
            </a>
            <div class="sb-div"></div>
            <div class="sb-sec">Account</div>
            <a href="${pageContext.request.contextPath}/settings" class="sb-item on">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                <span class="sb-txt">Settings</span>
                <span class="sb-dot"></span>
            </a>
            <a href="${pageContext.request.contextPath}/about" class="sb-item">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <span class="sb-txt">About</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                <span class="sb-txt">Logout</span>
            </a>
        </div>
        <div class="sb-bot">
            <div class="sb-user">
                <div class="sb-av"><%= initials %></div>
                <div class="sb-ui">
                    <div class="sb-un"><%= fullName %></div>
                    <div class="sb-ur"><%= role %></div>
                </div>
                <button class="sb-lo" onclick="location.href='${pageContext.request.contextPath}/logout'">
                    <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                </button>
            </div>
        </div>
    </div>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">⚙️ Settings</div>
                <div class="topbar-sub">Manage your Smart Surgery System preferences</div>
            </div>
            <div class="live-clock">
                <div class="clock-display">
                    <div class="clock-time" id="liveClock">--:--:--</div>
                    <div class="clock-date" id="liveDate">Loading...</div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <% if ("saved".equals(msg)) { %><div class="alert-msg alert-success">✅ Settings saved successfully!</div><% } %>
            <% if ("error".equals(msg)) { %><div class="alert-msg alert-error">❌ Failed to save settings.</div><% } %>
            <% if ("pass_saved".equals(msg)) { %><div class="alert-msg alert-success">✅ Password updated successfully!</div><% } %>
            <% if ("pass_mismatch".equals(msg)) { %><div class="alert-msg alert-error">❌ Passwords do not match!</div><% } %>
            <% if ("pass_weak".equals(msg)) { %><div class="alert-msg alert-error">❌ Password too short (min 6 characters)!</div><% } %>
            <% if ("pass_wrong".equals(msg)) { %><div class="alert-msg alert-error">❌ Current password is incorrect!</div><% } %>

            <div class="settings-layout">
                <div class="settings-nav">
                    <a href="?tab=profile"       class="settings-nav-item <%= "profile".equals(activeTab) ? "active" : "" %>">👤 Profile</a>
                    <a href="?tab=hospital"      class="settings-nav-item <%= "hospital".equals(activeTab) ? "active" : "" %>">🏥 Hospital</a>
                    <a href="?tab=system"        class="settings-nav-item <%= "system".equals(activeTab) ? "active" : "" %>">🖥️ System</a>
                    <a href="?tab=risk"          class="settings-nav-item <%= "risk".equals(activeTab) ? "active" : "" %>">📊 Risk Settings</a>
                    <div class="nav-divider"></div>
                    <a href="?tab=notifications" class="settings-nav-item <%= "notifications".equals(activeTab) ? "active" : "" %>">🔔 Notifications</a>
                    <a href="?tab=security"      class="settings-nav-item <%= "security".equals(activeTab) ? "active" : "" %>">🔒 Security</a>
                    <div class="nav-divider"></div>
                    <a href="?tab=about"         class="settings-nav-item <%= "about".equals(activeTab) ? "active" : "" %>">ℹ️ About</a>
                </div>

                <div class="settings-content">

                    <!-- PROFILE -->
                    <div class="settings-section <%= "profile".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">👤</div><div><div class="s-card-title">Profile Information</div><div class="s-card-sub">Your personal account details</div></div></div>
                            <div class="s-card-body">
                                <div class="avatar-section">
                                    <div class="avatar-circle"><%= fullName.substring(0,1).toUpperCase() %></div>
                                    <div class="avatar-info">
                                        <h3><%= fullName %></h3>
                                        <p>Smart Surgery System User</p>
                                        <span class="role-badge"><%= role %></span>
                                    </div>
                                </div>
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="profile">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Full Name</label><input type="text" name="fullName" class="form-control" value="<%= fullName %>"></div>
                                        <div class="form-group"><label class="form-label">Role</label><input type="text" class="form-control" value="<%= role %>" disabled style="opacity:0.6;cursor:not-allowed;"></div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Profile</button></div>
                                </form>
                            </div>
                        </div>
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">🔑</div><div><div class="s-card-title">Change Password</div><div class="s-card-sub">Update your login credentials</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="password">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Current Password</label><input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required></div>
                                        <div class="form-group"><label class="form-label">New Password</label>
                                            <input type="password" name="newPassword" id="newPass" class="form-control" placeholder="••••••••" oninput="checkPassStrength()" required>
                                            <div style="height:4px;border-radius:2px;background:#c8d8e8;margin-top:6px;overflow:hidden;"><div id="passBar" style="height:100%;width:0%;border-radius:2px;transition:all 0.3s;"></div></div>
                                            <div class="form-hint" id="passHint">Enter new password</div>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Confirm New Password</label><input type="password" name="confirmPassword" class="form-control" placeholder="••••••••" required></div>
                                        <div></div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">🔑 Update Password</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- HOSPITAL -->
                    <div class="settings-section <%= "hospital".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon blue">🏥</div><div><div class="s-card-title">Hospital Information</div><div class="s-card-sub">Hospital details</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="hospital">
                                    <div class="form-row full"><div class="form-group"><label class="form-label">Hospital Name</label><input type="text" name="hospital_name" class="form-control" value="<%= s.get("hospital_name","Khwaja Yunus Ali Medical College Hospital") %>"></div></div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Hospital Code</label><input type="text" name="hospital_code" class="form-control" value="<%= s.get("hospital_code","KYAMCH") %>"></div>
                                        <div class="form-group"><label class="form-label">License Number</label><input type="text" name="hospital_license" class="form-control" value="<%= s.get("hospital_license","DGHS-2024-001") %>"></div>
                                    </div>
                                    <div class="form-row full"><div class="form-group"><label class="form-label">Address</label><input type="text" name="hospital_address" class="form-control" value="<%= s.get("hospital_address","Enayetpur, Sirajganj, Bangladesh") %>"></div></div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Phone</label><input type="text" name="hospital_phone" class="form-control" value="<%= s.get("hospital_phone","") %>"></div>
                                        <div class="form-group"><label class="form-label">Email</label><input type="email" name="hospital_email" class="form-control" value="<%= s.get("hospital_email","info@kyamch.org") %>"></div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Total OT Rooms</label><input type="number" name="hospital_total_ot" class="form-control" value="<%= s.get("hospital_total_ot","6") %>" min="1"></div>
                                        <div class="form-group"><label class="form-label">Max Surgeries/Day</label><input type="number" name="hospital_max_surgeries_day" class="form-control" value="<%= s.get("hospital_max_surgeries_day","12") %>" min="1"></div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- SYSTEM -->
                    <div class="settings-section <%= "system".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon purple">🖥️</div><div><div class="s-card-title">System Preferences</div><div class="s-card-sub">Configure system-wide settings</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="system">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Timezone</label><select name="sys_timezone" class="form-control"><option value="Asia/Dhaka" <%= "Asia/Dhaka".equals(s.get("sys_timezone","Asia/Dhaka")) ? "selected" : "" %>>Asia/Dhaka (GMT+6)</option><option value="Asia/Kolkata" <%= "Asia/Kolkata".equals(s.get("sys_timezone")) ? "selected" : "" %>>Asia/Kolkata (GMT+5:30)</option><option value="UTC" <%= "UTC".equals(s.get("sys_timezone")) ? "selected" : "" %>>UTC (GMT+0)</option></select></div>
                                        <div class="form-group"><label class="form-label">Date Format</label><select name="sys_date_format" class="form-control"><option value="DD/MM/YYYY" <%= "DD/MM/YYYY".equals(s.get("sys_date_format","DD/MM/YYYY")) ? "selected" : "" %>>DD/MM/YYYY</option><option value="MM/DD/YYYY" <%= "MM/DD/YYYY".equals(s.get("sys_date_format")) ? "selected" : "" %>>MM/DD/YYYY</option><option value="YYYY-MM-DD" <%= "YYYY-MM-DD".equals(s.get("sys_date_format")) ? "selected" : "" %>>YYYY-MM-DD</option></select></div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Language</label><select name="sys_language" class="form-control"><option value="English" <%= "English".equals(s.get("sys_language","English")) ? "selected" : "" %>>English</option><option value="Bengali" <%= "Bengali".equals(s.get("sys_language")) ? "selected" : "" %>>বাংলা (Bengali)</option></select></div>
                                        <div class="form-group"><label class="form-label">Time Format</label><select name="sys_time_format" class="form-control"><option value="12" <%= "12".equals(s.get("sys_time_format","12")) ? "selected" : "" %>>12 Hour (AM/PM)</option><option value="24" <%= "24".equals(s.get("sys_time_format")) ? "selected" : "" %>>24 Hour</option></select></div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">OT Start Time</label><input type="time" name="sys_ot_start" class="form-control" value="<%= s.get("sys_ot_start","06:00") %>"></div>
                                        <div class="form-group"><label class="form-label">OT End Time</label><input type="time" name="sys_ot_end" class="form-control" value="<%= s.get("sys_ot_end","22:00") %>"></div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- RISK -->
                    <div class="settings-section <%= "risk".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">📊</div><div><div class="s-card-title">Risk Score Thresholds</div><div class="s-card-sub">Define risk level boundaries</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="risk">
                                    <div class="threshold-grid">
                                        <div class="threshold-item"><div class="threshold-label low">🟢 Low Risk Max</div><input type="number" name="risk_low_max" class="threshold-input" value="<%= s.get("risk_low_max","25") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label medium">🟡 Medium Risk Max</div><input type="number" name="risk_medium_max" class="threshold-input" value="<%= s.get("risk_medium_max","50") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label high">🟠 High Risk Max</div><input type="number" name="risk_high_max" class="threshold-input" value="<%= s.get("risk_high_max","75") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label critical">🔴 Critical Risk</div><input type="number" class="threshold-input" value="100" disabled style="opacity:0.5;cursor:not-allowed;"></div>
                                    </div>
                                    <div style="margin-top:20px;padding-top:16px;border-top:1px solid #c8d8e8;">
                                        <div style="font-size:12px;font-weight:700;color:#5a7a90;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:12px;">Score Weight Factors</div>
                                        <div class="form-row">
                                            <div class="form-group"><label class="form-label">ASA Grade Weight</label><input type="number" name="risk_asa_weight" class="form-control" value="<%= s.get("risk_asa_weight","30") %>" min="0" max="50"></div>
                                            <div class="form-group"><label class="form-label">Age Factor Weight</label><input type="number" name="risk_age_weight" class="form-control" value="<%= s.get("risk_age_weight","20") %>" min="0" max="50"></div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group"><label class="form-label">Comorbidity Weight</label><input type="number" name="risk_comorbidity_weight" class="form-control" value="<%= s.get("risk_comorbidity_weight","35") %>" min="0" max="50"></div>
                                            <div class="form-group"><label class="form-label">BMI Factor Weight</label><input type="number" name="risk_bmi_weight" class="form-control" value="<%= s.get("risk_bmi_weight","10") %>" min="0" max="20"></div>
                                        </div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- NOTIFICATIONS -->
                    <div class="settings-section <%= "notifications".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon orange">🔔</div><div><div class="s-card-title">Notification Preferences</div><div class="s-card-sub">Control what alerts you receive</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="notifications">
                                    <div class="toggle-row"><div class="toggle-info"><h4>🚨 Critical Risk Alerts</h4><p>Notify when a patient reaches critical risk level</p></div><label class="toggle-switch"><input type="checkbox" name="notif_critical_risk" <%= s.getBool("notif_critical_risk") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📅 Surgery Reminders</h4><p>Remind 1 hour before scheduled surgery</p></div><label class="toggle-switch"><input type="checkbox" name="notif_surgery_reminder" <%= s.getBool("notif_surgery_reminder") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🏨 OT Conflict Alerts</h4><p>Alert when OT scheduling conflict is detected</p></div><label class="toggle-switch"><input type="checkbox" name="notif_ot_conflict" <%= s.getBool("notif_ot_conflict") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>👨‍⚕️ Surgeon Unavailability</h4><p>Notify when assigned surgeon becomes unavailable</p></div><label class="toggle-switch"><input type="checkbox" name="notif_surgeon_unavail" <%= s.getBool("notif_surgeon_unavail") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>✅ Pre-op Checklist Incomplete</h4><p>Alert when pre-op items are incomplete</p></div><label class="toggle-switch"><input type="checkbox" name="notif_preop_incomplete" <%= s.getBool("notif_preop_incomplete") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📊 Daily Summary Report</h4><p>Send daily surgery summary at end of day</p></div><label class="toggle-switch"><input type="checkbox" name="notif_daily_summary" <%= s.getBool("notif_daily_summary") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🧹 Sterilization Complete</h4><p>Notify when OT sterilization is finished</p></div><label class="toggle-switch"><input type="checkbox" name="notif_sterilization" <%= s.getBool("notif_sterilization") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Preferences</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- SECURITY -->
                    <div class="settings-section <%= "security".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">⏱️</div><div><div class="s-card-title">Live Session Status</div><div class="s-card-sub">Real-time session information</div></div></div>
                            <div class="s-card-body">
                                <div class="session-timer-card">
                                    <div class="timer-ring">
                                        <svg width="80" height="80" viewBox="0 0 80 80">
                                            <circle cx="40" cy="40" r="34" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="6"/>
                                            <circle id="timerArc" cx="40" cy="40" r="34" fill="none" stroke="#34d399" stroke-width="6" stroke-linecap="round" stroke-dasharray="213.6" stroke-dashoffset="0"/>
                                        </svg>
                                        <div class="timer-ring-text">
                                            <div class="timer-ring-min" id="timerMin">--</div>
                                            <div class="timer-ring-lbl">min left</div>
                                        </div>
                                    </div>
                                    <div class="timer-info">
                                        <h3>Session Active</h3>
                                        <p>Logged in: <%= loginTimeStr %></p>
                                        <div class="timer-badges">
                                            <div class="timer-badge"><span class="dot"></span>IP: <%= loginIp %></div>
                                            <div class="timer-badge">🔐 Secured</div>
                                            <div class="timer-badge" id="sessionDuration">Duration: --</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="security-stats">
                                    <div class="sec-stat"><div class="sec-stat-num green"><%= loginHistory.size() %></div><div class="sec-stat-lbl">Total Logins</div></div>
                                    <div class="sec-stat"><div class="sec-stat-num green"><%= loginHistory.stream().filter(h -> "SUCCESS".equals(h.get("status"))).count() %></div><div class="sec-stat-lbl">Successful</div></div>
                                    <div class="sec-stat"><div class="sec-stat-num red"><%= loginHistory.stream().filter(h -> "FAILED".equals(h.get("status"))).count() %></div><div class="sec-stat-lbl">Failed Attempts</div></div>
                                </div>
                            </div>
                        </div>
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">🔒</div><div><div class="s-card-title">Security Settings</div><div class="s-card-sub">Manage access and security preferences</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="security">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Session Timeout</label><select name="sec_session_timeout" class="form-control"><option value="15" <%= "15".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>15 minutes</option><option value="30" <%= "30".equals(s.get("sec_session_timeout","30")) ? "selected" : "" %>>30 minutes</option><option value="60" <%= "60".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>60 minutes</option><option value="0" <%= "0".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>Never</option></select></div>
                                        <div class="form-group"><label class="form-label">Max Login Attempts</label><select name="sec_max_login_attempts" class="form-control"><option value="3" <%= "3".equals(s.get("sec_max_login_attempts")) ? "selected" : "" %>>3 attempts</option><option value="5" <%= "5".equals(s.get("sec_max_login_attempts","5")) ? "selected" : "" %>>5 attempts</option><option value="10" <%= "10".equals(s.get("sec_max_login_attempts")) ? "selected" : "" %>>10 attempts</option></select></div>
                                    </div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🔔 Login Notifications</h4><p>Alert on new login</p></div><label class="toggle-switch"><input type="checkbox" name="sec_login_notify" <%= s.getBool("sec_login_notify") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📝 Activity Logging</h4><p>Log all user actions for audit trail</p></div><label class="toggle-switch"><input type="checkbox" name="sec_activity_log" <%= s.getBool("sec_activity_log") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon blue">📋</div><div><div class="s-card-title">Login History</div><div class="s-card-sub">Last 10 login attempts</div></div></div>
                            <div class="s-card-body" style="padding:0">
                                <% if (loginHistory.isEmpty()) { %>
                                    <div style="text-align:center;padding:24px;color:#64748b;font-size:13px">No login history found</div>
                                <% } else { %>
                                    <table class="history-table">
                                        <thead><tr><th>Date & Time</th><th>IP Address</th><th>Status</th></tr></thead>
                                        <tbody>
                                        <% for (java.util.Map<String, String> h : loginHistory) { %>
                                            <tr><td><%= h.get("time") %></td><td><%= h.get("ip") %></td><td><span class="status-badge <%= "SUCCESS".equals(h.get("status")) ? "status-success" : "status-failed" %>"><%= h.get("status") %></span></td></tr>
                                        <% } %>
                                        </tbody>
                                    </table>
                                <% } %>
                            </div>
                        </div>
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">⚠️</div><div><div class="s-card-title">Danger Zone</div><div class="s-card-sub">Irreversible actions</div></div></div>
                            <div class="s-card-body">
                                <div class="danger-item">
                                    <div class="danger-info"><h4>Reset System to Default</h4><p>Reset all settings to factory defaults.</p></div>
                                    <button class="btn-danger-outline" onclick="if(confirm('Reset all settings?')) window.location.href='${pageContext.request.contextPath}/settings?action=reset'">⚙️ Reset</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ABOUT -->
                    <div class="settings-section <%= "about".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">ℹ️</div><div><div class="s-card-title">About Smart Surgery System</div><div class="s-card-sub">System information and version details</div></div></div>
                            <div class="s-card-body">
                                <div class="about-logo"><div class="about-logo-icon">🏥</div><div class="about-logo-text"><h2>Smart Surgery Scheduling</h2><p>Risk Analysis & Surgical Management System</p></div></div>
                                <div class="about-grid">
                                    <div class="about-item"><div class="about-item-label">System Name</div><div class="about-item-value">Smart Surgery System</div></div>
                                    <div class="about-item"><div class="about-item-label">Version</div><div class="about-item-value">v1.0.0 (2026)</div></div>
                                    <div class="about-item"><div class="about-item-label">Hospital</div><div class="about-item-value"><%= s.get("hospital_code","KYAMCH") %></div></div>
                                    <div class="about-item"><div class="about-item-label">Platform</div><div class="about-item-value">Jakarta EE / Tomcat</div></div>
                                    <div class="about-item"><div class="about-item-label">Database</div><div class="about-item-value">MySQL 8.0</div></div>
                                    <div class="about-item"><div class="about-item-label">Framework</div><div class="about-item-value">Java Servlets + JSP</div></div>
                                    <div class="about-item"><div class="about-item-label">Build Date</div><div class="about-item-value">May 2026</div></div>
                                    <div class="about-item"><div class="about-item-label">License</div><div class="about-item-value">Academic Project</div></div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
// LIVE CLOCK
function updateClock() {
    var now = new Date();
    var h = now.getHours(), m = now.getMinutes(), sec = now.getSeconds();
    var ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12; if (h === 0) h = 12;
    var timeStr = (h<10?'0':'')+h+':'+(m<10?'0':'')+m+':'+(sec<10?'0':'')+sec+' '+ampm;
    var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var dateStr = days[now.getDay()]+', '+now.getDate()+' '+months[now.getMonth()]+' '+now.getFullYear();
    var el = document.getElementById('liveClock');
    var del = document.getElementById('liveDate');
    if (el) el.textContent = timeStr;
    if (del) del.textContent = dateStr;
}
setInterval(updateClock, 1000);
updateClock();

// SESSION TIMER
var sessionTimeoutSec = <%= session.getMaxInactiveInterval() %>;
var loginTimeMs = <%= loginTime != null ? loginTime : System.currentTimeMillis() %>;
var circumference = 2 * Math.PI * 34;
function updateTimer() {
    var now = Date.now();
    var elapsedSec = Math.floor((now - loginTimeMs) / 1000);
    var remainingSec = Math.max(0, sessionTimeoutSec - elapsedSec);
    document.getElementById('timerMin').textContent = Math.floor(remainingSec / 60);
    var progress = remainingSec / sessionTimeoutSec;
    var arc = document.getElementById('timerArc');
    if (arc) {
        arc.style.strokeDashoffset = circumference * (1 - progress);
        arc.style.stroke = progress > 0.5 ? '#34d399' : progress > 0.25 ? '#f59e0b' : '#ef4444';
    }
    var elapsedMin = Math.floor(elapsedSec / 60);
    var elapsedS = elapsedSec % 60;
    var dur = document.getElementById('sessionDuration');
    if (dur) dur.textContent = 'Duration: ' + elapsedMin + 'm ' + (elapsedS < 10 ? '0' : '') + elapsedS + 's';
    if (remainingSec <= 0) window.location.href = '${pageContext.request.contextPath}/logout';
}
setInterval(updateTimer, 1000);
updateTimer();

// PASSWORD STRENGTH
function checkPassStrength() {
    var pass = document.getElementById('newPass').value;
    var bar = document.getElementById('passBar');
    var hint = document.getElementById('passHint');
    if (!pass) { bar.style.width='0%'; hint.textContent='Enter new password'; hint.style.color='#5a7a90'; return; }
    var strength = 0;
    if (pass.length >= 8) strength++;
    if (/[A-Z]/.test(pass)) strength++;
    if (/[0-9]/.test(pass)) strength++;
    if (/[^A-Za-z0-9]/.test(pass)) strength++;
    var colors = ['#e24b4a','#e67e22','#f1c40f','#007a63'];
    var labels = ['Weak','Fair','Good','Strong'];
    var widths = ['25%','50%','75%','100%'];
    var i = Math.max(0, strength - 1);
    bar.style.width = widths[i]; bar.style.background = colors[i];
    hint.textContent = 'Password strength: ' + labels[i]; hint.style.color = colors[i];
}

// TOAST
<% if (msg != null && !msg.isEmpty()) { %>
window.addEventListener('DOMContentLoaded', function() {
    var toast = document.getElementById('toast');
    <% if ("saved".equals(msg)) { %>toast.textContent='✅ Settings saved!';toast.className='toast success';
    <% } else if ("error".equals(msg)) { %>toast.textContent='❌ Failed to save!';toast.className='toast error';
    <% } else if ("pass_saved".equals(msg)) { %>toast.textContent='✅ Password updated!';toast.className='toast success';
    <% } else if ("pass_mismatch".equals(msg)) { %>toast.textContent='❌ Passwords do not match!';toast.className='toast error';
    <% } else if ("pass_wrong".equals(msg)) { %>toast.textContent='❌ Current password incorrect!';toast.className='toast error';
    <% } %>
    toast.classList.add('show');
    setTimeout(function(){ toast.classList.remove('show'); }, 3500);
});
<% } %>
</script>
</body>
</html>
