<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("currentPage", "settings");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    com.surgery.model.User currentUser = (com.surgery.model.User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settings — Smart Surgery System</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>

/* ══════════════════════════════════════════
   CSS VARIABLES — LIGHT / DARK
══════════════════════════════════════════ */
:root {
  --bg-base:        #f0f4f8;
  --bg-surface:     #ffffff;
  --bg-raised:      #fafcff;
  --bg-hover:       #f0f6fc;
  --bg-input:       #fafcff;
  --bg-tab:         #e8eef6;
  --bg-tab-active:  #ffffff;
  --bg-header:      #f5f9ff;
  --bg-overlay:     rgba(0,0,0,.45);

  --border:         #c8d8e8;
  --border-focus:   #007a63;

  --text-primary:   #0a1628;
  --text-secondary: #2a4060;
  --text-muted:     #5a7a90;
  --text-faint:     #7a9ab0;

  --accent:         #007a63;
  --accent-dark:    #005f4d;
  --accent-glow:    rgba(0,122,99,.15);
  --accent-blue:    #1560a8;
  --accent-red:     #a80028;

  --shadow-sm:      0 2px 8px rgba(0,0,0,.06);
  --shadow-md:      0 6px 24px rgba(0,0,0,.10);
  --shadow-lg:      0 24px 60px rgba(0,0,0,.14);
  --shadow-btn:     0 6px 20px rgba(0,122,99,.28);

  --radius-sm:      8px;
  --radius-md:      12px;
  --radius-lg:      16px;
  --radius-xl:      20px;

  --transition:     all .2s ease;
}

[data-theme="dark"] {
  --bg-base:        #0d1117;
  --bg-surface:     #161b22;
  --bg-raised:      #1c2330;
  --bg-hover:       #1f2937;
  --bg-input:       #1c2330;
  --bg-tab:         #161b22;
  --bg-tab-active:  #1c2330;
  --bg-header:      #161b22;
  --bg-overlay:     rgba(0,0,0,.65);

  --border:         #2d3748;
  --border-focus:   #00c49a;

  --text-primary:   #e6edf3;
  --text-secondary: #b0c4d8;
  --text-muted:     #6e8ca8;
  --text-faint:     #4a6880;

  --accent:         #00c49a;
  --accent-dark:    #00a882;
  --accent-glow:    rgba(0,196,154,.15);
  --accent-blue:    #4d9de0;
  --accent-red:     #f85149;

  --shadow-sm:      0 2px 8px rgba(0,0,0,.3);
  --shadow-md:      0 6px 24px rgba(0,0,0,.4);
  --shadow-lg:      0 24px 60px rgba(0,0,0,.5);
  --shadow-btn:     0 6px 20px rgba(0,196,154,.25);
}

/* ══════════════════════════════════════════
   BASE
══════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; }

body {
  font-family: 'DM Sans', sans-serif;
  background: var(--bg-base);
  color: var(--text-primary);
  transition: background .3s ease, color .3s ease;
}

/* ══════════════════════════════════════════
   TOPBAR
══════════════════════════════════════════ */
.topbar-inner {
  padding: 0 24px;
  height: 62px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}
.topbar-left { display: flex; align-items: center; gap: 12px; }
.tb-title  { font-size: 15px; font-weight: 700; color: var(--text-primary); }
.tb-sub    { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

/* ── Theme Toggle ── */
.theme-toggle {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--bg-raised);
  border: 1px solid var(--border);
  border-radius: 40px;
  padding: 5px 14px 5px 8px;
  cursor: pointer;
  transition: var(--transition);
  font-size: 12px;
  font-weight: 600;
  color: var(--text-secondary);
  user-select: none;
}
.theme-toggle:hover { border-color: var(--accent); color: var(--accent); }

.toggle-track {
  width: 36px; height: 20px;
  background: var(--bg-tab);
  border: 1px solid var(--border);
  border-radius: 20px;
  position: relative;
  transition: background .3s;
}
[data-theme="dark"] .toggle-track { background: var(--accent); border-color: var(--accent); }

.toggle-thumb {
  width: 14px; height: 14px;
  background: #fff;
  border-radius: 50%;
  position: absolute;
  top: 2px; left: 2px;
  transition: transform .3s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 1px 4px rgba(0,0,0,.2);
}
[data-theme="dark"] .toggle-thumb { transform: translateX(16px); }

/* ══════════════════════════════════════════
   TABS
══════════════════════════════════════════ */
.tabs-wrap {
  display: flex;
  gap: 4px;
  padding: 20px 28px 0;
}
.tab-btn {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 9px 18px;
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  background: var(--bg-tab);
  color: var(--text-muted);
  border-bottom: 2px solid transparent;
  transition: var(--transition);
  font-family: 'DM Sans', sans-serif;
}
.tab-btn.active {
  background: var(--bg-tab-active);
  color: var(--accent);
  border-bottom: 2px solid var(--accent);
  box-shadow: var(--shadow-sm);
}
.tab-btn:hover:not(.active) { background: var(--bg-hover); color: var(--accent); }

/* ══════════════════════════════════════════
   CONTENT AREA
══════════════════════════════════════════ */
.content-area {
  padding: 0 28px 28px;
  overflow-y: auto;
  height: calc(100vh - 110px);
}
.tab-panel { display: none; }
.tab-panel.active { display: block; animation: fadeIn .25s ease; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

/* ══════════════════════════════════════════
   CARDS
══════════════════════════════════════════ */
.settings-card {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  margin-bottom: 16px;
  box-shadow: var(--shadow-sm);
  transition: background .3s, border-color .3s;
}
.card-header {
  padding: 16px 22px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--bg-header);
}
.card-header-icon {
  width: 36px; height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 17px;
  flex-shrink: 0;
}
.card-header-title  { font-size: 14px; font-weight: 700; color: var(--text-primary); }
.card-header-sub    { font-size: 11px; color: var(--text-muted); margin-top: 1px; }
.card-body          { padding: 22px; }

/* ══════════════════════════════════════════
   FORM ELEMENTS
══════════════════════════════════════════ */
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 16px;
}
.form-row.single { grid-template-columns: 1fr; }
.form-group { display: flex; flex-direction: column; gap: 6px; min-width: 0; }

