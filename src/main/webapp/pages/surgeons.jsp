<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("currentPage", "surgeons");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Surgeons — Smart Surgery System</title>
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
        .area{flex:1;overflow-y:auto;min-width:0}

        /* Topbar */
        .topbar{background:#0a3d2e;border-bottom:none;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
        .topbar-title{font-size:16px;font-weight:700;color:#fff}
        .topbar-sub{font-size:12px;color:rgba(255,255,255,0.6);margin-top:2px}
        .topbar-right{display:flex;align-items:center;gap:10px}

        /* Page body */
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
        .alert-warning{background:rgba(168,98,0,0.08);border-color:rgba(168,98,0,0.30);color:#a86200}

        /* Empty state */
        .empty-state{text-align:center;padding:60px 20px;color:#5a7a90}
        .empty-state .empty-icon{font-size:48px;margin-bottom:14px;opacity:0.4}
        .empty-state p{font-size:14px;margin-bottom:16px}

        /* Search/Filter bar */
        .search-filter-bar{padding:12px 16px 0;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .bar-left{display:flex;align-items:center;gap:8px}
        .bar-right{margin-left:auto;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .search-input-wrap{position:relative}
        .search-input-wrap .search-icon{position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:13px;pointer-events:none}
        .search-input-wrap input{padding:7px 12px 7px 30px;border-radius:999px;border:1px solid #c8d8e8;font-size:12px;color:#0a1628;background:#fff;outline:none;width:240px;font-family:'Space Grotesk',sans-serif}
        .search-input-wrap input:focus{border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.10)}
        .filter-btn{padding:6px 14px;border-radius:999px;border:1px solid #c8d8e8;background:transparent;font-size:12px;font-weight:600;cursor:pointer;transition:all 0.18s;color:#5a7a90;font-family:'Space Grotesk',sans-serif}
        .filter-btn.active-all        {background:#007a63;color:#fff;border-color:#007a63}
        .filter-btn.active-available  {background:#eaf3de;color:#27500a;border-color:#27500a}
        .filter-btn.active-unavailable{background:#fcebeb;color:#791f1f;border-color:#791f1f}

        /* Surgeon Grid */
        .surgeons-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;padding:16px}
        .surgeon-card{background:#fff;border:1px solid #c8d8e8;border-radius:16px;padding:12px;display:flex;flex-direction:column;gap:8px;transition:box-shadow 0.2s,transform 0.2s;cursor:pointer}
        .surgeon-card:hover{box-shadow:0 8px 24px rgba(0,0,0,0.10);transform:translateY(-4px) scale(1.01)}
        .sc-top{display:flex;align-items:center;gap:12px}
        .sc-avatar{width:40px;height:40px;border-radius:50%;background:#e6f1fb;color:#185fa5;display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:600;flex-shrink:0}
        .sc-id  {font-size:10px;color:#007a63;font-weight:500}
        .sc-name{font-size:15px;font-weight:600;color:#0a1628;margin-top:1px}
        .sc-spec{font-size:12px;color:#185fa5;margin-top:1px}
        .avail-badge{margin-left:auto;font-size:10px;font-weight:600;border-radius:999px;padding:3px 10px;white-space:nowrap;cursor:pointer;text-decoration:none;display:inline-block}
        .av-yes{background:#eaf3de;color:#27500a}
        .av-no {background:#fcebeb;color:#791f1f}
        .sc-divider{height:1px;background:#c8d8e8}
        .sc-mid{display:flex;flex-direction:column;gap:5px}
        .info-row{display:flex;align-items:center;gap:6px;font-size:12px;color:#5a7a90}
        .info-row span{color:#0a1628;font-weight:500}
        .sc-bottom{display:flex;border-top:1px solid #c8d8e8;padding-top:8px}
        .stat-cell{flex:1;display:flex;flex-direction:column;gap:4px;padding:0 10px;border-right:1px solid #c8d8e8;align-items:center}
        .stat-cell:first-child{padding-left:0;align-items:flex-start}
        .stat-cell:last-child{border-right:none}
        .stat-label{font-size:10px;color:#5a7a90;text-transform:uppercase;letter-spacing:0.4px}
        .stat-value{font-size:13px;font-weight:600;color:#0a1628}
        .stat-value.teal{color:#007a63}
        .exp-badge{font-size:11px;font-weight:600;border-radius:999px;padding:3px 10px}
        .exp-high{background:#eaf3de;color:#27500a}
        .exp-mid {background:#faeeda;color:#633806}
        .exp-low {background:#e6f1fb;color:#185fa5}
        .sc-actions{display:flex;justify-content:flex-end;gap:6px;margin-top:auto}
        .act-btn{width:28px;height:28px;border-radius:50%;border:1px solid #c8d8e8;background:#f0f4f8;display:flex;align-items:center;justify-content:center;font-size:12px;cursor:pointer;transition:background 0.15s;text-decoration:none}
        .act-btn:hover{background:#c8d8e8}

        /* No results */
        .no-results{display:none;flex-direction:column;align-items:center;justify-content:center;padding:48px 16px;color:#5a7a90;font-size:14px;gap:8px}

        /* Overlay */
        .overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:999;align-items:center;justify-content:center}
        .overlay.open{display:flex}
        .popup-box{background:#fff;border-radius:24px;padding:28px;width:420px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,0.2);position:relative;animation:popIn 0.2s ease}
        .modal-box{background:#fff;border-radius:24px;padding:28px;width:480px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,0.2);position:relative;animation:popIn 0.2s ease;max-height:90vh;overflow-y:auto}
        @keyframes popIn{from{transform:scale(0.9);opacity:0}to{transform:scale(1);opacity:1}}
        .box-close{position:absolute;top:16px;right:16px;width:30px;height:30px;border-radius:50%;border:1px solid #c8d8e8;background:#f0f4f8;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:14px}
        .box-close:hover{background:#c8d8e8}
        .box-title{font-size:17px;font-weight:600;color:#0a1628;margin-bottom:20px}

        /* Popup detail */
        .popup-avatar{width:64px;height:64px;border-radius:50%;background:#e6f1fb;color:#185fa5;display:flex;align-items:center;justify-content:center;font-size:22px;font-weight:600;margin-bottom:12px}
        .popup-name{font-size:18px;font-weight:600;color:#0a1628}
        .popup-spec{font-size:13px;color:#185fa5;margin-top:3px}
        .popup-id  {font-size:11px;color:#007a63;margin-top:2px}
        .popup-divider{height:1px;background:#c8d8e8;margin:16px 0}
        .popup-row{display:flex;align-items:center;gap:8px;font-size:13px;color:#5a7a90;margin-bottom:10px}
        .popup-row strong{color:#0a1628}
        .popup-stats{display:flex;border:1px solid #c8d8e8;border-radius:12px;overflow:hidden;margin-top:16px}
        .popup-stat{flex:1;padding:12px;text-align:center;border-right:1px solid #c8d8e8}
        .popup-stat:last-child{border-right:none}
        .popup-stat-label{font-size:10px;color:#5a7a90;text-transform:uppercase;letter-spacing:0.4px}
        .popup-stat-value{font-size:16px;font-weight:600;color:#0a1628;margin-top:4px}

        /* Form modal */
        .form-group{margin-bottom:14px}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#5a7a90;margin-bottom:5px}
        .form-group input,.form-group select{width:100%;padding:8px 12px;border-radius:10px;border:1px solid #c8d8e8;font-size:13px;color:#0a1628;background:#fff;outline:none;box-sizing:border-box;font-family:'Space Grotesk',sans-serif}
        .form-group input:focus,.form-group select:focus{border-color:#007a63}
        .auto-id-wrap{position:relative}
        .auto-id-wrap input{background:#f0f4f8;color:#007a63;font-weight:600;cursor:default}
        .auto-id-badge{position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:10px;background:#eaf3de;color:#27500a;border-radius:999px;padding:2px 8px;font-weight:600;pointer-events:none}
        .select-wrap{position:relative}
        .select-wrap::after{content:'▾';position:absolute;right:12px;top:50%;transform:translateY(-50%);font-size:12px;color:#5a7a90;pointer-events:none}
        .select-wrap select{padding-right:28px;appearance:none;-webkit-appearance:none}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
        .btn-submit{width:100%;padding:10px;border-radius:999px;background:#007a63;color:#fff;border:none;font-size:14px;font-weight:500;cursor:pointer;margin-top:6px;font-family:'Space Grotesk',sans-serif}
        .btn-submit:hover{background:#005f4d}
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">👨‍⚕️ Surgical Team</div>
                <div class="topbar-sub">Khwaja Yunus Ali Medical College Hospital</div>
            </div>
            <div class="topbar-right">
                <button class="btn btn-primary btn-sm" onclick="openAddModal()">➕ Add Surgeon</button>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${param.msg == 'added'}">
                <div class="alert alert-success">✅ Surgeon added successfully!</div>
            </c:if>
            <c:if test="${param.msg == 'updated'}">
                <div class="alert alert-success">✅ Surgeon updated successfully!</div>
            </c:if>
            <c:if test="${param.msg == 'deleted'}">
                <div class="alert alert-warning">🗑️ Surgeon deleted.</div>
            </c:if>

            <div class="search-filter-bar">
                <div class="bar-left">
                    <span>👨‍⚕️</span>
                    <span style="font-weight:600;">KYAMCH Surgeons</span>
                    <span style="font-size:12px;color:#5a7a90;" id="surgeonCount">(${surgeons.size()} total)</span>
                </div>
                <div class="bar-right">
                    <div class="search-input-wrap">
                        <span class="search-icon">🔍</span>
                        <input type="text" id="surgeonSearch" placeholder="Search name or specialization..." oninput="filterSurgeons()">
                    </div>
                    <button id="filterAll" class="filter-btn active-all" onclick="setFilter('all')">All</button>
                    <button id="filterAvailable" class="filter-btn" onclick="setFilter('available')">✅ Available</button>
                    <button id="filterUnavailable" class="filter-btn" onclick="setFilter('unavailable')">🔴 Unavailable</button>
                </div>
            </div>

            <c:if test="${empty surgeons}">
                <div class="empty-state">
                    <div class="empty-icon">👨‍⚕️</div>
                    <p>No surgeons found</p>
                    <button class="btn btn-primary btn-sm" onclick="openAddModal()">Add First Surgeon</button>
                </div>
            </c:if>

            <c:if test="${not empty surgeons}">
                <span id="totalSurgeonCount" style="display:none">${surgeons.size()}</span>
                <div class="surgeons-grid" id="surgeonsGrid">
                    <c:forEach var="s" items="${surgeons}">
                        <div class="surgeon-card"
                             data-name="${s.fullName}"
                             data-spec="${s.specialization}"
                             data-available="${s.available}"
                             onclick="openPopup('${s.initials}','${s.fullName}','${s.specialization}','${s.specializationIcon}','${s.surgeonId}','${s.qualification}','${s.contactNumber}','${s.email}','${s.experienceYears}','${s.maxSurgeriesPerDay}','${s.available}')">
                            <div class="sc-top">
                                <div class="sc-avatar">${s.initials}</div>
                                <div>
                                    <div class="sc-id">${s.surgeonId}</div>
                                    <div class="sc-name">${s.fullName}</div>
                                    <div class="sc-spec">${s.specializationIcon} ${s.specialization}</div>
                                </div>
                                <a href="${pageContext.request.contextPath}/surgeons?action=toggle&id=${s.id}"
                                   class="avail-badge ${s.available ? 'av-yes' : 'av-no'}"
                                   onclick="event.stopPropagation()" title="Click to toggle">
                                    ${s.available ? '✅ Available' : '🔴 Unavailable'}
                                </a>
                            </div>
                            <div class="sc-divider"></div>
                            <div class="sc-mid">
                                <div class="info-row">🎓 <span>${s.qualification}</span></div>
                                <div class="info-row">📞 <span>${s.contactNumber}</span></div>
                                <c:if test="${not empty s.email}">
                                    <div class="info-row">📧 <span>${s.email}</span></div>
                                </c:if>
                            </div>
                            <div class="sc-bottom">
                                <div class="stat-cell">
                                    <div class="stat-label">Experience</div>
                                    <span class="exp-badge ${s.experienceYears >= 20 ? 'exp-high' : s.experienceYears >= 10 ? 'exp-mid' : 'exp-low'}">${s.experienceYears} YRS</span>
                                </div>
                                <div class="stat-cell">
                                    <div class="stat-label">Max/Day</div>
                                    <div class="stat-value teal">${s.maxSurgeriesPerDay}/day</div>
                                </div>
                            </div>
                            <div class="sc-actions" onclick="event.stopPropagation()">
                                <button class="act-btn" title="Edit"
                                    onclick="openEditModal('${s.id}','${s.surgeonId}','${s.fullName}','${s.specialization}','${s.qualification}','${s.experienceYears}','${s.contactNumber}','${s.email}','${s.maxSurgeriesPerDay}')">✏️</button>
                                <a href="${pageContext.request.contextPath}/surgeons?action=delete&id=${s.id}"
                                   class="act-btn" title="Delete"
                                   onclick="return confirm('Delete ${s.fullName}?')">🗑️</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="no-results" id="noResults">
                    <div style="font-size:40px;">🔍</div>
                    <div style="font-weight:600;color:#0a1628;">No surgeons found</div>
                    <div>Try a different name, specialization, or filter.</div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Detail Popup -->
<div class="overlay" id="popupOverlay" onclick="closeOnBg(event,'popupOverlay')">
    <div class="popup-box">
        <div class="box-close" onclick="closeOverlay('popupOverlay')">✕</div>
        <div class="popup-avatar" id="popAvatar"></div>
        <div class="popup-name"   id="popName"></div>
        <div class="popup-spec"   id="popSpec"></div>
        <div class="popup-id"     id="popId"></div>
        <div class="popup-divider"></div>
        <div class="popup-row">🎓 &nbsp;<strong id="popQual"></strong></div>
        <div class="popup-row">📞 &nbsp;<strong id="popContact"></strong></div>
        <div class="popup-row">📧 &nbsp;<strong id="popEmail"></strong></div>
        <div class="popup-row" id="popAvailRow"></div>
        <div class="popup-stats">
            <div class="popup-stat"><div class="popup-stat-label">Experience</div><div class="popup-stat-value" id="popExp"></div></div>
            <div class="popup-stat"><div class="popup-stat-label">Max/Day</div><div class="popup-stat-value" id="popMax"></div></div>
        </div>
    </div>
</div>

<!-- Add/Edit Modal -->
<div class="overlay" id="modalOverlay" onclick="closeOnBg(event,'modalOverlay')">
    <div class="modal-box">
        <div class="box-close" onclick="closeOverlay('modalOverlay')">✕</div>
        <div class="box-title" id="modalTitle">➕ Add Surgeon</div>
        <form method="post" action="${pageContext.request.contextPath}/surgeons">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="form-row">
                <div class="form-group">
                    <label>Surgeon ID *</label>
                    <div class="auto-id-wrap">
                        <input type="text" name="surgeonId" id="fSurgeonId" readonly required>
                        <span class="auto-id-badge" id="autoIdBadge">Auto</span>
                    </div>
                </div>
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" id="fFullName" placeholder="Dr. John Doe" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Specialization *</label>
                    <div class="select-wrap">
                        <select name="specialization" id="fSpec" required>
                            <option value="" disabled selected>Select specialization</option>
                            <option value="Cardiac Surgery">❤️ Cardiac Surgery</option>
                            <option value="Orthopedic Surgery">🦴 Orthopedic Surgery</option>
                            <option value="Neurosurgery">🧠 Neurosurgery</option>
                            <option value="General Surgery">🏥 General Surgery</option>
                            <option value="Plastic & Reconstructive">💎 Plastic &amp; Reconstructive</option>
                            <option value="Urology">💧 Urology</option>
                            <option value="ENT Surgery">👂 ENT Surgery</option>
                            <option value="Laparoscopic Surgery">🔬 Laparoscopic Surgery</option>
                            <option value="Vascular Surgery">🩸 Vascular Surgery</option>
                            <option value="Thoracic Surgery">🫁 Thoracic Surgery</option>
                            <option value="Pediatric Surgery">👶 Pediatric Surgery</option>
                            <option value="Ophthalmology">👁️ Ophthalmology</option>
                            <option value="Oncology Surgery">🎗️ Oncology Surgery</option>
                            <option value="Hepatobiliary Surgery">🫀 Hepatobiliary Surgery</option>
                            <option value="Colorectal Surgery">🔹 Colorectal Surgery</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Qualification *</label>
                    <div class="select-wrap">
                        <select name="qualification" id="fQual" required>
                            <option value="" disabled selected>Select qualification</option>
                            <option value="MBBS">MBBS</option>
                            <option value="MBBS, MS">MBBS, MS</option>
                            <option value="MBBS, MS (Cardiac)">MBBS, MS (Cardiac)</option>
                            <option value="MBBS, MS (Ortho)">MBBS, MS (Ortho)</option>
                            <option value="MBBS, MS (Ortho), FCPS">MBBS, MS (Ortho), FCPS</option>
                            <option value="MBBS, MS (Neuro)">MBBS, MS (Neuro)</option>
                            <option value="MBBS, MS (Urology)">MBBS, MS (Urology)</option>
                            <option value="MBBS, MS (ENT)">MBBS, MS (ENT)</option>
                            <option value="MBBS, MS (Laparoscopy)">MBBS, MS (Laparoscopy)</option>
                            <option value="MBBS, MS (Plastic Surgery)">MBBS, MS (Plastic Surgery)</option>
                            <option value="MBBS, MS (Vascular)">MBBS, MS (Vascular)</option>
                            <option value="MBBS, MS (Thoracic)">MBBS, MS (Thoracic)</option>
                            <option value="MBBS, MCh">MBBS, MCh</option>
                            <option value="MBBS, MS, MCh">MBBS, MS, MCh</option>
                            <option value="MBBS, MS, MCh (Cardiac)">MBBS, MS, MCh (Cardiac)</option>
                            <option value="MBBS, FCPS">MBBS, FCPS</option>
                            <option value="MBBS, MS, FCPS">MBBS, MS, FCPS</option>
                            <option value="MBBS, PhD">MBBS, PhD</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Experience (Years) *</label>
                    <input type="number" name="experienceYears" id="fExp" min="0" max="50" placeholder="10" required>
                </div>
                <div class="form-group">
                    <label>Max Surgeries/Day *</label>
                    <input type="number" name="maxSurgeriesPerDay" id="fMax" min="1" max="10" placeholder="3" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="text" name="contactNumber" id="fContact" placeholder="01711-000000">
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="fEmail" placeholder="doctor@hospital.com">
                </div>
            </div>
            <button type="submit" class="btn-submit" id="submitBtn">➕ Add Surgeon</button>
        </form>
    </div>
</div>

<script>
let currentFilter='all';

function filterSurgeons(){
    const query=document.getElementById('surgeonSearch').value.toLowerCase().trim();
    const cards=document.querySelectorAll('#surgeonsGrid .surgeon-card');
    let visibleCount=0;
    cards.forEach(function(card){
        const name=(card.dataset.name||'').toLowerCase();
        const spec=(card.dataset.spec||'').toLowerCase();
        const available=card.dataset.available==='true';
        const matchSearch=!query||name.includes(query)||spec.includes(query);
        const matchFilter=currentFilter==='all'||(currentFilter==='available'&&available)||(currentFilter==='unavailable'&&!available);
        if(matchSearch&&matchFilter){card.style.display='';visibleCount++;}
        else{card.style.display='none';}
    });
    document.getElementById('surgeonCount').textContent='('+visibleCount+' total)';
    const noResults=document.getElementById('noResults');
    const grid=document.getElementById('surgeonsGrid');
    if(noResults&&grid){
        if(visibleCount===0){grid.style.display='none';noResults.style.display='flex';}
        else{grid.style.display='';noResults.style.display='none';}
    }
}

function setFilter(type){
    currentFilter=type;
    document.getElementById('filterAll').className='filter-btn';
    document.getElementById('filterAvailable').className='filter-btn';
    document.getElementById('filterUnavailable').className='filter-btn';
    if(type==='all')         document.getElementById('filterAll').className='filter-btn active-all';
    if(type==='available')   document.getElementById('filterAvailable').className='filter-btn active-available';
    if(type==='unavailable') document.getElementById('filterUnavailable').className='filter-btn active-unavailable';
    filterSurgeons();
}

function generateNextId(){
    var countEl=document.getElementById('totalSurgeonCount');
    var total=countEl?parseInt(countEl.textContent):0;
    var next=total+1;
    var padded=next<10?'0'+next:''+next;
    return'KYAMCH-SRG'+padded;
}

function openPopup(initials,name,spec,icon,id,qual,contact,email,exp,maxDay,available){
    document.getElementById('popAvatar').textContent =initials;
    document.getElementById('popName').textContent   =name;
    document.getElementById('popSpec').textContent   =icon+' '+spec;
    document.getElementById('popId').textContent     =id;
    document.getElementById('popQual').textContent   =qual;
    document.getElementById('popContact').textContent=contact;
    document.getElementById('popEmail').textContent  =email||'N/A';
    document.getElementById('popExp').textContent    =exp+' yrs';
    document.getElementById('popMax').textContent    =maxDay+'/day';
    document.getElementById('popAvailRow').innerHTML =available==='true'?'✅ &nbsp;<strong style="color:#27500a;">Available</strong>':'🔴 &nbsp;<strong style="color:#791f1f;">Unavailable</strong>';
    document.getElementById('popupOverlay').classList.add('open');
}

function openAddModal(){
    document.getElementById('modalTitle').textContent='➕ Add Surgeon';
    document.getElementById('formAction').value='add';
    document.getElementById('formId').value='';
    document.getElementById('fSurgeonId').value=generateNextId();
    document.getElementById('fSurgeonId').readOnly=true;
    document.getElementById('autoIdBadge').style.display='';
    document.getElementById('fFullName').value='';
    document.getElementById('fSpec').value='';
    document.getElementById('fQual').value='';
    document.getElementById('fExp').value='';
    document.getElementById('fMax').value='';
    document.getElementById('fContact').value='';
    document.getElementById('fEmail').value='';
    document.getElementById('submitBtn').textContent='➕ Add Surgeon';
    document.getElementById('modalOverlay').classList.add('open');
}

function openEditModal(id,surgeonId,fullName,spec,qual,exp,contact,email,maxDay){
    document.getElementById('modalTitle').textContent='✏️ Edit Surgeon';
    document.getElementById('formAction').value='edit';
    document.getElementById('formId').value=id;
    document.getElementById('fSurgeonId').value=surgeonId;
    document.getElementById('fSurgeonId').readOnly=true;
    document.getElementById('autoIdBadge').style.display='none';
    document.getElementById('fFullName').value=fullName;
    document.getElementById('fSpec').value=spec;
    document.getElementById('fQual').value=qual;
    document.getElementById('fExp').value=exp;
    document.getElementById('fMax').value=maxDay;
    document.getElementById('fContact').value=contact;
    document.getElementById('fEmail').value=email;
    document.getElementById('submitBtn').textContent='✅ Save Changes';
    document.getElementById('modalOverlay').classList.add('open');
}

function closeOverlay(id){document.getElementById(id).classList.remove('open');}
function closeOnBg(e,id){if(e.target===document.getElementById(id))closeOverlay(id);}
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeOverlay('popupOverlay');closeOverlay('modalOverlay');}});

<c:if test="${not empty editSurgeon}">
window.onload=function(){
    openEditModal('${editSurgeon.id}','${editSurgeon.surgeonId}','${editSurgeon.fullName}','${editSurgeon.specialization}','${editSurgeon.qualification}','${editSurgeon.experienceYears}','${editSurgeon.contactNumber}','${editSurgeon.email}','${editSurgeon.maxSurgeriesPerDay}');
};
</c:if>
</script>
</body>
</html>