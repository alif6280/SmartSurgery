<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("currentPage", "surgeries");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    request.setAttribute("today", today);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Surgeries — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:#f5f7f5}
        :root{
            --teal:#007a63;--teal-dim:#005f4d;--teal-glow:rgba(0,122,99,0.12);
            --bg-base:#f0f4f8;--bg-card:#ffffff;--bg-hover:#e2eaf2;
            --border:#c8d8e8;--border-light:#a0b8cc;
            --text-primary:#0a1628;--text-secondary:#2a4060;--text-muted:#5a7a90;
            --font-main:'Space Grotesk',sans-serif;
            --risk-low:#007a63;--risk-medium:#a86200;--risk-high:#c03a1a;--risk-critical:#a80028;
        }
        .shell{display:flex;height:100vh;overflow:hidden}
        .area{flex:1;overflow-y:auto;min-width:0}

        /* Topbar */
        .topbar{background:#0a3d2e;border-bottom:none;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between}
        .topbar-title{font-size:16px;font-weight:700;color:#fff}
        .topbar-sub{font-size:12px;color:rgba(255,255,255,0.6);margin-top:2px}
        .topbar-right{display:flex;align-items:center;gap:10px}

        /* Page body scroll */
        .page-body{padding-bottom:40px}
        .page-body::-webkit-scrollbar{width:4px}
        .page-body::-webkit-scrollbar-thumb{background:#c8d8c8;border-radius:4px}

        /* Buttons */
        .btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;cursor:pointer;transition:all 0.18s;border:1px solid transparent;text-decoration:none;white-space:nowrap}
        .btn-primary{background:#007a63;color:#fff;border-color:#007a63}
        .btn-primary:hover{background:#005f4d;color:#fff}
        .btn-sm{padding:5px 10px;font-size:12px}

        /* Alerts */
        .alert{padding:12px 16px;border-radius:8px;font-size:13px;margin:12px 16px 0;display:flex;align-items:center;gap:10px;border:1px solid}
        .alert-success{background:rgba(0,122,99,0.08);border-color:rgba(0,122,99,0.30);color:#007a63}

        /* Empty state */
        .empty-state{text-align:center;padding:60px 20px;color:#5a7a90}
        .empty-state .empty-icon{font-size:48px;margin-bottom:14px;opacity:0.4}
        .empty-state p{font-size:14px;margin-bottom:16px}

        /* Badges */
        .badge{display:inline-flex;padding:2px 8px;border-radius:6px;font-size:10px;font-weight:700;text-transform:uppercase}
        .risk-low     {background:rgba(0,122,99,0.10); color:#007a63;border:1px solid rgba(0,122,99,0.30)}
        .risk-medium  {background:rgba(168,98,0,0.10); color:#a86200;border:1px solid rgba(168,98,0,0.30)}
        .risk-high    {background:rgba(192,58,26,0.10);color:#c03a1a;border:1px solid rgba(192,58,26,0.30)}
        .risk-critical{background:rgba(168,0,40,0.10); color:#a80028;border:1px solid rgba(168,0,40,0.30)}
        .priority-low     {background:rgba(0,122,99,0.08); color:#007a63}
        .priority-medium  {background:rgba(168,98,0,0.08); color:#a86200}
        .priority-high    {background:rgba(192,58,26,0.08);color:#c03a1a}
        .priority-critical{background:rgba(168,0,40,0.10); color:#a80028}
        .status-scheduled  {background:rgba(21,96,168,0.10); color:#1560a8;border:1px solid rgba(21,96,168,0.30)}
        .status-inprogress {background:rgba(168,98,0,0.10);  color:#a86200;border:1px solid rgba(168,98,0,0.30)}
        .status-completed  {background:rgba(0,122,99,0.10);  color:#007a63;border:1px solid rgba(0,122,99,0.30)}
        .status-cancelled  {background:rgba(90,122,144,0.10);color:#5a7a90;border:1px solid rgba(90,122,144,0.25)}

        /* Stats */
        .surgery-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;padding:16px 16px 0}
        .sstat{border-radius:16px;padding:16px 18px;display:flex;align-items:center;gap:12px;color:#fff;position:relative;overflow:hidden}
        .sstat::after{content:'';position:absolute;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.10);bottom:-18px;right:-18px}
        .sstat.total     {background:linear-gradient(135deg,#1a5276,#154360)}
        .sstat.scheduled {background:linear-gradient(135deg,#1a9e75,#157a5b)}
        .sstat.inprogress{background:linear-gradient(135deg,#e67e22,#ca6f1e)}
        .sstat.completed {background:linear-gradient(135deg,#27ae60,#1e8449)}
        .sstat.cancelled {background:linear-gradient(135deg,#c0392b,#96281b)}
        .sstat-icon{font-size:22px}
        .sstat-val{font-size:28px;font-weight:700;line-height:1}
        .sstat-lbl{font-size:10px;opacity:0.85;text-transform:uppercase;letter-spacing:0.5px;margin-top:2px}

        /* Toolbar */
        .surgery-toolbar{padding:14px 16px 0;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .tb-left{display:flex;align-items:center;gap:8px}
        .tb-right{margin-left:auto;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .search-wrap{position:relative}
        .search-wrap .si{position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:13px;pointer-events:none}
        .search-wrap input{padding:7px 12px 7px 30px;border-radius:999px;border:1px solid #c8d8e8;font-size:12px;color:#0a1628;background:#fff;outline:none;width:210px;font-family:'Space Grotesk',sans-serif}
        .search-wrap input:focus{border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.12)}
        .filter-select{padding:6px 24px 6px 10px;border-radius:999px;border:1px solid #c8d8e8;font-size:12px;color:#0a1628;background:#fff;outline:none;appearance:none;cursor:pointer;font-family:'Space Grotesk',sans-serif;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%236b7280'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 8px center}

        /* Surgery Cards */
        .surgeries-grid{display:flex;flex-direction:column;gap:10px;padding:16px}
        .surgery-card{background:#fff;border:1px solid #c8d8e8;border-radius:16px;padding:16px;display:flex;flex-direction:column;gap:12px;transition:box-shadow 0.2s,transform 0.2s;position:relative;overflow:hidden}
        .surgery-card:hover{box-shadow:0 8px 24px rgba(0,0,0,0.10);transform:translateY(-2px)}
        .surgery-card.today-card{border-color:#e67e22;background:linear-gradient(135deg,#fffbf5,#fff)}
        .surgery-card.today-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,#e67e22,#f39c12)}
        .surgery-card.inprogress-card{border-color:#e67e22;box-shadow:0 0 0 2px rgba(230,126,34,0.15)}

        .sc-top{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap}
        .sc-left{display:flex;align-items:center;gap:12px}
        .sc-icon{width:46px;height:46px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:700;flex-shrink:0}
        .sc-ref{font-size:11px;color:#007a63;font-weight:600}
        .sc-patient{font-size:15px;font-weight:700;color:#0a1628;margin-top:2px}
        .sc-type{font-size:12px;color:#5a7a90;margin-top:2px}
        .sc-badges{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
        .today-tag{font-size:10px;font-weight:700;border-radius:999px;padding:3px 10px;background:#faeeda;color:#633806;animation:pulse 2s infinite}
        @keyframes pulse{0%,100%{opacity:1}50%{opacity:0.7}}
        .cat-badge{font-size:10px;font-weight:600;border-radius:999px;padding:3px 10px}
        .cat-elective {background:#e6f1fb;color:#185fa5}
        .cat-urgent   {background:#faeeda;color:#633806}
        .cat-emergency{background:#fcebeb;color:#791f1f}

        /* Live Timer */
        .live-timer-box{background:linear-gradient(135deg,#faeeda,#fef3e2);border:1px solid #f5d08a;border-radius:10px;padding:10px 14px;display:flex;align-items:center;gap:10px;flex-wrap:wrap}
        .live-dot{width:8px;height:8px;border-radius:50%;background:#e67e22;flex-shrink:0;animation:livePulse 1s infinite}
        @keyframes livePulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:0.5;transform:scale(0.8)}}
        .live-label{font-size:11px;font-weight:600;color:#633806}
        .live-elapsed{font-size:16px;font-weight:700;color:#633806;font-family:monospace}
        .live-progress-wrap{flex:1;min-width:100px}
        .live-progress-bg{width:100%;height:6px;border-radius:999px;background:rgba(230,126,34,0.2);overflow:hidden;margin-top:4px}
        .live-progress-fill{height:100%;border-radius:999px;background:#e67e22;transition:width 1s linear}
        .live-progress-fill.overtime{background:#c0392b}
        .live-pct{font-size:10px;color:#633806;text-align:right}
        .live-remaining{font-size:11px;color:#633806;font-weight:600;white-space:nowrap}

        /* Mid */
        .sc-mid{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
        .surgeon-box{display:flex;align-items:center;gap:8px}
        .surgeon-avatar{width:32px;height:32px;border-radius:50%;background:#e6f1fb;color:#185fa5;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0}
        .surgeon-name{font-size:12px;color:#0a1628;font-weight:500}
        .surgeon-label{font-size:10px;color:#5a7a90}
        .mid-sep{width:1px;height:28px;background:#c8d8e8}
        .ot-box{display:flex;align-items:center;gap:6px}
        .ot-num{font-size:12px;font-weight:700;color:#007a63}
        .ot-name-txt{font-size:11px;color:#5a7a90}

        /* Bottom */
        .sc-bottom{display:flex;border-top:1px solid #c8d8e8;padding-top:10px;flex-wrap:wrap}
        .info-cell{flex:1;min-width:80px;display:flex;flex-direction:column;gap:3px;padding:0 14px;border-right:1px solid #c8d8e8}
        .info-cell:first-child{padding-left:0}
        .info-cell:last-child{border-right:none}
        .info-label{font-size:10px;color:#5a7a90;text-transform:uppercase;letter-spacing:0.4px}
        .info-value{font-size:13px;font-weight:600;color:#0a1628}
        .info-value.teal  {color:#007a63}
        .info-value.orange{color:#e67e22}

        .preop-preview{font-size:11px;color:#5a7a90;background:#f0f4f8;border-radius:8px;padding:7px 10px;border-left:3px solid #c8d8e8;cursor:pointer;line-height:1.5;display:-webkit-box;-webkit-line-clamp:1;-webkit-box-orient:vertical;overflow:hidden}
        .preop-preview:hover{background:#e2eaf2}

        .sc-footer{display:flex;justify-content:space-between;align-items:center}
        .sc-meta{font-size:11px;color:#5a7a90}
        .sc-actions{display:flex;gap:6px}
        .sc-action{display:flex;align-items:center;gap:5px;padding:6px 14px;border-radius:999px;border:1px solid #c8d8e8;background:#f0f4f8;font-size:11px;font-weight:600;text-decoration:none;cursor:pointer;transition:all 0.15s;color:#0a1628;font-family:'Space Grotesk',sans-serif}
        .sc-action.start   {background:#eaf3de;border-color:#a8d08d;color:#27500a}
        .sc-action.complete{background:#eaf3de;border-color:#a8d08d;color:#27500a}
        .sc-action.cancel  {background:#fcebeb;border-color:#f7c1c1;color:#791f1f}
        .sc-action:hover{opacity:0.85;transform:scale(1.02)}

        .no-results{display:none;flex-direction:column;align-items:center;justify-content:center;padding:48px 16px;color:#5a7a90;font-size:14px;gap:8px}

        /* Pre-op Modal */
        .overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:999;align-items:center;justify-content:center}
        .overlay.open{display:flex}
        .popup-box{background:#fff;border-radius:20px;padding:24px;width:460px;max-width:95vw;max-height:80vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.2);position:relative;animation:popIn 0.2s ease}
        @keyframes popIn{from{transform:scale(0.9);opacity:0}to{transform:scale(1);opacity:1}}
        .box-close{position:absolute;top:14px;right:14px;width:28px;height:28px;border-radius:50%;border:1px solid #c8d8e8;background:#f0f4f8;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:13px}
        .box-close:hover{background:#e2eaf2}
        .popup-title{font-size:15px;font-weight:600;color:#0a1628;margin-bottom:14px}
        .popup-notes{font-size:13px;color:#0a1628;line-height:1.7;white-space:pre-wrap}

        /* Confirm Modal */
        .confirm-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.50);z-index:1100;align-items:center;justify-content:center}
        .confirm-overlay.open{display:flex}
        .confirm-box{background:#fff;border-radius:20px;padding:32px 28px 24px;width:400px;max-width:94vw;box-shadow:0 24px 60px rgba(0,0,0,0.22);animation:popIn 0.22s cubic-bezier(0.34,1.56,0.64,1);text-align:center}
        .confirm-icon{width:56px;height:56px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px}
        .confirm-icon.start   {background:#eaf3de}
        .confirm-icon.complete{background:#eaf3de}
        .confirm-icon.cancel  {background:#fcebeb}
        .confirm-title{font-size:17px;font-weight:700;color:#0a1628;margin-bottom:8px}
        .confirm-msg{font-size:13px;color:#5a7a90;line-height:1.6;margin-bottom:24px}
        .confirm-msg strong{color:#0a1628}
        .confirm-btns{display:flex;gap:10px}
        .confirm-btn{flex:1;padding:11px 0;border-radius:12px;font-size:13px;font-weight:600;cursor:pointer;border:none;font-family:'Space Grotesk',sans-serif;transition:all 0.15s}
        .confirm-btn.secondary{background:#f0f4f8;color:#2a4060;border:1px solid #c8d8e8}
        .confirm-btn.secondary:hover{background:#e2eaf2}
        .confirm-btn.primary-start{background:linear-gradient(135deg,#27ae60,#1e8449);color:#fff}
        .confirm-btn.primary-start:hover{opacity:0.90;transform:scale(1.02)}
        .confirm-btn.primary-complete{background:linear-gradient(135deg,#007a63,#005f4d);color:#fff}
        .confirm-btn.primary-complete:hover{opacity:0.90;transform:scale(1.02)}
        .confirm-btn.primary-cancel{background:linear-gradient(135deg,#c0392b,#96281b);color:#fff}
        .confirm-btn.primary-cancel:hover{opacity:0.90;transform:scale(1.02)}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">🔪 Surgery Schedule</div>
                <div class="topbar-sub">Priority-sorted surgery queue</div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="btn btn-primary btn-sm">📅 Schedule Surgery</a>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${param.msg == 'scheduled'}">
                <div class="alert alert-success">✅ Surgery scheduled successfully!</div>
            </c:if>
            <c:if test="${param.msg == 'updated'}">
                <div class="alert alert-success">✅ Surgery status updated.</div>
            </c:if>

            <c:if test="${not empty surgeries}">
                <div class="surgery-stats">
                    <div class="sstat total">
                        <div class="sstat-icon">📋</div>
                        <div><div class="sstat-val">${surgeries.size()}</div><div class="sstat-lbl">Total</div></div>
                    </div>
                    <div class="sstat scheduled">
                        <div class="sstat-icon">🗓️</div>
                        <div><div class="sstat-val" id="countScheduled">0</div><div class="sstat-lbl">Scheduled</div></div>
                    </div>
                    <div class="sstat inprogress">
                        <div class="sstat-icon">🔄</div>
                        <div><div class="sstat-val" id="countInProgress">0</div><div class="sstat-lbl">In Progress</div></div>
                    </div>
                    <div class="sstat completed">
                        <div class="sstat-icon">✅</div>
                        <div><div class="sstat-val" id="countCompleted">0</div><div class="sstat-lbl">Completed</div></div>
                    </div>
                    <div class="sstat cancelled">
                        <div class="sstat-icon">❌</div>
                        <div><div class="sstat-val" id="countCancelled">0</div><div class="sstat-lbl">Cancelled</div></div>
                    </div>
                </div>
            </c:if>

            <div class="surgery-toolbar">
                <div class="tb-left">
                    <span>📋</span>
                    <span style="font-weight:600;">All Surgeries</span>
                    <span style="font-size:12px;color:#5a7a90;" id="surgeryCount">(${surgeries.size()} total)</span>
                </div>
                <div class="tb-right">
                    <div class="search-wrap">
                        <span class="si">🔍</span>
                        <input type="text" id="surgerySearch" placeholder="Search patient, surgeon, type..." oninput="filterSurgeries()">
                    </div>
                    <select class="filter-select" id="statusFilter" onchange="filterSurgeries()">
                        <option value="">All Status</option>
                        <option value="SCHEDULED">🗓️ Scheduled</option>
                        <option value="IN_PROGRESS">🔄 In Progress</option>
                        <option value="COMPLETED">✅ Completed</option>
                        <option value="CANCELLED">❌ Cancelled</option>
                    </select>
                    <select class="filter-select" id="priorityFilter" onchange="filterSurgeries()">
                        <option value="">All Priority</option>
                        <option value="CRITICAL">🚨 Critical</option>
                        <option value="HIGH">🔴 High</option>
                        <option value="MEDIUM">🟠 Medium</option>
                        <option value="LOW">🟢 Low</option>
                    </select>
                    <select class="filter-select" id="categoryFilter" onchange="filterSurgeries()">
                        <option value="">All Category</option>
                        <option value="EMERGENCY">🚨 Emergency</option>
                        <option value="URGENT">⚠️ Urgent</option>
                        <option value="ELECTIVE">📋 Elective</option>
                    </select>
                </div>
            </div>

            <c:if test="${empty surgeries}">
                <div class="empty-state">
                    <div class="empty-icon">🔪</div>
                    <p>No surgeries scheduled yet</p>
                    <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="btn btn-primary btn-sm">Schedule First Surgery</a>
                </div>
            </c:if>

            <c:if test="${not empty surgeries}">
                <div class="surgeries-grid" id="surgeriesGrid">
                    <c:forEach var="s" items="${surgeries}">
                        <c:set var="borderColor" value="${s.priorityLevel == 'CRITICAL' ? '#e24b4a' : s.priorityLevel == 'HIGH' ? '#ef9f27' : s.priorityLevel == 'MEDIUM' ? '#ba7517' : '#639922'}"/>
                        <c:set var="iconBg"      value="${s.priorityLevel == 'CRITICAL' ? '#fcebeb' : s.priorityLevel == 'HIGH' ? '#faeeda' : s.priorityLevel == 'MEDIUM' ? '#fef9c3' : '#eaf3de'}"/>
                        <c:set var="iconColor"   value="${s.priorityLevel == 'CRITICAL' ? '#791f1f' : s.priorityLevel == 'HIGH' ? '#633806' : s.priorityLevel == 'MEDIUM' ? '#854d0e' : '#27500a'}"/>
                        <fmt:formatDate var="sDateStr" value="${s.scheduledDate}" pattern="yyyy-MM-dd"/>
                        <c:set var="isToday" value="${sDateStr == today}"/>
                        <c:set var="isInProgress" value="${s.status == 'IN_PROGRESS'}"/>

                        <div class="surgery-card ${isToday ? 'today-card' : ''} ${isInProgress ? 'inprogress-card' : ''}"
                             data-patient="${s.patientName}"
                             data-surgeon="${s.surgeonName}"
                             data-type="${s.surgeryType}"
                             data-status="${s.status}"
                             data-priority="${s.priorityLevel}"
                             data-category="${s.surgeryCategory}"
                             data-ref="${s.surgeryRef}"
                             data-date="${s.scheduledDate}"
                             style="border-left:4px solid ${borderColor};">

                            <div class="sc-top">
                                <div class="sc-left">
                                    <div class="sc-icon" style="background:${iconBg};color:${iconColor};">${s.patientInitials}</div>
                                    <div>
                                        <div class="sc-ref">${s.surgeryRef}</div>
                                        <div class="sc-patient">${s.patientName}</div>
                                        <div class="sc-type">🔪 ${s.surgeryType}</div>
                                    </div>
                                </div>
                                <div class="sc-badges">
                                    <c:if test="${isToday}"><span class="today-tag">📅 Today</span></c:if>
                                    <span class="cat-badge cat-${s.surgeryCategory.toLowerCase()}">
                                        ${s.surgeryCategory == 'EMERGENCY' ? '🚨' : s.surgeryCategory == 'URGENT' ? '⚠️' : '📋'} ${s.surgeryCategory}
                                    </span>
                                    <span class="badge risk-${s.patientRiskLevel.toLowerCase()}">${s.patientRiskLevel} Risk</span>
                                    <span class="badge priority-${s.priorityLevel.toLowerCase()}">${s.priorityLevel}</span>
                                    <span class="badge status-${s.status.toLowerCase().replace('_','')}">
                                        ${s.status == 'SCHEDULED' ? '🗓️ Scheduled' : s.status == 'IN_PROGRESS' ? '🔄 In Progress' : s.status == 'COMPLETED' ? '✅ Completed' : s.status == 'CANCELLED' ? '❌ Cancelled' : s.status}
                                    </span>
                                </div>
                            </div>

                            <c:if test="${isInProgress}">
                                <div class="live-timer-box"
                                     data-surg-date="${s.scheduledDate}"
                                     data-surg-time="${s.scheduledTime}"
                                     data-duration="${s.estimatedDuration}"
                                     data-surgery-id="${s.id}">
                                    <div class="live-dot"></div>
                                    <div>
                                        <div class="live-label">🔴 Live — Surgery in progress</div>
                                        <div class="live-elapsed" id="elapsed-${s.id}">--:--</div>
                                    </div>
                                    <div class="live-progress-wrap">
                                        <div class="live-pct" id="progressPct-${s.id}">0%</div>
                                        <div class="live-progress-bg">
                                            <div class="live-progress-fill" id="progressBar-${s.id}" style="width:0%"></div>
                                        </div>
                                    </div>
                                    <div class="live-remaining" id="remaining-${s.id}">-- min left</div>
                                </div>
                            </c:if>

                            <div class="sc-mid">
                                <div class="surgeon-box">
                                    <div class="surgeon-avatar">${s.surgeonName.substring(0,1)}</div>
                                    <div>
                                        <div class="surgeon-name">${s.surgeonName}</div>
                                        <div class="surgeon-label">Surgeon</div>
                                    </div>
                                </div>
                                <div class="mid-sep"></div>
                                <div class="ot-box">
                                    <span class="ot-num">${s.otNumber}</span>
                                    <span class="ot-name-txt">— ${s.otName}</span>
                                </div>
                            </div>

                            <div class="sc-bottom">
                                <div class="info-cell">
                                    <div class="info-label">Date</div>
                                    <div class="info-value">${s.scheduledDate}</div>
                                </div>
                                <div class="info-cell">
                                    <div class="info-label">Start Time</div>
                                    <div class="info-value teal">${s.formattedTime}</div>
                                </div>
                                <div class="info-cell">
                                    <div class="info-label">Duration</div>
                                    <div class="info-value">${s.estimatedDuration} min</div>
                                </div>
                                <div class="info-cell">
                                    <div class="info-label">End Time</div>
                                    <div class="info-value orange" id="endTime-${s.id}">--</div>
                                </div>
                            </div>

                            <c:if test="${not empty s.preOpNotes}">
                                <div class="preop-preview" onclick="openNotes('${s.surgeryRef}','${s.preOpNotes.replace("'","&#39;")}')">
                                    📝 ${s.preOpNotes}
                                </div>
                            </c:if>

                            <div class="sc-footer">
                                <div class="sc-meta">${s.surgeryCategory} · ${s.otNumber} · ${s.scheduledDate}</div>
                                <div class="sc-actions">
                                    <c:if test="${s.status == 'SCHEDULED'}">
                                        <button class="sc-action start"
                                                onclick="showConfirm('start','${s.patientName}','${pageContext.request.contextPath}/surgeries?action=updateStatus&id=${s.id}&status=IN_PROGRESS')">
                                            ▶️ Start
                                        </button>
                                        <button class="sc-action cancel"
                                                onclick="showConfirm('cancel','${s.patientName}','${pageContext.request.contextPath}/surgeries?action=updateStatus&id=${s.id}&status=CANCELLED')">
                                            ❌ Cancel
                                        </button>
                                    </c:if>
                                    <c:if test="${s.status == 'IN_PROGRESS'}">
                                        <button class="sc-action complete"
                                                onclick="showConfirm('complete','${s.patientName}','${pageContext.request.contextPath}/surgeries?action=updateStatus&id=${s.id}&status=COMPLETED')">
                                            ✅ Complete
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="no-results" id="noResults">
                    <div style="font-size:40px;">🔍</div>
                    <div style="font-weight:600;color:#0a1628;">No surgeries found</div>
                    <div>Try a different search or filter.</div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Pre-op Notes Popup -->
<div class="overlay" id="notesOverlay" onclick="closeOnBg(event,'notesOverlay')">
    <div class="popup-box">
        <div class="box-close" onclick="closeOverlay('notesOverlay')">✕</div>
        <div class="popup-title" id="notesTitle">Pre-Operative Notes</div>
        <div class="popup-notes" id="notesContent"></div>
    </div>
</div>

<!-- Confirm Modal -->
<div class="confirm-overlay" id="confirmOverlay">
    <div class="confirm-box">
        <div class="confirm-icon" id="confirmIcon"></div>
        <div class="confirm-title" id="confirmTitle"></div>
        <div class="confirm-msg" id="confirmMsg"></div>
        <div class="confirm-btns">
            <button class="confirm-btn secondary" onclick="closeConfirm()">Cancel</button>
            <button class="confirm-btn" id="confirmOkBtn" onclick="doConfirm()"></button>
        </div>
    </div>
</div>

<script>
var allCards = document.querySelectorAll('.surgery-card');
var counts = {SCHEDULED:0,IN_PROGRESS:0,COMPLETED:0,CANCELLED:0};
allCards.forEach(function(c){var st=c.dataset.status;if(counts[st]!==undefined)counts[st]++;});
if(document.getElementById('countScheduled')) document.getElementById('countScheduled').textContent=counts.SCHEDULED;
if(document.getElementById('countInProgress'))document.getElementById('countInProgress').textContent=counts.IN_PROGRESS;
if(document.getElementById('countCompleted')) document.getElementById('countCompleted').textContent=counts.COMPLETED;
if(document.getElementById('countCancelled')) document.getElementById('countCancelled').textContent=counts.CANCELLED;

function calcEndTime(timeStr,durationMin){
    if(!timeStr||!durationMin)return'--';
    var match=timeStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
    if(!match)return'--';
    var h=parseInt(match[1]),m=parseInt(match[2]),p=match[3].toUpperCase();
    if(p==='PM'&&h!==12)h+=12;if(p==='AM'&&h===12)h=0;
    var totalM=h*60+m+durationMin;
    var endH=Math.floor(totalM/60)%24,endM=totalM%60;
    var endP=endH>=12?'PM':'AM',endH12=endH%12||12;
    return(endH12<10?'0':'')+endH12+':'+(endM<10?'0':'')+endM+' '+endP;
}

allCards.forEach(function(card){
    var endEl=card.querySelector('[id^="endTime-"]');if(!endEl)return;
    var cells=card.querySelectorAll('.info-cell');
    var timeVal=cells[1]?cells[1].querySelector('.info-value').textContent.trim():'';
    var durVal=cells[2]?parseInt(cells[2].querySelector('.info-value').textContent):0;
    endEl.textContent=calcEndTime(timeVal,durVal);
});

var timerBoxes=document.querySelectorAll('[data-surg-date][data-surg-time][data-duration]');
function updateLiveTimers(){
    timerBoxes.forEach(function(box){
        var surgDate=box.dataset.surgDate,surgTime=box.dataset.surgTime;
        var durationMin=parseInt(box.dataset.duration),surgId=box.dataset.surgeryId;
        var dp=surgDate.split('-'),tp=surgTime.split(':');
        var startDate=new Date(parseInt(dp[0]),parseInt(dp[1])-1,parseInt(dp[2]),parseInt(tp[0]),parseInt(tp[1]),0,0);
        var now=new Date(),elapsedMs=now-startDate,totalMs=durationMin*60*1000,remainMs=totalMs-elapsedMs;
        var elapsedEl=document.getElementById('elapsed-'+surgId);
        var remainEl=document.getElementById('remaining-'+surgId);
        var barEl=document.getElementById('progressBar-'+surgId);
        var pctEl=document.getElementById('progressPct-'+surgId);
        if(!elapsedEl)return;
        if(elapsedMs<0){elapsedEl.textContent='00:00';if(remainEl)remainEl.textContent=durationMin+' min left';if(barEl)barEl.style.width='0%';if(pctEl)pctEl.textContent='0%';return;}
        var elH=Math.floor(elapsedMs/3600000),elMin=Math.floor((elapsedMs%3600000)/60000),elSec=Math.floor((elapsedMs%60000)/1000);
        elapsedEl.textContent=elH>0?(elH<10?'0':'')+elH+':'+(elMin<10?'0':'')+elMin+':'+(elSec<10?'0':'')+elSec:(elMin<10?'0':'')+elMin+':'+(elSec<10?'0':'')+elSec;
        var pct=Math.min(Math.round((elapsedMs/totalMs)*100),100);
        if(barEl)barEl.style.width=pct+'%';if(pctEl)pctEl.textContent=pct+'%';
        if(remainMs<=0){if(remainEl)remainEl.textContent='⚠️ Overtime!';if(barEl){barEl.style.width='100%';barEl.style.background='#c0392b';}}
        else{var remH=Math.floor(remainMs/3600000),remMin=Math.floor((remainMs%3600000)/60000);if(remainEl)remainEl.textContent=remH>0?remH+'h '+remMin+'min left':remMin+' min left';}
    });
}
if(timerBoxes.length>0){setInterval(updateLiveTimers,1000);updateLiveTimers();}

function filterSurgeries(){
    var query=document.getElementById('surgerySearch').value.toLowerCase().trim();
    var status=document.getElementById('statusFilter').value;
    var priority=document.getElementById('priorityFilter').value;
    var category=document.getElementById('categoryFilter').value;
    var cards=document.querySelectorAll('#surgeriesGrid .surgery-card');
    var visible=0;
    cards.forEach(function(card){
        var matchSearch=!query||(card.dataset.patient||'').toLowerCase().includes(query)||(card.dataset.surgeon||'').toLowerCase().includes(query)||(card.dataset.type||'').toLowerCase().includes(query)||(card.dataset.ref||'').toLowerCase().includes(query);
        var matchStatus=!status||card.dataset.status===status;
        var matchPriority=!priority||card.dataset.priority===priority;
        var matchCategory=!category||card.dataset.category===category;
        if(matchSearch&&matchStatus&&matchPriority&&matchCategory){card.style.display='';visible++;}
        else{card.style.display='none';}
    });
    document.getElementById('surgeryCount').textContent='('+visible+' total)';
    var noR=document.getElementById('noResults'),grid=document.getElementById('surgeriesGrid');
    if(noR&&grid){grid.style.display=visible===0?'none':'';noR.style.display=visible===0?'flex':'none';}
}

function openNotes(ref,notes){
    document.getElementById('notesTitle').textContent='📝 Pre-Op Notes — '+ref;
    document.getElementById('notesContent').textContent=notes;
    document.getElementById('notesOverlay').classList.add('open');
}
function closeOverlay(id){document.getElementById(id).classList.remove('open');}
function closeOnBg(e,id){if(e.target===document.getElementById(id))closeOverlay(id);}

var _confirmUrl='';
function showConfirm(type,patientName,url){
    _confirmUrl=url;
    var icon=document.getElementById('confirmIcon');
    var title=document.getElementById('confirmTitle');
    var msg=document.getElementById('confirmMsg');
    var okBtn=document.getElementById('confirmOkBtn');
    icon.className='confirm-icon '+type;
    if(type==='start'){icon.textContent='▶️';title.textContent='Start Surgery?';msg.innerHTML='You are about to start surgery for <strong>'+patientName+'</strong>.<br>This will mark it as <strong>In Progress</strong>.';okBtn.textContent='▶️ Yes, Start Surgery';okBtn.className='confirm-btn primary-start';}
    else if(type==='complete'){icon.textContent='✅';title.textContent='Mark as Completed?';msg.innerHTML='Surgery for <strong>'+patientName+'</strong> will be marked as <strong>Completed</strong>.';okBtn.textContent='✅ Yes, Mark Complete';okBtn.className='confirm-btn primary-complete';}
    else if(type==='cancel'){icon.textContent='❌';title.textContent='Cancel Surgery?';msg.innerHTML='Are you sure you want to cancel surgery for <strong>'+patientName+'</strong>?';okBtn.textContent='❌ Yes, Cancel Surgery';okBtn.className='confirm-btn primary-cancel';}
    document.getElementById('confirmOverlay').classList.add('open');
    document.body.style.overflow='hidden';
}
function closeConfirm(){document.getElementById('confirmOverlay').classList.remove('open');document.body.style.overflow='';_confirmUrl='';}
function doConfirm(){if(_confirmUrl)window.location.href=_confirmUrl;}
document.getElementById('confirmOverlay').addEventListener('click',function(e){if(e.target===this)closeConfirm();});
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeOverlay('notesOverlay');closeConfirm();}});
</script>
</body>
</html>