.form-label {
  font-size: 11.5px;
  font-weight: 700;
  color: var(--text-secondary);
  letter-spacing: .03em;
  text-transform: uppercase;
}

.form-input {
  width: 100%;
  box-sizing: border-box;
  padding: 10px 14px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  color: var(--text-primary);
  font-family: 'DM Sans', sans-serif;
  outline: none;
  transition: var(--transition);
  background: var(--bg-input);
}
.form-input:focus {
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px var(--accent-glow);
}
.form-input:disabled {
  background: var(--bg-tab);
  color: var(--text-muted);
  cursor: not-allowed;
  opacity: .8;
}
.form-input::placeholder { color: var(--text-faint); }

.form-select {
  width: 100%;
  box-sizing: border-box;
  padding: 10px 14px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  color: var(--text-primary);
  font-family: 'DM Sans', sans-serif;
  outline: none;
  background: var(--bg-input);
  cursor: pointer;
  transition: var(--transition);
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='%235a7a90' d='M1 1l5 5 5-5'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 32px;
}
.form-select:focus {
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px var(--accent-glow);
}

.form-hint { font-size: 11px; color: var(--text-faint); margin-top: 2px; }

/* ══════════════════════════════════════════
   BUTTONS
══════════════════════════════════════════ */
.btn-primary {
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  color: #fff;
  border: none;
  padding: 10px 24px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  transition: var(--transition);
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-family: 'DM Sans', sans-serif;
  white-space: nowrap;
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-btn);
}

.btn-secondary {
  background: var(--bg-raised);
  color: var(--text-secondary);
  border: 1px solid var(--border);
  padding: 10px 20px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  font-family: 'DM Sans', sans-serif;
}
.btn-secondary:hover { background: var(--bg-hover); border-color: var(--accent); color: var(--accent); }

.btn-danger {
  background: var(--accent-red);
  color: #fff;
  border: none;
  padding: 7px 14px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  font-family: 'DM Sans', sans-serif;
}
.btn-danger:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168,0,40,.3); opacity: .9; }

.btn-edit {
  background: rgba(21,96,168,.1);
  color: var(--accent-blue);
  border: 1px solid rgba(21,96,168,.2);
  padding: 7px 14px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  font-family: 'DM Sans', sans-serif;
}
.btn-edit:hover { background: rgba(21,96,168,.18); }

