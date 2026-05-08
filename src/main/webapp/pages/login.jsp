<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login — Smart Surgery Scheduling System</title>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{height:100%;width:100%;overflow:hidden}

body{
  font-family:'Space Grotesk',sans-serif;
  min-height:100vh;
  background:linear-gradient(135deg,#0a3d2e 0%,#0d5c3a 30%,#0a4a2e 60%,#063320 100%);
  display:flex;align-items:center;justify-content:center;
  position:relative;
}
body::before{content:'';position:fixed;top:-100px;left:-100px;width:350px;height:350px;border-radius:50%;background:rgba(52,211,153,0.15);filter:blur(60px);pointer-events:none;}
body::after{content:'';position:fixed;bottom:-80px;right:-80px;width:300px;height:300px;border-radius:50%;background:rgba(16,185,129,0.12);filter:blur(50px);pointer-events:none;}
.orb1{position:fixed;top:40%;left:10%;width:180px;height:180px;border-radius:50%;background:rgba(52,211,153,0.08);filter:blur(40px);pointer-events:none;}
.orb2{position:fixed;top:20%;right:15%;width:140px;height:140px;border-radius:50%;background:rgba(110,231,183,0.1);filter:blur(35px);pointer-events:none;}
.dots{position:fixed;inset:0;background-image:radial-gradient(circle,rgba(52,211,153,0.15) 1px,transparent 1px);background-size:32px 32px;pointer-events:none;}

/* ── Card ── */
.card{
  position:relative;z-index:2;
  width:min(860px,96vw);
  height:min(560px,96vh);
  display:grid;
  grid-template-columns:1fr 1fr;
  border-radius:28px;
  overflow:hidden;
  box-shadow:0 32px 80px rgba(0,0,0,0.5),0 0 0 1px rgba(52,211,153,0.2),inset 0 1px 0 rgba(255,255,255,0.08);
  animation:cardIn 0.6s cubic-bezier(0.16,1,0.3,1) forwards;
  opacity:0;
}
@keyframes cardIn{from{opacity:0;transform:translateY(18px) scale(0.97)}to{opacity:1;transform:none}}

/* ══ LEFT ══ */
.left{
  background:rgba(255,255,255,0.06);
  backdrop-filter:blur(24px);
  -webkit-backdrop-filter:blur(24px);
  border-right:1px solid rgba(52,211,153,0.15);
  padding:36px 34px;
  display:flex;flex-direction:column;justify-content:space-between;
  position:relative;overflow:hidden;
}
.left::before{content:'';position:absolute;top:-60px;right:-60px;width:200px;height:200px;border-radius:50%;background:rgba(52,211,153,0.08);}
.left::after{content:'';position:absolute;bottom:-50px;left:-30px;width:160px;height:160px;border-radius:50%;background:rgba(52,211,153,0.05);}

.brand{display:flex;align-items:center;gap:12px;position:relative;z-index:1}
.brand-icon{
  width:42px;height:42px;
  background:rgba(52,211,153,0.15);
  border:1px solid rgba(52,211,153,0.35);
  border-radius:13px;
  display:flex;align-items:center;justify-content:center;
  flex-shrink:0;
  box-shadow:0 0 18px rgba(52,211,153,0.15);
}
.brand-icon svg{width:20px;height:20px;stroke:#6ee7b7;fill:none;stroke-width:1.8}
.brand-name{font-size:12.5px;font-weight:700;color:rgba(255,255,255,0.88);letter-spacing:0.01em}
.brand-sub{font-size:10px;color:rgba(255,255,255,0.32);margin-top:2px}

.hero{position:relative;z-index:1}
.pill{
  display:inline-flex;align-items:center;gap:6px;
  background:rgba(52,211,153,0.12);
  border:1px solid rgba(52,211,153,0.25);
  border-radius:20px;padding:4px 11px;
  font-size:9.5px;font-weight:700;color:#6ee7b7;
  letter-spacing:0.1em;text-transform:uppercase;
  margin-bottom:16px;
}
.pdot{width:5px;height:5px;border-radius:50%;background:#34d399;animation:blink 2s infinite}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0.2}}

.big-title{
  font-size:34px;font-weight:800;
  color:#fff;line-height:1.1;
  letter-spacing:-1.2px;
  margin-bottom:12px;
}
.big-title .accent{
  display:block;
  background:linear-gradient(90deg,#34d399,#6ee7b7);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
}
.desc{font-size:12px;color:rgba(255,255,255,0.38);line-height:1.75;max-width:230px;margin-bottom:16px}

.feat-list{display:flex;flex-direction:column;gap:7px}
.feat{display:flex;align-items:center;gap:8px;font-size:11.5px;color:rgba(255,255,255,0.42)}
.feat-dot{width:5px;height:5px;border-radius:50%;background:#34d399;flex-shrink:0}

.metrics{display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;position:relative;z-index:1}
.metric{
  background:rgba(52,211,153,0.08);
  border:1px solid rgba(52,211,153,0.15);
  border-radius:11px;padding:10px 8px;text-align:center;
}
.metric-val{font-size:17px;font-weight:800;color:#34d399;letter-spacing:-0.5px}
.metric-lbl{font-size:9px;color:rgba(255,255,255,0.28);text-transform:uppercase;letter-spacing:0.06em;margin-top:2px}

/* ══ RIGHT ══ */
.right{
  background:#fff;
  padding:36px 36px;
  display:flex;flex-direction:column;justify-content:center;
  position:relative;
}

.eyebrow{font-size:10px;font-weight:700;color:#059669;letter-spacing:0.1em;text-transform:uppercase;margin-bottom:6px;display:flex;align-items:center;gap:8px;}
.ssl-badge{display:inline-flex;align-items:center;gap:3px;background:#ecfdf5;border:1px solid #a7f3d0;border-radius:5px;padding:2px 7px;font-size:9px;font-weight:700;color:#065f46;letter-spacing:0.05em;}
.ssl-badge svg{width:9px;height:9px;stroke:#059669;fill:none;stroke-width:2.5}

.htitle{font-size:24px;font-weight:800;color:#111;letter-spacing:-0.7px;line-height:1.15;margin-bottom:3px;}
.hsub{font-size:12px;color:#9ca3af;margin-bottom:20px}

/* Alerts */
.alert-err{background:#fff5f5;border:1.5px solid #fecaca;border-radius:10px;padding:9px 13px;color:#b91c1c;font-size:12px;display:flex;align-items:center;gap:7px;margin-bottom:14px;animation:shake 0.4s ease;}
.alert-lock{background:#fff7ed;border:1.5px solid #fed7aa;border-radius:10px;padding:9px 13px;color:#92400e;font-size:12px;display:flex;align-items:center;gap:7px;margin-bottom:14px;}
.alert-err svg,.alert-lock svg{width:13px;height:13px;fill:none;stroke-width:2;flex-shrink:0}
.alert-err svg{stroke:#b91c1c}
.alert-lock svg{stroke:#d97706}
@keyframes shake{0%,100%{transform:translateX(0)}25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}

/* Fields */
.field{margin-bottom:12px}
.field-lbl{font-size:10px;font-weight:700;color:#9ca3af;text-transform:uppercase;letter-spacing:0.08em;margin-bottom:6px;display:block;}
.ibox{display:flex;align-items:center;border:1.5px solid #e5e7eb;border-radius:11px;background:#f9fafb;transition:all 0.2s;overflow:hidden;}
.ibox:focus-within{border-color:#059669;background:#f0fdf4;box-shadow:0 0 0 3px rgba(5,150,105,0.1);}
.ibox.disabled{opacity:0.5;pointer-events:none;background:#f3f4f6}
.iico{padding:0 12px;display:flex;align-items:center;opacity:0.3;flex-shrink:0}
.iico svg{width:15px;height:15px;stroke:#111;fill:none;stroke-width:2}
.ibox input{flex:1;border:none;outline:none;background:transparent;padding:12px 10px 12px 0;font-family:'Space Grotesk',sans-serif;font-size:13.5px;color:#111;}
.ibox input::placeholder{color:#d1d5db}
.tpw-btn{padding:0 12px;background:transparent;border:none;cursor:pointer;display:flex;align-items:center;opacity:0.3;transition:opacity 0.2s;flex-shrink:0;}
.tpw-btn:hover{opacity:0.7}
.tpw-btn svg{width:15px;height:15px;stroke:#374151;fill:none;stroke-width:2}

.row-opts{display:flex;align-items:center;justify-content:space-between;margin:3px 0 15px}
.remember{display:flex;align-items:center;gap:6px;cursor:pointer}
.remember input[type="checkbox"]{width:13px;height:13px;accent-color:#059669;cursor:pointer;}
.remember span{font-size:12px;color:#6b7280}
.forgot-link{font-size:12px;color:#059669;text-decoration:none;font-weight:600;transition:opacity 0.2s}
.forgot-link:hover{opacity:0.7;text-decoration:underline}

/* Button */
.btn-login{
  width:100%;padding:13px;border:none;border-radius:11px;
  background:linear-gradient(135deg,#047857,#059669);
  color:#fff;font-family:'Space Grotesk',sans-serif;
  font-size:14px;font-weight:700;cursor:pointer;
  letter-spacing:0.04em;text-transform:uppercase;
  transition:transform 0.18s,box-shadow 0.18s;
  display:flex;align-items:center;justify-content:center;gap:7px;
  box-shadow:0 4px 16px rgba(5,150,105,0.3);
}
.btn-login:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 8px 24px rgba(5,150,105,0.4);}
.btn-login:active:not(:disabled){transform:translateY(0)}
.btn-login:disabled{opacity:0.5;cursor:not-allowed;background:#d1d5db;box-shadow:none;}
.btn-arrow{transition:transform 0.2s}
.btn-login:hover:not(:disabled) .btn-arrow{transform:translateX(3px)}
.spinner{display:none;width:14px;height:14px;border:2px solid rgba(255,255,255,0.3);border-top-color:#fff;border-radius:50%;animation:spin 0.7s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
.btn-login.loading .spinner{display:block}
.btn-login.loading .btn-text,.btn-login.loading .btn-arrow{display:none}

/* Divider */
.divider{display:flex;align-items:center;gap:8px;margin:13px 0 10px}
.divider hr{flex:1;border:none;border-top:1px solid #f0f1f3}
.divider span{font-size:10px;color:#d1d5db;white-space:nowrap;font-weight:500}

/* Demo creds */
.creds-box{background:#f8fffe;border:1.5px dashed #a7f3d0;border-radius:11px;padding:11px 14px;}
.creds-title{font-size:9.5px;font-weight:700;color:#059669;text-transform:uppercase;letter-spacing:0.1em;margin-bottom:8px;opacity:0.7}
.cred-row{display:flex;align-items:center;justify-content:space-between;padding:4px 0}
.cred-row+.cred-row{border-top:1px solid rgba(5,150,105,0.08)}
.cred-role{font-size:11.5px;color:#6b7280;font-weight:500}
.cred-tag{background:#ecfdf5;color:#065f46;padding:2px 8px;border-radius:5px;font-family:monospace;font-size:11px;font-weight:700;border:1px solid #a7f3d0;cursor:pointer;transition:background 0.15s;user-select:none;}
.cred-tag:hover{background:#d1fae5}

/* Footer */
.card-footer{
  grid-column:1/-1;
  background:#f9fafb;border-top:1px solid #f0f1f3;
  padding:9px 36px;
  display:flex;align-items:center;justify-content:space-between;
  font-size:10.5px;color:#b0b7c0;
}
.card-footer span{display:flex;align-items:center;gap:4px}
.card-footer svg{width:11px;height:11px;stroke:#059669;fill:none;stroke-width:2.5}

/* Responsive */
@media(max-width:680px){
  .card{grid-template-columns:1fr;height:auto;max-height:98vh;overflow-y:auto;}
  .left{display:none}
  .right{padding:32px 24px}
  .card-footer{padding:9px 24px;flex-direction:column;gap:4px;text-align:center}
}
</style>
</head>
<body>

<div class="dots"></div>
<div class="orb1"></div>
<div class="orb2"></div>

<%
  boolean isLocked = Boolean.TRUE.equals(request.getAttribute("locked"));
  Integer loginAttempts = (Integer) session.getAttribute("loginAttempts");
  if (loginAttempts == null) loginAttempts = 0;
  String rememberedUsername = (String) request.getAttribute("rememberedUsername");
  String lastUsername = (request.getParameter("username") != null)
      ? request.getParameter("username")
      : (rememberedUsername != null ? rememberedUsername : "");
%>

<div class="card">

  <!-- ════ LEFT ════ -->
  <div class="left">
    <div class="brand">
      <div class="brand-icon">
        <svg viewBox="0 0 24 24"><path d="M9 12h6M12 9v6"/><circle cx="12" cy="12" r="9"/></svg>
      </div>
      <div>
        <div class="brand-name">Smart Surgery System</div>
        <div class="brand-sub">KYAMCH · Hospital Management</div>
      </div>
    </div>

    <div class="hero">
      <div class="pill"><span class="pdot"></span>System Online</div>
      <div class="big-title">
        Surgical
        <span class="accent">Scheduling</span>
        Reimagined
      </div>
      <p class="desc">AI-driven OT scheduling with real-time risk analysis and priority-based surgery management.</p>
      <div class="feat-list">
        <div class="feat"><span class="feat-dot"></span>AI-powered patient risk analysis</div>
        <div class="feat"><span class="feat-dot"></span>Real-time surgeon &amp; OT availability</div>
        <div class="feat"><span class="feat-dot"></span>Conflict-free priority scheduling</div>
      </div>
    </div>

    <div class="metrics">
      <div class="metric"><div class="metric-val">98%</div><div class="metric-lbl">Accuracy</div></div>
      <div class="metric"><div class="metric-val">0</div><div class="metric-lbl">Conflicts</div></div>
      <div class="metric"><div class="metric-val">24/7</div><div class="metric-lbl">Uptime</div></div>
    </div>
  </div>

  <!-- ════ RIGHT ════ -->
  <div class="right" style="padding-bottom:44px">
    <div class="eyebrow">
      Secure Access
      <span class="ssl-badge">
        <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        SSL Encrypted
      </span>
    </div>
    <div class="htitle">Welcome back,<br>Doctor.</div>
    <div class="hsub">Sign in to your surgical management dashboard.</div>

    <%-- Alerts --%>
    <% if (isLocked) { %>
    <div class="alert-lock">
      <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
      ${error}
    </div>
    <% } else if (request.getAttribute("error") != null) { %>
    <div class="alert-err">
      <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
      ${error}
    </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">

      <div class="field">
        <label class="field-lbl" for="username">Username</label>
        <div class="ibox <%= isLocked ? "disabled" : "" %>">
          <span class="iico"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg></span>
          <input type="text" id="username" name="username"
                 placeholder="Enter your username"
                 required autocomplete="username"
                 <%= isLocked ? "disabled" : "autofocus" %>
                 value="<%= lastUsername %>">
        </div>
      </div>

      <div class="field">
        <label class="field-lbl" for="password">Password</label>
        <div class="ibox <%= isLocked ? "disabled" : "" %>">
          <span class="iico"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
          <input type="password" id="password" name="password"
                 placeholder="Enter your password"
                 required autocomplete="current-password"
                 <%= isLocked ? "disabled" : "" %>>
          <button type="button" class="tpw-btn" id="togglePw"
                  title="Show/hide password" <%= isLocked ? "disabled" : "" %>>
            <svg id="eyeIcon" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
      </div>

      <div class="row-opts">
        <label class="remember">
          <input type="checkbox" name="rememberMe" id="rememberMe"
                 <%= (rememberedUsername != null && !rememberedUsername.isEmpty()) ? "checked" : "" %>
                 <%= isLocked ? "disabled" : "" %>>
          <span>Remember me</span>
        </label>
        <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">Forgot password?</a>
      </div>

      <button type="submit" class="btn-login" id="submitBtn" <%= isLocked ? "disabled" : "" %>>
        <span class="spinner"></span>
        <span class="btn-text"><%= isLocked ? "Account Locked" : "Sign in to Dashboard" %></span>
        <% if (!isLocked) { %>
        <span class="btn-arrow">
          <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path d="M5 12h14M12 5l7 7-7 7"/>
          </svg>
        </span>
        <% } %>
      </button>
    </form>

    <div class="divider"><hr><span>Demo Credentials</span><hr></div>

    <div class="creds-box">
      <div class="creds-title">Test Accounts — Click to fill</div>
      <div class="cred-row">
        <span class="cred-role">Admin</span>
        <span class="cred-tag" onclick="fillCreds('admin','admin1234')">admin / admin1234</span>
      </div>
      <div class="cred-row">
        <span class="cred-role">Doctor</span>
        <span class="cred-tag" onclick="fillCreds('doctor1','admin1234')">doctor1 / admin1234</span>
      </div>
      <div class="cred-row">
        <span class="cred-role">Nurse</span>
        <span class="cred-tag" onclick="fillCreds('nurse1','admin1234')">nurse1 / admin1234</span>
      </div>
    </div>
  </div>

  <!-- ════ FOOTER ════ -->
  <div class="card-footer">
    <span>© 2026 Smart Surgery System · KYAMCH</span>
    <span>
      <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
      256-bit SSL Secured
    </span>
  </div>

</div>

<script>
  /* Password toggle */
  const toggleBtn = document.getElementById('togglePw');
  const pwInput   = document.getElementById('password');
  const eyeIcon   = document.getElementById('eyeIcon');
  const eyeOpen   = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
  const eyeClosed = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>';
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const showing = pwInput.type === 'text';
      pwInput.type = showing ? 'password' : 'text';
      eyeIcon.innerHTML = showing ? eyeOpen : eyeClosed;
      toggleBtn.style.opacity = showing ? '0.3' : '0.75';
    });
  }

  /* Loading spinner */
  document.getElementById('loginForm')?.addEventListener('submit', function() {
    const u = document.getElementById('username').value.trim();
    const p = document.getElementById('password').value.trim();
    if (!u || !p) return;
    const btn = document.getElementById('submitBtn');
    btn.classList.add('loading');
    btn.disabled = true;
    setTimeout(() => { btn.classList.remove('loading'); btn.disabled = false; }, 8000);
  });

  /* Click to fill demo credentials */
  function fillCreds(user, pass) {
    document.getElementById('username').value = user;
    document.getElementById('password').value = pass;
    if (pwInput) { pwInput.type = 'password'; }
    if (eyeIcon) eyeIcon.innerHTML = eyeOpen;
    if (toggleBtn) toggleBtn.style.opacity = '0.3';
    document.getElementById('username').focus();
  }
</script>
</body>
</html>
