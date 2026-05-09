<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.surgery.model.Surgery, java.util.List, java.util.Map" %>
<%
    request.setAttribute("currentPage", "ot");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Operation Theaters — Smart Surgery System</title>
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
        }
        .shell{display:flex;height:100vh;overflow:hidden}
        .area{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}

        /* Topbar */
        .topbar{background:#E1F5EE;border-bottom:2px solid #1D9E75;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
        .topbar-title{font-size:16px;font-weight:700;color:#085041}
        .topbar-sub{font-size:12px;color:#0F6E56;margin-top:2px}
        .topbar-right{display:flex;align-items:center;gap:10px}

        /* Page body */
        .page-body{flex:1;overflow-y:auto;overflow-x:hidden;padding-bottom:40px}
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
        .alert-warning{background:rgba(168,98,0,0.08);border-color:rgba(168,98,0,0.30);color:#a86200}

        /* Empty state */
        .empty-state{text-align:center;padding:60px 20px;color:#5a7a90}
        .empty-state .empty-icon{font-size:48px;margin-bottom:14px;opacity:0.4}
        .empty-state p{font-size:14px;margin-bottom:16px}

        /* Stats */
        .ot-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;padding:16px 16px 0}
        .ot-stat-card{border-radius:16px;padding:16px 18px;display:flex;flex-direction:column;gap:5px;position:relative;overflow:hidden;color:#fff}
        .ot-stat-card::after{content:'';position:absolute;width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,0.10);bottom:-18px;right:-18px}
        .ot-stat-card.green {background:linear-gradient(135deg,#1a9e75,#157a5b)}
        .ot-stat-card.red   {background:linear-gradient(135deg,#c0392b,#96281b)}
        .ot-stat-card.orange{background:linear-gradient(135deg,#e67e22,#ca6f1e)}
        .ot-stat-card.purple{background:linear-gradient(135deg,#8e44ad,#6c3483)}
        .ot-stat-card.blue  {background:linear-gradient(135deg,#1a5276,#154360)}
        .ot-stat-icon {font-size:22px}
        .ot-stat-label{font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;opacity:0.85}
        .ot-stat-value{font-size:32px;font-weight:700;line-height:1}
        .ot-stat-sub  {font-size:10px;opacity:0.75}

        /* Toolbar */
        .ot-toolbar{padding:14px 16px 0;display:flex;align-items:center;gap:10px;flex-wrap:wrap}
        .tb-left {display:flex;align-items:center;gap:8px}
        .tb-right{margin-left:auto;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .search-wrap{position:relative}
        .search-wrap .si{position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:13px;pointer-events:none}
        .search-wrap input{padding:7px 12px 7px 30px;border-radius:999px;border:1px solid #c8d8e8;font-size:12px;color:#0a1628;background:#fff;outline:none;width:210px;font-family:'Space Grotesk',sans-serif}
        .search-wrap input:focus{border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.12)}
        .type-select{padding:7px 28px 7px 12px;border-radius:999px;border:1px solid #c8d8e8;font-size:12px;color:#0a1628;background:#fff;outline:none;appearance:none;cursor:pointer;font-family:'Space Grotesk',sans-serif;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%236b7280'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 10px center}
        .filter-btn{padding:6px 12px;border-radius:999px;border:1px solid #c8d8e8;background:transparent;font-size:11px;font-weight:600;cursor:pointer;transition:all 0.18s;color:#5a7a90;font-family:'Space Grotesk',sans-serif}
        .filter-btn.f-all        {background:#1a9e75;color:#fff;border-color:#1a9e75}
        .filter-btn.f-available  {background:#eaf3de;color:#27500a;border-color:#27500a}
        .filter-btn.f-occupied   {background:#fcebeb;color:#791f1f;border-color:#791f1f}
        .filter-btn.f-maintenance{background:#faeeda;color:#633806;border-color:#e67e22}
        .filter-btn.f-sterilizing{background:#f3e8ff;color:#6c3483;border-color:#8e44ad}

        /* OT Grid */
        .ot-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;padding:16px}
        .ot-card{background:#fff;border:1px solid #c8d8e8;border-radius:16px;padding:14px;display:flex;flex-direction:column;gap:10px;transition:box-shadow 0.2s,transform 0.2s}
        .ot-card:hover{box-shadow:0 8px 24px rgba(0,0,0,0.10);transform:translateY(-3px)}
        .ot-card.status-occupied   {border-left:3px solid #c0392b}
        .ot-card.status-sterilizing{border-left:3px solid #8e44ad}
        .ot-card.status-maintenance{border-left:3px solid #e67e22}
        .ot-card.status-available  {border-left:3px solid #1a9e75}

        .ot-card-top{display:flex;align-items:flex-start;gap:12px}
        .ot-icon-wrap{width:44px;height:44px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:19px;flex-shrink:0}
        .ot-icon-wrap.green {background:#eaf3de}
        .ot-icon-wrap.red   {background:#fcebeb}
        .ot-icon-wrap.orange{background:#faeeda}
        .ot-icon-wrap.purple{background:#f3e8ff}
        .ot-num {font-size:11px;color:#007a63;font-weight:600}
        .ot-name{font-size:14px;font-weight:700;color:#0a1628;margin-top:1px}
        .ot-type-badge{display:inline-block;font-size:10px;font-weight:600;border-radius:999px;padding:2px 9px;margin-top:3px;background:#e6f1fb;color:#185fa5}
        .ot-status-badge{margin-left:auto;font-size:10px;font-weight:700;border-radius:999px;padding:4px 10px;white-space:nowrap;cursor:pointer;display:inline-flex;align-items:center;gap:4px;border:none;transition:opacity 0.15s;font-family:'Space Grotesk',sans-serif}
        .ot-status-badge:hover{opacity:0.8}
        .sb-available  {background:#eaf3de;color:#27500a}
        .sb-occupied   {background:#fcebeb;color:#791f1f}
        .sb-maintenance{background:#faeeda;color:#633806}
        .sb-sterilizing{background:#f3e8ff;color:#6c3483}

        .ot-divider{height:1px;background:#c8d8e8}
        .ot-equip{font-size:11px;color:#5a7a90;display:flex;align-items:flex-start;gap:6px}
        .ot-equip span{color:#0a1628;font-size:11px;line-height:1.5}

        .util-section{display:flex;flex-direction:column;gap:4px}
        .util-header{display:flex;align-items:center;justify-content:space-between}
        .util-label{font-size:10px;font-weight:600;color:#5a7a90;text-transform:uppercase;letter-spacing:0.5px}
        .util-pct{font-size:11px;font-weight:700}
        .util-bar-bg{width:100%;height:6px;border-radius:999px;background:#c8d8e8;overflow:hidden}
        .util-bar-fill{height:100%;border-radius:999px;transition:width 0.5s ease}
        .util-bar-fill.low   {background:#1a9e75}
        .util-bar-fill.medium{background:#e67e22}
        .util-bar-fill.high  {background:#c0392b}
        .util-detail{font-size:10px;color:#5a7a90}

        .steril-box{background:linear-gradient(135deg,#f3e8ff,#ede0ff);border:1px solid #c39ae0;border-radius:10px;padding:10px 12px;display:flex;flex-direction:column;gap:6px}
        .steril-header{display:flex;align-items:center;justify-content:space-between}
        .steril-title{font-size:11px;font-weight:700;color:#6c3483}
        .steril-timer{font-size:14px;font-weight:700;color:#6c3483;font-family:monospace}
        .steril-bar-bg{width:100%;height:5px;border-radius:999px;background:rgba(142,68,173,0.2);overflow:hidden}
        .steril-bar-fill{height:100%;border-radius:999px;background:#8e44ad;transition:width 1s linear}
        .steril-sub{font-size:10px;color:#8e44ad}

        .last-steril{font-size:10px;color:#5a7a90;display:flex;align-items:center;gap:4px}
        .last-steril.fresh{color:#1a9e75}

        .ot-schedule-header{display:flex;align-items:center;justify-content:space-between;font-size:11px;font-weight:600;color:#5a7a90;text-transform:uppercase;letter-spacing:0.5px}
        .schedule-count-badge{font-size:10px;border-radius:999px;padding:2px 8px;font-weight:600}
        .surgery-slot{background:#f0f4f8;border:1px solid #c8d8e8;border-radius:10px;padding:8px 10px;display:flex;flex-direction:column;gap:4px;margin-bottom:5px}
        .surgery-slot:last-child{margin-bottom:0}
        .slot-top{display:flex;align-items:center;gap:6px}
        .slot-time{font-size:11px;font-weight:700;color:#007a63;background:#eaf3de;border-radius:6px;padding:1px 7px;white-space:nowrap}
        .slot-ref{font-size:10px;color:#5a7a90}
        .slot-status{margin-left:auto;font-size:10px;font-weight:600;border-radius:999px;padding:2px 8px}
        .ss-scheduled  {background:#e6f1fb;color:#185fa5}
        .ss-in_progress{background:#faeeda;color:#633806}
        .ss-completed  {background:#eaf3de;color:#27500a}
        .ss-cancelled  {background:#f0f4f8;color:#5a7a90}
        .slot-patient{font-size:12px;font-weight:600;color:#0a1628}
        .slot-surgeon{font-size:11px;color:#5a7a90}
        .slot-bottom{display:flex;align-items:center;justify-content:space-between}
        .slot-type   {font-size:11px;color:#185fa5}
        .slot-duration{font-size:10px;color:#5a7a90}
        .priority-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}
        .pd-critical{background:#c0392b}
        .pd-high    {background:#e67e22}
        .pd-medium  {background:#f1c40f}
        .pd-low     {background:#1a9e75}
        .no-surgery-today{text-align:center;padding:10px 8px;color:#5a7a90;font-size:12px}

        .ot-actions{display:flex;justify-content:space-between;align-items:center;margin-top:auto}
        .ot-quick-actions{display:flex;gap:6px}
        .act-btn{width:28px;height:28px;border-radius:50%;border:1px solid #c8d8e8;background:#f0f4f8;display:flex;align-items:center;justify-content:center;font-size:12px;cursor:pointer;transition:background 0.15s;text-decoration:none}
        .act-btn:hover{background:#c8d8e8}
        .steril-btn{font-size:10px;font-weight:600;padding:4px 10px;border-radius:999px;background:#f3e8ff;color:#6c3483;border:1px solid #c39ae0;cursor:pointer;text-decoration:none;transition:background 0.15s;font-family:'Space Grotesk',sans-serif}
        .steril-btn:hover{background:#ede0ff}
        .steril-done-btn{font-size:10px;font-weight:600;padding:4px 10px;border-radius:999px;background:#eaf3de;color:#27500a;border:1px solid #a8d08d;cursor:pointer;text-decoration:none;transition:background 0.15s;font-family:'Space Grotesk',sans-serif}

        .no-results{display:none;flex-direction:column;align-items:center;justify-content:center;padding:48px 16px;color:#5a7a90;font-size:14px;gap:8px}

        /* Modal */
        .overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:999;align-items:center;justify-content:center}
        .overlay.open{display:flex}
        .modal-box{background:#fff;border-radius:24px;padding:28px;width:500px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,0.2);position:relative;animation:popIn 0.2s ease;max-height:90vh;overflow-y:auto}
        @keyframes popIn{from{transform:scale(0.9);opacity:0}to{transform:scale(1);opacity:1}}
        .box-close{position:absolute;top:16px;right:16px;width:30px;height:30px;border-radius:50%;border:1px solid #c8d8e8;background:#f0f4f8;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:14px}
        .box-close:hover{background:#c8d8e8}
        .box-title{font-size:17px;font-weight:600;color:#0a1628;margin-bottom:20px}
        .form-group{margin-bottom:14px}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#5a7a90;margin-bottom:5px}
        .form-group input,.form-group select,.form-group textarea{width:100%;padding:8px 12px;border-radius:10px;border:1px solid #c8d8e8;font-size:13px;color:#0a1628;background:#fff;outline:none;box-sizing:border-box;font-family:'Space Grotesk',sans-serif}
        .form-group textarea{resize:vertical;min-height:70px}
        .form-group input:focus,.form-group select:focus,.form-group textarea:focus{border-color:#007a63}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
        .auto-id-wrap{position:relative}
        .auto-id-wrap input{background:#f0f4f8;color:#007a63;font-weight:600;cursor:default}
        .auto-id-badge{position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:10px;background:#eaf3de;color:#27500a;border-radius:999px;padding:2px 8px;font-weight:600;pointer-events:none}
        .select-wrap{position:relative}
        .select-wrap::after{content:'▾';position:absolute;right:12px;top:50%;transform:translateY(-50%);font-size:12px;color:#5a7a90;pointer-events:none}
        .select-wrap select{padding-right:28px;appearance:none;-webkit-appearance:none}
        .btn-submit{width:100%;padding:10px;border-radius:999px;background:#007a63;color:#fff;border:none;font-size:14px;font-weight:500;cursor:pointer;margin-top:6px;font-family:'Space Grotesk',sans-serif}
        .btn-submit:hover{background:#005f4d}
        .form-hint{font-size:11px;color:#5a7a90;margin-top:3px}

        /* Confirm Modal */
        .confirm-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.50);z-index:1100;align-items:center;justify-content:center}
        .confirm-overlay.open{display:flex}
        .confirm-box{background:#fff;border-radius:20px;padding:32px 28px 24px;width:380px;max-width:94vw;box-shadow:0 24px 60px rgba(0,0,0,0.22);animation:popIn 0.22s cubic-bezier(0.34,1.56,0.64,1);text-align:center}
        .confirm-icon{width:56px;height:56px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px}
        .confirm-icon.toggle   {background:#e6f1fb}
        .confirm-icon.sterilize{background:#f3e8ff}
        .confirm-icon.done     {background:#eaf3de}
        .confirm-icon.delete   {background:#fcebeb}
        .confirm-title{font-size:17px;font-weight:700;color:#0a1628;margin-bottom:8px}
        .confirm-msg  {font-size:13px;color:#5a7a90;line-height:1.6;margin-bottom:24px}
        .confirm-msg strong{color:#0a1628}
        .confirm-btns{display:flex;gap:10px}
        .confirm-btn{flex:1;padding:11px 0;border-radius:12px;font-size:13px;font-weight:600;cursor:pointer;border:none;font-family:'Space Grotesk',sans-serif;transition:all 0.15s}
        .confirm-btn.secondary{background:#f0f4f8;color:#2a4060;border:1px solid #c8d8e8}
        .confirm-btn.secondary:hover{background:#e2eaf2}
        .confirm-btn.btn-toggle   {background:linear-gradient(135deg,#1560a8,#0f4d8a);color:#fff}
        .confirm-btn.btn-sterilize{background:linear-gradient(135deg,#8e44ad,#6c3483);color:#fff}
        .confirm-btn.btn-done     {background:linear-gradient(135deg,#007a63,#005f4d);color:#fff}
        .confirm-btn.btn-delete   {background:linear-gradient(135deg,#c0392b,#96281b);color:#fff}
        .confirm-btn.btn-toggle:hover,.confirm-btn.btn-sterilize:hover,.confirm-btn.btn-done:hover,.confirm-btn.btn-delete:hover{opacity:0.90;transform:scale(1.02)}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">🏨 Operation Theaters</div>
                <div class="topbar-sub">Smart OT management &amp; scheduling</div>
            </div>
            <div class="topbar-right">
                <button class="btn btn-primary btn-sm" onclick="openAddModal()">➕ Add OT</button>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${param.msg == 'added'}">      <div class="alert alert-success">✅ OT added successfully!</div></c:if>
            <c:if test="${param.msg == 'updated'}">    <div class="alert alert-success">✅ OT updated successfully!</div></c:if>
            <c:if test="${param.msg == 'deleted'}">    <div class="alert alert-warning">🗑️ OT deleted.</div></c:if>
            <c:if test="${param.msg == 'sterilizing'}"><div class="alert alert-success">🧹 Sterilization started!</div></c:if>
            <c:if test="${param.msg == 'available'}">  <div class="alert alert-success">✅ OT is now Available!</div></c:if>

            <div class="ot-stats">
                <div class="ot-stat-card green">
                    <div class="ot-stat-icon">✅</div>
                    <div class="ot-stat-label">Available</div>
                    <div class="ot-stat-value">${availCount}</div>
                    <div class="ot-stat-sub">Ready for surgery</div>
                </div>
                <div class="ot-stat-card red">
                    <div class="ot-stat-icon">🔴</div>
                    <div class="ot-stat-label">Occupied</div>
                    <div class="ot-stat-value">${occupCount}</div>
                    <div class="ot-stat-sub">Currently in use</div>
                </div>
                <div class="ot-stat-card purple">
                    <div class="ot-stat-icon">🧹</div>
                    <div class="ot-stat-label">Sterilizing</div>
                    <div class="ot-stat-value">${sterilCount}</div>
                    <div class="ot-stat-sub">Being sterilized</div>
                </div>
                <div class="ot-stat-card orange">
                    <div class="ot-stat-icon">🔧</div>
                    <div class="ot-stat-label">Maintenance</div>
                    <div class="ot-stat-value">${maintCount}</div>
                    <div class="ot-stat-sub">Under maintenance</div>
                </div>
                <div class="ot-stat-card blue">
                    <div class="ot-stat-icon">🏨</div>
                    <div class="ot-stat-label">Total OTs</div>
                    <div class="ot-stat-value">${ots.size()}</div>
                    <div class="ot-stat-sub">Operation theaters</div>
                </div>
            </div>

            <div class="ot-toolbar">
                <div class="tb-left">
                    <span style="font-weight:600;">🏨 OT List</span>
                    <span style="font-size:12px;color:#5a7a90;" id="otCount">(${ots.size()} total)</span>
                </div>
                <div class="tb-right">
                    <div class="search-wrap">
                        <span class="si">🔍</span>
                        <input type="text" id="otSearch" placeholder="Search OT name or number..." oninput="filterOTs()">
                    </div>
                    <select class="type-select" id="typeFilter" onchange="filterOTs()">
                        <option value="">All Types</option>
                        <option value="GENERAL">🏥 General</option>
                        <option value="CARDIAC">❤️ Cardiac</option>
                        <option value="NEURO">🧠 Neuro</option>
                        <option value="ORTHOPEDIC">🦴 Orthopedic</option>
                        <option value="EMERGENCY">🚨 Emergency</option>
                        <option value="LAPAROSCOPIC">🔬 Laparoscopic</option>
                    </select>
                    <button id="btnAll"    class="filter-btn f-all" onclick="setFilter('all')">All</button>
                    <button id="btnAvail"  class="filter-btn"       onclick="setFilter('available')">✅ Available</button>
                    <button id="btnOccup"  class="filter-btn"       onclick="setFilter('occupied')">🔴 Occupied</button>
                    <button id="btnSteril" class="filter-btn"       onclick="setFilter('sterilizing')">🧹 Sterilizing</button>
                    <button id="btnMaint"  class="filter-btn"       onclick="setFilter('maintenance')">🔧 Maintenance</button>
                </div>
            </div>

            <c:if test="${empty ots}">
                <div class="empty-state">
                    <div class="empty-icon">🏨</div>
                    <p>No operation theaters found</p>
                    <button class="btn btn-primary btn-sm" onclick="openAddModal()">Add First OT</button>
                </div>
            </c:if>

            <c:if test="${not empty ots}">
                <span id="nextOTNumber" style="display:none">${nextOtNumber}</span>
                <div class="ot-grid" id="otGrid">
                    <c:forEach var="ot" items="${ots}">
                        <c:set var="otSurgeries"    value="${scheduleMap[ot.id]}"/>
                        <c:set var="surgeryCount"   value="${utilizationMap[ot.id]}"/>
                        <c:set var="surgeryMinutes" value="${surgeryMinutesMap[ot.id]}"/>
                        <c:set var="surgeryCountVal"   value="${surgeryCount   != null ? surgeryCount   : 0}"/>
                        <c:set var="surgeryMinutesVal" value="${surgeryMinutes != null ? surgeryMinutes : 0}"/>
                        <c:set var="utilPct"       value="${surgeryMinutesVal > 0 ? (surgeryMinutesVal * 100 / 480) : 0}"/>
                        <c:set var="utilPctCapped" value="${utilPct > 100 ? 100 : utilPct}"/>

                        <div class="ot-card status-${ot.status.toLowerCase()}"
                             data-name="${ot.otName}" data-number="${ot.otNumber}"
                             data-type="${ot.otType}" data-status="${ot.status}">

                            <div class="ot-card-top">
                                <div class="ot-icon-wrap ${ot.status == 'AVAILABLE' ? 'green' : ot.status == 'OCCUPIED' ? 'red' : ot.status == 'STERILIZING' ? 'purple' : 'orange'}">
                                    <c:choose>
                                        <c:when test="${ot.otType == 'CARDIAC'}">❤️</c:when>
                                        <c:when test="${ot.otType == 'NEURO'}">🧠</c:when>
                                        <c:when test="${ot.otType == 'ORTHOPEDIC'}">🦴</c:when>
                                        <c:when test="${ot.otType == 'EMERGENCY'}">🚨</c:when>
                                        <c:when test="${ot.otType == 'LAPAROSCOPIC'}">🔬</c:when>
                                        <c:otherwise>🏥</c:otherwise>
                                    </c:choose>
                                </div>
                                <div style="flex:1;min-width:0;">
                                    <div class="ot-num">${ot.otNumber}</div>
                                    <div class="ot-name">${ot.otName}</div>
                                    <span class="ot-type-badge">${ot.otType}</span>
                                </div>
                                <button class="ot-status-badge ${ot.status == 'AVAILABLE' ? 'sb-available' : ot.status == 'OCCUPIED' ? 'sb-occupied' : ot.status == 'STERILIZING' ? 'sb-sterilizing' : 'sb-maintenance'}"
                                        onclick="showConfirm('toggle','${ot.otName}','${pageContext.request.contextPath}/ot?action=toggle&id=${ot.id}&status=${ot.status}')">
                                    <c:choose>
                                        <c:when test="${ot.status == 'AVAILABLE'}">✅ Available</c:when>
                                        <c:when test="${ot.status == 'OCCUPIED'}">🔴 Occupied</c:when>
                                        <c:when test="${ot.status == 'STERILIZING'}">🧹 Sterilizing</c:when>
                                        <c:when test="${ot.status == 'MAINTENANCE'}">🔧 Maintenance</c:when>
                                        <c:otherwise>${ot.status}</c:otherwise>
                                    </c:choose>
                                </button>
                            </div>

                            <div class="ot-divider"></div>

                            <div class="ot-equip">
                                🩺
                                <c:choose>
                                    <c:when test="${not empty ot.equipmentList}"><span>${ot.equipmentList}</span></c:when>
                                    <c:otherwise><span style="color:#5a7a90;font-style:italic;">No equipment listed</span></c:otherwise>
                                </c:choose>
                            </div>

                            <div class="ot-divider"></div>

                            <div class="util-section">
                                <div class="util-header">
                                    <span class="util-label">📊 Today's Utilization</span>
                                    <span class="util-pct" style="color:${utilPctCapped >= 80 ? '#c0392b' : utilPctCapped >= 50 ? '#e67e22' : '#1a9e75'}">${utilPctCapped}%</span>
                                </div>
                                <div class="util-bar-bg">
                                    <div class="util-bar-fill ${utilPctCapped >= 80 ? 'high' : utilPctCapped >= 50 ? 'medium' : 'low'}" style="width:${utilPctCapped}%"></div>
                                </div>
                                <div class="util-detail">${surgeryCountVal} surgery &nbsp;|&nbsp; ${surgeryMinutesVal} min used &nbsp;|&nbsp; 480 min capacity</div>
                            </div>

                            <div class="ot-divider"></div>

                            <c:choose>
                                <c:when test="${ot.status == 'STERILIZING'}">
                                    <div class="steril-box" data-steril-start="${ot.lastSterilized.time}" data-steril-min="${ot.sterilizationMinutes}" data-ot-id="${ot.id}">
                                        <div class="steril-header">
                                            <span class="steril-title">🧹 Sterilizing in progress...</span>
                                            <span class="steril-timer" id="timer-${ot.id}">--:--</span>
                                        </div>
                                        <div class="steril-bar-bg">
                                            <div class="steril-bar-fill" id="steril-bar-${ot.id}" style="width:0%"></div>
                                        </div>
                                        <div style="display:flex;align-items:center;justify-content:space-between;">
                                            <span class="steril-sub">${ot.sterilizationMinutes} min total</span>
                                            <button class="steril-done-btn" onclick="showConfirm('done','${ot.otName}','${pageContext.request.contextPath}/ot?action=sterilize_done&id=${ot.id}')">✅ Mark Done</button>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="last-steril ${ot.minutesSinceLastSterilized >= 0 && ot.minutesSinceLastSterilized < 120 ? 'fresh' : ''}">
                                        🧼
                                        <c:choose>
                                            <c:when test="${ot.lastSterilized != null}">
                                                <c:choose>
                                                    <c:when test="${ot.minutesSinceLastSterilized < 60}">Last sterilized ${ot.minutesSinceLastSterilized} min ago</c:when>
                                                    <c:when test="${ot.minutesSinceLastSterilized < 1440}">Last sterilized ${ot.minutesSinceLastSterilized / 60} hrs ago</c:when>
                                                    <c:otherwise>Last sterilized ${ot.minutesSinceLastSterilized / 1440} days ago</c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>Never sterilized — record not available</c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <div class="ot-divider"></div>

                            <div class="ot-schedule-header">
                                <span>📅 Today's Schedule</span>
                                <c:choose>
                                    <c:when test="${not empty otSurgeries}">
                                        <span class="schedule-count-badge" style="background:#e6f1fb;color:#185fa5;">${otSurgeries.size()} surgery</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="schedule-count-badge" style="background:#f0f4f8;color:#5a7a90;">0 surgery</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:choose>
                                <c:when test="${not empty otSurgeries}">
                                    <c:forEach var="surg" items="${otSurgeries}">
                                        <div class="surgery-slot">
                                            <div class="slot-top">
                                                <div class="priority-dot ${surg.priorityLevel == 'CRITICAL' ? 'pd-critical' : surg.priorityLevel == 'HIGH' ? 'pd-high' : surg.priorityLevel == 'MEDIUM' ? 'pd-medium' : 'pd-low'}"></div>
                                                <span class="slot-time">${surg.formattedTime}</span>
                                                <span class="slot-ref">${surg.surgeryRef}</span>
                                                <span class="slot-status ${surg.status == 'SCHEDULED' ? 'ss-scheduled' : surg.status == 'IN_PROGRESS' ? 'ss-in_progress' : surg.status == 'COMPLETED' ? 'ss-completed' : 'ss-cancelled'}">
                                                    <c:choose>
                                                        <c:when test="${surg.status == 'IN_PROGRESS'}">🔄 In Progress</c:when>
                                                        <c:when test="${surg.status == 'COMPLETED'}">✅ Done</c:when>
                                                        <c:when test="${surg.status == 'CANCELLED'}">❌ Cancelled</c:when>
                                                        <c:otherwise>🗓️ Scheduled</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="slot-patient">👤 ${surg.patientName}</div>
                                            <div class="slot-surgeon">👨‍⚕️ ${surg.surgeonName}</div>
                                            <div class="slot-bottom">
                                                <span class="slot-type">🔪 ${surg.surgeryType}</span>
                                                <span class="slot-duration">⏱ ${surg.estimatedDuration} min</span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-surgery-today">😴 No surgery scheduled today</div>
                                </c:otherwise>
                            </c:choose>

                            <div class="ot-actions">
                                <div>
                                    <c:if test="${ot.status == 'AVAILABLE' || ot.status == 'OCCUPIED'}">
                                        <button class="steril-btn" onclick="showConfirm('sterilize','${ot.otName}','${pageContext.request.contextPath}/ot?action=sterilize&id=${ot.id}')">🧹 Sterilize</button>
                                    </c:if>
                                </div>
                                <div class="ot-quick-actions">
                                    <button class="act-btn" title="Edit"
                                        onclick="openEditModal('${ot.id}','${ot.otNumber}','${ot.otName}','${ot.otType}','${ot.status}','${ot.equipmentList}','${ot.sterilizationMinutes}')">✏️</button>
                                    <button class="act-btn" title="Delete"
                                        onclick="showConfirm('delete','${ot.otName}','${pageContext.request.contextPath}/ot?action=delete&id=${ot.id}')">🗑️</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="no-results" id="noResults">
                    <div style="font-size:40px;">🔍</div>
                    <div style="font-weight:600;color:#0a1628;">No OTs found</div>
                    <div>Try a different search or filter.</div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Add/Edit Modal -->
<div class="overlay" id="modalOverlay" onclick="closeOnBg(event,'modalOverlay')">
    <div class="modal-box">
        <div class="box-close" onclick="closeOverlay('modalOverlay')">✕</div>
        <div class="box-title" id="modalTitle">➕ Add Operation Theater</div>
        <form method="post" action="${pageContext.request.contextPath}/ot">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="form-row">
                <div class="form-group">
                    <label>OT Number *</label>
                    <div class="auto-id-wrap">
                        <input type="text" name="otNumber" id="fOtNumber" readonly required>
                        <span class="auto-id-badge" id="autoNumBadge">Auto</span>
                    </div>
                </div>
                <div class="form-group">
                    <label>OT Name *</label>
                    <input type="text" name="otName" id="fOtName" placeholder="e.g. Cardiac Suite" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>OT Type *</label>
                    <div class="select-wrap">
                        <select name="otType" id="fOtType" required>
                            <option value="" disabled selected>Select type</option>
                            <option value="GENERAL">🏥 General</option>
                            <option value="CARDIAC">❤️ Cardiac</option>
                            <option value="NEURO">🧠 Neuro</option>
                            <option value="ORTHOPEDIC">🦴 Orthopedic</option>
                            <option value="EMERGENCY">🚨 Emergency</option>
                            <option value="LAPAROSCOPIC">🔬 Laparoscopic</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Sterilization Time (min) *</label>
                    <input type="number" name="sterilizationMinutes" id="fSterilMin" min="5" max="120" value="30" required>
                    <div class="form-hint">How long sterilization takes (default: 30 min)</div>
                </div>
            </div>
            <div class="form-group" id="statusGroup" style="display:none;">
                <label>Status *</label>
                <div class="select-wrap">
                    <select name="status" id="fStatus">
                        <option value="AVAILABLE">✅ Available</option>
                        <option value="OCCUPIED">🔴 Occupied</option>
                        <option value="STERILIZING">🧹 Sterilizing</option>
                        <option value="MAINTENANCE">🔧 Maintenance</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>Equipment List</label>
                <textarea name="equipmentList" id="fEquip" placeholder="e.g. Ventilator, ECG Monitor, Defibrillator..."></textarea>
            </div>
            <button type="submit" class="btn-submit" id="submitBtn">➕ Add OT</button>
        </form>
    </div>
</div>

<!-- Confirm Modal -->
<div class="confirm-overlay" id="confirmOverlay">
    <div class="confirm-box">
        <div class="confirm-icon" id="confirmIcon"></div>
        <div class="confirm-title" id="confirmTitle"></div>
        <div class="confirm-msg"   id="confirmMsg"></div>
        <div class="confirm-btns">
            <button class="confirm-btn secondary" onclick="closeConfirm()">Cancel</button>
            <button class="confirm-btn" id="confirmOkBtn" onclick="doConfirm()"></button>
        </div>
    </div>
</div>

<script>
function updateSterilTimers(){
    var boxes=document.querySelectorAll('[data-steril-start]');
    boxes.forEach(function(box){
        var startMs=parseInt(box.dataset.sterilStart);var totalMin=parseInt(box.dataset.sterilMin);var otId=box.dataset.otId;
        var now=Date.now();var elapsedMs=now-startMs;var totalMs=totalMin*60*1000;var remainingMs=totalMs-elapsedMs;
        var timerEl=document.getElementById('timer-'+otId);var barEl=document.getElementById('steril-bar-'+otId);
        if(remainingMs<=0){if(timerEl)timerEl.textContent='✅ Done!';if(barEl)barEl.style.width='100%';}
        else{var remMin=Math.floor(remainingMs/60000);var remSec=Math.floor((remainingMs%60000)/1000);if(timerEl)timerEl.textContent=remMin+':'+(remSec<10?'0':'')+remSec;var pct=Math.min((elapsedMs/totalMs)*100,100);if(barEl)barEl.style.width=pct+'%';}
    });
}
setInterval(updateSterilTimers,1000);updateSterilTimers();

var currentFilter='all';
function filterOTs(){
    var query=document.getElementById('otSearch').value.toLowerCase().trim();
    var type=document.getElementById('typeFilter').value;
    var cards=document.querySelectorAll('#otGrid .ot-card');var visible=0;
    cards.forEach(function(card){
        var name=(card.dataset.name||'').toLowerCase();var number=(card.dataset.number||'').toLowerCase();
        var cType=(card.dataset.type||'');var status=(card.dataset.status||'').toLowerCase();
        var matchSearch=!query||name.includes(query)||number.includes(query);
        var matchType=!type||cType===type;
        var matchFilter=currentFilter==='all'||(currentFilter==='available'&&status==='available')||(currentFilter==='occupied'&&status==='occupied')||(currentFilter==='sterilizing'&&status==='sterilizing')||(currentFilter==='maintenance'&&status==='maintenance');
        if(matchSearch&&matchType&&matchFilter){card.style.display='';visible++;}else{card.style.display='none';}
    });
    document.getElementById('otCount').textContent='('+visible+' total)';
    var noR=document.getElementById('noResults');var grid=document.getElementById('otGrid');
    if(noR&&grid){grid.style.display=visible===0?'none':'';noR.style.display=visible===0?'flex':'none';}
}

function setFilter(type){
    currentFilter=type;
    ['btnAll','btnAvail','btnOccup','btnSteril','btnMaint'].forEach(function(id){document.getElementById(id).className='filter-btn';});
    if(type==='all')        document.getElementById('btnAll').className   ='filter-btn f-all';
    if(type==='available')  document.getElementById('btnAvail').className ='filter-btn f-available';
    if(type==='occupied')   document.getElementById('btnOccup').className ='filter-btn f-occupied';
    if(type==='sterilizing')document.getElementById('btnSteril').className='filter-btn f-sterilizing';
    if(type==='maintenance')document.getElementById('btnMaint').className ='filter-btn f-maintenance';
    filterOTs();
}

function openAddModal(){
    document.getElementById('modalTitle').textContent='➕ Add Operation Theater';
    document.getElementById('formAction').value='add';document.getElementById('formId').value='';
    var nextNum=document.getElementById('nextOTNumber');
    document.getElementById('fOtNumber').value=nextNum?nextNum.textContent.trim():'OT-01';
    document.getElementById('fOtNumber').readOnly=true;document.getElementById('autoNumBadge').style.display='';
    document.getElementById('fOtName').value='';document.getElementById('fOtType').value='';
    document.getElementById('fSterilMin').value='30';document.getElementById('fEquip').value='';
    document.getElementById('statusGroup').style.display='none';document.getElementById('submitBtn').textContent='➕ Add OT';
    document.getElementById('modalOverlay').classList.add('open');
}

function openEditModal(id,otNumber,otName,otType,status,equip,sterilMin){
    document.getElementById('modalTitle').textContent='✏️ Edit Operation Theater';
    document.getElementById('formAction').value='edit';document.getElementById('formId').value=id;
    document.getElementById('fOtNumber').value=otNumber;document.getElementById('fOtNumber').readOnly=true;
    document.getElementById('autoNumBadge').style.display='none';
    document.getElementById('fOtName').value=otName;document.getElementById('fOtType').value=otType;
    document.getElementById('fStatus').value=status;document.getElementById('fSterilMin').value=sterilMin||'30';
    document.getElementById('fEquip').value=equip||'';
    document.getElementById('statusGroup').style.display='block';document.getElementById('submitBtn').textContent='✅ Save Changes';
    document.getElementById('modalOverlay').classList.add('open');
}

function closeOverlay(id){document.getElementById(id).classList.remove('open');}
function closeOnBg(e,id){if(e.target===document.getElementById(id))closeOverlay(id);}

var _confirmUrl='';
function showConfirm(type,otName,url){
    _confirmUrl=url;
    var icon=document.getElementById('confirmIcon');var title=document.getElementById('confirmTitle');
    var msg=document.getElementById('confirmMsg');var okBtn=document.getElementById('confirmOkBtn');
    icon.className='confirm-icon '+type;
    if(type==='toggle'){icon.textContent='🔄';title.textContent='Change OT Status?';msg.innerHTML='Change the status of <strong>'+otName+'</strong>?<br>This will update the OT availability.';okBtn.textContent='🔄 Yes, Change Status';okBtn.className='confirm-btn btn-toggle';}
    else if(type==='sterilize'){icon.textContent='🧹';title.textContent='Start Sterilization?';msg.innerHTML='Start sterilization for <strong>'+otName+'</strong>?<br>The OT will be marked as Sterilizing.';okBtn.textContent='🧹 Yes, Start Sterilization';okBtn.className='confirm-btn btn-sterilize';}
    else if(type==='done'){icon.textContent='✅';title.textContent='Mark Sterilization Complete?';msg.innerHTML='Mark sterilization as complete for <strong>'+otName+'</strong>?<br>The OT will become Available.';okBtn.textContent='✅ Yes, Mark as Done';okBtn.className='confirm-btn btn-done';}
    else if(type==='delete'){icon.textContent='🗑️';title.textContent='Delete OT?';msg.innerHTML='Are you sure you want to delete <strong>'+otName+'</strong>?<br>This action cannot be undone.';okBtn.textContent='🗑️ Yes, Delete';okBtn.className='confirm-btn btn-delete';}
    document.getElementById('confirmOverlay').classList.add('open');document.body.style.overflow='hidden';
}
function closeConfirm(){document.getElementById('confirmOverlay').classList.remove('open');document.body.style.overflow='';_confirmUrl='';}
function doConfirm(){if(_confirmUrl)window.location.href=_confirmUrl;}
document.getElementById('confirmOverlay').addEventListener('click',function(e){if(e.target===this)closeConfirm();});
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeOverlay('modalOverlay');closeConfirm();}});

<c:if test="${not empty editOT}">
window.onload=function(){openEditModal('${editOT.id}','${editOT.otNumber}','${editOT.otName}','${editOT.otType}','${editOT.status}','${editOT.equipmentList}','${editOT.sterilizationMinutes}');};
</c:if>
</script>
</body>
</html>