/* ══════════════════════════════════════════
   ALERT
══════════════════════════════════════════ */
.alert {
  padding: 12px 16px;
  border-radius: var(--radius-sm);
  font-size: 12.5px;
  font-weight: 600;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.alert-success {
  background: var(--accent-glow);
  color: var(--accent-dark);
  border: 1px solid rgba(0,122,99,.2);
}
.alert-error {
  background: rgba(168,0,40,.08);
  color: var(--accent-red);
  border: 1px solid rgba(168,0,40,.2);
}

/* ══════════════════════════════════════════
   USER TABLE
══════════════════════════════════════════ */
.user-table { width: 100%; border-collapse: collapse; }
.user-table th {
  font-size: 10.5px;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: .07em;
  padding: 10px 14px;
  background: var(--bg-header);
  border-bottom: 1px solid var(--border);
  text-align: left;
}
.user-table td {
  padding: 12px 14px;
  border-bottom: 1px solid var(--border);
  font-size: 12.5px;
  color: var(--text-secondary);
  vertical-align: middle;
}
.user-table tr:last-child td { border-bottom: none; }
.user-table tr:hover td { background: var(--bg-hover); }

.user-avatar {
  width: 32px; height: 32px;
  border-radius: var(--radius-sm);
  background: linear-gradient(135deg, var(--accent), var(--accent-blue));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  color: #fff;
  flex-shrink: 0;
}

.role-badge {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: .04em;
}
.role-ADMIN  { background: rgba(168,0,40,.12);  color: var(--accent-red); }
.role-DOCTOR { background: rgba(21,96,168,.12); color: var(--accent-blue); }
.role-NURSE  { background: rgba(0,122,99,.12);  color: var(--accent); }

.status-active, .status-inactive {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 11px;
  font-weight: 600;
}
.status-active   { color: var(--accent); }
.status-inactive { color: var(--accent-red); }
.status-dot { width: 6px; height: 6px; border-radius: 50%; }

/* ── Username monospace ── */
.mono { font-family: 'JetBrains Mono', monospace; font-size: 11.5px; }

/* ══════════════════════════════════════════
   EXPORT GRID
══════════════════════════════════════════ */
.export-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.export-card {
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 20px;
  background: var(--bg-raised);
  transition: var(--transition);
  cursor: default;
}
.export-card:hover {
  border-color: var(--accent);
  background: var(--bg-hover);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}
.export-icon  { font-size: 30px; margin-bottom: 10px; }
.export-title { font-size: 13px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
.export-desc  { font-size: 11.5px; color: var(--text-muted); line-height: 1.55; }
.export-btns  { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }

.export-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  color: #fff;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: var(--transition);
  font-family: 'DM Sans', sans-serif;
}
.export-btn:hover { transform: translateY(-1px); box-shadow: 0 4px 14px var(--accent-glow); }
.export-btn.blue {
  background: linear-gradient(135deg, var(--accent-blue), #0f4d8a);
}
.export-btn.blue:hover { box-shadow: 0 4px 14px rgba(21,96,168,.3); }

/* ══════════════════════════════════════════
   PASSWORD STRENGTH
══════════════════════════════════════════ */
.strength-bar { height: 4px; border-radius: 2px; background: var(--border); margin-top: 6px; overflow: hidden; }
.strength-fill { height: 100%; border-radius: 2px; transition: all .3s ease; width: 0; }
.strength-text { font-size: 10px; font-weight: 600; margin-top: 4px; }

/* ══════════════════════════════════════════
   MODAL
══════════════════════════════════════════ */
.modal-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: var(--bg-overlay);
  z-index: 9999;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.modal-overlay.show { display: flex; animation: fadeIn .2s ease; }

.modal {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 28px;
  width: 100%;
  max-width: 480px;
  box-sizing: border-box;
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  transition: background .3s, border-color .3s;
}

.modal-title {
  font-size: 15px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

/* ══════════════════════════════════════════
   APPEARANCE PANEL
══════════════════════════════════════════ */
.theme-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-top: 4px;
}
.theme-option {
  border: 2px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 16px;
  cursor: pointer;
  transition: var(--transition);
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.theme-option:hover { border-color: var(--accent); }
.theme-option.selected { border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-glow); }

.theme-preview {
  height: 72px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  position: relative;
  border: 1px solid var(--border);
}
.preview-light {
  background: #f0f4f8;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 8px;
}
.preview-dark {
  background: #0d1117;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 8px;
}
.preview-bar { height: 8px; border-radius: 4px; }
.preview-card { height: 28px; border-radius: 6px; }

.theme-option-label {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-primary);
}
.theme-option-sub {
  font-size: 11px;
  color: var(--text-muted);
  margin-top: -4px;
}
.theme-check {
  width: 18px; height: 18px;
  border-radius: 50%;
  border: 2px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  transition: var(--transition);
  flex-shrink: 0;
  align-self: flex-start;
}
.theme-option.selected .theme-check {
  background: var(--accent);
  border-color: var(--accent);
  color: #fff;
}

.appearance-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid var(--border);
}
.appearance-row:last-child { border-bottom: none; }
.appearance-label { font-size: 13px; font-weight: 600; color: var(--text-primary); }
.appearance-hint  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

