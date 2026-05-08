<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("currentPage", "patients");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Patient Details — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:#f5f7f5}
        :root{
            --teal:#007a63;--teal-dim:#005f4d;--teal-glow:rgba(0,122,99,0.12);
            --blue:#1560a8;--blue-dim:#0f4d8a;
            --bg-base:#f0f4f8;--bg-surface:#ffffff;--bg-card:#ffffff;--bg-hover:#e2eaf2;
            --border:#c8d8e8;--border-light:#a0b8cc;
            --text-primary:#0a1628;--text-secondary:#2a4060;--text-muted:#5a7a90;
            --risk-low:#007a63;--risk-medium:#a86200;--risk-high:#c03a1a;--risk-critical:#a80028;
            --font-main:'Space Grotesk',sans-serif;--font-mono:monospace;
            --radius:8px;--radius-lg:14px;
            --shadow:0 4px 24px rgba(0,0,0,0.08);--shadow-lg:0 8px 40px rgba(0,0,0,0.14);
        }
        .shell{display:flex;height:100vh;overflow:hidden}
        .area{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}

        /* Topbar */
        .topbar{background:#fff;border-bottom:1px solid #e2e8e2;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
        .topbar-title{font-size:16px;font-weight:700;color:#0a2318}
        .topbar-sub{font-size:12px;color:#64748b;margin-top:2px}
        .topbar-right{display:flex;align-items:center;gap:10px}

        /* Page body */
        .page-body{flex:1;overflow-y:auto;overflow-x:hidden;padding:24px}
        .page-body::-webkit-scrollbar{width:4px}
        .page-body::-webkit-scrollbar-thumb{background:#c8d8c8;border-radius:4px}

        /* Buttons */
        .btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;cursor:pointer;transition:all 0.18s;border:1px solid transparent;text-decoration:none;white-space:nowrap}
        .btn-primary{background:#007a63;color:#fff;border-color:#007a63}
        .btn-primary:hover{background:#005f4d;color:#fff}
        .btn-secondary{background:#e2eaf2;color:#2a4060;border-color:#a0b8cc}
        .btn-secondary:hover{background:#c8d8e8;color:#0a1628}
        .btn-sm{padding:5px 10px;font-size:12px}

        /* Cards */
        .card{background:#fff;border:1px solid #c8d8e8;border-radius:14px;overflow:hidden}
        .card-header{padding:16px 20px 12px;border-bottom:1px solid #c8d8e8;display:flex;align-items:center;justify-content:space-between}
        .card-title{font-size:13.5px;font-weight:600;color:#0a1628;display:flex;align-items:center;gap:8px}
        .card-title .icon{color:#007a63;font-size:15px}
        .card-body{padding:18px 20px}

        /* Form grid */
        .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .form-label{font-size:11px;font-weight:700;color:#5a7a90;letter-spacing:0.04em;text-transform:uppercase;margin-bottom:4px}

        /* Badges */
        .badge{display:inline-flex;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;white-space:nowrap}
        .risk-low     {background:rgba(0,122,99,0.10); color:#007a63;border:1px solid rgba(0,122,99,0.30)}
        .risk-medium  {background:rgba(168,98,0,0.10); color:#a86200;border:1px solid rgba(168,98,0,0.30)}
        .risk-high    {background:rgba(192,58,26,0.10);color:#c03a1a;border:1px solid rgba(192,58,26,0.30)}
        .risk-critical{background:rgba(168,0,40,0.10); color:#a80028;border:1px solid rgba(168,0,40,0.30)}

        /* Alerts */
        .alert{padding:12px 16px;border-radius:8px;font-size:13px;display:flex;align-items:flex-start;gap:10px;border:1px solid}
        .alert-success{background:rgba(0,122,99,0.08); border-color:rgba(0,122,99,0.30); color:#007a63}
        .alert-warning{background:rgba(168,98,0,0.08); border-color:rgba(168,98,0,0.30); color:#a86200}
        .alert-error  {background:rgba(168,0,40,0.08); border-color:rgba(168,0,40,0.30); color:#a80028}

        /* Risk bar */
        .risk-bar-bg  {height:12px;background:#c8d8e8;border-radius:6px;overflow:hidden;margin-bottom:16px}
        .risk-bar-fill{height:100%;border-radius:6px;background:var(--fill-color,#007a63)}

        /* Mono */
        .mono{font-family:monospace}

        /* Comorbidity items */
        .comorbid-item{display:flex;align-items:center;gap:8px;padding:9px 12px;background:#f0f4f8;border-radius:8px;border:1px solid #c8d8e8;font-size:13px}
        .comorbid-item .co-label{color:#2a4060;flex:1}
        .comorbid-item .co-val{font-size:11px;font-weight:700}
        .co-yes{color:#a80028}
        .co-no {color:#007a63}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">👤 Patient Details</div>
                <div class="topbar-sub">Full risk analysis report</div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/report/patient?id=${patient.id}"
                   class="btn btn-primary btn-sm" target="_blank">📥 Download PDF</a>
                <a href="${pageContext.request.contextPath}/patients?action=edit&id=${patient.id}"
                   class="btn btn-secondary btn-sm">✏️ Edit</a>
                <a href="${pageContext.request.contextPath}/patients"
                   class="btn btn-secondary btn-sm">← Back</a>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${not empty patient}">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">

                    <!-- Left Column -->
                    <div style="display:flex;flex-direction:column;gap:16px;">

                        <!-- Identity Card -->
                        <div class="card">
                            <div class="card-body">
                                <div style="display:flex;gap:16px;align-items:center;margin-bottom:18px;">
                                    <div style="width:60px;height:60px;border-radius:50%;background:linear-gradient(135deg,#007a63,#1560a8);display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:700;color:#fff;flex-shrink:0;">
                                        ${patient.fullName.substring(0,1)}
                                    </div>
                                    <div>
                                        <div style="font-size:20px;font-weight:700;color:#0a1628;">${patient.fullName}</div>
                                        <div style="font-size:12px;color:#5a7a90;margin-top:4px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                            <span class="mono" style="color:#007a63;">${patient.patientId}</span>
                                            <span>·</span>
                                            <span>${patient.age} yrs</span>
                                            <span>·</span>
                                            <span>${patient.gender}</span>
                                            <span>·</span>
                                            <span class="badge risk-${patient.riskLevel.toLowerCase()}">${patient.riskLevel}</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-grid">
                                    <div>
                                        <div class="form-label">Blood Group</div>
                                        <div style="color:#0a1628;font-weight:600;">${patient.bloodGroup}</div>
                                    </div>
                                    <div>
                                        <div class="form-label">Contact</div>
                                        <div style="color:#0a1628;font-weight:600;">${patient.contactNumber}</div>
                                    </div>
                                    <div>
                                        <div class="form-label">BMI</div>
                                        <div style="color:#0a1628;font-weight:600;">
                                            <fmt:formatNumber value="${patient.bmi}" maxFractionDigits="1"/> kg/m²
                                        </div>
                                    </div>
                                    <div>
                                        <div class="form-label">ASA Grade</div>
                                        <div style="color:#0a1628;font-weight:600;">Grade ${patient.asaGrade}</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Comorbidities -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">🏥</span> Comorbidities</div>
                            </div>
                            <div class="card-body">
                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                                    <div class="comorbid-item">
                                        <span>${patient.hasDiabetes ? '🔴' : '🟢'}</span>
                                        <span class="co-label">Diabetes (DM)</span>
                                        <span class="co-val ${patient.hasDiabetes ? 'co-yes' : 'co-no'}">${patient.hasDiabetes ? 'YES' : 'No'}</span>
                                    </div>
                                    <div class="comorbid-item">
                                        <span>${patient.hasHypertension ? '🔴' : '🟢'}</span>
                                        <span class="co-label">Hypertension</span>
                                        <span class="co-val ${patient.hasHypertension ? 'co-yes' : 'co-no'}">${patient.hasHypertension ? 'YES' : 'No'}</span>
                                    </div>
                                    <div class="comorbid-item">
                                        <span>${patient.hasHeartDisease ? '🔴' : '🟢'}</span>
                                        <span class="co-label">Heart Disease</span>
                                        <span class="co-val ${patient.hasHeartDisease ? 'co-yes' : 'co-no'}">${patient.hasHeartDisease ? 'YES' : 'No'}</span>
                                    </div>
                                    <div class="comorbid-item">
                                        <span>${patient.hasKidneyDisease ? '🔴' : '🟢'}</span>
                                        <span class="co-label">Kidney Disease</span>
                                        <span class="co-val ${patient.hasKidneyDisease ? 'co-yes' : 'co-no'}">${patient.hasKidneyDisease ? 'YES' : 'No'}</span>
                                    </div>
                                    <div class="comorbid-item">
                                        <span>${patient.smoker ? '🔴' : '🟢'}</span>
                                        <span class="co-label">Smoker</span>
                                        <span class="co-val ${patient.smoker ? 'co-yes' : 'co-no'}">${patient.smoker ? 'YES' : 'No'}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div style="display:flex;flex-direction:column;gap:16px;">

                        <!-- Risk Analysis -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">📊</span> Risk Analysis Report</div>
                            </div>
                            <div class="card-body" style="text-align:center;">
                                <div style="margin-bottom:20px;">
                                    <div style="font-size:64px;font-weight:700;font-family:monospace;line-height:1;color:<c:choose><c:when test="${patient.riskScore > 75}">#a80028</c:when><c:when test="${patient.riskScore > 50}">#c03a1a</c:when><c:when test="${patient.riskScore > 25}">#a86200</c:when><c:otherwise>#007a63</c:otherwise></c:choose>;">
                                        <fmt:formatNumber value="${patient.riskScore}" maxFractionDigits="1"/>
                                    </div>
                                    <div style="font-size:14px;color:#5a7a90;margin-top:4px;">out of 100 — Risk Score</div>
                                </div>

                                <div class="risk-bar-bg">
                                    <div class="risk-bar-fill" style="width:${patient.riskScore}%;--fill-color:<c:choose><c:when test="${patient.riskScore > 75}">#a80028</c:when><c:when test="${patient.riskScore > 50}">#c03a1a</c:when><c:when test="${patient.riskScore > 25}">#a86200</c:when><c:otherwise>#007a63</c:otherwise></c:choose>;"></div>
                                </div>

                                <span class="badge risk-${patient.riskLevel.toLowerCase()}" style="font-size:14px;padding:8px 24px;">
                                    ${patient.riskLevel} RISK
                                </span>

                                <div style="margin-top:20px;text-align:left;">
                                    <c:choose>
                                        <c:when test="${patient.riskLevel == 'CRITICAL'}">
                                            <div class="alert alert-error">
                                                🚨 <strong>CRITICAL RISK:</strong> Requires immediate pre-op optimization. Multi-specialist team review mandatory. Consider ICU post-op admission.
                                            </div>
                                        </c:when>
                                        <c:when test="${patient.riskLevel == 'HIGH'}">
                                            <div class="alert alert-error">
                                                🔴 <strong>HIGH RISK:</strong> Schedule urgent surgical review. Anaesthesia pre-assessment required.
                                            </div>
                                        </c:when>
                                        <c:when test="${patient.riskLevel == 'MEDIUM'}">
                                            <div class="alert alert-warning">
                                                ⚠️ <strong>MEDIUM RISK:</strong> Standard surgical protocol with enhanced monitoring. Anaesthesia consultation advised.
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="alert alert-success">
                                                ✅ <strong>LOW RISK:</strong> Routine surgical scheduling. Standard pre-operative preparation is sufficient.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Schedule Surgery -->
                        <div class="card">
                            <div class="card-body" style="text-align:center;padding:24px;">
                                <p style="color:#5a7a90;font-size:13px;margin-bottom:14px;">
                                    Ready to schedule surgery for this patient?
                                </p>
                                <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="btn btn-primary">
                                    📅 Schedule Surgery
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty patient}">
                <div style="text-align:center;padding:60px 20px;color:#5a7a90;">
                    <div style="font-size:48px;margin-bottom:14px;opacity:0.4;">👤</div>
                    <p style="font-size:14px;margin-bottom:16px;">Patient not found</p>
                    <a href="${pageContext.request.contextPath}/patients" class="btn btn-primary btn-sm">← Back to Patients</a>
                </div>
            </c:if>
        </div>
    </div>
</div>
</body>
</html>