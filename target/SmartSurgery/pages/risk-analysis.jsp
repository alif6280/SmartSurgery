<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"      prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"       prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Risk Analysis — Smart Surgery System</title>
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
.sidebar-logo h2 { color:#fff; font-size:13px; font-weight:700; letter-spacing:0.5px; line-height:1.3; }
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

/* STAT CARDS */
.stats-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:14px; margin-bottom:24px; }
.stat-card { border-radius:12px; padding:16px 18px; position:relative; overflow:hidden; color:#fff; }
.stat-card .label { font-size:10px; font-weight:700; letter-spacing:0.8px; text-transform:uppercase; margin-bottom:10px; opacity:0.85; }
.stat-card .value { font-size:32px; font-weight:700; line-height:1; margin-bottom:6px; }
.stat-card .sub   { font-size:11px; opacity:0.75; }
.stat-card .dot   { position:absolute; right:12px; top:14px; width:10px; height:10px; border-radius:50%; background:rgba(255,255,255,0.4); }
.stat-card .circle{ position:absolute; right:-12px; bottom:-18px; width:70px; height:70px; border-radius:50%; background:rgba(255,255,255,0.06); }
.sc-total    { background:#2d6a4f; }
.sc-critical { background:#991b1b; }
.sc-high     { background:#9a3412; }
.sc-medium   { background:#92400e; }
.sc-low      { background:#166534; }

/* GRID */
.grid-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px; margin-bottom:20px; }
.grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px; }

/* CARD */
.card { background:var(--card); border-radius:12px; border:1px solid var(--border); overflow:hidden; }
.card-header { padding:16px 20px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; }
.card-header h3 { font-size:14px; font-weight:600; color:var(--text); }
.card-header span { font-size:11px; color:var(--muted); }
.card-body { padding:20px; }

/* GAUGE */
.gauge-wrap { display:flex; flex-direction:column; align-items:center; }
.gauge-wrap svg { width:180px; }
.gauge-val { text-align:center; margin-top:-8px; }
.gauge-val .num { font-size:28px; font-weight:700; color:var(--text); }
.gauge-val .lbl { font-size:11px; color:var(--muted); display:block; }
.risk-legend { display:grid; grid-template-columns:1fr 1fr; gap:8px; width:100%; margin-top:12px; }
.leg-item { display:flex; align-items:center; gap:6px; font-size:11px; color:var(--text); }
.leg-dot  { width:8px; height:8px; border-radius:50%; flex-shrink:0; }

/* BAR */
.bar-item { margin-bottom:14px; }
.bar-item:last-child { margin-bottom:0; }
.bar-label { display:flex; justify-content:space-between; margin-bottom:5px; font-size:12px; }
.bar-label span:first-child { color:var(--text); font-weight:500; }
.bar-label span:last-child  { color:var(--muted); }
.bar-track { height:8px; background:var(--bg); border-radius:99px; overflow:hidden; }
.bar-fill  { height:100%; border-radius:99px; }

/* ASA */
.asa-cols { display:flex; align-items:flex-end; gap:6px; height:100px; }
.asa-col  { flex:1; display:flex; flex-direction:column; align-items:center; gap:4px; height:100%; justify-content:flex-end; }
.asa-bar  { width:100%; border-radius:4px 4px 0 0; }
.asa-lbl  { font-size:10px; color:var(--muted); }
.asa-num  { font-size:10px; color:var(--muted); }
.asa-axis { border-top:1px solid var(--border); margin-top:4px; }
.asa-table { width:100%; border-collapse:collapse; margin-top:12px; }
.asa-table th { padding:7px 10px; font-size:11px; font-weight:600; color:var(--muted); text-align:left; border-bottom:1px solid var(--border); text-transform:uppercase; }
.asa-table td { padding:9px 10px; font-size:12px; color:var(--text); border-bottom:1px solid var(--bg); }
.asa-badge { display:inline-block; padding:2px 8px; border-radius:6px; font-size:11px; font-weight:600; }
.asa-1 { background:#dcfce7; color:#166534; }
.asa-2 { background:#fef9c3; color:#854d0e; }
.asa-3 { background:#ffedd5; color:#9a3412; }
.asa-4 { background:#fee2e2; color:#991b1b; }

/* HEATMAP */
.heatmap { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; }
.heat-cell { border-radius:10px; padding:12px; text-align:center; cursor:pointer; transition:transform 0.15s; }
.heat-cell:hover { transform:scale(1.03); }
.heat-cell .c-name  { font-size:11px; font-weight:600; margin-bottom:4px; }
.heat-cell .c-count { font-size:22px; font-weight:700; }
.heat-cell .c-pct   { font-size:10px; opacity:0.7; margin-top:2px; }
.cc-h { background:#fee2e2; color:#991b1b; }
.cc-m { background:#ffedd5; color:#9a3412; }
.cc-l { background:#fef9c3; color:#854d0e; }
.cc-n { background:#f0fdf4; color:#166534; }

/* CALCULATOR */
.calc-form { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.form-group label { display:block; font-size:11px; font-weight:600; color:var(--accent); margin-bottom:5px; text-transform:uppercase; letter-spacing:0.5px; }
.form-group select, .form-group input { width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:13px; color:var(--text); background:#fff; outline:none; }
.form-group select:focus, .form-group input:focus { border-color:var(--accent-bright); }
.btn-calc { width:100%; padding:10px; background:var(--accent); color:#fff; border:none; border-radius:8px; font-size:13px; font-weight:600; cursor:pointer; margin-top:4px; }
.btn-calc:hover { background:var(--accent-bright); }
.calc-result { margin-top:14px; padding:14px; border-radius:10px; background:linear-gradient(135deg,#f0fdf4,#e8f5e9); border:1px solid #a7d7a7; display:flex; align-items:center; gap:14px; }
.calc-score-num { font-size:36px; font-weight:700; color:var(--low); line-height:1; }
.calc-score-info h4 { font-size:13px; font-weight:600; color:var(--text); }
.calc-score-info p  { font-size:11px; color:var(--muted); margin-top:3px; }
.calc-bar-wrap { flex:1; }
.calc-bar-track { height:8px; background:var(--border); border-radius:99px; overflow:hidden; margin-top:6px; }
.calc-bar-fill  { height:100%; border-radius:99px; background:var(--low); width:28%; transition:width 0.6s, background 0.4s; }

/* PATIENT TABLE */
.pt-table { width:100%; border-collapse:collapse; }
.pt-table th { padding:9px 14px; font-size:11px; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid var(--border); background:var(--bg); text-align:left; }
.pt-table td { padding:11px 14px; font-size:12px; color:var(--text); border-bottom:1px solid var(--bg); vertical-align:middle; }
.pt-table tr:hover td { background:#f7fbf7; }
.avatar-sm { width:28px; height:28px; border-radius:6px; background:var(--accent-bright); color:#fff; display:inline-flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; margin-right:6px; }
.avatar-f  { background:#d946ef; }
.score-wrap  { display:flex; align-items:center; gap:8px; }
.score-track { flex:1; height:6px; background:var(--bg); border-radius:99px; overflow:hidden; }
.score-fill  { height:100%; border-radius:99px; }
.score-num   { font-weight:600; font-size:12px; min-width:28px; }
.risk-badge  { display:inline-flex; align-items:center; gap:4px; padding:3px 8px; border-radius:6px; font-size:11px; font-weight:600; }
.rb-critical { background:#fee2e2; color:#991b1b; }
.rb-high     { background:#ffedd5; color:#9a3412; }
.rb-medium   { background:#fef9c3; color:#854d0e; }
.rb-low      { background:#dcfce7; color:#166534; }
.tag { display:inline-block; padding:2px 6px; border-radius:4px; font-size:10px; font-weight:600; background:#e8f4e8; color:var(--accent); margin:1px; }
.preop-dot { display:inline-block; width:8px; height:8px; border-radius:50%; margin:1px; }
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
  <a class="nav-item active" href="${pageContext.request.contextPath}/risk-analysis">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
    Risk Analysis
  </a>
  <a class="nav-item" href="${pageContext.request.contextPath}/reports">
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
      <h1>📊 Risk Analysis</h1>
      <p>Patient risk scoring, ASA classification &amp; surgical risk insights</p>
    </div>
    <div class="header-actions">
      <a href="${pageContext.request.contextPath}/risk-analysis" class="btn btn-outline">🔄 Refresh</a>
      <a href="${pageContext.request.contextPath}/reports"       class="btn btn-primary">📋 Reports</a>
    </div>
  </div>

  <div class="content">

    <!-- STAT CARDS -->
    <div class="stats-grid">
      <div class="stat-card sc-total">
        <div class="dot"></div>
        <div class="label">Total Patients</div>
        <div class="value">${totalPatients}</div>
        <div class="sub">All registered</div>
        <div class="circle"></div>
      </div>
      <div class="stat-card sc-critical">
        <div class="dot"></div>
        <div class="label">Critical Risk</div>
        <div class="value">${criticalCount}</div>
        <div class="sub">Risk &gt; 75</div>
        <div class="circle"></div>
      </div>
      <div class="stat-card sc-high">
        <div class="dot"></div>
        <div class="label">High Risk</div>
        <div class="value">${highCount}</div>
        <div class="sub">Risk 51–75</div>
        <div class="circle"></div>
      </div>
      <div class="stat-card sc-medium">
        <div class="dot"></div>
        <div class="label">Medium Risk</div>
        <div class="value">${mediumCount}</div>
        <div class="sub">Risk 26–50</div>
        <div class="circle"></div>
      </div>
      <div class="stat-card sc-low">
        <div class="dot"></div>
        <div class="label">Low Risk</div>
        <div class="value">${lowCount}</div>
        <div class="sub">Risk ≤25</div>
        <div class="circle"></div>
      </div>
    </div>

    <!-- ROW 1: Gauge + Factor Bars + ASA -->
    <div class="grid-3">

      <!-- Gauge -->
      <div class="card">
        <div class="card-header"><h3>Average Risk Score</h3><span>All patients</span></div>
        <div class="card-body">
          <div class="gauge-wrap">
            <svg viewBox="0 0 180 100" xmlns="http://www.w3.org/2000/svg">
              <path d="M15,90 A75,75 0 0,1 55,18"  fill="none" stroke="#fee2e2" stroke-width="14" stroke-linecap="round"/>
              <path d="M55,18 A75,75 0 0,1 100,8"   fill="none" stroke="#ffedd5" stroke-width="14" stroke-linecap="round"/>
              <path d="M100,8 A75,75 0 0,1 145,18"  fill="none" stroke="#fef9c3" stroke-width="14" stroke-linecap="round"/>
              <path d="M145,18 A75,75 0 0,1 165,90" fill="none" stroke="#dcfce7" stroke-width="14" stroke-linecap="round"/>
              <path d="M15,90 A75,75 0 0,1 118,21"  fill="none"
                stroke="${avgRisk > 75 ? '#dc2626' : avgRisk > 50 ? '#ea580c' : avgRisk > 25 ? '#d97706' : '#16a34a'}"
                stroke-width="14" stroke-linecap="round" opacity="0.9"/>
              <circle cx="90" cy="90" r="6" fill="#1b2d1b"/>
            </svg>
            <div class="gauge-val">
              <span class="num">${avgRisk}</span>
              <span class="lbl">Avg Score / 100</span>
            </div>
            <div class="risk-legend">
              <div class="leg-item"><div class="leg-dot" style="background:#dc2626"></div>Critical (&gt;75)</div>
              <div class="leg-item"><div class="leg-dot" style="background:#ea580c"></div>High (51–75)</div>
              <div class="leg-item"><div class="leg-dot" style="background:#d97706"></div>Medium (26–50)</div>
              <div class="leg-item"><div class="leg-dot" style="background:#16a34a"></div>Low (≤25)</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Top Risk Factors -->
      <div class="card">
        <div class="card-header"><h3>Top Risk Factors</h3><span>By patient count</span></div>
        <div class="card-body">
          <c:forEach var="entry" items="${comorbidityCount}">
            <c:set var="pct" value="${totalPatients > 0 ? (entry.value * 100) / totalPatients : 0}"/>
            <div class="bar-item">
              <div class="bar-label">
                <span>${entry.key}</span>
                <span>${entry.value} pt${entry.value != 1 ? 's' : ''}</span>
              </div>
              <div class="bar-track">
                <div class="bar-fill" style="width:${pct}%;background:${pct>=75?'#dc2626':pct>=50?'#ea580c':'#d97706'}"></div>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty comorbidityCount}">
            <p style="color:var(--muted);font-size:12px;text-align:center;padding:20px 0">No comorbidity data</p>
          </c:if>
        </div>
      </div>

      <!-- ASA Distribution -->
      <div class="card">
        <div class="card-header"><h3>ASA Grade Distribution</h3><span>${totalPatients} patients</span></div>
        <div class="card-body">
          <c:set var="maxAsa" value="${asa1 > asa2 ? asa1 : asa2}"/>
          <c:set var="maxAsa" value="${maxAsa > asa3 ? maxAsa : asa3}"/>
          <c:set var="maxAsa" value="${maxAsa > asa4 ? maxAsa : asa4}"/>
          <c:set var="maxAsa" value="${maxAsa < 1 ? 1 : maxAsa}"/>
          <div class="asa-cols">
            <div class="asa-col">
              <div class="asa-num">${asa1}</div>
              <div class="asa-bar" style="height:${(asa1 * 80 / maxAsa) + 4}px;background:#dcfce7;border-top:3px solid #16a34a"></div>
              <div class="asa-lbl">G1</div>
            </div>
            <div class="asa-col">
              <div class="asa-num">${asa2}</div>
              <div class="asa-bar" style="height:${(asa2 * 80 / maxAsa) + 4}px;background:#fef9c3;border-top:3px solid #d97706"></div>
              <div class="asa-lbl">G2</div>
            </div>
            <div class="asa-col">
              <div class="asa-num">${asa3}</div>
              <div class="asa-bar" style="height:${(asa3 * 80 / maxAsa) + 4}px;background:#ffedd5;border-top:3px solid #ea580c"></div>
              <div class="asa-lbl">G3</div>
            </div>
            <div class="asa-col">
              <div class="asa-num">${asa4}</div>
              <div class="asa-bar" style="height:${(asa4 * 80 / maxAsa) + 4}px;background:#fee2e2;border-top:3px solid #dc2626"></div>
              <div class="asa-lbl">G4</div>
            </div>
          </div>
          <div class="asa-axis"></div>
          <table class="asa-table">
            <tr><th>Grade</th><th>Description</th><th>#</th></tr>
            <tr><td><span class="asa-badge asa-1">GRADE 1</span></td><td>Normal healthy</td><td>${asa1}</td></tr>
            <tr><td><span class="asa-badge asa-2">GRADE 2</span></td><td>Mild systemic</td><td>${asa2}</td></tr>
            <tr><td><span class="asa-badge asa-3">GRADE 3</span></td><td>Severe systemic</td><td>${asa3}</td></tr>
            <tr><td><span class="asa-badge asa-4">GRADE 4</span></td><td>Life-threatening</td><td>${asa4}</td></tr>
          </table>
        </div>
      </div>
    </div>

    <!-- ROW 2: Heatmap + Calculator -->
    <div class="grid-2">

      <!-- Comorbidity Heatmap -->
      <div class="card">
        <div class="card-header"><h3>Comorbidity Heatmap</h3><span>Frequency across patients</span></div>
        <div class="card-body">
          <div class="heatmap">
            <c:forEach var="entry" items="${comorbidityCount}">
              <c:set var="pct" value="${totalPatients > 0 ? (entry.value * 100) / totalPatients : 0}"/>
              <div class="heat-cell ${pct >= 75 ? 'cc-h' : pct >= 50 ? 'cc-m' : pct >= 25 ? 'cc-l' : 'cc-n'}">
                <div class="c-name">${entry.key}</div>
                <div class="c-count">${entry.value}</div>
                <div class="c-pct"><fmt:formatNumber value="${pct}" maxFractionDigits="0"/>% pts</div>
              </div>
            </c:forEach>
            <c:if test="${empty comorbidityCount}">
              <div style="grid-column:1/-1;text-align:center;padding:30px;color:var(--muted);font-size:12px">No data available</div>
            </c:if>
          </div>
        </div>
      </div>

      <!-- Quick Risk Calculator -->
      <div class="card">
        <div class="card-header"><h3>⚡ Quick Risk Calculator</h3><span>Real-time estimation</span></div>
        <div class="card-body">
          <div class="calc-form">
            <div class="form-group">
              <label>Age</label>
              <input type="number" id="c-age" value="35" min="1" max="120" oninput="calcRisk()">
            </div>
            <div class="form-group">
              <label>ASA Grade</label>
              <select id="c-asa" onchange="calcRisk()">
                <option value="1">Grade 1 — Normal</option>
                <option value="2" selected>Grade 2 — Mild</option>
                <option value="3">Grade 3 — Severe</option>
                <option value="4">Grade 4 — Critical</option>
              </select>
            </div>
            <div class="form-group">
              <label>Surgery Type</label>
              <select id="c-type" onchange="calcRisk()">
                <option value="1">Minor</option>
                <option value="2" selected>Moderate</option>
                <option value="3">Major</option>
                <option value="4">Emergency</option>
              </select>
            </div>
            <div class="form-group">
              <label>Comorbidities</label>
              <select id="c-comor" onchange="calcRisk()">
                <option value="0">None</option>
                <option value="1" selected>1 condition</option>
                <option value="2">2 conditions</option>
                <option value="3">3+ conditions</option>
              </select>
            </div>
          </div>
          <button class="btn-calc" onclick="calcRisk()">🔍 Calculate Risk Score</button>
          <div class="calc-result" id="calc-result">
            <div class="calc-score-num" id="c-score">28</div>
            <div class="calc-score-info">
              <h4 id="c-level">MEDIUM RISK</h4>
              <p id="c-desc">Proceed with standard precautions</p>
            </div>
            <div class="calc-bar-wrap">
              <div style="font-size:10px;color:var(--muted)">Score / 100</div>
              <div class="calc-bar-track"><div class="calc-bar-fill" id="c-bar"></div></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Patient Risk Table -->
    <div class="card">
      <div class="card-header">
        <h3>Patient Risk Breakdown</h3>
        <span>${totalPatients} patients · Sorted by risk score</span>
      </div>
      <div style="overflow-x:auto">
        <table class="pt-table">
          <thead>
            <tr>
              <th>Patient</th><th>ID</th><th>Age/Sex</th><th>Blood</th>
              <th>ASA</th><th>Conditions</th><th>Risk Score</th>
              <th>Risk Level</th><th>Pre-op</th><th>Last Surgery</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${patients}">
              <c:set var="r"      value="${p.riskScore}"/>
              <c:set var="rColor" value="${r>75?'#dc2626':r>50?'#ea580c':r>25?'#d97706':'#16a34a'}"/>
              <c:set var="rClass" value="${r>75?'rb-critical':r>50?'rb-high':r>25?'rb-medium':'rb-low'}"/>
              <c:set var="rLabel" value="${r>75?'CRITICAL':r>50?'HIGH':r>25?'MEDIUM':'LOW'}"/>

              <%-- Count pre-op steps --%>
              <c:set var="steps" value="0"/>
              <c:if test="${p.labsDone}">       <c:set var="steps" value="${steps+1}"/></c:if>
              <c:if test="${p.ecgDone}">        <c:set var="steps" value="${steps+1}"/></c:if>
              <c:if test="${p.consentSigned}">  <c:set var="steps" value="${steps+1}"/></c:if>
              <c:if test="${p.anaesthesiaDone}"><c:set var="steps" value="${steps+1}"/></c:if>
              <c:if test="${p.npoDone}">        <c:set var="steps" value="${steps+1}"/></c:if>

              <tr>
                <td>
                  <span class="avatar-sm ${'FEMALE' == p.gender ? 'avatar-f' : ''}">${fn:substring(p.fullName,0,1)}</span>
                  ${p.fullName}
                </td>
                <td style="font-family:monospace;color:var(--muted)">${p.patientId}</td>
                <td>${p.age} · ${fn:substring(p.gender,0,1)}</td>
                <td><strong>${p.bloodGroup}</strong></td>
                <td><span class="asa-badge asa-${p.asaGrade}">GRADE ${p.asaGrade}</span></td>
                <td>
                  <c:if test="${p.hasDiabetes}">     <span class="tag">DM</span></c:if>
                  <c:if test="${p.hasHypertension}">  <span class="tag">HTN</span></c:if>
                  <c:if test="${p.hasHeartDisease}">  <span class="tag">CVD</span></c:if>
                  <c:if test="${p.hasKidneyDisease}"> <span class="tag">CKD</span></c:if>
                  <c:if test="${p.smoker}">            <span class="tag">SMK</span></c:if>
                </td>
                <td>
                  <div class="score-wrap">
                    <div class="score-track">
                      <div class="score-fill" style="width:${r}%;background:${rColor}"></div>
                    </div>
                    <span class="score-num" style="color:${rColor}"><fmt:formatNumber value="${r}" maxFractionDigits="1"/></span>
                  </div>
                </td>
                <td><span class="risk-badge ${rClass}">${rLabel}</span></td>
                <td>
                  <span style="font-size:11px;color:var(--muted)">${steps}/5</span>
                  <span class="preop-dot" style="background:${p.labsDone?'#16a34a':'#d1d5db'}"></span>
                  <span class="preop-dot" style="background:${p.ecgDone?'#16a34a':'#d1d5db'}"></span>
                  <span class="preop-dot" style="background:${p.consentSigned?'#16a34a':'#d1d5db'}"></span>
                  <span class="preop-dot" style="background:${p.anaesthesiaDone?'#16a34a':'#d1d5db'}"></span>
                  <span class="preop-dot" style="background:${p.npoDone?'#16a34a':'#d1d5db'}"></span>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty p.lastSurgeryStatus}">
                      <span style="font-size:11px;font-weight:600;color:${'COMPLETED'==p.lastSurgeryStatus?'#16a34a':'SCHEDULED'==p.lastSurgeryStatus?'#1e40af':'#d97706'}">
                        ● ${p.lastSurgeryStatus}
                      </span>
                    </c:when>
                    <c:otherwise><span style="font-size:11px;color:var(--muted)">—</span></c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty patients}">
              <tr><td colspan="10" style="text-align:center;padding:30px;color:var(--muted)">No patients registered</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</main>

<script>
function calcRisk() {
  const age   = parseInt(document.getElementById('c-age').value)   || 35;
  const asa   = parseInt(document.getElementById('c-asa').value);
  const stype = parseInt(document.getElementById('c-type').value);
  const comor = parseInt(document.getElementById('c-comor').value);

  let s = age > 70 ? 20 : age > 60 ? 14 : age > 50 ? 9 : age > 40 ? 5 : 2;
  s += (asa   - 1) * 14;
  s += (stype - 1) * 12;
  s +=  comor      *  8;
  s = Math.min(100, s);

  document.getElementById('c-score').textContent = s;
  document.getElementById('c-bar').style.width   = s + '%';

  let color, bg, border, level, desc;
  if (s > 75) {
    color='#dc2626'; bg='linear-gradient(135deg,#fef2f2,#fee2e2)'; border='#fca5a5';
    level='CRITICAL RISK'; desc='Surgery not recommended — stabilise first';
  } else if (s > 50) {
    color='#ea580c'; bg='linear-gradient(135deg,#fff7ed,#ffedd5)'; border='#fdba74';
    level='HIGH RISK'; desc='Requires senior surgeon & ICU standby';
  } else if (s > 25) {
    color='#d97706'; bg='linear-gradient(135deg,#fffbeb,#fef9c3)'; border='#fde047';
    level='MEDIUM RISK'; desc='Proceed with standard precautions';
  } else {
    color='#16a34a'; bg='linear-gradient(135deg,#f0fdf4,#dcfce7)'; border='#a7d7a7';
    level='LOW RISK'; desc='Safe for standard surgical procedure';
  }
  const res = document.getElementById('calc-result');
  document.getElementById('c-score').style.color   = color;
  document.getElementById('c-bar').style.background = color;
  document.getElementById('c-level').textContent   = level;
  document.getElementById('c-desc').textContent    = desc;
  res.style.background  = bg;
  res.style.borderColor = border;
}
calcRisk();
</script>
</body>
</html>