/* Compact toggle for appearance rows */
.mini-toggle {
  width: 40px; height: 22px;
  background: var(--border);
  border-radius: 22px;
  position: relative;
  cursor: pointer;
  transition: background .3s;
  flex-shrink: 0;
}
.mini-toggle.on { background: var(--accent); }
.mini-toggle::after {
  content: '';
  width: 16px; height: 16px;
  background: #fff;
  border-radius: 50%;
  position: absolute;
  top: 3px; left: 3px;
  transition: transform .3s;
  box-shadow: 0 1px 3px rgba(0,0,0,.2);
}
.mini-toggle.on::after { transform: translateX(18px); }

</style>
</head>
<body>
<div class="wrapper">
<%@ include file="sidebar.jsp" %>

<div class="main-content">

  <!-- TOPBAR -->
  <div class="topbar" style="padding:0">
    <div class="topbar-inner">
      <div class="topbar-left">
        <div>
          <div class="tb-title">⚙️ Settings</div>
          <div class="tb-sub">Manage your account and system preferences</div>
        </div>
      </div>
      <!-- Theme Toggle -->
      <div class="theme-toggle" onclick="toggleTheme()" id="themeToggle" title="Toggle light/dark mode">
        <div class="toggle-track"><div class="toggle-thumb"></div></div>
        <span id="themeLabel">Light Mode</span>
      </div>
    </div>
  </div>

  <!-- TABS -->
  <div class="tabs-wrap">
    <button class="tab-btn active" onclick="switchTab('password', this)">🔒 Password Change</button>
    <button class="tab-btn"        onclick="switchTab('users', this)">👥 User Management</button>
    <button class="tab-btn"        onclick="switchTab('export', this)">📤 Data Export</button>
    <button class="tab-btn"        onclick="switchTab('appearance', this)">🎨 Appearance</button>
  </div>

  <div class="content-area">

    <!-- ══ TAB 1: PASSWORD CHANGE ══ -->
    <div class="tab-panel active" id="tab-password">
      <div style="max-width:540px;margin-top:20px">

        <c:if test="${not empty successMsg}">
          <div class="alert alert-success">✅ ${successMsg}</div>
        </c:if>
        <c:if test="${not empty errorMsg}">
          <div class="alert alert-error">❌ ${errorMsg}</div>
        </c:if>

        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:var(--accent-glow)">🔒</div>
            <div>
              <div class="card-header-title">Change Password</div>
              <div class="card-header-sub">Keep your account secure with a strong password</div>
            </div>
          </div>
          <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/settings" onsubmit="return validatePassword()">
              <input type="hidden" name="action" value="changePassword">
              <div class="form-row single">
                <div class="form-group">
                  <label class="form-label">Current Password</label>
                  <input type="password" name="currentPassword" id="currentPassword" class="form-input" placeholder="Enter current password" required>
                </div>
              </div>
              <div class="form-row single">
                <div class="form-group">
                  <label class="form-label">New Password</label>
                  <input type="password" name="newPassword" id="newPassword" class="form-input" placeholder="Enter new password" oninput="checkStrength(this.value)" required>
                  <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                  <div class="strength-text" id="strengthText"></div>
                </div>
              </div>
              <div class="form-row single">
                <div class="form-group">
                  <label class="form-label">Confirm New Password</label>
                  <input type="password" name="confirmPassword" id="confirmPassword" class="form-input" placeholder="Re-enter new password" required>
                  <div class="form-hint" id="matchHint"></div>
                </div>
              </div>
              <div style="display:flex;gap:10px;margin-top:8px">
                <button type="submit" class="btn-primary">🔒 Update Password</button>
                <button type="reset" class="btn-secondary">Clear</button>
              </div>
            </form>
          </div>
        </div>

        <!-- My Profile -->
        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:rgba(21,96,168,.1)">👤</div>
            <div>
              <div class="card-header-title">My Profile</div>
              <div class="card-header-sub">Your account information</div>
            </div>
          </div>
          <div class="card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" class="form-input" value="<%= currentUser.getFullName() %>" disabled>
              </div>
              <div class="form-group">
                <label class="form-label">Username</label>
                <input type="text" class="form-input" value="<%= currentUser.getUsername() %>" disabled>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Email</label>
                <input type="text" class="form-input" value="<%= currentUser.getEmail() != null ? currentUser.getEmail() : "—" %>" disabled>
              </div>
              <div class="form-group">
                <label class="form-label">Role</label>
                <input type="text" class="form-input" value="<%= currentUser.getRole() %>" disabled>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══ TAB 2: USER MANAGEMENT ══ -->
    <div class="tab-panel" id="tab-users">
      <div style="margin-top:20px">
        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:rgba(21,96,168,.1)">👥</div>
            <div style="flex:1">
              <div class="card-header-title">User Management</div>
              <div class="card-header-sub">Add, edit or deactivate system users</div>
            </div>
            <button class="btn-primary" onclick="openAddModal()">➕ Add User</button>
          </div>
          <div class="card-body" style="padding:0">
            <table class="user-table">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Username</th>
                  <th>Role</th>
                  <th>Status</th>
                  <th>Created</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="u" items="${allUsers}">
                <tr>
                  <td>
                    <div style="display:flex;align-items:center;gap:9px">
                      <div class="user-avatar">${u.fullName.charAt(0)}</div>
                      <div>
                        <div style="font-weight:600;font-size:12.5px;color:var(--text-primary)">${u.fullName}</div>
                        <div style="font-size:11px;color:var(--text-faint)">${u.email}</div>
                      </div>
                    </div>
                  </td>
                  <td><span class="mono">${u.username}</span></td>
                  <td><span class="role-badge role-${u.role}">${u.role}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${u.active}">
                        <span class="status-active"><span class="status-dot" style="background:var(--accent)"></span>Active</span>
                      </c:when>
                      <c:otherwise>
                        <span class="status-inactive"><span class="status-dot" style="background:var(--accent-red)"></span>Inactive</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td style="font-size:11.5px;color:var(--text-muted)">
                    <fmt:formatDate value="${u.createdAt}" pattern="dd MMM yyyy"/>
                  </td>
                  <td>
                    <div style="display:flex;gap:6px">
                      <button class="btn-edit" onclick="openEditModal(${u.id},'${u.fullName}','${u.username}','${u.email}','${u.role}',${u.active})">✏️ Edit</button>
                      <c:if test="${u.id != sessionScope.user.id}">
                        <form method="post" action="${pageContext.request.contextPath}/settings" style="display:inline" onsubmit="return confirm('Are you sure?')">
                          <input type="hidden" name="action" value="toggleUser">
                          <input type="hidden" name="userId" value="${u.id}">
                          <input type="hidden" name="active" value="${!u.active}">
                          <button type="submit" class="btn-danger">${u.active ? '🚫 Disable' : '✅ Enable'}</button>
                        </form>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty allUsers}">
                  <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--text-muted)">No users found</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- ══ TAB 3: DATA EXPORT ══ -->
    <div class="tab-panel" id="tab-export">
      <div style="margin-top:20px">
        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:rgba(168,98,0,.1)">📤</div>
            <div>
              <div class="card-header-title">Data Export</div>
              <div class="card-header-sub">Download system data as PDF or Excel</div>
            </div>
          </div>
          <div class="card-body">
            <div class="export-grid">

              <div class="export-card">
                <div class="export-icon">🧑‍⚕️</div>
                <div class="export-title">Patient Report</div>
                <div class="export-desc">All registered patients with risk levels, diagnosis and surgery history</div>
                <div class="export-btns">
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="patients">
                    <input type="hidden" name="format" value="pdf">
                    <button type="submit" class="export-btn">📄 PDF</button>
                  </form>
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="patients">
                    <input type="hidden" name="format" value="excel">
                    <button type="submit" class="export-btn blue">📊 Excel</button>
                  </form>
                </div>
              </div>

              <div class="export-card">
                <div class="export-icon">🔪</div>
                <div class="export-title">Surgery Report</div>
                <div class="export-desc">All scheduled and completed surgeries with surgeon and OT details</div>
                <div class="export-btns">
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="surgeries">
                    <input type="hidden" name="format" value="pdf">
                    <button type="submit" class="export-btn">📄 PDF</button>
                  </form>
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="surgeries">
                    <input type="hidden" name="format" value="excel">
                    <button type="submit" class="export-btn blue">📊 Excel</button>
                  </form>
                </div>
              </div>

              <div class="export-card">
                <div class="export-icon">⚠️</div>
                <div class="export-title">Risk Analysis Report</div>
                <div class="export-desc">High and critical risk patients with detailed risk score breakdown</div>
                <div class="export-btns">
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="risk">
                    <input type="hidden" name="format" value="pdf">
                    <button type="submit" class="export-btn">📄 PDF</button>
                  </form>
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="risk">
                    <input type="hidden" name="format" value="excel">
                    <button type="submit" class="export-btn blue">📊 Excel</button>
                  </form>
                </div>
              </div>

              <div class="export-card">
                <div class="export-icon">👨‍⚕️</div>
                <div class="export-title">Surgeon Schedule</div>
                <div class="export-desc">Surgeon availability and assigned surgery schedule overview</div>
                <div class="export-btns">
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="surgeons">
                    <input type="hidden" name="format" value="pdf">
                    <button type="submit" class="export-btn">📄 PDF</button>
                  </form>
                  <form method="get" action="${pageContext.request.contextPath}/export">
                    <input type="hidden" name="type" value="surgeons">
                    <input type="hidden" name="format" value="excel">
                    <button type="submit" class="export-btn blue">📊 Excel</button>
                  </form>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══ TAB 4: APPEARANCE ══ -->
    <div class="tab-panel" id="tab-appearance">
      <div style="max-width:600px;margin-top:20px">

        <!-- Theme Selector -->
        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:rgba(168,98,0,.1)">🎨</div>
            <div>
              <div class="card-header-title">Theme</div>
              <div class="card-header-sub">Choose how the interface looks</div>
            </div>
          </div>
          <div class="card-body">
            <div class="theme-options">

              <!-- Light -->
              <div class="theme-option" id="opt-light" onclick="setTheme('light')">
                <div class="theme-preview">
                  <div class="preview-light">
                    <div class="preview-bar" style="width:60%;background:#007a63;"></div>
                    <div class="preview-bar" style="width:40%;background:#c8d8e8;"></div>
                    <div class="preview-card" style="background:#fff;border:1px solid #c8d8e8;"></div>
                  </div>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between">
                  <div>
                    <div class="theme-option-label">☀️ Light Mode</div>
                    <div class="theme-option-sub">Clean & bright</div>
                  </div>
                  <div class="theme-check" id="check-light">✓</div>
                </div>
              </div>

              <!-- Dark -->
              <div class="theme-option" id="opt-dark" onclick="setTheme('dark')">
                <div class="theme-preview">
                  <div class="preview-dark">
                    <div class="preview-bar" style="width:60%;background:#00c49a;"></div>
                    <div class="preview-bar" style="width:40%;background:#2d3748;"></div>
                    <div class="preview-card" style="background:#161b22;border:1px solid #2d3748;"></div>
                  </div>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between">
                  <div>
                    <div class="theme-option-label">🌙 Dark Mode</div>
                    <div class="theme-option-sub">Easy on the eyes</div>
                  </div>
                  <div class="theme-check" id="check-dark">✓</div>
                </div>
              </div>

            </div>
          </div>
        </div>

        <!-- Display Preferences -->
        <div class="settings-card">
          <div class="card-header">
            <div class="card-header-icon" style="background:rgba(21,96,168,.1)">🖥️</div>
            <div>
              <div class="card-header-title">Display Preferences</div>
              <div class="card-header-sub">Customize your interface experience</div>
            </div>
          </div>
          <div class="card-body">

            <div class="appearance-row">
              <div>
                <div class="appearance-label">Compact Mode</div>
                <div class="appearance-hint">Reduce spacing between elements</div>
              </div>
              <div class="mini-toggle" id="tog-compact" onclick="togglePref('compact', this)"></div>
            </div>

            <div class="appearance-row">
              <div>
                <div class="appearance-label">Animations</div>
                <div class="appearance-hint">Enable smooth transitions and effects</div>
              </div>
              <div class="mini-toggle on" id="tog-anim" onclick="togglePref('anim', this)"></div>
            </div>

            <div class="appearance-row">
              <div>
                <div class="appearance-label">High Contrast</div>
                <div class="appearance-hint">Increase border and text contrast</div>
              </div>
              <div class="mini-toggle" id="tog-contrast" onclick="togglePref('contrast', this)"></div>
            </div>

          </div>
        </div>

      </div>
    </div>

  </div><!-- /content-area -->
