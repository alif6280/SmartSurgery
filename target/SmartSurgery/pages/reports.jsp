<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"      prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"       prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Reports — Smart Surgery System</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
:root {
  --sidebar-bg:#1a2e1a; --accent:#2d6a4f; --accent-light:#40916c;
  --accent-bright:#52b788; --bg:#f0f4f0; --card:#fff;
  --text:#1b2d1b; --muted:#6b8c6b; --border:#d4e6d4;
  --critical:#dc2626; --high:#ea580c; --medium:#d97706; --low:#16a34a;
}
body { font-family:'Segoe UI',system-ui,sans-serif; display:flex; min-height:100vh; background:var(--bg); font-size:13px; }

/* SIDEBAR */
.sidebar { width:240px; min-height:100vh; background:var(--sidebar-bg); display:flex; flex-direction:column; position:fixed; left:0; top:0; z-index:100; }
.sidebar-logo { padding:20px 16px 16px; border-bottom:1px solid rgba(255,255,255,0.08); }
.logo-icon { width:44px; height:44px; background:var(--accent-bright); border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:20px; margin-bottom:10px; }
.sidebar-logo h2 { color:#fff; font-size:13px; font-weight:700; line-height:1.3; }
.sidebar-logo p { color:rgba(255,255,255,0.45); font-size:11px; margin-top:2px; }
.sidebar-section { padding:16px 12px 4px; color:rgba(255,255,255,0.3); font-size:10px; font-weight:600; letter-spacing:1px; text-transform:uppercase; }
.nav-item { display:flex; align-items:center; gap:10px; padding:10px 16px; color:rgba(255,255,255,0.6); text-decoration:none; font-size:13px; border-radius:8px; transition:all 0.2s; margin:1px 8px; }
.nav-item:hover { background:rgba(255,255,255,0.06); color:#fff; }
.nav-item.active { background:var(--accent); color:#fff; font-weight:500; }
.nav-item svg { width:16px; height:16px; flex-shrink:0; }
.sidebar-bottom { margin-top:auto; border-top:1px solid rgba(255,255,255,0.08); padding:12px; }
.user-card { display:flex; align-items:center; gap:10px; padding:8px; border-radius:8px; }
.user-avatar { width:32px; height:32px; background:var(--accent-bright); border-radius:8px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:12px; font-weight:700; }
.user-info p { color:#fff; font-size:12px; font-weight:500; }
.user-info span { color:rgba(255,255,255,0.4); font-size:10px; }

/* MAIN */
.main { margin-left:240px; flex:1; }
.page-header { background:#fff; border-bottom:1px solid var(--border); padding:20px 28px; display:flex; align-items:center; justify-content:space-between; }
.page-header h1 { font-size:20px; font-weight:700; color:var(--text); }
.page-header p { color:var(--muted); font-size:13px; margin-top:3px; }
.header-actions { display:flex; gap:10px; }
.btn { padding:8px 16px; border-radius:8px; font-size:13px; font-weight:500; cursor:pointer; border:none; transition:all 0.2s; text-decoration:none; display:inline-flex; align-items:center; gap:6px; }
.btn-primary { background:var(--accent-bright); color:#fff; }
.btn-primary:hover { background:var(--accent-light); }
.btn-outline { background:#fff; color:var(--text); border:1px solid var(--border); }
.btn-outline:hover { background:var(--bg); }
.content { padding:24px 28px; }

/* TABS */
.tabs { display:flex; gap:8px; margin-bottom:24px; flex-wrap:wrap; }
.tab { padding:8px 18px; border-radius:8px; font-size:13px; font-weight:500; cursor:pointer; border:1.5px solid var(--border); background:#fff; color:var(--muted); transition:all 0.2s; }
.tab.active { background:var(--accent); color:#fff; border-color:var(--accent); }
.tab:hover:not(.active) { border-color:var(--accent-bright); color:var(--accent); }

/* FILTER */
.filter-bar { background:#fff; border:1px solid var(--border); border-radius:12px; padding:14px 20px; display:flex; align-items:center; gap:14px; margin-bottom:24px; flex-wrap:wrap; }
.filter-bar label { font-size:11px; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px; }
.filter-bar select { padding:7px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px; color:var(--text); outline:none; background:var(--bg); }
.filter-sep { width:1px; height:28px; background:var(--border); }

/* SUMMARY GRID */
.sum-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:24px; }
.sum-card { background:#fff; border:1px solid var(--border); border-radius:12px; padding:18px 20px; }
.sum-card .s-icon { font-size:24px; margin-bottom:10px; }
.sum-card .s-val  { font-size:28px; font-weight:700; color:var(--text); }
.sum-card .s-lbl  { font-size:12px; color:var(--muted); margin-top:3px; }
.sum-card .s-ch   { font-size:11px; font-weight:600; margin-top:8px; }
.sum-card .s-bar  { height:4px; border-radius:99px; margin-top:12px; background:var(--border); overflow:hidden; }
.sum-card .s-bf   { height:100%; border-radius:99px; }

/* GRIDS */
.grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px; }
.grid-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px; margin-bottom:20px; }

/* CARD */
.card { background:var(--card); border-radius:12px; border:1px solid var(--border); overflow:hidden; }
.card-header { padding:16px 20px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; }
.card-header h3 { font-size:14px; font-weight:600; color:var(--text); }
.card-header span { font-size:11px; color:var(--muted); }
.card-body { padding:20px; }

/* TABLE */
.rep-table { width:100%; border-collapse:collapse; }
.rep-table th { padding:9px 14px; font-size:11px; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid var(--border); background:var(--bg); text-align:left; }
.rep-table td { padding:11px 14px; font-size:12px; color:var(--text); border-bottom:1px solid #f5f5f5; vertical-align:middle; }
.rep-table tr:last-child td { border-bottom:none; }
.rep-table tr:hover td { background:#f7fbf7; }

/* BADGES */
.badge { display:inline-block; padding:3px 9px; border-radius:6px; font-size:11px; font-weight:600; }
.b-critical { background:#fee2e2; color:#991b1b; }
.b-high     { background:#ffedd5; color:#9a3412; }
.b-medium   { background:#fef9c3; color:#854d0e; }
.b-low      { background:#dcfce7; color:#166534; }
.b-success  { background:#dcfce7; color:#166534; }
.b-pending  { background:#fef9c3; color:#854d0e; }
.b-info     { background:#dbeafe; color:#1e40af; }
.asa-badge  { display:inline-block; padding:2px 8px; border-radius:6px; font-size:11px; font-weight:600; }
.asa-1 { background:#dcfce7; color:#166534; }
.asa-2 { background:#fef9c3; color:#854d0e; }
.asa-3 { background:#ffedd5; color:#9a3412; }
.asa-4 { background:#fee2e2; color:#991b1b; }

/* AVATAR */
.avatar-sm { width:28px; height:28px; border-radius:6px; background:var(--accent-bright); color:#fff; display:inline-flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; margin-right:6px; }
.avatar-f  { background:#d946ef; }
.tag { display:inline-block; padding:2px 6px; border-radius:4px; font-size:10px; font-weight:600; background:#e8f4e8; color:var(--accent); margin:1px; }

/* BAR ROWS */
.bar-row { display:flex; align-items:center; gap:10px; margin-bottom:12px; }
.bar-row:last-child { margin-bottom:0; }
.bar-row-lbl { font-size:12px; color:var(--text); width:160px; flex-shrink:0; }
.bar-track { flex:1; height:10px; background:var(--bg); border-radius:99px; overflow:hidden; }
.bar-fill  { height:100%; border-radius:99px; }
.bar-val   { font-size:12px; font-weight:600; color:var(--text); width:48px; text-align:right; flex-shrink:0; }

/* DONUT */
.donut-wrap { display:flex; align-items:center; gap:20px; }
.dl-item { display:flex; align-items:center; gap:8px; margin-bottom:8px; font-size:12px; }
.dl-item:last-child { margin-bottom:0; }
.dl-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.dl-item span:last-child { margin-left:auto; font-weight:600; }

/* OT BARS */
.ot-row { display:flex; align-items:center; gap:12px; padding:10px 0; border-bottom:1px solid #f5f5f5; }
.ot-row:last-child { border-bottom:none; }
.ot-name  { font-size:12px; font-weight:600; color:var(--text); width:70px; }
.ot-track { flex:1; height:18px; background:var(--bg); border-radius:6px; overflow:hidden; }
.ot-fill  { height:100%; border-radius:6px; display:flex; align-items:center; padding-left:8px; font-size:10px; font-weight:700; color:#fff; }
.ot-pct   { font-size:12px; font-weight:600; color:var(--text); width:36px; text-align:right; }

/* SAVED */
.rep-item { display:flex; align-items:center; gap:14px; padding:12px 0; border-bottom:1px solid #f5f5f5; }
.rep-item:last-child { border-bottom:none; }
.rep-icon { width:38px; height:38px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0; }
.rep-info h4 { font-size:13px; font-weight:600; color:var(--text); }
.rep-info p  { font-size:11px; color:var(--muted); margin-top:2px; }
.rep-actions { display:flex; gap:6px; }
.btn-sm   { padding:5px 12px; border-radius:6px; font-size:11px; font-weight:600; cursor:pointer; border:none; text-decoration:none; display:inline-flex; align-items:center; }
.btn-sm-p { background:var(--accent); color:#fff; }
.btn-sm-p:hover { background:var(--accent-bright); }
.btn-sm-o { background:#fff; border:1px solid var(--border); color:var(--text); }

/* PRINT BANNER */
.print-banner { background:linear-gradient(135deg,#f0fdf4,#e8f5e9); border:1px solid #a7d7a7; border-radius:12px; padding:20px; display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
.print-banner h3 { font-size:15px; font-weight:600; color:var(--text); }
.print-banner p  { font-size:12px; color:var(--muted); margin-top:3px; }

.alert { padding:10px 14px; border-radius:8px; font-size:11px; margin-top:12px; }
.alert-warn { background:#fff7ed; border:1px solid #fed7aa; color:#9a3412; }
.alert-info { background:#eff6ff; border:1px solid #bfdbfe; color:#1e40af; }

.preop-dot { display:inline-block; width:8px; height:8px; border-radius:50%; margin:1px; }

@media print { .sidebar,.header-actions,.tabs,.filter-bar,.print-banner { display:none; } .main { margin-left:0; } }
</style>
</head>
<body>

<!-- SIDEBAR -->
<nav class="sidebar">
  <div class="sidebar-logo">
    <div class="logo-icon">🏥</div>
    <h2>SMART SURGERY<br>SCHEDULING</h2>
    <p>Risk Analysis System</p>
  </div>
  <div class="sidebar-section">Resources</div>
  <a class="nav-item" href="${pageContext.request.contextPath}/surgeons">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
    Surgeons
  </a>
  <a class="nav-item" href="${pageContext.request.contextPath}/ot">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    Operation Theaters
  </a>
  <div class="sidebar-section">Tools</div>
  <a class="nav-item" href="${pageContext.request.contextPath}/patients">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
    Patients
  </a>
  <a class="nav-item" href="${pageContext.request.contextPath}/risk-analysis">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
    Risk Analysis
  </a>
  <a class="nav-item active" href="${pageContext.request.contextPath}/reports">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
    Reports
  </a>
  <div class="sidebar-section">Account</div>
  <a class="nav-item" href="${pageContext.request.contextPath}/settings">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93A10 10 0 1 0 4.93 19.07 10 10 0 0 0 19.07 4.93z"/></svg>
    Settings
  </a>
  <a class="nav-item" href="${pageContext.request.contextPath}/logout">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
    Logout
  </a>
  <div class="sidebar-bottom">
    <div class="user-card">
      <div class="user-avatar">
        <c:choose>
          <c:when test="${not empty sessionScope.user.fullName}">${fn:substring(sessionScope.user.fullName,0,2)}</c:when>
          <c:otherwise>SA</c:otherwise>
        </c:choose>
      </div>
      <div class="user-info">
        <p>${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'System Administrator'}</p>
        <span>${not empty sessionScope.user.role ? sessionScope.user.role : 'ADMIN'}</span>
      </div>
    </div>
  </div>
</nav>

<!-- MAIN -->
<main class="main">
  <div class="page-header">
    <div>
      <h1>📋 Reports</h1>
      <p>Surgery summaries, patient risk reports &amp; operational insights</p>
    </div>
    <div class="header-actions">
      <button class="btn btn-outline" onclick="window.print()">🖨️ Print</button>
      <a href="${pageContext.request.contextPath}/reports?export=pdf" class="btn btn-primary">📥 Export PDF</a>
    </div>
  </div>

  <div class="content">

    <!-- TABS -->
    <div class="tabs">
      <div class="tab active" onclick="showTab('overview',this)">📊 Overview</div>
      <div class="tab"        onclick="showTab('patient',this)">🧑‍⚕️ Patient Report</div>
      <div class="tab"        onclick="showTab('surgeon',this)">👨‍⚕️ Surgeon Report</div>
      <div class="tab"        onclick="showTab('ot',this)">🏥 OT Utilization</div>
      <div class="tab"        onclick="showTab('saved',this)">📁 Saved Reports</div>
    </div>

    <!-- FILTER -->
    <div class="filter-bar">
      <label>Period</label>
      <select><option>This Month</option><option>Last Month</option><option>Last 3 Months</option><option>This Year</option></select>
      <div class="filter-sep"></div>
      <label>Risk Level</label>
      <select><option>All Risk Levels</option><option>Critical</option><option>High</option><option>Medium</option><option>Low</option></select>
      <div class="filter-sep"></div>
      <label>Status</label>
      <select><option>All Statuses</option><option>Scheduled</option><option>Completed</option><option>Pending</option></select>
    </div>

    <!-- ===== OVERVIEW ===== -->
    <div id="tab-overview">

      <div class="print-banner">
        <div>
          <h3>📄 Full System Report</h3>
          <p>Generated: <fmt:formatDate value="<%=new java.util.Date()%>" pattern="dd MMM yyyy, hh:mm a"/> · ${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'System Administrator'}</p>
        </div>
        <div class="header-actions">
          <a href="${pageContext.request.contextPath}/reports?export=excel" class="btn btn-outline">📊 Excel</a>
          <a href="${pageContext.request.contextPath}/reports?export=pdf"   class="btn btn-primary">📄 PDF</a>
        </div>
      </div>

      <!-- Summary Cards -->
      <div class="sum-grid">
        <div class="sum-card">
          <div class="s-icon">👥</div>
          <div class="s-val">${totalPatients}</div>
          <div class="s-lbl">Total Patients</div>
          <div class="s-ch" style="color:var(--low)">All registered</div>
          <div class="s-bar"><div class="s-bf" style="width:100%;background:var(--accent-bright)"></div></div>
        </div>
        <div class="sum-card">
          <div class="s-icon">⚠️</div>
          <div class="s-val">${mediumCount}</div>
          <div class="s-lbl">Medium Risk Patients</div>
          <div class="s-ch" style="color:var(--medium)">Monitoring required</div>
          <div class="s-bar"><div class="s-bf" style="width:${totalPatients>0?(mediumCount*100/totalPatients):0}%;background:var(--medium)"></div></div>
        </div>
        <div class="sum-card">
          <div class="s-icon">✅</div>
          <div class="s-val">${completedCount}</div>
          <div class="s-lbl">Completed Surgeries</div>
          <div class="s-ch" style="color:var(--low)">Successfully done</div>
          <div class="s-bar"><div class="s-bf" style="width:70%;background:var(--low)"></div></div>
        </div>
        <div class="sum-card">
          <div class="s-icon">🏥</div>
          <div class="s-val">${scheduledCount}</div>
          <div class="s-lbl">Scheduled Surgeries</div>
          <div class="s-ch" style="color:var(--muted)">Upcoming</div>
          <div class="s-bar"><div class="s-bf" style="width:30%;background:var(--accent)"></div></div>
        </div>
      </div>

      <!-- Risk Distribution + Comorbidity -->
      <div class="grid-2">
        <div class="card">
          <div class="card-header"><h3>Risk Level Distribution</h3><span>${totalPatients} patients</span></div>
          <div class="card-body">
            <div class="donut-wrap">
              <c:set var="tp" value="${totalPatients < 1 ? 1 : totalPatients}"/>
              <svg width="120" height="120" viewBox="0 0 120 120">
                <c:set var="circ" value="289.1"/>
                <circle cx="60" cy="60" r="46" fill="none" stroke="#dcfce7" stroke-width="20"
                  stroke-dasharray="${(lowCount*circ)/tp} ${circ-(lowCount*circ)/tp}"
                  stroke-dashoffset="0" transform="rotate(-90 60 60)"/>
                <circle cx="60" cy="60" r="46" fill="none" stroke="#fef9c3" stroke-width="20"
                  stroke-dasharray="${(mediumCount*circ)/tp} ${circ-(mediumCount*circ)/tp}"
                  stroke-dashoffset="-${(lowCount*circ)/tp}" transform="rotate(-90 60 60)"/>
                <circle cx="60" cy="60" r="46" fill="none" stroke="#ffedd5" stroke-width="20"
                  stroke-dasharray="${(highCount*circ)/tp} ${circ-(highCount*circ)/tp}"
                  stroke-dashoffset="-${((lowCount+mediumCount)*circ)/tp}" transform="rotate(-90 60 60)"/>
                <circle cx="60" cy="60" r="46" fill="none" stroke="#fee2e2" stroke-width="20"
                  stroke-dasharray="${(criticalCount*circ)/tp} ${circ-(criticalCount*circ)/tp}"
                  stroke-dashoffset="-${((lowCount+mediumCount+highCount)*circ)/tp}" transform="rotate(-90 60 60)"/>
                <text x="60" y="56" text-anchor="middle" font-size="16" font-weight="700" fill="#1b2d1b">${totalPatients}</text>
                <text x="60" y="70" text-anchor="middle" font-size="9"  fill="#6b8c6b">patients</text>
              </svg>
              <div>
                <div class="dl-item"><div class="dl-dot" style="background:#dc2626"></div>Critical<span>${criticalCount}</span></div>
                <div class="dl-item"><div class="dl-dot" style="background:#ea580c"></div>High<span>${highCount}</span></div>
                <div class="dl-item"><div class="dl-dot" style="background:#d97706"></div>Medium<span>${mediumCount}</span></div>
                <div class="dl-item"><div class="dl-dot" style="background:#16a34a"></div>Low<span>${lowCount}</span></div>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><h3>Comorbidity Frequency</h3><span>Across all patients</span></div>
          <div class="card-body">
            <c:forEach var="entry" items="${comorbidityCount}">
              <c:set var="pct" value="${totalPatients>0?(entry.value*100/totalPatients):0}"/>
              <div class="bar-row">
                <div class="bar-row-lbl">${entry.key}</div>
                <div class="bar-track">
                  <div class="bar-fill" style="width:${pct}%;background:${pct>=75?'#dc2626':pct>=50?'#ea580c':'#d97706'}"></div>
                </div>
                <div class="bar-val">${entry.value} pt${entry.value!=1?'s':''}</div>
              </div>
            </c:forEach>
            <c:if test="${empty comorbidityCount}">
              <p style="text-align:center;color:var(--muted);padding:20px 0;font-size:12px">No comorbidity data</p>
            </c:if>
          </div>
        </div>
      </div>

      <!-- Blood Group + Pre-op + Surgery Stats -->
      <div class="grid-3">
        <div class="card">
          <div class="card-header"><h3>Blood Group Report</h3><span>Blood bank prep</span></div>
          <div class="card-body">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
              <c:forEach var="entry" items="${bloodGroupCount}">
                <div style="background:#f0fdf4;border-radius:8px;padding:12px;text-align:center">
                  <div style="font-size:20px;font-weight:700;color:var(--accent)">${entry.key}</div>
                  <div style="font-size:11px;color:var(--muted);margin-top:2px">${entry.value} pt${entry.value!=1?'s':''}</div>
                </div>
              </c:forEach>
              <c:if test="${empty bloodGroupCount}">
                <div style="grid-column:1/-1;text-align:center;color:var(--muted);font-size:12px;padding:20px">No data</div>
              </c:if>
            </div>
            <div class="alert alert-info">💉 Ensure all blood types are stocked before scheduling.</div>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><h3>Pre-op Completion</h3><span>Per patient</span></div>
          <div class="card-body">
            <table class="rep-table">
              <thead><tr><th>Patient</th><th>Steps</th><th>Status</th></tr></thead>
              <tbody>
                <c:forEach var="p" items="${patients}">
                  <c:set var="steps" value="0"/>
                  <c:if test="${p.labsDone}">        <c:set var="steps" value="${steps+1}"/></c:if>
                  <c:if test="${p.ecgDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
                  <c:if test="${p.consentSigned}">   <c:set var="steps" value="${steps+1}"/></c:if>
                  <c:if test="${p.anaesthesiaDone}"> <c:set var="steps" value="${steps+1}"/></c:if>
                  <c:if test="${p.npoDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
                  <tr>
                    <td>${fn:substring(p.fullName,0,14)}</td>
                    <td>${steps}/5</td>
                    <td><span class="badge ${steps>=5?'b-success':'b-pending'}">${steps>=5?'Done':'Pending'}</span></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty patients}">
                  <tr><td colspan="3" style="text-align:center;color:var(--muted)">No data</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><h3>Surgery Statistics</h3><span>All time</span></div>
          <div class="card-body">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px">
              <div style="background:#f0fdf4;border-radius:8px;padding:12px;text-align:center">
                <div style="font-size:24px;font-weight:700;color:var(--low)">${completedCount}</div>
                <div style="font-size:11px;color:var(--muted)">Completed</div>
              </div>
              <div style="background:#dbeafe;border-radius:8px;padding:12px;text-align:center">
                <div style="font-size:24px;font-weight:700;color:#1e40af">${scheduledCount}</div>
                <div style="font-size:11px;color:var(--muted)">Scheduled</div>
              </div>
            </div>
            <c:if test="${criticalCount > 0}">
              <div class="alert alert-warn">🚨 ${criticalCount} critical risk patient(s) need urgent attention.</div>
            </c:if>
            <c:if test="${criticalCount == 0}">
              <div class="alert" style="background:#f0fdf4;border:1px solid #a7d7a7;color:#166534">✅ No critical risk patients currently.</div>
            </c:if>
          </div>
        </div>
      </div>

      <!-- Full Patient Table -->
      <div class="card">
        <div class="card-header"><h3>Full Patient Risk Report</h3><span>${totalPatients} patients</span></div>
        <div style="overflow-x:auto">
          <table class="rep-table">
            <thead>
              <tr><th>Patient</th><th>ID</th><th>Age/Sex</th><th>Blood</th><th>ASA</th><th>Risk</th><th>Level</th><th>Conditions</th><th>Pre-op</th><th>Surgery</th></tr>
            </thead>
            <tbody>
              <c:forEach var="p" items="${patients}">
                <c:set var="r" value="${p.riskScore}"/>
                <c:set var="steps" value="0"/>
                <c:if test="${p.labsDone}">        <c:set var="steps" value="${steps+1}"/></c:if>
                <c:if test="${p.ecgDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
                <c:if test="${p.consentSigned}">   <c:set var="steps" value="${steps+1}"/></c:if>
                <c:if test="${p.anaesthesiaDone}"> <c:set var="steps" value="${steps+1}"/></c:if>
                <c:if test="${p.npoDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
                <tr>
                  <td>
                    <span class="avatar-sm ${'FEMALE'==p.gender?'avatar-f':''}">${fn:substring(p.fullName,0,1)}</span>
                    ${p.fullName}
                  </td>
                  <td style="font-family:monospace;color:var(--muted)">${p.patientId}</td>
                  <td>${p.age} · ${fn:substring(p.gender,0,1)}</td>
                  <td><b>${p.bloodGroup}</b></td>
                  <td><span class="asa-badge asa-${p.asaGrade}">G${p.asaGrade}</span></td>
                  <td><b style="color:${r>75?'#dc2626':r>50?'#ea580c':r>25?'#d97706':'#16a34a'}"><fmt:formatNumber value="${r}" maxFractionDigits="1"/></b></td>
                  <td><span class="badge ${r>75?'b-critical':r>50?'b-high':r>25?'b-medium':'b-low'}">${r>75?'CRITICAL':r>50?'HIGH':r>25?'MEDIUM':'LOW'}</span></td>
                  <td>
                    <c:if test="${p.hasDiabetes}">     <span class="tag">DM</span></c:if>
                    <c:if test="${p.hasHypertension}">  <span class="tag">HTN</span></c:if>
                    <c:if test="${p.hasHeartDisease}">  <span class="tag">CVD</span></c:if>
                    <c:if test="${p.hasKidneyDisease}"> <span class="tag">CKD</span></c:if>
                    <c:if test="${p.smoker}">            <span class="tag">SMK</span></c:if>
                  </td>
                  <td>
                    <span class="preop-dot" style="background:${p.labsDone?'#16a34a':'#d1d5db'}"></span>
                    <span class="preop-dot" style="background:${p.ecgDone?'#16a34a':'#d1d5db'}"></span>
                    <span class="preop-dot" style="background:${p.consentSigned?'#16a34a':'#d1d5db'}"></span>
                    <span class="preop-dot" style="background:${p.anaesthesiaDone?'#16a34a':'#d1d5db'}"></span>
                    <span class="preop-dot" style="background:${p.npoDone?'#16a34a':'#d1d5db'}"></span>
                    <span style="font-size:10px;color:var(--muted);margin-left:4px">${steps}/5</span>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty p.lastSurgeryStatus}">
                        <span class="badge ${'COMPLETED'==p.lastSurgeryStatus?'b-success':'SCHEDULED'==p.lastSurgeryStatus?'b-info':'b-pending'}">${p.lastSurgeryStatus}</span>
                      </c:when>
                      <c:otherwise><span style="color:var(--muted);font-size:11px">—</span></c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty patients}">
                <tr><td colspan="10" style="text-align:center;padding:30px;color:var(--muted)">No patients found</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>
    </div><!-- /overview -->

    <!-- ===== PATIENT TAB ===== -->
    <div id="tab-patient" style="display:none">
      <div class="card">
        <div class="card-header"><h3>🧑‍⚕️ Individual Patient Reports</h3><span>Click to expand</span></div>
        <div class="card-body">
          <c:forEach var="p" items="${patients}" varStatus="st">
            <c:set var="r" value="${p.riskScore}"/>
            <c:set var="rColor" value="${r>75?'#dc2626':r>50?'#ea580c':r>25?'#d97706':'#16a34a'}"/>
            <c:set var="steps" value="0"/>
            <c:if test="${p.labsDone}">        <c:set var="steps" value="${steps+1}"/></c:if>
            <c:if test="${p.ecgDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
            <c:if test="${p.consentSigned}">   <c:set var="steps" value="${steps+1}"/></c:if>
            <c:if test="${p.anaesthesiaDone}"> <c:set var="steps" value="${steps+1}"/></c:if>
            <c:if test="${p.npoDone}">         <c:set var="steps" value="${steps+1}"/></c:if>
            <div style="border:1px solid var(--border);border-radius:10px;margin-bottom:12px;overflow:hidden">
              <div style="display:flex;align-items:center;gap:14px;padding:14px 18px;cursor:pointer;background:var(--bg)"
                   onclick="togglePt('pt${st.index}','ar${st.index}')">
                <div style="width:36px;height:36px;border-radius:8px;background:${'FEMALE'==p.gender?'#d946ef':'var(--accent-bright)'};color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:13px">
                  ${fn:substring(p.fullName,0,1)}
                </div>
                <div style="flex:1">
                  <div style="font-weight:600;font-size:13px;color:var(--text)">${p.fullName}</div>
                  <div style="font-size:11px;color:var(--muted)">${p.patientId} · ${p.age} yrs · ${p.gender} · ${p.bloodGroup}</div>
                </div>
                <span class="badge ${r>75?'b-critical':r>50?'b-high':r>25?'b-medium':'b-low'}">${r>75?'CRITICAL':r>50?'HIGH':r>25?'MEDIUM':'LOW'}</span>
                <span style="font-size:20px;font-weight:700;color:${rColor}"><fmt:formatNumber value="${r}" maxFractionDigits="1"/></span>
                <span id="ar${st.index}" style="font-size:16px;color:var(--muted)">▼</span>
              </div>
              <div id="pt${st.index}" style="display:none;padding:16px 18px;border-top:1px solid var(--border)">
                <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:14px">
                  <div style="background:var(--bg);border-radius:8px;padding:10px;text-align:center">
                    <div style="font-size:10px;color:var(--muted);text-transform:uppercase;font-weight:600">ASA</div>
                    <div style="font-size:14px;font-weight:700;color:var(--text);margin-top:4px">Grade ${p.asaGrade}</div>
                  </div>
                  <div style="background:var(--bg);border-radius:8px;padding:10px;text-align:center">
                    <div style="font-size:10px;color:var(--muted);text-transform:uppercase;font-weight:600">Risk Score</div>
                    <div style="font-size:14px;font-weight:700;color:${rColor};margin-top:4px"><fmt:formatNumber value="${r}" maxFractionDigits="1"/>/100</div>
                  </div>
                  <div style="background:var(--bg);border-radius:8px;padding:10px;text-align:center">
                    <div style="font-size:10px;color:var(--muted);text-transform:uppercase;font-weight:600">Pre-op</div>
                    <div style="font-size:14px;font-weight:700;color:var(--text);margin-top:4px">${steps}/5 done</div>
                  </div>
                  <div style="background:var(--bg);border-radius:8px;padding:10px;text-align:center">
                    <div style="font-size:10px;color:var(--muted);text-transform:uppercase;font-weight:600">BMI</div>
                    <div style="font-size:14px;font-weight:700;color:var(--text);margin-top:4px"><fmt:formatNumber value="${p.bmi}" maxFractionDigits="1"/></div>
                  </div>
                </div>
                <div style="margin-bottom:10px">
                  <span style="font-size:11px;font-weight:600;color:var(--accent);text-transform:uppercase">Conditions: </span>
                  <c:if test="${p.hasDiabetes}">     <span class="tag">Diabetes</span></c:if>
                  <c:if test="${p.hasHypertension}">  <span class="tag">Hypertension</span></c:if>
                  <c:if test="${p.hasHeartDisease}">  <span class="tag">Heart Disease</span></c:if>
                  <c:if test="${p.hasKidneyDisease}"> <span class="tag">Kidney Disease</span></c:if>
                  <c:if test="${p.smoker}">            <span class="tag">Smoker</span></c:if>
                  <c:if test="${!p.hasDiabetes && !p.hasHypertension && !p.hasHeartDisease && !p.hasKidneyDisease && !p.smoker}">
                    <span style="font-size:12px;color:var(--muted)">None</span>
                  </c:if>
                </div>
                <div style="margin-bottom:6px">
                  <span style="font-size:11px;font-weight:600;color:var(--accent);text-transform:uppercase">Pre-op Checklist: </span>
                  <span style="font-size:11px;color:${p.labsDone?'var(--low)':'var(--muted)'}">Labs ${p.labsDone?'✓':'✗'}</span> ·
                  <span style="font-size:11px;color:${p.ecgDone?'var(--low)':'var(--muted)'}">ECG ${p.ecgDone?'✓':'✗'}</span> ·
                  <span style="font-size:11px;color:${p.consentSigned?'var(--low)':'var(--muted)'}">Consent ${p.consentSigned?'✓':'✗'}</span> ·
                  <span style="font-size:11px;color:${p.anaesthesiaDone?'var(--low)':'var(--muted)'}">Anaesthesia ${p.anaesthesiaDone?'✓':'✗'}</span> ·
                  <span style="font-size:11px;color:${p.npoDone?'var(--low)':'var(--muted)'}">NPO ${p.npoDone?'✓':'✗'}</span>
                </div>
                <div style="height:8px;background:var(--border);border-radius:99px;overflow:hidden;margin-top:12px">
                  <div style="height:100%;width:${r}%;background:${rColor};border-radius:99px"></div>
                </div>
                <div style="display:flex;justify-content:space-between;font-size:10px;color:var(--muted);margin-top:4px">
                  <span>0</span><span>25</span><span>50</span><span>75</span><span>100</span>
                </div>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty patients}">
            <p style="text-align:center;color:var(--muted);padding:30px;font-size:13px">No patients found</p>
          </c:if>
        </div>
      </div>
    </div><!-- /patient -->

    <!-- ===== SURGEON TAB ===== -->
    <div id="tab-surgeon" style="display:none">
      <div class="grid-2">
        <div class="card">
          <div class="card-header"><h3>👨‍⚕️ Surgeon List</h3><span>${totalSurgeons} surgeons</span></div>
          <div style="overflow-x:auto">
            <table class="rep-table">
              <thead><tr><th>Name</th><th>Specialty</th><th>Status</th></tr></thead>
              <tbody>
                <c:forEach var="s" items="${surgeons}">
                  <tr>
                    <td><span class="avatar-sm">${fn:substring(s.name,0,1)}</span>${s.name}</td>
                    <td>${s.specialty}</td>
                    <td><span class="badge ${s.available?'b-success':'b-medium'}">${s.available?'Available':'Busy'}</span></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty surgeons}">
                  <tr><td colspan="3" style="text-align:center;color:var(--muted);padding:20px">No surgeons found</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card">
          <div class="card-header"><h3>Surgery Records</h3><span>All surgeries</span></div>
          <div style="overflow-x:auto">
            <table class="rep-table">
              <thead><tr><th>Type</th><th>Date</th><th>Status</th></tr></thead>
              <tbody>
                <c:forEach var="s" items="${surgeries}">
                  <tr>
                    <td>${s.surgeryType != null ? s.surgeryType : 'N/A'}</td>
                    <td><fmt:formatDate value="${s.scheduledDate}" pattern="dd MMM yyyy"/></td>
                    <td><span class="badge ${'COMPLETED'==s.status?'b-success':'SCHEDULED'==s.status?'b-info':'b-pending'}">${s.status}</span></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty surgeries}">
                  <tr><td colspan="3" style="text-align:center;color:var(--muted);padding:20px">No surgeries found</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div><!-- /surgeon -->

    <!-- ===== OT TAB ===== -->
    <div id="tab-ot" style="display:none">
      <div class="grid-2">
        <div class="card">
          <div class="card-header"><h3>🏥 OT Status</h3><span>All theaters</span></div>
          <div class="card-body">
            <c:forEach var="ot" items="${ots}">
              <div class="ot-row">
                <div class="ot-name">${ot.name != null ? ot.name : ot.otId}</div>
                <div class="ot-track">
                  <div class="ot-fill" style="width:${ot.utilizationRate != null ? ot.utilizationRate : 0}%;background:var(--accent-bright)">
                    <c:if test="${ot.utilizationRate != null && ot.utilizationRate > 20}">${ot.utilizationRate}%</c:if>
                  </div>
                </div>
                <div class="ot-pct">${ot.utilizationRate != null ? ot.utilizationRate : 0}%</div>
              </div>
            </c:forEach>
            <c:if test="${empty ots}">
              <p style="text-align:center;color:var(--muted);padding:20px;font-size:12px">No OT data available</p>
            </c:if>
          </div>
        </div>
        <div class="card">
          <div class="card-header"><h3>OT Schedule</h3><span>Current assignments</span></div>
          <div style="overflow-x:auto">
            <table class="rep-table">
              <thead><tr><th>OT Room</th><th>Status</th></tr></thead>
              <tbody>
                <c:forEach var="ot" items="${ots}">
                  <tr>
                    <td>${ot.name != null ? ot.name : ot.otId}</td>
                    <td><span class="badge ${'AVAILABLE'==ot.status?'b-success':'b-medium'}">${ot.status != null ? ot.status : 'N/A'}</span></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty ots}">
                  <tr><td colspan="2" style="text-align:center;color:var(--muted);padding:20px">No OT data</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div><!-- /ot -->

    <!-- ===== SAVED REPORTS TAB ===== -->
    <div id="tab-saved" style="display:none">
      <div class="card">
        <div class="card-header"><h3>📁 Saved &amp; Generated Reports</h3><span>Download anytime</span></div>
        <div class="card-body">
          <div class="rep-item">
            <div class="rep-icon" style="background:#dcfce7">📊</div>
            <div class="rep-info">
              <h4>Full Risk Analysis Report</h4>
              <p>${totalPatients} patients · All risk levels · PDF</p>
            </div>
            <div class="rep-actions">
              <a href="${pageContext.request.contextPath}/reports?type=risk&format=pdf" class="btn-sm btn-sm-p">⬇ PDF</a>
            </div>
          </div>
          <div class="rep-item">
            <div class="rep-icon" style="background:#dbeafe">🧑‍⚕️</div>
            <div class="rep-info">
              <h4>Patient Risk Report — Full</h4>
              <p>${totalPatients} patients · All details · Excel</p>
            </div>
            <div class="rep-actions">
              <a href="${pageContext.request.contextPath}/reports?type=patient&format=excel" class="btn-sm btn-sm-p">⬇ Excel</a>
            </div>
          </div>
          <div class="rep-item">
            <div class="rep-icon" style="background:#fef9c3">🏥</div>
            <div class="rep-info">
              <h4>OT Utilization Report</h4>
              <p>All operation theaters · PDF</p>
            </div>
            <div class="rep-actions">
              <a href="${pageContext.request.contextPath}/reports?type=ot&format=pdf" class="btn-sm btn-sm-p">⬇ PDF</a>
            </div>
          </div>
          <div class="rep-item">
            <div class="rep-icon" style="background:#ede9fe">👨‍⚕️</div>
            <div class="rep-info">
              <h4>Surgeon Report</h4>
              <p>${totalSurgeons} surgeons · PDF</p>
            </div>
            <div class="rep-actions">
              <a href="${pageContext.request.contextPath}/reports?type=surgeon&format=pdf" class="btn-sm btn-sm-p">⬇ PDF</a>
            </div>
          </div>
          <div class="rep-item">
            <div class="rep-icon" style="background:#fee2e2">📋</div>
            <div class="rep-info">
              <h4>Full System Export</h4>
              <p>All modules · Complete data · PDF</p>
            </div>
            <div class="rep-actions">
              <a href="${pageContext.request.contextPath}/reports?type=full&format=pdf" class="btn-sm btn-sm-p">⬇ PDF</a>
            </div>
          </div>
        </div>
      </div>
    </div><!-- /saved -->

  </div>
</main>

<script>
function showTab(name, el) {
  ['overview','patient','surgeon','ot','saved'].forEach(t => {
    const d = document.getElementById('tab-' + t);
    if (d) d.style.display = t === name ? 'block' : 'none';
  });
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
}
function togglePt(ptId, arId) {
  const el = document.getElementById(ptId);
  const ar = document.getElementById(arId);
  const open = el.style.display !== 'none';
  el.style.display = open ? 'none' : 'block';
  ar.textContent   = open ? '▼' : '▲';
}
</script>
</body>
</html>
