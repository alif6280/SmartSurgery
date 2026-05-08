<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("currentPage", "patients");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    boolean isEdit = request.getAttribute("patient") != null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Edit Patient" : "Register Patient" %> — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:#f5f7f5}
        :root{
            --teal:#007a63;--teal-dim:#005f4d;--teal-glow:rgba(0,122,99,0.12);
            --blue:#1560a8;
            --bg-base:#f0f4f8;--bg-surface:#ffffff;--bg-card:#ffffff;--bg-hover:#e2eaf2;
            --border:#c8d8e8;--border-light:#a0b8cc;
            --text-primary:#0a1628;--text-secondary:#2a4060;--text-muted:#5a7a90;
            --risk-low:#007a63;--risk-medium:#a86200;--risk-high:#c03a1a;--risk-critical:#a80028;
            --font-main:'Space Grotesk',sans-serif;
            --radius:8px;--radius-lg:14px;
            --shadow:0 4px 24px rgba(0,0,0,0.08);
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
        .card{background:#fff;border:1px solid #c8d8e8;border-radius:14px;overflow:hidden;margin-bottom:20px}
        .card-header{padding:16px 20px 12px;border-bottom:1px solid #c8d8e8;display:flex;align-items:center;justify-content:space-between}
        .card-title{font-size:13.5px;font-weight:600;color:#0a1628;display:flex;align-items:center;gap:8px}
        .card-title .icon{color:#007a63;font-size:15px}
        .card-body{padding:18px 20px}

        /* Forms */
        .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .form-grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px}
        .form-full{grid-column:1/-1}
        .form-group{display:flex;flex-direction:column;gap:6px}
        .form-label{font-size:11px;font-weight:700;color:#5a7a90;letter-spacing:0.04em;text-transform:uppercase}
        .form-control{background:#fff;border:1px solid #a0b8cc;border-radius:8px;padding:9px 13px;color:#0a1628;font-family:'Space Grotesk',sans-serif;font-size:13.5px;transition:border-color 0.18s,box-shadow 0.18s;width:100%}
        .form-control:focus{outline:none;border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.12)}
        .form-control::placeholder{color:#5a7a90}
        select.form-control{cursor:pointer}
        textarea.form-control{resize:vertical;min-height:90px;line-height:1.5}

        /* Checkbox grid */
        .checkbox-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px}
        .check-item{display:flex;align-items:center;gap:9px;padding:10px 13px;background:#f0f4f8;border:1px solid #c8d8e8;border-radius:8px;cursor:pointer;transition:all 0.18s;font-size:13px;color:#2a4060}
        .check-item:hover{border-color:#007a63;color:#0a1628;background:rgba(0,122,99,0.06)}
        .check-item input[type="checkbox"]{accent-color:#007a63;width:15px;height:15px}

        /* Section title */
        .section-title{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.1em;color:#5a7a90;padding:14px 0 8px;display:flex;align-items:center;gap:10px}
        .section-title::after{content:'';flex:1;height:1px;background:#c8d8e8}

        /* Risk display */
        .risk-score-num{font-size:48px;font-weight:700;font-family:monospace;color:#007a63;line-height:1}
        .risk-score-label{font-size:12px;color:#5a7a90;margin-top:4px;text-transform:uppercase;letter-spacing:0.08em}
        .risk-bar-bg{height:10px;background:#c8d8e8;border-radius:5px;overflow:hidden;margin-bottom:14px}
        .risk-bar-fill{height:100%;border-radius:5px;background:var(--fill-color,#007a63);transition:width 0.3s ease}

        /* Badges */
        .badge{display:inline-flex;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;white-space:nowrap}
        .risk-low     {background:rgba(0,122,99,0.10); color:#007a63;border:1px solid rgba(0,122,99,0.30)}
        .risk-medium  {background:rgba(168,98,0,0.10); color:#a86200;border:1px solid rgba(168,98,0,0.30)}
        .risk-high    {background:rgba(192,58,26,0.10);color:#c03a1a;border:1px solid rgba(192,58,26,0.30)}
        .risk-critical{background:rgba(168,0,40,0.10); color:#a80028;border:1px solid rgba(168,0,40,0.30)}

        /* Pre-op checklist */
        .preop-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px;margin-top:10px}
        .preop-item{display:flex;align-items:center;gap:10px;background:#f0f4f8;border:1px solid #c8d8e8;border-radius:12px;padding:10px 14px;cursor:pointer;transition:border-color 0.15s,background 0.15s}
        .preop-item:has(input:checked){border-color:#639922;background:#f0fdf4}
        .preop-item input[type="checkbox"]{width:16px;height:16px;accent-color:#639922;cursor:pointer;flex-shrink:0}
        .preop-item-label{font-size:13px;font-weight:600;color:#0a1628;user-select:none}
        .preop-item-sub{font-size:11px;color:#5a7a90}
        .preop-progress{display:flex;align-items:center;gap:10px;margin-top:12px;font-size:12px;color:#5a7a90}
        .preop-bar-bg{flex:1;height:6px;background:#c8d8e8;border-radius:3px}
        .preop-bar-fill{height:6px;border-radius:3px;background:#639922;transition:width 0.3s ease}
        .preop-count{font-weight:700;color:#639922;min-width:36px}

        /* Breakdown */
        #riskBreakdown{margin-top:18px;text-align:left;background:#f0f4f8;border-radius:8px;padding:12px;font-size:12px;color:#5a7a90;font-family:monospace;line-height:1.8}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title"><%= isEdit ? "✏️ Edit Patient" : "➕ Register Patient" %></div>
                <div class="topbar-sub">Auto risk score calculated from health data</div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/patients" class="btn btn-secondary btn-sm">← Back</a>
            </div>
        </div>

        <div class="page-body">
            <form action="${pageContext.request.contextPath}/patients" method="POST">
                <input type="hidden" name="action" value="<%= isEdit ? "edit" : "add" %>">
                <c:if test="${not empty patient}">
                    <input type="hidden" name="id" value="${patient.id}">
                </c:if>

                <!-- Basic Information -->
                <div class="card">
                    <div class="card-header">
                        <div class="card-title"><span class="icon">👤</span> Basic Information</div>
                    </div>
                    <div class="card-body">
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">Full Name *</label>
                                <input type="text" name="fullName" class="form-control" value="${patient.fullName}" placeholder="Patient full name" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Age *</label>
                                <input type="number" name="age" id="age" class="form-control" value="${patient.age}" min="1" max="120" placeholder="Age in years" required oninput="calcRisk()">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Gender *</label>
                                <select name="gender" class="form-control" required>
                                    <option value="">-- Select --</option>
                                    <option value="MALE"   ${patient.gender == 'MALE'   ? 'selected' : ''}>Male</option>
                                    <option value="FEMALE" ${patient.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                    <option value="OTHER"  ${patient.gender == 'OTHER'  ? 'selected' : ''}>Other</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Blood Group</label>
                                <select name="bloodGroup" class="form-control">
                                    <option value="">-- Select --</option>
                                    <c:forEach var="bg" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                        <option value="${bg}" ${patient.bloodGroup == bg ? 'selected' : ''}>${bg}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Contact Number</label>
                                <input type="text" name="contactNumber" class="form-control" value="${patient.contactNumber}" placeholder="01XXXXXXXXX">
                            </div>
                            <div class="form-group">
                                <label class="form-label">BMI (kg/m²)</label>
                                <input type="number" name="bmi" id="bmi" class="form-control" value="${patient.bmi}" step="0.1" min="10" max="60" placeholder="e.g. 24.5" oninput="calcRisk()">
                            </div>
                            <div class="form-group form-full">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" value="${patient.address}" placeholder="Full address">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Risk Factors + Live Calculator -->
                <div style="display:grid;grid-template-columns:2fr 1fr;gap:20px;">
                    <div style="display:flex;flex-direction:column;gap:0;">

                        <!-- Risk Factors -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">⚠️</span> Risk Factors & Medical History</div>
                            </div>
                            <div class="card-body">
                                <div class="section-title">ASA Physical Status Grade</div>
                                <div class="form-group" style="margin-bottom:16px;">
                                    <select name="asaGrade" id="asaGrade" class="form-control" required onchange="calcRisk()">
                                        <option value="1" ${patient.asaGrade == 1 || empty patient ? 'selected' : ''}>Grade 1 — Normal healthy patient</option>
                                        <option value="2" ${patient.asaGrade == 2 ? 'selected' : ''}>Grade 2 — Mild systemic disease</option>
                                        <option value="3" ${patient.asaGrade == 3 ? 'selected' : ''}>Grade 3 — Severe systemic disease</option>
                                        <option value="4" ${patient.asaGrade == 4 ? 'selected' : ''}>Grade 4 — Life-threatening disease</option>
                                        <option value="5" ${patient.asaGrade == 5 ? 'selected' : ''}>Grade 5 — Moribund patient</option>
                                    </select>
                                </div>

                                <div class="section-title">Comorbidities</div>
                                <div class="checkbox-grid">
                                    <label class="check-item">
                                        <input type="checkbox" name="hasDiabetes" id="chkDM" ${patient.hasDiabetes ? 'checked' : ''} onchange="calcRisk()">
                                        🩸 Diabetes Mellitus
                                    </label>
                                    <label class="check-item">
                                        <input type="checkbox" name="hasHypertension" id="chkHTN" ${patient.hasHypertension ? 'checked' : ''} onchange="calcRisk()">
                                        💉 Hypertension (HTN)
                                    </label>
                                    <label class="check-item">
                                        <input type="checkbox" name="hasHeartDisease" id="chkCVD" ${patient.hasHeartDisease ? 'checked' : ''} onchange="calcRisk()">
                                        ❤️ Heart Disease (CVD)
                                    </label>
                                    <label class="check-item">
                                        <input type="checkbox" name="hasKidneyDisease" id="chkCKD" ${patient.hasKidneyDisease ? 'checked' : ''} onchange="calcRisk()">
                                        🫘 Kidney Disease (CKD)
                                    </label>
                                    <label class="check-item">
                                        <input type="checkbox" name="isSmoker" id="chkSmoke" ${patient.smoker ? 'checked' : ''} onchange="calcRisk()">
                                        🚬 Current Smoker
                                    </label>
                                </div>

                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Medical History</label>
                                        <textarea name="medicalHistory" class="form-control" placeholder="Previous surgeries, conditions...">${patient.medicalHistory}</textarea>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Known Allergies</label>
                                        <textarea name="allergies" class="form-control" placeholder="Drug allergies, food allergies...">${patient.allergies}</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Pre-op Checklist -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">✅</span> Pre-operative Checklist</div>
                            </div>
                            <div class="card-body">
                                <p style="font-size:13px;color:#5a7a90;margin-bottom:4px;">Mark completed pre-op steps. Visible on patient card and list.</p>
                                <div class="preop-progress">
                                    <span>Progress:</span>
                                    <div class="preop-bar-bg"><div class="preop-bar-fill" id="preopBarFill" style="width:0%;"></div></div>
                                    <span class="preop-count" id="preopCount">0/5</span>
                                </div>
                                <div class="preop-grid">
                                    <label class="preop-item">
                                        <input type="checkbox" name="labsDone" id="chkLabs" ${patient.labsDone ? 'checked' : ''} onchange="updatePreopProgress()">
                                        <div><div class="preop-item-label">🧪 Lab Tests</div><div class="preop-item-sub">CBC, LFT, RFT, Coag</div></div>
                                    </label>
                                    <label class="preop-item">
                                        <input type="checkbox" name="ecgDone" id="chkEcg" ${patient.ecgDone ? 'checked' : ''} onchange="updatePreopProgress()">
                                        <div><div class="preop-item-label">💓 ECG / Echo</div><div class="preop-item-sub">Cardiac baseline check</div></div>
                                    </label>
                                    <label class="preop-item">
                                        <input type="checkbox" name="consentSigned" id="chkConsent" ${patient.consentSigned ? 'checked' : ''} onchange="updatePreopProgress()">
                                        <div><div class="preop-item-label">📝 Consent Signed</div><div class="preop-item-sub">Informed consent form</div></div>
                                    </label>
                                    <label class="preop-item">
                                        <input type="checkbox" name="anaesthesiaDone" id="chkAnaes" ${patient.anaesthesiaDone ? 'checked' : ''} onchange="updatePreopProgress()">
                                        <div><div class="preop-item-label">💉 Anaesthesia Review</div><div class="preop-item-sub">Pre-anaesthesia assessment</div></div>
                                    </label>
                                    <label class="preop-item">
                                        <input type="checkbox" name="npoDone" id="chkNpo" ${patient.npoDone ? 'checked' : ''} onchange="updatePreopProgress()">
                                        <div><div class="preop-item-label">🚫 NPO Status</div><div class="preop-item-sub">Nil Per Os confirmed</div></div>
                                    </label>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- Live Risk Calculator -->
                    <div>
                        <div class="card" style="position:sticky;top:20px;">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">🧮</span> Live Risk Calculator</div>
                            </div>
                            <div class="card-body" style="text-align:center;">
                                <div style="margin-bottom:16px;">
                                    <div id="riskScoreNum" class="risk-score-num">0</div>
                                    <div class="risk-score-label">/ 100 Risk Score</div>
                                </div>
                                <div class="risk-bar-bg">
                                    <div id="riskBarFill" class="risk-bar-fill" style="width:0%;height:10px;border-radius:5px;"></div>
                                </div>
                                <span id="riskLevelBadge" class="badge risk-low" style="font-size:14px;padding:6px 18px;">LOW RISK</span>
                                <div id="riskBreakdown">
                                    <div style="font-weight:700;color:#2a4060;margin-bottom:6px;font-family:'Space Grotesk',sans-serif;">Score Breakdown:</div>
                                    <div id="brk-age">  Age factor:     0 pts</div>
                                    <div id="brk-asa">  ASA Grade:      0 pts</div>
                                    <div id="brk-cond"> Comorbidities:  0 pts</div>
                                    <div id="brk-bmi">  BMI factor:     0 pts</div>
                                    <div id="brk-smoke">Smoking:        0 pts</div>
                                </div>
                                <p style="font-size:11px;color:#5a7a90;margin-top:12px;">⚡ Score updates as you fill in the form</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Submit -->
                <div style="display:flex;justify-content:flex-end;gap:12px;margin-top:20px;">
                    <a href="${pageContext.request.contextPath}/patients" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "💾 Update Patient" : "✅ Register Patient" %>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function calcRisk() {
    const age = parseInt(document.getElementById('age').value) || 0;
    let ageScore = 0;
    if      (age < 18)  ageScore = 5;
    else if (age <= 40) ageScore = 0;
    else if (age <= 55) ageScore = 5;
    else if (age <= 65) ageScore = 10;
    else if (age <= 75) ageScore = 15;
    else                ageScore = 20;

    const asa = parseInt(document.getElementById('asaGrade').value) || 1;
    const asaScores = {1:0, 2:7.5, 3:15, 4:25, 5:30};
    const asaScore = asaScores[asa] || 0;

    let condScore = 0;
    if (document.getElementById('chkDM').checked)    condScore += 10;
    if (document.getElementById('chkHTN').checked)   condScore += 8;
    if (document.getElementById('chkCVD').checked)   condScore += 15;
    if (document.getElementById('chkCKD').checked)   condScore += 10;
    condScore = Math.min(condScore, 35);

    const bmi = parseFloat(document.getElementById('bmi').value) || 0;
    let bmiScore = 0;
    if      (bmi > 0 && bmi < 18.5) bmiScore = 5;
    else if (bmi <= 24.9)            bmiScore = 0;
    else if (bmi <= 29.9)            bmiScore = 3;
    else if (bmi <= 34.9)            bmiScore = 7;
    else if (bmi > 34.9)             bmiScore = 10;

    const smokeScore = document.getElementById('chkSmoke').checked ? 5 : 0;
    const score = Math.min(ageScore + asaScore + condScore + bmiScore + smokeScore, 100);

    document.getElementById('riskScoreNum').textContent = score.toFixed(1);
    document.getElementById('riskBarFill').style.width  = score + '%';

    let level, color;
    if      (score <= 25) { level = 'LOW';      color = '#007a63'; }
    else if (score <= 50) { level = 'MEDIUM';   color = '#a86200'; }
    else if (score <= 75) { level = 'HIGH';     color = '#c03a1a'; }
    else                  { level = 'CRITICAL'; color = '#a80028'; }

    const badge = document.getElementById('riskLevelBadge');
    badge.textContent = level + ' RISK';
    badge.className   = 'badge risk-' + level.toLowerCase();
    document.getElementById('riskScoreNum').style.color     = color;
    document.getElementById('riskBarFill').style.background = color;

    document.getElementById('brk-age').textContent   = '  Age factor:     ' + ageScore   + ' pts';
    document.getElementById('brk-asa').textContent   = '  ASA Grade:      ' + asaScore   + ' pts';
    document.getElementById('brk-cond').textContent  = '  Comorbidities:  ' + condScore  + ' pts';
    document.getElementById('brk-bmi').textContent   = '  BMI factor:     ' + bmiScore   + ' pts';
    document.getElementById('brk-smoke').textContent = '  Smoking:        ' + smokeScore + ' pts';
}

function updatePreopProgress() {
    const ids  = ['chkLabs','chkEcg','chkConsent','chkAnaes','chkNpo'];
    const done = ids.filter(id => document.getElementById(id)?.checked).length;
    const pct  = (done / ids.length) * 100;
    const fill  = document.getElementById('preopBarFill');
    const count = document.getElementById('preopCount');
    if (fill)  fill.style.width  = pct + '%';
    if (count) count.textContent = done + '/' + ids.length;
    if (fill)  fill.style.background = done === ids.length ? '#639922' : done >= 3 ? '#ef9f27' : '#e24b4a';
}

window.onload = () => { calcRisk(); updatePreopProgress(); };
</script>
</body>
</html>