</div><!-- /main-content -->
</div><!-- /wrapper -->

<!-- ══ ADD USER MODAL ══ -->
<div class="modal-overlay" id="addModal">
  <div class="modal">
    <div class="modal-title">➕ Add New User</div>
    <form method="post" action="${pageContext.request.contextPath}/settings">
      <input type="hidden" name="action" value="addUser">
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Full Name</label>
          <input type="text" name="fullName" class="form-input" placeholder="Enter full name" required>
        </div>
        <div class="form-group">
          <label class="form-label">Username</label>
          <input type="text" name="username" class="form-input" placeholder="Enter username" required>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Email</label>
          <input type="email" name="email" class="form-input" placeholder="Enter email">
        </div>
        <div class="form-group">
          <label class="form-label">Role</label>
          <select name="role" class="form-select" required>
            <option value="ADMIN">Admin</option>
            <option value="DOCTOR">Doctor</option>
            <option value="NURSE">Nurse</option>
          </select>
        </div>
      </div>
      <div class="form-row single">
        <div class="form-group">
          <label class="form-label">Password</label>
          <input type="password" name="password" class="form-input" placeholder="Enter password" required>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-secondary" onclick="closeModal('addModal')">Cancel</button>
        <button type="submit" class="btn-primary">➕ Add User</button>
      </div>
    </form>
  </div>
