<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    if (fullName == null) fullName = "User";
    if (role == null) role = "Staff";
    String[] np = fullName.trim().split(" ");
    String initials = np.length >= 2
        ? ("" + np[0].charAt(0) + np[1].charAt(0)).toUpperCase()
        : fullName.substring(0, Math.min(2, fullName.length())).toUpperCase();
%>
<style>
.sb{width:220px;flex-shrink:0;background:linear-gradient(160deg,#0a3d2e 0%,#0d5c3a 55%,#0a4a2e 100%);display:flex;flex-direction:column;position:relative;overflow:hidden;transition:width 0.28s cubic-bezier(0.4,0,0.2,1);z-index:50;border-right:1px solid rgba(52,211,153,0.1)}
.sb.col{width:62px}
.sb::before{content:'';position:absolute;inset:0;background-image:radial-gradient(rgba(52,211,153,0.1) 1px,transparent 1px);background-size:22px 22px;pointer-events:none;z-index:0}
.sb::after{content:'';position:absolute;top:-50px;right:-50px;width:160px;height:160px;border-radius:50%;background:rgba(52,211,153,0.09);pointer-events:none;z-index:0}
.sb-tog{position:absolute;right:-10px;top:28px;width:20px;height:20px;background:#fff;border:1px solid #c8e0d0;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;z-index:999;box-shadow:0 2px 6px rgba(0,0,0,0.13)}
.sb-tog svg{width:9px;height:9px;stroke:#059669;fill:none;stroke-width:2.5;transition:transform 0.28s}
.sb.col .sb-tog svg{transform:rotate(180deg)}
.sb-logo{padding:20px 14px 18px;border-bottom:1px solid rgba(52,211,153,0.12);display:flex;flex-direction:column;align-items:flex-start;position:relative;z-index:1;overflow:hidden;flex-shrink:0}
.sb-ico{width:48px;height:48px;background:linear-gradient(135deg,#1a6b4a,#2d9e6b);border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0;box-shadow:0 4px 16px rgba(0,0,0,0.25);font-size:22px;margin-bottom:12px;position:relative;z-index:1}
.sb-ico::after{content:'';position:absolute;inset:0;border-radius:14px;background:linear-gradient(135deg,rgba(255,255,255,0.15),transparent);pointer-events:none}
.sb-brand{overflow:hidden;transition:opacity 0.2s,max-height 0.28s;max-height:60px}
.sb-brand .sb-n{font-size:13px;font-weight:800;color:#fff;letter-spacing:0.02em;line-height:1.25;text-transform:uppercase;white-space:normal}
.sb-brand .sb-s{font-size:10px;color:rgba(255,255,255,0.45);margin-top:4px;font-weight:400}
.sb.col .sb-logo{padding:14px 7px 12px;align-items:center}
.sb.col .sb-ico{width:38px;height:38px;font-size:18px;margin-bottom:0}
.sb.col .sb-brand{opacity:0;max-height:0;pointer-events:none}
.sb-nav{flex:1;overflow-y:auto;overflow-x:hidden;position:relative;z-index:1;padding-bottom:8px}
.sb-nav::-webkit-scrollbar{width:3px}
.sb-nav::-webkit-scrollbar-thumb{background:rgba(52,211,153,0.2);border-radius:4px}
.sb-sec{padding:13px 14px 4px;font-size:8.5px;font-weight:700;color:rgba(255,255,255,0.2);text-transform:uppercase;letter-spacing:0.13em;white-space:nowrap;overflow:hidden;transition:opacity 0.2s}
.sb.col .sb-sec{opacity:0}
.sb-item{display:flex;align-items:center;gap:10px;padding:10px 13px;margin:2px 7px;border-radius:10px;font-size:12px;color:rgba(255,255,255,0.42);font-weight:500;cursor:pointer;transition:all 0.15s;position:relative;text-decoration:none;white-space:nowrap;overflow:hidden;border:1px solid transparent}
.sb-item:hover{background:rgba(255,255,255,0.07);color:rgba(255,255,255,0.78)}
.sb-item.on{background:rgba(52,211,153,0.16);color:#6ee7b7;border-color:rgba(52,211,153,0.25)}
.sb-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;flex-shrink:0}
.sb-txt{transition:opacity 0.2s,max-width 0.28s;max-width:140px;overflow:hidden}
.sb.col .sb-txt{opacity:0;max-width:0}
.sb-dot{width:5px;height:5px;border-radius:50%;background:#34d399;margin-left:auto;animation:sbbl 2s infinite;flex-shrink:0;transition:opacity 0.2s}
.sb.col .sb-dot{opacity:0}
@keyframes sbbl{0%,100%{opacity:1}50%{opacity:0.2}}
.sb-tip{position:fixed;left:72px;background:#163d28;color:#fff;font-size:11px;font-weight:600;padding:5px 10px;border-radius:7px;white-space:nowrap;pointer-events:none;opacity:0;transition:opacity 0.15s;border:1px solid rgba(52,211,153,0.2);box-shadow:0 4px 14px rgba(0,0,0,0.2);z-index:9999}
.sb.col .sb-item:hover .sb-tip{opacity:1}
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
</style>

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
        <a href="${pageContext.request.contextPath}/dashboard" class="sb-item <%= "dashboard".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
            <span class="sb-txt">Dashboard</span>
            <% if("dashboard".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">Dashboard</span>
        </a>

        <div class="sb-sec">Management</div>
        <a href="${pageContext.request.contextPath}/patients" class="sb-item <%= "patients".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            <span class="sb-txt">Patients</span>
            <% if("patients".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">Patients</span>
        </a>
        <a href="${pageContext.request.contextPath}/surgeries" class="sb-item <%= "surgeries".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
            <span class="sb-txt">Surgeries</span>
            <% if("surgeries".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">Surgeries</span>
        </a>
        <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="sb-item <%= "schedule".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            <span class="sb-txt">Schedule Surgery</span>
            <% if("schedule".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">Schedule Surgery</span>
        </a>

        <div class="sb-sec">Resources</div>
        <a href="${pageContext.request.contextPath}/surgeons" class="sb-item <%= "surgeons".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M20 7H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><path d="M16 3H8l-2 4h12z"/></svg>
            <span class="sb-txt">Surgeons</span>
            <% if("surgeons".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">Surgeons</span>
        </a>
        <a href="${pageContext.request.contextPath}/ot" class="sb-item <%= "ot".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            <span class="sb-txt">Operation Theaters</span>
            <% if("ot".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">OT Rooms</span>
        </a>

        <div class="sb-div"></div>
        <div class="sb-sec">Account</div>
        <a href="${pageContext.request.contextPath}/settings" class="sb-item <%= "settings".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            <span class="sb-txt">Settings</span>
            <span class="sb-tip">Settings</span>
        </a>
        <a href="${pageContext.request.contextPath}/about" class="sb-item <%= "about".equals(currentPage) ? "on" : "" %>">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span class="sb-txt">About</span>
            <% if("about".equals(currentPage)){%><span class="sb-dot"></span><%}%>
            <span class="sb-tip">About</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sb-item">
            <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            <span class="sb-txt">Logout</span>
            <span class="sb-tip">Logout</span>
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
