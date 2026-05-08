<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("currentPage", "schedule");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Schedule Surgery — Smart Surgery System</title>
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
        .btn-primary:disabled{background:#9ca3af!important;cursor:not-allowed;opacity:0.7}
        .btn-secondary{background:#e2eaf2;color:#2a4060;border-color:#a0b8cc}
        .btn-secondary:hover{background:#c8d8e8;color:#0a1628}
        .btn-sm{padding:5px 10px;font-size:12px}

        /* Cards */
        .card{background:#fff;border:1px solid #c8d8e8;border-radius:14px;overflow:hidden;margin-bottom:18px}
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
        .mt-4{margin-top:16px}

        /* Alerts */
        .alert{padding:12px 16px;border-radius:8px;font-size:13px;margin-bottom:18px;display:flex;align-items:flex-start;gap:10px;border:1px solid}
        .alert-success{background:rgba(0,122,99,0.08);border-color:rgba(0,122,99,0.30);color:#007a63}
        .alert-warning{background:rgba(168,98,0,0.08);border-color:rgba(168,98,0,0.30);color:#a86200}
        .alert-error  {background:rgba(168,0,40,0.08);border-color:rgba(168,0,40,0.30);color:#a80028}

        /* Conflict Box */
        .conflict-box{border-radius:12px;padding:12px 16px;display:flex;align-items:flex-start;gap:10px;font-size:13px;margin-top:12px;transition:all 0.3s ease}
        .conflict-box.incomplete{background:#f3f4f6;border:1px dashed #d1d5db;color:#9ca3af}
        .conflict-box.checking  {background:#f3f4f6;border:1px solid #e5e7eb;color:#6b7280}
        .conflict-box.safe      {background:#eaf3de;border:1px solid #a8d08d;color:#27500a}
        .conflict-box.conflict  {background:#fcebeb;border:1px solid #f7c1c1;color:#791f1f}
        .conflict-box.warning   {background:#faeeda;border:1px solid #f5d08a;color:#633806}
        .conflict-icon{font-size:18px;flex-shrink:0;margin-top:1px}
        .conflict-title{font-weight:600;font-size:13px;margin-bottom:3px}
        .conflict-msg{font-size:12px;opacity:0.85;line-height:1.5}
        .conflict-badges{display:flex;gap:8px;flex-wrap:wrap;margin-top:8px}
        .cbadge{font-size:11px;font-weight:600;border-radius:999px;padding:3px 10px}
        .cbadge.ok  {background:#eaf3de;color:#27500a}
        .cbadge.bad {background:#fcebeb;color:#791f1f}
        .cbadge.warn{background:#faeeda;color:#633806}

        /* Surgeon filter */
        .surgeon-filter-box{background:#e6f1fb;border:1px solid #b5d4f4;border-radius:10px;padding:10px 14px;margin-top:8px;font-size:12px;color:#185fa5;display:none}
        .surgeon-filter-box.show{display:block}
        .surgeon-filter-box strong{color:#0c447c}
        .surgeon-count-badge{display:inline-block;font-size:11px;font-weight:600;border-radius:999px;padding:2px 9px;background:#185fa5;color:#fff;margin-left:6px}
        .no-surgeon-box{background:#fcebeb;border:1px solid #f7c1c1;border-radius:10px;padding:10px 14px;margin-top:8px;font-size:12px;color:#791f1f;display:none}
        .no-surgeon-box.show{display:block}

        /* OT Suggestion */
        .ot-suggestion{margin-top:8px;padding:10px 12px;background:#e6f1fb;border:1px solid #b5d4f4;border-radius:10px;font-size:12px;color:#185fa5}
        .suggest-list{display:flex;gap:6px;flex-wrap:wrap;margin-top:6px}
        .suggest-btn{font-size:11px;font-weight:600;padding:3px 12px;border-radius:999px;background:#185fa5;color:#fff;border:none;cursor:pointer;transition:background 0.15s}
        .suggest-btn:hover{background:#0c447c}

        /* Avail legend */
        .avail-legend{display:flex;gap:10px;flex-wrap:wrap;margin-top:6px}
        .avail-item{font-size:11px;display:flex;align-items:center;gap:4px}
        .avail-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}
        .avail-dot.green{background:#1a9e75}
        .avail-dot.red  {background:#c0392b}
        .avail-dot.gray {background:#9ca3af}

        /* Priority preview */
        .priority-preview{display:inline-flex;align-items:center;gap:6px;font-size:12px;font-weight:600;border-radius:999px;padding:4px 14px;margin-top:8px}
        .pp-critical{background:#fcebeb;color:#791f1f}
        .pp-high    {background:#faeeda;color:#633806}
        .pp-medium  {background:#fef9c3;color:#854d0e}
        .pp-low     {background:#eaf3de;color:#27500a}

        /* Time slot preview */
        .time-slot-preview{background:#f0f4f8;border:1px solid #c8d8e8;border-radius:10px;padding:10px 14px;margin-top:10px;font-size:12px;color:#5a7a90;display:none}
        .time-slot-preview.show{display:block}
        .time-slot-preview strong{color:#0a1628;font-size:13px}

        /* OT status hint */
        .ot-status-hint{font-size:11px;color:#5a7a90;margin-top:4px;display:flex;align-items:center;gap:5px}

        /* Duration hint */
        .duration-hint{font-size:11px;color:#1a9e75;margin-top:4px;font-weight:500;display:none}

        /* Spinner */
        .spinner{width:14px;height:14px;border:2px solid #d1d5db;border-top-color:#6b7280;border-radius:50%;animation:spin 0.7s linear infinite;display:inline-block}
        @keyframes spin{to{transform:rotate(360deg)}}

        .required-star{color:#c0392b}
        .form-hint{font-size:11px;color:#5a7a90;margin-top:3px}

        /* Step circles */
        .step-circle{width:22px;height:22px;border-radius:50%;background:#1a9e75;color:#fff;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">📅 Schedule Surgery</div>
                <div class="topbar-sub">Conflict-free scheduling with real-time validation</div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/surgeries" class="btn btn-secondary btn-sm">← Back</a>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${not empty error}">
                <div class="alert alert-error">⚠️ ${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/surgeries" method="POST" id="scheduleForm">
                <input type="hidden" name="action" value="schedule">

                <div style="display:grid;grid-template-columns:2fr 1fr;gap:20px;">

                    <!-- Left: Main Form -->
                    <div style="display:flex;flex-direction:column;gap:0;">

                        <!-- Surgery Details -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">🔪</span> Surgery Details</div>
                            </div>
                            <div class="card-body">
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Surgery Type <span class="required-star">*</span></label>
                                        <select name="surgeryType" id="surgeryTypeSelect" class="form-control" required onchange="onSurgeryTypeChange()">
                                            <option value="">-- Select Surgery Type --</option>
                                            <optgroup label="🫀 Cardiac">
                                                <option value="CABG Surgery"       data-duration="240" data-spec="Cardiac Surgery">CABG Surgery (240 min)</option>
                                                <option value="Valve Replacement"  data-duration="180" data-spec="Cardiac Surgery">Valve Replacement (180 min)</option>
                                                <option value="Heart Bypass"       data-duration="240" data-spec="Cardiac Surgery">Heart Bypass (240 min)</option>
                                                <option value="Pacemaker Implant"  data-duration="90"  data-spec="Cardiac Surgery">Pacemaker Implant (90 min)</option>
                                            </optgroup>
                                            <optgroup label="🧠 Neuro">
                                                <option value="Brain Tumor Resection" data-duration="300" data-spec="Neurosurgery">Brain Tumor Resection (300 min)</option>
                                                <option value="Spinal Decompression"  data-duration="120" data-spec="Neurosurgery">Spinal Decompression (120 min)</option>
                                                <option value="Craniotomy"            data-duration="180" data-spec="Neurosurgery">Craniotomy (180 min)</option>
                                                <option value="VP Shunt"              data-duration="90"  data-spec="Neurosurgery">VP Shunt (90 min)</option>
                                            </optgroup>
                                            <optgroup label="🦴 Orthopedic">
                                                <option value="Total Knee Replacement" data-duration="120" data-spec="Orthopedic Surgery">Total Knee Replacement (120 min)</option>
                                                <option value="Hip Replacement"        data-duration="150" data-spec="Orthopedic Surgery">Hip Replacement (150 min)</option>
                                                <option value="Fracture Fixation"      data-duration="90"  data-spec="Orthopedic Surgery">Fracture Fixation (90 min)</option>
                                                <option value="Spinal Fusion"          data-duration="180" data-spec="Orthopedic Surgery">Spinal Fusion (180 min)</option>
                                            </optgroup>
                                            <optgroup label="🏥 General">
                                                <option value="Appendectomy"    data-duration="60"  data-spec="General Surgery">Appendectomy (60 min)</option>
                                                <option value="Cholecystectomy" data-duration="90"  data-spec="General Surgery">Cholecystectomy (90 min)</option>
                                                <option value="Hernia Repair"   data-duration="75"  data-spec="General Surgery">Hernia Repair (75 min)</option>
                                                <option value="Bowel Resection" data-duration="150" data-spec="General Surgery">Bowel Resection (150 min)</option>
                                                <option value="Gastrectomy"     data-duration="180" data-spec="General Surgery">Gastrectomy (180 min)</option>
                                            </optgroup>
                                            <optgroup label="🔬 Laparoscopic">
                                                <option value="Laparoscopic Appendectomy"    data-duration="45" data-spec="Laparoscopic Surgery">Laparoscopic Appendectomy (45 min)</option>
                                                <option value="Laparoscopic Cholecystectomy" data-duration="60" data-spec="Laparoscopic Surgery">Laparoscopic Cholecystectomy (60 min)</option>
                                                <option value="Laparoscopic Hernia"          data-duration="60" data-spec="Laparoscopic Surgery">Laparoscopic Hernia (60 min)</option>
                                            </optgroup>
                                            <optgroup label="💧 Urology">
                                                <option value="Nephrectomy"   data-duration="150" data-spec="Urology">Nephrectomy (150 min)</option>
                                                <option value="Prostatectomy" data-duration="180" data-spec="Urology">Prostatectomy (180 min)</option>
                                                <option value="Cystectomy"    data-duration="150" data-spec="Urology">Cystectomy (150 min)</option>
                                                <option value="TURP"          data-duration="60"  data-spec="Urology">TURP (60 min)</option>
                                            </optgroup>
                                            <optgroup label="💎 Plastic">
                                                <option value="Skin Graft"          data-duration="90"  data-spec="Plastic & Reconstructive">Skin Graft (90 min)</option>
                                                <option value="Reconstructive Flap" data-duration="180" data-spec="Plastic & Reconstructive">Reconstructive Flap (180 min)</option>
                                                <option value="Burn Surgery"        data-duration="120" data-spec="Plastic & Reconstructive">Burn Surgery (120 min)</option>
                                            </optgroup>
                                            <optgroup label="👂 ENT">
                                                <option value="Tonsillectomy" data-duration="45"  data-spec="ENT Surgery">Tonsillectomy (45 min)</option>
                                                <option value="Septoplasty"   data-duration="60"  data-spec="ENT Surgery">Septoplasty (60 min)</option>
                                                <option value="Mastoidectomy" data-duration="120" data-spec="ENT Surgery">Mastoidectomy (120 min)</option>
                                            </optgroup>
                                            <optgroup label="🚨 Emergency">
                                                <option value="Emergency Laparotomy" data-duration="120" data-spec="General Surgery">Emergency Laparotomy (120 min)</option>
                                                <option value="Trauma Surgery"       data-duration="180" data-spec="General Surgery">Trauma Surgery (180 min)</option>
                                                <option value="Emergency C-Section"  data-duration="60"  data-spec="General Surgery">Emergency C-Section (60 min)</option>
                                            </optgroup>
                                        </select>
                                        <div class="duration-hint" id="durationHint"></div>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Surgery Category <span class="required-star">*</span></label>
                                        <select name="surgeryCategory" id="categorySelect" class="form-control" required onchange="updatePriorityPreview()">
                                            <option value="ELECTIVE">Elective (Planned)</option>
                                            <option value="URGENT">Urgent (Within 24–72 hrs)</option>
                                            <option value="EMERGENCY">Emergency (Immediate)</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group mt-4">
                                    <label class="form-label">Pre-Operative Notes</label>
                                    <textarea name="preOpNotes" class="form-control" placeholder="Special instructions, anaesthesia notes..."></textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Patient & Surgeon -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">👥</span> Patient & Surgeon Assignment</div>
                            </div>
                            <div class="card-body">
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Select Patient <span class="required-star">*</span></label>
                                        <select name="patientId" id="patientSelect" class="form-control" required onchange="updatePatientRisk();updatePriorityPreview();">
                                            <option value="">-- Select Patient --</option>
                                            <c:forEach var="p" items="${patients}">
                                                <option value="${p.id}" data-risk="${p.riskLevel}" data-score="${p.riskScore}">
                                                    ${p.patientId} — ${p.fullName} (${p.riskLevel} RISK)
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Assign Surgeon <span class="required-star">*</span></label>
                                        <select name="surgeonId" id="surgeonSelect" class="form-control" required onchange="checkConflict()">
                                            <option value="">-- Select Surgery Type First --</option>
                                            <c:forEach var="sr" items="${surgeons}">
                                                <option value="${sr.id}" data-spec="${sr.specialization}" data-name="${sr.fullName}" style="display:none;">
                                                    ${sr.fullName} — ${sr.specialization}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="surgeon-filter-box" id="surgeonFilterBox">
                                            🎯 Showing <strong id="specName">--</strong> specialists
                                            <span class="surgeon-count-badge" id="surgeonCountBadge">0</span>
                                            <div class="avail-legend" id="availLegend" style="display:none;">
                                                <span class="avail-item"><div class="avail-dot green"></div> Available now</span>
                                                <span class="avail-item"><div class="avail-dot red"></div> Busy at this time</span>
                                            </div>
                                        </div>
                                        <div class="no-surgeon-box" id="noSurgeonBox">
                                            ⚠️ No <strong id="noSurgeonSpec">--</strong> specialist available.
                                        </div>
                                    </div>
                                </div>
                                <div id="patientRiskBox" style="display:none;margin-top:14px;">
                                    <span id="patientRiskText"></span>
                                </div>
                            </div>
                        </div>

                        <!-- OT & Time Slot -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">🏨</span> OT & Time Slot</div>
                            </div>
                            <div class="card-body">
                                <div class="form-grid-3">
                                    <div class="form-group">
                                        <label class="form-label">Operation Theater <span class="required-star">*</span></label>
                                        <select name="otId" id="otSelect" class="form-control" required onchange="onOTChange();checkConflict();">
                                            <option value="">-- Select OT --</option>
                                            <c:forEach var="ot" items="${ots}">
                                                <option value="${ot.id}" data-status="${ot.status}">
                                                    ${ot.otNumber} — ${ot.otName}
                                                    <c:if test="${ot.status != 'AVAILABLE'}"> (${ot.status})</c:if>
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="ot-status-hint" id="otStatusHint" style="display:none;"></div>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Date <span class="required-star">*</span></label>
                                        <input type="date" name="scheduledDate" id="dateInput" class="form-control"
                                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                               required onchange="checkConflict();updateTimeSlotPreview();updateSurgeonAvailability();">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Start Time <span class="required-star">*</span></label>
                                        <input type="time" name="scheduledTime" id="timeInput" class="form-control"
                                               min="06:00" max="22:00"
                                               required onchange="checkConflict();updateTimeSlotPreview();updateSurgeonAvailability();">
                                    </div>
                                </div>
                                <div class="form-group mt-4" style="max-width:300px;">
                                    <label class="form-label">Estimated Duration (minutes) <span class="required-star">*</span></label>
                                    <input type="number" name="estimatedDuration" id="durationInput" class="form-control"
                                           min="30" max="600" step="15" placeholder="e.g. 90" value="90"
                                           required onchange="checkConflict();updateTimeSlotPreview();updateSurgeonAvailability();">
                                </div>
                                <div class="time-slot-preview" id="timeSlotPreview">
                                    ⏰ Scheduled: <strong id="previewStart">--</strong> → <strong id="previewEnd">--</strong>
                                    &nbsp;|&nbsp; Duration: <strong id="previewDuration">--</strong> min
                                </div>
                                <div class="conflict-box incomplete" id="conflictBox">
                                    <div class="conflict-icon">ℹ️</div>
                                    <div>
                                        <div class="conflict-title">Conflict Check</div>
                                        <div class="conflict-msg">Fill in OT, date, time, and duration to check for conflicts.</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="display:flex;justify-content:flex-end;gap:12px;margin-bottom:24px;">
                            <a href="${pageContext.request.contextPath}/surgeries" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary" id="submitBtn">📅 Schedule Surgery</button>
                        </div>
                    </div>

                    <!-- Right: Info Panel -->
                    <div style="display:flex;flex-direction:column;gap:0;">

                        <!-- Smart Flow Guide -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">💡</span> Smart Scheduling Flow</div>
                            </div>
                            <div class="card-body" style="font-size:12px;color:#5a7a90;">
                                <div style="display:flex;flex-direction:column;gap:10px;">
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="step-circle">1</div>
                                        <span><strong style="color:#0a1628;">Select Surgery Type</strong> → Duration auto-fills, surgeon list filters</span>
                                    </div>
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="step-circle">2</div>
                                        <span><strong style="color:#0a1628;">Select Patient</strong> → Risk level & priority preview shown</span>
                                    </div>
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="step-circle">3</div>
                                        <span><strong style="color:#0a1628;">Select Surgeon</strong> → Only matching specialists shown</span>
                                    </div>
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="step-circle">4</div>
                                        <span><strong style="color:#0a1628;">Set OT + Date + Time</strong> → Real-time conflict check runs</span>
                                    </div>
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="step-circle">5</div>
                                        <span><strong style="color:#0a1628;">Schedule</strong> → Only allowed if no conflicts ✅</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Priority Preview -->
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">🎯</span> Auto Priority</div>
                            </div>
                            <div class="card-body" style="font-size:13px;">
                                <div style="color:#5a7a90;margin-bottom:8px;">Priority is auto-assigned based on patient risk + surgery category:</div>
                                <div id="priorityPreview" style="margin-bottom:8px;">
                                    <span style="font-size:12px;color:#5a7a90;">Select patient & category to preview</span>
                                </div>
                                <div style="font-size:11px;color:#5a7a90;line-height:1.6;">
                                    🚨 EMERGENCY category → always <strong>CRITICAL</strong><br>
                                    🔴 HIGH/CRITICAL risk → <strong>HIGH</strong> or <strong>CRITICAL</strong><br>
                                    🟠 MEDIUM risk + URGENT → <strong>HIGH</strong><br>
                                    🟢 LOW risk + ELECTIVE → <strong>LOW</strong>
                                </div>
                            </div>
                        </div>

                        <!-- Scheduling Rules -->
                        <div class="card" style="position:sticky;top:20px;">
                            <div class="card-header">
                                <div class="card-title"><span class="icon">📋</span> Scheduling Rules</div>
                            </div>
                            <div class="card-body" style="font-size:12px;color:#5a7a90;">
                                <div style="display:flex;flex-direction:column;gap:10px;">
                                    <div><div style="color:#2a4060;font-weight:600;margin-bottom:2px;">⚡ Real-time Conflict Check</div>OT and surgeon availability checked instantly.</div>
                                    <div><div style="color:#2a4060;font-weight:600;margin-bottom:2px;">🔒 Double Booking Prevention</div>Cannot schedule if OT or surgeon is already booked.</div>
                                    <div><div style="color:#2a4060;font-weight:600;margin-bottom:2px;">💡 Smart OT Suggestion</div>If OT has conflict, alternatives are suggested.</div>
                                    <div><div style="color:#2a4060;font-weight:600;margin-bottom:2px;">🩺 Specialization Match</div>Only matching surgeons shown for selected surgery.</div>
                                    <div><div style="color:#2a4060;font-weight:600;margin-bottom:2px;">📋 Auto Reference</div>Surgery ref auto-generated (e.g. SRY-2026-001).</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
var BASE_URL         = '${pageContext.request.contextPath}';
var conflictTimer    = null;
var surgeonTimer     = null;
var lastConflictSafe = false;

var allSurgeons = [
    <c:forEach var="sr" items="${surgeons}" varStatus="loop">
    {id:${sr.id},name:'${sr.fullName.replace("'","\\'")}',spec:'${sr.specialization.replace("'","\\'")}',available:${sr.available}}${!loop.last?',':''}
    </c:forEach>
];

var allOTs = [
    <c:forEach var="ot" items="${ots}" varStatus="loop">
    {id:${ot.id},number:'${ot.otNumber}',name:'${ot.otName}',status:'${ot.status}'}${!loop.last?',':''}
    </c:forEach>
];

function onSurgeryTypeChange() {
    var sel=document.getElementById('surgeryTypeSelect');
    var opt=sel.options[sel.selectedIndex];
    var duration=opt.getAttribute('data-duration');
    var spec=opt.getAttribute('data-spec');
    var hint=document.getElementById('durationHint');
    if(duration){
        document.getElementById('durationInput').value=duration;
        hint.style.display='block';
        hint.textContent='⏱ Suggested duration: '+duration+' min (auto-filled)';
        updateTimeSlotPreview();checkConflict();updateSurgeonAvailability();
    } else { hint.style.display='none'; }
    if(spec) filterSurgeonsBySpec(spec);
    else resetSurgeonDropdown();
    updatePriorityPreview();
}

function filterSurgeonsBySpec(spec) {
    var sel=document.getElementById('surgeonSelect');
    var filterBox=document.getElementById('surgeonFilterBox');
    var noSurgBox=document.getElementById('noSurgeonBox');
    var specNameEl=document.getElementById('specName');
    var noSpecEl=document.getElementById('noSurgeonSpec');
    var countBadge=document.getElementById('surgeonCountBadge');
    sel.innerHTML='';
    var defOpt=document.createElement('option');defOpt.value='';defOpt.text='-- Select Surgeon --';sel.appendChild(defOpt);
    var matched=allSurgeons.filter(function(s){return s.spec.toLowerCase().indexOf(spec.toLowerCase())!==-1||spec.toLowerCase().indexOf(s.spec.toLowerCase())!==-1;});
    if(matched.length===0){filterBox.classList.remove('show');noSurgBox.classList.add('show');noSpecEl.textContent=spec;setSubmitState(false,'fill');return;}
    noSurgBox.classList.remove('show');filterBox.classList.add('show');specNameEl.textContent=spec;countBadge.textContent=matched.length;
    matched.forEach(function(s){
        var opt=document.createElement('option');opt.value=s.id;opt.setAttribute('data-spec',s.spec);
        if(s.available){opt.text='✅ '+s.name+' — '+s.spec;opt.style.color='#27500a';}
        else{opt.text='⭕ '+s.name+' — '+s.spec+' (Unavailable)';opt.style.color='#9ca3af';}
        sel.appendChild(opt);
    });
}

function resetSurgeonDropdown() {
    document.getElementById('surgeonSelect').innerHTML='<option value="">-- Select Surgery Type First --</option>';
    document.getElementById('surgeonFilterBox').classList.remove('show');
    document.getElementById('noSurgeonBox').classList.remove('show');
}

function updateSurgeonAvailability() {
    var date=document.getElementById('dateInput').value;
    var time=document.getElementById('timeInput').value;
    var duration=document.getElementById('durationInput').value;
    var spec=getCurrentSpec();
    if(!date||!time||!duration||!spec)return;
    document.getElementById('availLegend').style.display='flex';
    if(surgeonTimer)clearTimeout(surgeonTimer);
    surgeonTimer=setTimeout(function(){
        var url=BASE_URL+'/surgeonAvailability?date='+encodeURIComponent(date)+'&time='+encodeURIComponent(time)+'&duration='+encodeURIComponent(duration);
        fetch(url).then(function(r){return r.json();}).then(function(data){
            var sel=document.getElementById('surgeonSelect');
            var currentVal=sel.value;
            var countBadge=document.getElementById('surgeonCountBadge');
            var availMap={};data.forEach(function(s){availMap[s.id]=s;});
            var matched=allSurgeons.filter(function(s){return s.spec.toLowerCase().indexOf(spec.toLowerCase())!==-1||spec.toLowerCase().indexOf(s.spec.toLowerCase())!==-1;});
            sel.innerHTML='<option value="">-- Select Surgeon --</option>';
            var availCount=0;
            matched.forEach(function(s){
                var av=availMap[s.id];var opt=document.createElement('option');opt.value=s.id;opt.setAttribute('data-spec',s.spec);
                if(av&&av.available){opt.text='✅ '+s.name+' — '+s.spec;opt.style.color='#27500a';availCount++;}
                else if(av&&!av.available){opt.text='🔴 '+s.name+' — '+s.spec+(av.reason?' ('+av.reason+')':'');opt.style.color='#c0392b';}
                else{opt.text='⭕ '+s.name+' — '+s.spec;opt.style.color='#9ca3af';}
                sel.appendChild(opt);
            });
            countBadge.textContent=availCount+' free';sel.value=currentVal;
        }).catch(function(){});
    },600);
}

function getCurrentSpec(){var sel=document.getElementById('surgeryTypeSelect');var opt=sel.options[sel.selectedIndex];return opt?opt.getAttribute('data-spec'):null;}

function checkConflict() {
    var otId=document.getElementById('otSelect').value;
    var surgeonId=document.getElementById('surgeonSelect').value;
    var date=document.getElementById('dateInput').value;
    var time=document.getElementById('timeInput').value;
    var duration=document.getElementById('durationInput').value;
    if(!otId||!date||!time||!duration){setConflictBox('incomplete','ℹ️','Conflict Check','Fill in OT, date, time, and duration to check for conflicts.');setSubmitState(false,'fill');return;}
    setConflictBox('checking','spinner','Checking...','Verifying OT and surgeon availability...');setSubmitState(false,'checking');
    if(conflictTimer)clearTimeout(conflictTimer);
    conflictTimer=setTimeout(function(){
        var url=BASE_URL+'/checkConflict?otId='+encodeURIComponent(otId)+'&surgeonId='+encodeURIComponent(surgeonId)+'&date='+encodeURIComponent(date)+'&time='+encodeURIComponent(time)+'&duration='+encodeURIComponent(duration);
        fetch(url).then(function(r){return r.json();}).then(function(data){
            if(data.safe){
                var badges='<div class="conflict-badges"><span class="cbadge ok">✅ OT Available</span>'+(surgeonId?'<span class="cbadge ok">✅ Surgeon Available</span>':'')+'</div>';
                setConflictBox('safe','✅','No Conflicts Detected',data.message+badges);setSubmitState(true,'ok');lastConflictSafe=true;
            } else {
                var badges='<div class="conflict-badges">';
                if(data.otConflict)badges+='<span class="cbadge bad">🔴 OT Conflict</span>';else badges+='<span class="cbadge ok">✅ OT OK</span>';
                if(surgeonId){if(data.surgeonConflict)badges+='<span class="cbadge warn">🟠 Surgeon Conflict</span>';else badges+='<span class="cbadge ok">✅ Surgeon OK</span>';}
                badges+='</div>';
                var suggestion=data.otConflict?buildOTSuggestion(otId):'';
                var boxType=data.otConflict?'conflict':'warning';
                setConflictBox(boxType,'⚠️','Conflict Detected!',data.message+badges+suggestion);setSubmitState(false,'conflict');lastConflictSafe=false;
            }
        }).catch(function(){setConflictBox('checking','⚠️','Unable to check','Network error. Please verify manually.');setSubmitState(true,'ok');});
    },500);
}

function buildOTSuggestion(conflictedOtId){
    var available=allOTs.filter(function(ot){return String(ot.id)!==String(conflictedOtId)&&ot.status==='AVAILABLE';});
    if(available.length===0)return'';
    var html='<div class="ot-suggestion"><strong>💡 Available OTs at this time:</strong><div class="suggest-list">';
    available.slice(0,4).forEach(function(ot){html+='<button type="button" class="suggest-btn" onclick="selectOT('+ot.id+')">'+ot.number+' — '+ot.name+'</button>';});
    return html+'</div></div>';
}

function selectOT(otId){document.getElementById('otSelect').value=otId;onOTChange();checkConflict();}

function onOTChange(){
    var sel=document.getElementById('otSelect');var opt=sel.options[sel.selectedIndex];var hint=document.getElementById('otStatusHint');var status=opt?opt.getAttribute('data-status'):null;
    if(!sel.value){hint.style.display='none';return;}
    hint.style.display='flex';
    var map={AVAILABLE:'✅ <span style="color:#27500a">This OT is currently available</span>',OCCUPIED:'🔴 <span style="color:#791f1f">This OT is currently occupied</span>',STERILIZING:'🧹 <span style="color:#6c3483">This OT is being sterilized</span>',MAINTENANCE:'🔧 <span style="color:#633806">This OT is under maintenance</span>'};
    hint.innerHTML=map[status]||'';
}

function updateTimeSlotPreview(){
    var time=document.getElementById('timeInput').value;var duration=parseInt(document.getElementById('durationInput').value);var preview=document.getElementById('timeSlotPreview');
    if(!time||!duration){preview.classList.remove('show');return;}
    preview.classList.add('show');
    var parts=time.split(':');var startH=parseInt(parts[0]);var startM=parseInt(parts[1]);var totalM=startH*60+startM+duration;var endH=Math.floor(totalM/60)%24;var endM=totalM%60;
    var fmt=function(h,m){var p=h>=12?'PM':'AM';var h12=h%12||12;return(h12<10?'0':'')+h12+':'+(m<10?'0':'')+m+' '+p;};
    document.getElementById('previewStart').textContent=fmt(startH,startM);document.getElementById('previewEnd').textContent=fmt(endH,endM);document.getElementById('previewDuration').textContent=duration;
}

function updatePatientRisk(){
    var sel=document.getElementById('patientSelect');var opt=sel.options[sel.selectedIndex];var box=document.getElementById('patientRiskBox');var txt=document.getElementById('patientRiskText');
    if(!sel.value){box.style.display='none';return;}
    var risk=opt.getAttribute('data-risk');var score=parseFloat(opt.getAttribute('data-score')).toFixed(1);
    var colorMap={LOW:'alert alert-success',MEDIUM:'alert alert-warning',HIGH:'alert alert-error',CRITICAL:'alert alert-error'};
    box.className=colorMap[risk]||'alert alert-warning';box.style.display='block';
    var icons={LOW:'✅',MEDIUM:'⚠️',HIGH:'🔴',CRITICAL:'🚨'};
    txt.innerHTML=(icons[risk]||'⚠️')+' <strong>Patient Risk: '+risk+'</strong> (Score: '+score+'/100) — Priority will be auto-assigned.';
}

function updatePriorityPreview(){
    var sel=document.getElementById('patientSelect');var opt=sel.options[sel.selectedIndex];var category=document.getElementById('categorySelect').value;var preview=document.getElementById('priorityPreview');
    if(!sel.value){preview.innerHTML='<span style="font-size:12px;color:#5a7a90;">Select patient & category to preview</span>';return;}
    var risk=opt.getAttribute('data-risk');var priority=calcPriority(risk,category);
    var classMap={CRITICAL:'pp-critical',HIGH:'pp-high',MEDIUM:'pp-medium',LOW:'pp-low'};
    var iconMap={CRITICAL:'🚨',HIGH:'🔴',MEDIUM:'🟠',LOW:'🟢'};
    preview.innerHTML='<span class="priority-preview '+(classMap[priority]||'pp-medium')+'">'+(iconMap[priority]||'⚠️')+' '+priority+' Priority</span>';
}

function calcPriority(risk,category){
    if(category==='EMERGENCY')return'CRITICAL';if(risk==='CRITICAL')return'CRITICAL';
    if(risk==='HIGH'&&category==='URGENT')return'CRITICAL';if(risk==='HIGH')return'HIGH';
    if(risk==='MEDIUM'&&category==='URGENT')return'HIGH';if(risk==='MEDIUM')return'MEDIUM';
    return'LOW';
}

function setConflictBox(type,icon,title,msgHtml){
    var box=document.getElementById('conflictBox');box.className='conflict-box '+type;
    var iconHtml=icon==='spinner'?'<div class="spinner"></div>':'<div class="conflict-icon">'+icon+'</div>';
    box.innerHTML=iconHtml+'<div><div class="conflict-title">'+title+'</div><div class="conflict-msg">'+msgHtml+'</div></div>';
}

function setSubmitState(enabled,reason){
    var btn=document.getElementById('submitBtn');btn.disabled=!enabled;
    if(!enabled){if(reason==='conflict')btn.textContent='⚠️ Resolve Conflicts First';else if(reason==='checking')btn.textContent='⏳ Checking...';else btn.textContent='📅 Schedule Surgery';}
    else{btn.textContent='📅 Schedule Surgery';}
}

document.getElementById('scheduleForm').addEventListener('submit',function(e){
    var box=document.getElementById('conflictBox');
    if((box.classList.contains('conflict')||box.classList.contains('warning'))&&!lastConflictSafe){e.preventDefault();alert('⚠️ Please resolve conflicts before scheduling.');}
});
</script>
</body>
</html>