</div>

<!-- ══ EDIT USER MODAL ══ -->
<div class="modal-overlay" id="editModal">
  <div class="modal">
    <div class="modal-title">✏️ Edit User</div>
    <form method="post" action="${pageContext.request.contextPath}/settings">
      <input type="hidden" name="action" value="editUser">
      <input type="hidden" name="userId" id="editUserId">
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Full Name</label>
          <input type="text" name="fullName" id="editFullName" class="form-input" required>
        </div>
        <div class="form-group">
          <label class="form-label">Username</label>
          <input type="text" name="username" id="editUsername" class="form-input" required>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Email</label>
          <input type="email" name="email" id="editEmail" class="form-input">
        </div>
        <div class="form-group">
          <label class="form-label">Role</label>
          <select name="role" id="editRole" class="form-select">
            <option value="ADMIN">Admin</option>
            <option value="DOCTOR">Doctor</option>
            <option value="NURSE">Nurse</option>
          </select>
        </div>
      </div>
      <div class="form-row single">
        <div class="form-group">
          <label class="form-label">New Password
            <span style="color:var(--text-faint);font-weight:400;text-transform:none;letter-spacing:0">(leave blank to keep current)</span>
          </label>
          <input type="password" name="newPassword" class="form-input" placeholder="Enter new password (optional)">
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-secondary" onclick="closeModal('editModal')">Cancel</button>
        <button type="submit" class="btn-primary">💾 Save Changes</button>
      </div>
    </form>
  </div>
</div>

<script>
/* ══ THEME ══ */
var currentTheme = localStorage.getItem('theme') || 'light';
applyTheme(currentTheme);

function applyTheme(theme) {
  currentTheme = theme;
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);

  var label = document.getElementById('themeLabel');
  if (label) label.textContent = theme === 'dark' ? 'Dark Mode' : 'Light Mode';

  // Update appearance panel selection
  var optLight = document.getElementById('opt-light');
  var optDark  = document.getElementById('opt-dark');
  var chkLight = document.getElementById('check-light');
  var chkDark  = document.getElementById('check-dark');
  if (optLight) {
    optLight.classList.toggle('selected', theme === 'light');
    optDark.classList.toggle('selected',  theme === 'dark');
  }
}

function toggleTheme() {
  applyTheme(currentTheme === 'dark' ? 'light' : 'dark');
}

function setTheme(t) { applyTheme(t); }

/* ══ DISPLAY PREFERENCES ══ */
function togglePref(pref, el) {
  el.classList.toggle('on');
  var isOn = el.classList.contains('on');
  localStorage.setItem('pref_' + pref, isOn ? '1' : '0');

  if (pref === 'compact') {
    document.body.style.setProperty('--compact', isOn ? '1' : '0');
    document.querySelectorAll('.card-body').forEach(function(c){
      c.style.padding = isOn ? '14px' : '';
    });
    document.querySelectorAll('.form-input, .form-select').forEach(function(i){
      i.style.padding = isOn ? '7px 12px' : '';
    });
  }
  if (pref === 'anim') {
    document.body.style.setProperty('--transition', isOn ? 'all .2s ease' : 'none');
  }
  if (pref === 'contrast') {
    document.documentElement.style.setProperty('--border', isOn ? (currentTheme === 'dark' ? '#4a6080' : '#8aa0b8') : '');
  }
}

// Restore preferences on load
(function(){
  if (localStorage.getItem('pref_compact') === '1') {
    var el = document.getElementById('tog-compact');
    if (el) togglePref('compact', el);
  }
  if (localStorage.getItem('pref_anim') === '0') {
    var el = document.getElementById('tog-anim');
    if (el) { el.classList.remove('on'); }
  }
  if (localStorage.getItem('pref_contrast') === '1') {
    var el = document.getElementById('tog-contrast');
    if (el) togglePref('contrast', el);
  }
})();

/* ══ TAB SWITCHING ══ */
function switchTab(name, btn) {
  document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
  document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
  if (btn) btn.classList.add('active');
  var panel = document.getElementById('tab-' + name);
  if (panel) panel.classList.add('active');
}

/* ══ Show tab from URL param ══ */
(function(){
  var urlParams = new URLSearchParams(window.location.search);
  var tabParam = urlParams.get('tab');
  if (tabParam) {
    var tabNames = ['password','users','export','appearance'];
    var idx = tabNames.indexOf(tabParam);
    var tabEl = document.getElementById('tab-' + tabParam);
    if (tabEl && idx !== -1) {
      document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
      document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
      tabEl.classList.add('active');
      var btns = document.querySelectorAll('.tab-btn');
      if (btns[idx]) btns[idx].classList.add('active');
    }
  }
})();

/* ══ PASSWORD STRENGTH ══ */
function checkStrength(val) {
  var fill = document.getElementById('strengthFill');
  var text = document.getElementById('strengthText');
  if (!val) { fill.style.width = '0'; text.textContent = ''; return; }
  var score = 0;
  if (val.length >= 8)         score++;
  if (/[A-Z]/.test(val))       score++;
  if (/[0-9]/.test(val))       score++;
  if (/[^A-Za-z0-9]/.test(val)) score++;
  var colors = ['#a80028','#a86200','#1560a8','#007a63'];
  var labels = ['Weak','Fair','Good','Strong'];
  fill.style.width = (score * 25) + '%';
  fill.style.background = colors[score - 1] || '#e8f0f8';
  text.textContent  = score ? labels[score - 1] : '';
  text.style.color  = colors[score - 1] || '#5a7a90';
}

/* ══ CONFIRM PASSWORD MATCH ══ */
document.addEventListener('DOMContentLoaded', function() {
  var confirmEl = document.getElementById('confirmPassword');
  if (confirmEl) {
    confirmEl.addEventListener('input', function() {
      var hint = document.getElementById('matchHint');
      var np = document.getElementById('newPassword').value;
      if (!this.value) { hint.textContent = ''; return; }
      if (this.value === np) {
        hint.textContent = '✅ Passwords match';
        hint.style.color = 'var(--accent)';
      } else {
        hint.textContent = '❌ Passwords do not match';
        hint.style.color = 'var(--accent-red)';
      }
    });
  }
});

function validatePassword() {
  var np = document.getElementById('newPassword').value;
  var cp = document.getElementById('confirmPassword').value;
  if (np !== cp) { alert('Passwords do not match!'); return false; }
  if (np.length < 6) { alert('Password must be at least 6 characters!'); return false; }
  return true;
}

/* ══ MODALS ══ */
function openAddModal()  { document.getElementById('addModal').classList.add('show'); }
function closeModal(id)  { document.getElementById(id).classList.remove('show'); }

function openEditModal(id, fullName, username, email, role, active) {
  document.getElementById('editUserId').value   = id;
  document.getElementById('editFullName').value = fullName;
  document.getElementById('editUsername').value = username;
  document.getElementById('editEmail').value    = email;
  document.getElementById('editRole').value     = role;
  document.getElementById('editModal').classList.add('show');
}

document.querySelectorAll('.modal-overlay').forEach(function(m) {
  m.addEventListener('click', function(e) {
    if (e.target === m) m.classList.remove('show');
  });
});
</script>
</body>
</html>
