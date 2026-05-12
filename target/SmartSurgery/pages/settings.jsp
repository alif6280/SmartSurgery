<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    request.setAttribute("currentPage", "settings");
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    if (fullName == null) fullName = "User";
    if (role == null) role = "Staff";
    String[] np = fullName.trim().split(" ");
    String initials = np.length >= 2
        ? ("" + np[0].charAt(0) + np[1].charAt(0)).toUpperCase()
        : fullName.substring(0, Math.min(2, fullName.length())).toUpperCase();
    com.surgery.model.Settings s = (com.surgery.model.Settings) request.getAttribute("settings");
    if (s == null) s = new com.surgery.model.Settings();
    String activeTab = request.getParameter("tab") != null ? request.getParameter("tab") : "profile";
    String msg = request.getParameter("msg");

    Long loginTime = (Long) session.getAttribute("loginTime");
    String loginIp = (String) session.getAttribute("loginIp");
    if (loginIp == null) loginIp = request.getRemoteAddr();
    String loginTimeStr = "Unknown";
    if (loginTime != null) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
        loginTimeStr = sdf.format(new java.util.Date(loginTime));
    }
    long sessionTimeoutMs = session.getMaxInactiveInterval() * 1000L;
    long sessionStartMs = loginTime != null ? loginTime : System.currentTimeMillis();
    long remainingMs = sessionStartMs + sessionTimeoutMs - System.currentTimeMillis();
    if (remainingMs < 0) remainingMs = 0;

    java.util.List<java.util.Map<String, String>> loginHistory =
        (java.util.List<java.util.Map<String, String>>) request.getAttribute("loginHistory");
    if (loginHistory == null) loginHistory = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en" id="htmlRoot">
<head>
    <meta charset="UTF-8">
    <title>Settings — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- QRCode.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        :root {
            --bg-main:#f5f7f5;--bg-card:#fff;--bg-hover:#f0f4f8;
            --border:#c8d8e8;--text-primary:#0a1628;--text-secondary:#5a7a90;
            --sb-bg:linear-gradient(160deg,#0a3d2e 0%,#0d5c3a 55%,#0a4a2e 100%);
            --topbar-bg:#fff;--topbar-border:#e2e8e2;
            --font-size:14px;
        }
        html.dark {
            --bg-main:#0f1923;--bg-card:#1a2535;--bg-hover:#1e2d3d;
            --border:#2a3d50;--text-primary:#e2eaf2;--text-secondary:#7a9ab0;
            --topbar-bg:#141e2a;--topbar-border:#2a3d50;
        }
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:var(--bg-main);font-size:var(--font-size);transition:background 0.3s,color 0.3s}
        .shell{display:flex;height:100vh;overflow:hidden}

        /* ── SIDEBAR ── */
        .sb{width:220px;flex-shrink:0;background:var(--sb-bg);display:flex;flex-direction:column;position:relative;overflow:hidden;transition:width 0.28s cubic-bezier(0.4,0,0.2,1);z-index:50;border-right:1px solid rgba(52,211,153,0.1)}
        .sb.col{width:62px}
        .sb::before{content:'';position:absolute;inset:0;background-image:radial-gradient(rgba(52,211,153,0.1) 1px,transparent 1px);background-size:22px 22px;pointer-events:none;z-index:0}
        .sb-tog{position:absolute;right:-10px;top:28px;width:20px;height:20px;background:#fff;border:1px solid #c8e0d0;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;z-index:999;box-shadow:0 2px 6px rgba(0,0,0,0.13)}
        .sb-tog svg{width:9px;height:9px;stroke:#059669;fill:none;stroke-width:2.5;transition:transform 0.28s}
        .sb.col .sb-tog svg{transform:rotate(180deg)}
        .sb-logo{padding:20px 14px 18px;border-bottom:1px solid rgba(52,211,153,0.12);display:flex;flex-direction:column;align-items:flex-start;position:relative;z-index:1;overflow:hidden;flex-shrink:0}
        .sb-ico{width:48px;height:48px;background:linear-gradient(135deg,#1a6b4a,#2d9e6b);border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:22px;margin-bottom:12px;position:relative;z-index:1}
        .sb-brand{overflow:hidden;transition:opacity 0.2s,max-height 0.28s;max-height:60px}
        .sb-brand .sb-n{font-size:13px;font-weight:800;color:#fff;letter-spacing:0.02em;line-height:1.25;text-transform:uppercase}
        .sb-brand .sb-s{font-size:10px;color:rgba(255,255,255,0.45);margin-top:4px}
        .sb.col .sb-logo{padding:14px 7px 12px;align-items:center}
        .sb.col .sb-ico{width:38px;height:38px;font-size:18px;margin-bottom:0}
        .sb.col .sb-brand{opacity:0;max-height:0;pointer-events:none}
        .sb-nav{flex:1;overflow-y:auto;overflow-x:hidden;position:relative;z-index:1;padding-bottom:8px}
        .sb-sec{padding:13px 14px 4px;font-size:8.5px;font-weight:700;color:rgba(255,255,255,0.2);text-transform:uppercase;letter-spacing:0.13em;white-space:nowrap;overflow:hidden}
        .sb.col .sb-sec{opacity:0}
        .sb-item{display:flex;align-items:center;gap:10px;padding:10px 13px;margin:2px 7px;border-radius:10px;font-size:12px;color:rgba(255,255,255,0.42);font-weight:500;cursor:pointer;transition:all 0.15s;text-decoration:none;white-space:nowrap;overflow:hidden;border:1px solid transparent}
        .sb-item:hover{background:rgba(255,255,255,0.07);color:rgba(255,255,255,0.78)}
        .sb-item.on{background:rgba(52,211,153,0.16);color:#6ee7b7;border-color:rgba(52,211,153,0.25)}
        .sb-item svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;flex-shrink:0}
        .sb-txt{transition:opacity 0.2s,max-width 0.28s;max-width:140px;overflow:hidden}
        .sb.col .sb-txt{opacity:0;max-width:0}
        .sb-dot{width:5px;height:5px;border-radius:50%;background:#34d399;margin-left:auto;animation:bl 2s infinite;flex-shrink:0}
        .sb.col .sb-dot{opacity:0}
        @keyframes bl{0%,100%{opacity:1}50%{opacity:0.2}}
        .sb-div{width:75%;height:1px;background:rgba(52,211,153,0.1);margin:6px auto;position:relative;z-index:1}
        .sb-bot{padding:10px 7px;border-top:1px solid rgba(52,211,153,0.1);position:relative;z-index:1;flex-shrink:0}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 11px;background:rgba(52,211,153,0.09);border:1px solid rgba(52,211,153,0.16);border-radius:10px;overflow:hidden}
        .sb-av{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:800;color:#fff;flex-shrink:0}
        .sb-ui{overflow:hidden;white-space:nowrap;transition:opacity 0.2s,max-width 0.28s;flex:1;max-width:120px}
        .sb-un{font-size:11px;font-weight:600;color:rgba(255,255,255,0.88)}
        .sb-ur{font-size:9px;color:rgba(255,255,255,0.3);margin-top:1px}
        .sb.col .sb-ui{opacity:0;max-width:0}
        .sb-lo{opacity:0.28;cursor:pointer;flex-shrink:0;transition:opacity 0.15s;background:none;border:none}
        .sb-lo:hover{opacity:0.8}
        .sb-lo svg{width:13px;height:13px;stroke:#fff;fill:none;stroke-width:2}
        .sb.col .sb-lo{display:none}

        /* ── MAIN ── */
        .area{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}
        .topbar{background:var(--topbar-bg);border-bottom:1px solid var(--topbar-border);padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0;transition:background 0.3s}
        .topbar-title{font-size:16px;font-weight:700;color:var(--text-primary)}
        .topbar-sub{font-size:12px;color:var(--text-secondary);margin-top:2px}
        .live-clock{display:flex;align-items:center;gap:12px}
        .clock-display{background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:12px;padding:8px 16px;display:flex;flex-direction:column;align-items:center}
        .clock-time{font-size:18px;font-weight:800;color:#fff;letter-spacing:2px;font-family:monospace}
        .clock-date{font-size:9px;color:rgba(255,255,255,0.5);margin-top:1px;text-align:center}
        .page-body{flex:1;overflow-y:auto;overflow-x:hidden;padding:24px;background:var(--bg-main);transition:background 0.3s}
        .settings-layout{display:grid;grid-template-columns:220px 1fr;gap:24px;max-width:1100px;margin:0 auto}
        .settings-nav{display:flex;flex-direction:column;gap:4px;position:sticky;top:0}
        .settings-nav-item{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:10px;font-size:13px;font-weight:500;color:var(--text-secondary);cursor:pointer;transition:all 0.15s;border:none;background:transparent;width:100%;text-align:left;font-family:'Space Grotesk',sans-serif;text-decoration:none}
        .settings-nav-item:hover{background:var(--bg-hover);color:var(--text-primary)}
        .settings-nav-item.active{background:linear-gradient(135deg,rgba(0,122,99,0.12),rgba(0,122,99,0.06));color:#007a63;font-weight:600}
        .nav-divider{height:1px;background:var(--border);margin:8px 0}
        .settings-content{display:flex;flex-direction:column;gap:20px}
        .settings-section{display:none}
        .settings-section.active{display:flex;flex-direction:column;gap:20px}
        .s-card{background:var(--bg-card);border:1px solid var(--border);border-radius:16px;overflow:hidden;transition:background 0.3s,border-color 0.3s}
        .s-card-header{padding:16px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:10px}
        .s-card-icon{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
        .s-card-icon.green{background:rgba(0,122,99,0.12)}
        .s-card-icon.blue{background:rgba(21,96,168,0.12)}
        .s-card-icon.orange{background:rgba(168,98,0,0.12)}
        .s-card-icon.red{background:rgba(168,0,40,0.12)}
        .s-card-icon.purple{background:rgba(109,40,217,0.12)}
        .s-card-title{font-size:14px;font-weight:700;color:var(--text-primary)}
        .s-card-sub{font-size:12px;color:var(--text-secondary);margin-top:1px}
        .s-card-body{padding:20px}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px}
        .form-row.full{grid-template-columns:1fr}
        .form-group{display:flex;flex-direction:column;gap:6px}
        .form-label{font-size:11px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.04em}
        .form-control{background:var(--bg-card);border:1px solid var(--border);border-radius:8px;padding:9px 13px;color:var(--text-primary);font-family:'Space Grotesk',sans-serif;font-size:13px;width:100%;outline:none;transition:border-color 0.18s,background 0.3s}
        .form-control:focus{border-color:#007a63;box-shadow:0 0 0 3px rgba(0,122,99,0.12)}
        .form-hint{font-size:11px;color:var(--text-secondary);margin-top:3px}
        .save-bar{display:flex;align-items:center;justify-content:flex-end;gap:10px;padding-top:16px;border-top:1px solid var(--border);margin-top:4px}
        .btn{display:inline-flex;align-items:center;gap:6px;padding:9px 20px;border-radius:8px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;cursor:pointer;transition:all 0.18s;border:1px solid transparent;text-decoration:none}
        .btn-primary{background:#007a63;color:#fff;border-color:#007a63}
        .btn-primary:hover{background:#005f4d}
        .btn-outline{background:transparent;color:var(--text-primary);border-color:var(--border)}
        .btn-outline:hover{background:var(--bg-hover)}
        .toggle-row{display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border)}
        .toggle-row:last-child{border-bottom:none;padding-bottom:0}
        .toggle-info h4{font-size:13px;font-weight:600;color:var(--text-primary)}
        .toggle-info p{font-size:11px;color:var(--text-secondary);margin-top:2px}
        .toggle-switch{position:relative;width:44px;height:24px;flex-shrink:0}
        .toggle-switch input{opacity:0;width:0;height:0;position:absolute}
        .toggle-slider{position:absolute;cursor:pointer;top:0;left:0;right:0;bottom:0;background:#c8d8e8;border-radius:999px;transition:0.3s}
        .toggle-slider::before{content:'';position:absolute;height:18px;width:18px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:0.3s;box-shadow:0 1px 4px rgba(0,0,0,0.2)}
        .toggle-switch input:checked+.toggle-slider{background:#007a63}
        .toggle-switch input:checked+.toggle-slider::before{transform:translateX(20px)}
        .alert-msg{padding:10px 16px;border-radius:8px;font-size:13px;margin-bottom:16px;display:flex;align-items:center;gap:8px;border:1px solid}
        .alert-success{background:rgba(0,122,99,0.08);border-color:rgba(0,122,99,0.30);color:#007a63}
        .alert-error{background:rgba(168,0,40,0.08);border-color:rgba(168,0,40,0.30);color:#a80028}
        .toast{position:fixed;bottom:24px;right:24px;padding:12px 20px;border-radius:12px;font-size:13px;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(0,0,0,0.2);z-index:9999;transform:translateY(80px);opacity:0;transition:all 0.3s cubic-bezier(0.34,1.56,0.64,1)}
        .toast.show{transform:translateY(0);opacity:1}
        .toast.success{background:linear-gradient(135deg,#007a63,#005f4d);color:#fff}
        .toast.error{background:linear-gradient(135deg,#a80028,#7a001e);color:#fff}

        /* ── PROFILE: AVATAR ── */
        .avatar-section{display:flex;align-items:center;gap:20px;margin-bottom:20px;padding:16px;background:var(--bg-hover);border-radius:12px;border:1px solid var(--border)}
        .avatar-circle{width:72px;height:72px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:28px;font-weight:700;color:#fff;flex-shrink:0;transition:background 0.3s,transform 0.2s;cursor:default;position:relative}
        .avatar-circle:hover{transform:scale(1.06)}
        .avatar-info h3{font-size:16px;font-weight:700;color:var(--text-primary)}
        .avatar-info p{font-size:12px;color:var(--text-secondary);margin-top:2px}
        .role-badge{display:inline-block;font-size:10px;font-weight:700;background:rgba(0,122,99,0.10);color:#007a63;border:1px solid rgba(0,122,99,0.30);border-radius:999px;padding:2px 10px;margin-top:6px;text-transform:uppercase}
        .color-swatches{display:flex;gap:8px;margin-top:10px;flex-wrap:wrap}
        .color-swatch{width:24px;height:24px;border-radius:50%;cursor:pointer;border:2px solid transparent;transition:all 0.18s;flex-shrink:0}
        .color-swatch:hover,.color-swatch.selected{border-color:#fff;box-shadow:0 0 0 2px #007a63;transform:scale(1.15)}
        .avatar-label{font-size:11px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.04em;margin-bottom:6px}

        /* ── LOGIN INFO CARD ── */
        .login-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px}
        .login-info-item{background:var(--bg-hover);border:1px solid var(--border);border-radius:12px;padding:14px}
        .login-info-label{font-size:10px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px}
        .login-info-value{font-size:14px;font-weight:700;color:var(--text-primary)}
        .login-info-sub{font-size:11px;color:var(--text-secondary);margin-top:3px}

        /* ── PASS STRENGTH ── */
        .pass-strength-bar-wrap{height:6px;border-radius:3px;background:var(--border);margin-top:8px;overflow:hidden}
        .pass-strength-bar{height:100%;border-radius:3px;width:0%;transition:all 0.35s cubic-bezier(0.4,0,0.2,1)}
        .pass-criteria{display:flex;flex-wrap:wrap;gap:6px;margin-top:8px}
        .pass-crit{font-size:10px;padding:3px 8px;border-radius:5px;font-weight:600;background:var(--bg-hover);color:var(--text-secondary);border:1px solid var(--border);transition:all 0.2s}
        .pass-crit.ok{background:rgba(0,122,99,0.1);color:#007a63;border-color:rgba(0,122,99,0.3)}

        /* ── HOSPITAL: LOGO ── */
        .hospital-logo-section{display:flex;gap:20px;margin-bottom:20px;align-items:flex-start}
        .logo-upload-area{width:120px;height:120px;border:2px dashed var(--border);border-radius:14px;display:flex;flex-direction:column;align-items:center;justify-content:center;cursor:pointer;transition:all 0.2s;flex-shrink:0;position:relative;overflow:hidden;background:var(--bg-hover)}
        .logo-upload-area:hover{border-color:#007a63;background:rgba(0,122,99,0.05)}
        .logo-upload-area img{width:100%;height:100%;object-fit:contain}
        .logo-upload-text{font-size:11px;color:var(--text-secondary);text-align:center;margin-top:6px;line-height:1.4}
        .logo-upload-icon{font-size:28px;margin-bottom:4px}
        .logo-info{flex:1}
        .char-counter-wrap{position:relative}
        .char-counter{position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:11px;color:var(--text-secondary);font-weight:600;pointer-events:none}
        .char-counter.warn{color:#f59e0b}
        .char-counter.over{color:#dc2626}

        /* ── QR CODE ── */
        .qr-section{background:var(--bg-hover);border:1px solid var(--border);border-radius:14px;padding:20px;display:flex;align-items:center;gap:20px;margin-top:16px}
        .qr-box{width:120px;height:120px;background:#fff;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;border:1px solid var(--border);overflow:hidden}
        .qr-info h4{font-size:13px;font-weight:700;color:var(--text-primary);margin-bottom:4px}
        .qr-info p{font-size:11px;color:var(--text-secondary);margin-bottom:12px}

        /* ── SYSTEM: DARK MODE CARD ── */
        .dark-mode-card{background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:14px;padding:20px;display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
        .dark-mode-info h3{font-size:14px;font-weight:700;color:#fff;margin-bottom:4px}
        .dark-mode-info p{font-size:12px;color:rgba(255,255,255,0.6)}
        .dark-toggle{position:relative;width:56px;height:28px;flex-shrink:0}
        .dark-toggle input{opacity:0;width:0;height:0;position:absolute}
        .dark-slider{position:absolute;cursor:pointer;top:0;left:0;right:0;bottom:0;background:rgba(255,255,255,0.2);border-radius:999px;transition:0.3s;display:flex;align-items:center;padding:4px}
        .dark-slider::before{content:'☀️';position:absolute;height:20px;width:20px;left:4px;display:flex;align-items:center;justify-content:center;font-size:12px;border-radius:50%;background:#fff;transition:0.3s}
        .dark-toggle input:checked+.dark-slider{background:rgba(52,211,153,0.4)}
        .dark-toggle input:checked+.dark-slider::before{content:'🌙';transform:translateX(28px)}

        /* ── FONT PREVIEW ── */
        .font-preview{background:var(--bg-hover);border:1px solid var(--border);border-radius:12px;padding:16px;margin-bottom:16px}
        .font-preview-text{color:var(--text-primary);margin-bottom:8px;transition:font-size 0.2s}
        .font-size-labels{display:flex;justify-content:space-between;font-size:10px;color:var(--text-secondary);margin-top:6px}
        input[type=range]{width:100%;-webkit-appearance:none;height:6px;border-radius:3px;background:linear-gradient(to right,#007a63 0%,#007a63 50%,#c8d8e8 50%,#c8d8e8 100%);outline:none;cursor:pointer}
        input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:18px;height:18px;border-radius:50%;background:#007a63;cursor:pointer;box-shadow:0 2px 6px rgba(0,122,99,0.4)}

        /* ── LANGUAGE PREVIEW ── */
        .lang-preview{background:var(--bg-hover);border:1px solid var(--border);border-radius:12px;padding:14px;margin-top:10px;font-size:12px;color:var(--text-secondary);display:flex;gap:16px;flex-wrap:wrap}
        .lang-sample{display:flex;flex-direction:column;gap:3px}
        .lang-sample-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;color:var(--text-secondary)}
        .lang-sample-text{font-size:13px;font-weight:600;color:var(--text-primary)}

        /* ── SESSION TIMER ── */
        .session-timer-card{background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:14px;padding:20px;display:flex;align-items:center;gap:16px;margin-bottom:16px}
        .timer-ring{position:relative;width:80px;height:80px;flex-shrink:0}
        .timer-ring svg{transform:rotate(-90deg)}
        .timer-ring-text{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center}
        .timer-ring-min{font-size:22px;font-weight:800;color:#fff;line-height:1}
        .timer-ring-lbl{font-size:9px;color:rgba(255,255,255,0.5);margin-top:2px}
        .timer-info h3{font-size:14px;font-weight:700;color:#fff;margin-bottom:4px}
        .timer-info p{font-size:12px;color:rgba(255,255,255,0.6)}
        .timer-badges{display:flex;gap:8px;margin-top:10px;flex-wrap:wrap}
        .timer-badge{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);border-radius:8px;padding:5px 10px;font-size:11px;color:rgba(255,255,255,0.8);display:flex;align-items:center;gap:5px}
        .timer-badge .dot{width:6px;height:6px;border-radius:50%;background:#34d399;animation:bl 2s infinite;flex-shrink:0}

        /* ── SECURITY ── */
        .security-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:16px}
        .sec-stat{background:var(--bg-hover);border:1px solid var(--border);border-radius:12px;padding:14px;text-align:center}
        .sec-stat-num{font-size:24px;font-weight:800;color:var(--text-primary)}
        .sec-stat-lbl{font-size:11px;color:var(--text-secondary);margin-top:4px}
        .sec-stat-num.green{color:#007a63}.sec-stat-num.red{color:#dc2626}
        .history-table{width:100%;border-collapse:collapse;font-size:12px}
        .history-table th{padding:8px 12px;text-align:left;font-size:10px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.05em;border-bottom:2px solid var(--border)}
        .history-table td{padding:10px 12px;border-bottom:1px solid var(--border);color:var(--text-primary)}
        .history-table tr:last-child td{border-bottom:none}
        .history-table tr:hover td{background:var(--bg-hover)}
        .status-badge{display:inline-flex;padding:2px 8px;border-radius:5px;font-size:10px;font-weight:700}
        .status-success{background:#ecfdf5;color:#059669}.status-failed{background:#fff5f5;color:#dc2626}
        .danger-item{display:flex;align-items:center;justify-content:space-between;padding:14px;background:#fff5f5;border:1px solid #fecaca;border-radius:10px;margin-bottom:10px}
        .danger-item:last-child{margin-bottom:0}
        .danger-info h4{font-size:13px;font-weight:600;color:#991b1b}
        .danger-info p{font-size:11px;color:#b91c1c;margin-top:2px;opacity:0.8}
        .btn-danger-outline{padding:7px 16px;border-radius:8px;border:1px solid #fca5a5;background:#fff;color:#dc2626;font-size:12px;font-weight:600;cursor:pointer;font-family:'Space Grotesk',sans-serif}

        /* ── ABOUT ── */
        .threshold-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:12px}
        .threshold-item{background:var(--bg-hover);border-radius:10px;padding:12px;border:1px solid var(--border)}
        .threshold-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px}
        .threshold-label.low{color:#007a63}.threshold-label.medium{color:#a86200}.threshold-label.high{color:#c03a1a}.threshold-label.critical{color:#a80028}
        .threshold-input{width:100%;border:1px solid var(--border);border-radius:6px;padding:6px 10px;font-size:13px;font-weight:600;font-family:'Space Grotesk',sans-serif;outline:none;background:var(--bg-card);color:var(--text-primary)}
        .about-logo{display:flex;align-items:center;gap:16px;padding:20px;background:linear-gradient(135deg,#0a3d2e,#0d5c3a);border-radius:14px;margin-bottom:16px}
        .about-logo-icon{width:56px;height:56px;background:linear-gradient(135deg,#1a6b4a,#2d9e6b);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:26px;flex-shrink:0}
        .about-logo-text h2{font-size:16px;font-weight:800;color:#fff;text-transform:uppercase;letter-spacing:0.05em}
        .about-logo-text p{font-size:11px;color:rgba(255,255,255,0.55);margin-top:3px}
        .about-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .about-item{background:var(--bg-hover);border-radius:10px;padding:12px 14px;border:1px solid var(--border)}
        .about-item-label{font-size:10px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.05em;margin-bottom:4px}
        .about-item-value{font-size:13px;font-weight:600;color:var(--text-primary)}

        /* ── DASHBOARD UPDATE BANNER ── */
        .dash-update-banner{background:linear-gradient(135deg,rgba(0,122,99,0.12),rgba(0,122,99,0.05));border:1px solid rgba(0,122,99,0.25);border-radius:12px;padding:12px 16px;font-size:12px;color:#007a63;display:flex;align-items:center;gap:8px;margin-bottom:12px}
    </style>
</head>
<body>
<div class="shell">

    <!-- SIDEBAR -->
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
            <a href="${pageContext.request.contextPath}/dashboard" class="sb-item">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                <span class="sb-txt">Dashboard</span>
            </a>
            <div class="sb-sec">Management</div>
            <a href="${pageContext.request.contextPath}/patients" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                <span class="sb-txt">Patients</span>
            </a>
            <a href="${pageContext.request.contextPath}/surgeries" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
                <span class="sb-txt">Surgeries</span>
            </a>
            <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="sb-item">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span class="sb-txt">Schedule Surgery</span>
            </a>
            <div class="sb-sec">Resources</div>
            <a href="${pageContext.request.contextPath}/surgeons" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M20 7H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><path d="M16 3H8l-2 4h12z"/></svg>
                <span class="sb-txt">Surgeons</span>
            </a>
            <a href="${pageContext.request.contextPath}/ot" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                <span class="sb-txt">Operation Theaters</span>
            </a>
            <div class="sb-div"></div>
            <div class="sb-sec">Account</div>
            <a href="${pageContext.request.contextPath}/settings" class="sb-item on">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                <span class="sb-txt">Settings</span>
                <span class="sb-dot"></span>
            </a>
            <a href="${pageContext.request.contextPath}/about" class="sb-item">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <span class="sb-txt">About</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="sb-item">
                <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                <span class="sb-txt">Logout</span>
            </a>
        </div>
        <div class="sb-bot">
            <div class="sb-user">
                <div class="sb-av" id="sbAvatar"><%= initials %></div>
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

    <!-- MAIN -->
    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title" id="topbarTitle">⚙️ <span data-i18n="settings">Settings</span></div>
                <div class="topbar-sub" id="topbarSub" data-i18n="settings_sub">Manage your Smart Surgery System preferences</div>
            </div>
            <div class="live-clock">
                <div class="clock-display">
                    <div class="clock-time" id="liveClock">--:--:--</div>
                    <div class="clock-date" id="liveDate">Loading...</div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <% if ("saved".equals(msg)) { %><div class="alert-msg alert-success">✅ Settings saved successfully!</div><% } %>
            <% if ("error".equals(msg)) { %><div class="alert-msg alert-error">❌ Failed to save settings.</div><% } %>
            <% if ("pass_saved".equals(msg)) { %><div class="alert-msg alert-success">✅ Password updated successfully!</div><% } %>
            <% if ("pass_mismatch".equals(msg)) { %><div class="alert-msg alert-error">❌ Passwords do not match!</div><% } %>
            <% if ("pass_weak".equals(msg)) { %><div class="alert-msg alert-error">❌ Password too short (min 6 characters)!</div><% } %>
            <% if ("pass_wrong".equals(msg)) { %><div class="alert-msg alert-error">❌ Current password is incorrect!</div><% } %>

            <div class="settings-layout">
                <!-- SIDE NAV -->
                <div class="settings-nav">
                    <a href="?tab=profile"       class="settings-nav-item <%= "profile".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_profile">👤 Profile</a>
                    <a href="?tab=hospital"      class="settings-nav-item <%= "hospital".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_hospital">🏥 Hospital</a>
                    <a href="?tab=system"        class="settings-nav-item <%= "system".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_system">🖥️ System</a>
                    <a href="?tab=risk"          class="settings-nav-item <%= "risk".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_risk">📊 Risk Settings</a>
                    <div class="nav-divider"></div>
                    <a href="?tab=notifications" class="settings-nav-item <%= "notifications".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_notif">🔔 Notifications</a>
                    <a href="?tab=security"      class="settings-nav-item <%= "security".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_security">🔒 Security</a>
                    <div class="nav-divider"></div>
                    <a href="?tab=about"         class="settings-nav-item <%= "about".equals(activeTab) ? "active" : "" %>" data-i18n-nav="nav_about">ℹ️ About</a>
                </div>

                <div class="settings-content">

                    <!-- ═══════════ PROFILE TAB ═══════════ -->
                    <div class="settings-section <%= "profile".equals(activeTab) ? "active" : "" %>">

                        <!-- Avatar Color + Live Preview -->
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">👤</div><div><div class="s-card-title" data-i18n="profile_title">Profile Information</div><div class="s-card-sub" data-i18n="profile_sub">Your personal account details</div></div></div>
                            <div class="s-card-body">
                                <div class="avatar-section">
                                    <div class="avatar-circle" id="bigAvatar"><%= initials %></div>
                                    <div class="avatar-info">
                                        <h3 id="avatarName"><%= fullName %></h3>
                                        <p data-i18n="profile_desc">Smart Surgery System User</p>
                                        <span class="role-badge"><%= role %></span>
                                        <div style="margin-top:12px">
                                            <div class="avatar-label" data-i18n="avatar_color">Avatar Color</div>
                                            <div class="color-swatches" id="colorSwatches">
                                                <!-- swatches generated by JS -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="profile">
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="label_fullname">Full Name</label>
                                            <input type="text" name="fullName" id="fullNameInput" class="form-control" value="<%= fullName %>" oninput="updateAvatarPreview(this.value)">
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="label_role">Role</label>
                                            <input type="text" class="form-control" value="<%= role %>" disabled style="opacity:0.6;cursor:not-allowed;">
                                        </div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_save_profile">💾 Save Profile</button></div>
                                </form>
                            </div>
                        </div>

                        <!-- Last Login & Session Info -->
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon blue">🕐</div><div><div class="s-card-title" data-i18n="login_info_title">Login & Session Info</div><div class="s-card-sub" data-i18n="login_info_sub">Last login details and current session</div></div></div>
                            <div class="s-card-body">
                                <div class="login-info-grid">
                                    <div class="login-info-item">
                                        <div class="login-info-label" data-i18n="last_login">Last Login Time</div>
                                        <div class="login-info-value"><%= loginTimeStr %></div>
                                        <div class="login-info-sub">This device</div>
                                    </div>
                                    <div class="login-info-item">
                                        <div class="login-info-label" data-i18n="login_ip">Login IP Address</div>
                                        <div class="login-info-value" style="font-family:monospace;font-size:13px"><%= loginIp %></div>
                                        <div class="login-info-sub">IPv4 Address</div>
                                    </div>
                                    <div class="login-info-item">
                                        <div class="login-info-label" data-i18n="session_duration">Session Duration</div>
                                        <div class="login-info-value" id="profileSessionDur">Calculating...</div>
                                        <div class="login-info-sub" data-i18n="session_active">Currently active</div>
                                    </div>
                                    <div class="login-info-item">
                                        <div class="login-info-label" data-i18n="session_timeout_label">Session Timeout</div>
                                        <div class="login-info-value" id="profileTimeLeft">Calculating...</div>
                                        <div class="login-info-sub" data-i18n="session_remaining">Remaining time</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Change Password with Live Strength Meter -->
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">🔑</div><div><div class="s-card-title" data-i18n="pass_title">Change Password</div><div class="s-card-sub" data-i18n="pass_sub">Update your login credentials</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="password">
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="current_pass">Current Password</label>
                                            <input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="new_pass">New Password</label>
                                            <input type="password" name="newPassword" id="newPass" class="form-control" placeholder="••••••••" oninput="checkPassStrength()" required>
                                            <div class="pass-strength-bar-wrap"><div id="passBar" class="pass-strength-bar"></div></div>
                                            <div class="pass-criteria" id="passCriteria">
                                                <span class="pass-crit" id="pc-len" data-i18n="pc_len">8+ chars</span>
                                                <span class="pass-crit" id="pc-upper" data-i18n="pc_upper">Uppercase</span>
                                                <span class="pass-crit" id="pc-num" data-i18n="pc_num">Number</span>
                                                <span class="pass-crit" id="pc-sym" data-i18n="pc_sym">Symbol</span>
                                            </div>
                                            <div class="form-hint" id="passHint" data-i18n="pass_hint">Enter new password</div>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="confirm_pass">Confirm New Password</label>
                                            <input type="password" name="confirmPassword" id="confirmPass" class="form-control" placeholder="••••••••" oninput="checkConfirm()" required>
                                            <div class="form-hint" id="confirmHint"></div>
                                        </div>
                                        <div></div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_update_pass">🔑 Update Password</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ HOSPITAL TAB ═══════════ -->
                    <div class="settings-section <%= "hospital".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon blue">🏥</div><div><div class="s-card-title" data-i18n="hospital_title">Hospital Information</div><div class="s-card-sub" data-i18n="hospital_sub">Hospital details and branding</div></div></div>
                            <div class="s-card-body">

                                <!-- Logo Upload & Preview -->
                                <div class="hospital-logo-section">
                                    <div>
                                        <div class="avatar-label" style="margin-bottom:8px" data-i18n="hospital_logo">Hospital Logo</div>
                                        <div class="logo-upload-area" id="logoDropArea" onclick="document.getElementById('logoFileInput').click()">
                                            <img id="logoPreview" src="" style="display:none">
                                            <div id="logoPlaceholder">
                                                <div class="logo-upload-icon">🏥</div>
                                                <div class="logo-upload-text" data-i18n="logo_upload_hint">Click to upload<br>PNG/JPG/SVG</div>
                                            </div>
                                        </div>
                                        <input type="file" id="logoFileInput" accept="image/*" style="display:none" onchange="handleLogoUpload(this)">
                                        <button class="btn btn-outline" style="width:120px;margin-top:8px;font-size:11px;padding:6px" onclick="clearLogo()" data-i18n="btn_remove_logo">🗑️ Remove</button>
                                    </div>
                                    <div class="logo-info" style="flex:1">
                                        <div class="avatar-label" data-i18n="hospital_name_label">Hospital Name</div>
                                        <div class="char-counter-wrap" style="margin-top:6px">
                                            <input type="text" id="hospitalNameInput" class="form-control" value="<%= s.get("hospital_name","Khwaja Yunus Ali Medical College Hospital") %>" maxlength="80" oninput="updateCharCounter(this,'hospitalNameCounter',80); updateQR();" style="padding-right:50px">
                                            <span class="char-counter" id="hospitalNameCounter">0/80</span>
                                        </div>
                                        <div class="form-hint" data-i18n="hospital_name_hint">Name shown in dashboard & reports</div>
                                        <div class="dash-update-banner" style="margin-top:12px">
                                            🔄 <span data-i18n="dashboard_sync_hint">Hospital name changes will automatically update the Dashboard header.</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- QR Code -->
                                <div class="qr-section">
                                    <div class="qr-box" id="qrCodeBox">
                                        <span style="font-size:11px;color:#aaa;text-align:center;padding:8px" data-i18n="qr_placeholder">QR will appear here</span>
                                    </div>
                                    <div class="qr-info">
                                        <h4 data-i18n="qr_title">Hospital QR Code</h4>
                                        <p data-i18n="qr_sub">Scan to get hospital information. Updates live as you type the name.</p>
                                        <div style="display:flex;gap:8px;flex-wrap:wrap">
                                            <button class="btn btn-primary" onclick="generateQR()" data-i18n="btn_gen_qr">📱 Generate QR</button>
                                            <button class="btn btn-outline" onclick="downloadQR()" data-i18n="btn_dl_qr">⬇️ Download</button>
                                        </div>
                                    </div>
                                </div>

                                <form method="post" action="${pageContext.request.contextPath}/settings" style="margin-top:20px">
                                    <input type="hidden" name="action" value="hospital">
                                    <input type="hidden" id="hospitalNameHidden" name="hospital_name" value="<%= s.get("hospital_name","Khwaja Yunus Ali Medical College Hospital") %>">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label" data-i18n="hospital_code">Hospital Code</label><input type="text" name="hospital_code" class="form-control" value="<%= s.get("hospital_code","KYAMCH") %>"></div>
                                        <div class="form-group"><label class="form-label" data-i18n="hospital_license">License Number</label><input type="text" name="hospital_license" class="form-control" value="<%= s.get("hospital_license","DGHS-2024-001") %>"></div>
                                    </div>
                                    <div class="form-row full"><div class="form-group"><label class="form-label" data-i18n="hospital_address">Address</label><input type="text" name="hospital_address" class="form-control" value="<%= s.get("hospital_address","Enayetpur, Sirajganj, Bangladesh") %>"></div></div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label" data-i18n="hospital_phone">Phone</label><input type="text" name="hospital_phone" class="form-control" value="<%= s.get("hospital_phone","") %>"></div>
                                        <div class="form-group"><label class="form-label" data-i18n="hospital_email">Email</label><input type="email" name="hospital_email" class="form-control" value="<%= s.get("hospital_email","info@kyamch.org") %>"></div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label" data-i18n="total_ot">Total OT Rooms</label><input type="number" name="hospital_total_ot" class="form-control" value="<%= s.get("hospital_total_ot","6") %>" min="1"></div>
                                        <div class="form-group"><label class="form-label" data-i18n="max_surgeries">Max Surgeries/Day</label><input type="number" name="hospital_max_surgeries_day" class="form-control" value="<%= s.get("hospital_max_surgeries_day","12") %>" min="1"></div>
                                    </div>
                                    <div class="save-bar">
                                        <button type="submit" class="btn btn-primary" onclick="syncHospitalName()" data-i18n="btn_save">💾 Save Changes</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ SYSTEM TAB ═══════════ -->
                    <div class="settings-section <%= "system".equals(activeTab) ? "active" : "" %>">

                        <!-- Dark Mode -->
                        <div class="dark-mode-card">
                            <div class="dark-mode-info">
                                <h3>🌙 <span data-i18n="dark_mode_title">Dark Mode</span></h3>
                                <p data-i18n="dark_mode_sub">Switch between light and dark theme — applies to all pages instantly</p>
                            </div>
                            <label class="dark-toggle">
                                <input type="checkbox" id="darkModeToggle" onchange="toggleDarkMode(this.checked)">
                                <span class="dark-slider"></span>
                            </label>
                        </div>

                        <!-- Font Size -->
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon purple">🔡</div><div><div class="s-card-title" data-i18n="font_size_title">Font Size</div><div class="s-card-sub" data-i18n="font_size_sub">Adjust text size — applies everywhere in real-time</div></div></div>
                            <div class="s-card-body">
                                <div class="font-preview" id="fontPreview">
                                    <div class="font-preview-text" id="previewText" style="font-size:14px;font-weight:600" data-i18n="font_preview">Smart Surgery System — Preview Text আব্দুল্লাহ রহমান</div>
                                    <div style="font-size:11px;color:var(--text-secondary)"><span data-i18n="current_size">Current size</span>: <span id="fontSizeLabel">14px</span></div>
                                </div>
                                <input type="range" id="fontSizeSlider" min="12" max="18" value="14" step="1" oninput="changeFontSize(this.value)">
                                <div class="font-size-labels"><span data-i18n="small">Small (12px)</span><span data-i18n="normal">Normal (14px)</span><span data-i18n="large">Large (18px)</span></div>
                            </div>
                        </div>

                        <!-- System Preferences -->
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon purple">🖥️</div><div><div class="s-card-title" data-i18n="sys_prefs_title">System Preferences</div><div class="s-card-sub" data-i18n="sys_prefs_sub">Configure system-wide settings</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="system">
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="timezone">Timezone</label>
                                            <select name="sys_timezone" id="timezoneSelect" class="form-control" onchange="updateClockTimezone(this.value)">
                                                <option value="Asia/Dhaka" <%= "Asia/Dhaka".equals(s.get("sys_timezone","Asia/Dhaka")) ? "selected" : "" %>>Asia/Dhaka (GMT+6)</option>
                                                <option value="Asia/Kolkata" <%= "Asia/Kolkata".equals(s.get("sys_timezone")) ? "selected" : "" %>>Asia/Kolkata (GMT+5:30)</option>
                                                <option value="UTC" <%= "UTC".equals(s.get("sys_timezone")) ? "selected" : "" %>>UTC (GMT+0)</option>
                                                <option value="America/New_York" <%= "America/New_York".equals(s.get("sys_timezone")) ? "selected" : "" %>>America/New_York (GMT-5)</option>
                                                <option value="Europe/London" <%= "Europe/London".equals(s.get("sys_timezone")) ? "selected" : "" %>>Europe/London (GMT+1)</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="date_format">Date Format</label>
                                            <select name="sys_date_format" class="form-control">
                                                <option value="DD/MM/YYYY" <%= "DD/MM/YYYY".equals(s.get("sys_date_format","DD/MM/YYYY")) ? "selected" : "" %>>DD/MM/YYYY</option>
                                                <option value="MM/DD/YYYY" <%= "MM/DD/YYYY".equals(s.get("sys_date_format")) ? "selected" : "" %>>MM/DD/YYYY</option>
                                                <option value="YYYY-MM-DD" <%= "YYYY-MM-DD".equals(s.get("sys_date_format")) ? "selected" : "" %>>YYYY-MM-DD</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="language">Language</label>
                                            <select name="sys_language" id="languageSelect" class="form-control" onchange="changeLanguage(this.value)">
                                                <option value="English" <%= "English".equals(s.get("sys_language","English")) ? "selected" : "" %>>English</option>
                                                <option value="Bengali" <%= "Bengali".equals(s.get("sys_language")) ? "selected" : "" %>>বাংলা (Bengali)</option>
                                            </select>
                                            <div class="lang-preview" id="langPreview">
                                                <div class="lang-sample">
                                                    <div class="lang-sample-label" data-i18n="preview">Preview</div>
                                                    <div class="lang-sample-text" id="langSampleText">Dashboard / Settings / Patients</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="time_format">Time Format</label>
                                            <select name="sys_time_format" id="timeFormatSelect" class="form-control" onchange="saveTimeFormat(this.value)">
                                                <option value="12" <%= "12".equals(s.get("sys_time_format","12")) ? "selected" : "" %>>12 Hour (AM/PM)</option>
                                                <option value="24" <%= "24".equals(s.get("sys_time_format")) ? "selected" : "" %>>24 Hour</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="ot_start">OT Start Time</label>
                                            <input type="time" name="sys_ot_start" id="otStart" class="form-control" value="<%= s.get("sys_ot_start","06:00") %>" onchange="saveDashboardOT()">
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label" data-i18n="ot_end">OT End Time</label>
                                            <input type="time" name="sys_ot_end" id="otEnd" class="form-control" value="<%= s.get("sys_ot_end","22:00") %>" onchange="saveDashboardOT()">
                                        </div>
                                    </div>
                                    <div class="dash-update-banner">
                                        🔄 <span data-i18n="ot_sync_hint">OT Start/End times will reflect on the Dashboard automatically after save.</span>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_save">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ RISK TAB ═══════════ -->
                    <div class="settings-section <%= "risk".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">📊</div><div><div class="s-card-title" data-i18n="risk_title">Risk Score Thresholds</div><div class="s-card-sub" data-i18n="risk_sub">Define risk level boundaries</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="risk">
                                    <div class="threshold-grid">
                                        <div class="threshold-item"><div class="threshold-label low">🟢 Low Risk Max</div><input type="number" name="risk_low_max" class="threshold-input" value="<%= s.get("risk_low_max","25") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label medium">🟡 Medium Risk Max</div><input type="number" name="risk_medium_max" class="threshold-input" value="<%= s.get("risk_medium_max","50") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label high">🟠 High Risk Max</div><input type="number" name="risk_high_max" class="threshold-input" value="<%= s.get("risk_high_max","75") %>" min="1" max="99"></div>
                                        <div class="threshold-item"><div class="threshold-label critical">🔴 Critical Risk</div><input type="number" class="threshold-input" value="100" disabled style="opacity:0.5;cursor:not-allowed;"></div>
                                    </div>
                                    <div style="margin-top:20px;padding-top:16px;border-top:1px solid var(--border);">
                                        <div style="font-size:12px;font-weight:700;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.05em;margin-bottom:12px;" data-i18n="weight_factors">Score Weight Factors</div>
                                        <div class="form-row">
                                            <div class="form-group"><label class="form-label" data-i18n="asa_weight">ASA Grade Weight</label><input type="number" name="risk_asa_weight" class="form-control" value="<%= s.get("risk_asa_weight","30") %>" min="0" max="50"></div>
                                            <div class="form-group"><label class="form-label" data-i18n="age_weight">Age Factor Weight</label><input type="number" name="risk_age_weight" class="form-control" value="<%= s.get("risk_age_weight","20") %>" min="0" max="50"></div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group"><label class="form-label" data-i18n="comorbidity_weight">Comorbidity Weight</label><input type="number" name="risk_comorbidity_weight" class="form-control" value="<%= s.get("risk_comorbidity_weight","35") %>" min="0" max="50"></div>
                                            <div class="form-group"><label class="form-label" data-i18n="bmi_weight">BMI Factor Weight</label><input type="number" name="risk_bmi_weight" class="form-control" value="<%= s.get("risk_bmi_weight","10") %>" min="0" max="20"></div>
                                        </div>
                                    </div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_save">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ NOTIFICATIONS TAB ═══════════ -->
                    <div class="settings-section <%= "notifications".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon orange">🔔</div><div><div class="s-card-title" data-i18n="notif_title">Notification Preferences</div><div class="s-card-sub" data-i18n="notif_sub">Control what alerts you receive</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="notifications">
                                    <div class="toggle-row"><div class="toggle-info"><h4>🚨 <span data-i18n="notif_critical">Critical Risk Alerts</span></h4><p data-i18n="notif_critical_sub">Notify when a patient reaches critical risk level</p></div><label class="toggle-switch"><input type="checkbox" name="notif_critical_risk" <%= s.getBool("notif_critical_risk") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📅 <span data-i18n="notif_surgery">Surgery Reminders</span></h4><p data-i18n="notif_surgery_sub">Remind 1 hour before scheduled surgery</p></div><label class="toggle-switch"><input type="checkbox" name="notif_surgery_reminder" <%= s.getBool("notif_surgery_reminder") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🏨 <span data-i18n="notif_ot">OT Conflict Alerts</span></h4><p data-i18n="notif_ot_sub">Alert when OT scheduling conflict is detected</p></div><label class="toggle-switch"><input type="checkbox" name="notif_ot_conflict" <%= s.getBool("notif_ot_conflict") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>👨‍⚕️ <span data-i18n="notif_surgeon">Surgeon Unavailability</span></h4><p data-i18n="notif_surgeon_sub">Notify when assigned surgeon becomes unavailable</p></div><label class="toggle-switch"><input type="checkbox" name="notif_surgeon_unavail" <%= s.getBool("notif_surgeon_unavail") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>✅ <span data-i18n="notif_preop">Pre-op Checklist Incomplete</span></h4><p data-i18n="notif_preop_sub">Alert when pre-op items are incomplete</p></div><label class="toggle-switch"><input type="checkbox" name="notif_preop_incomplete" <%= s.getBool("notif_preop_incomplete") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📊 <span data-i18n="notif_daily">Daily Summary Report</span></h4><p data-i18n="notif_daily_sub">Send daily surgery summary at end of day</p></div><label class="toggle-switch"><input type="checkbox" name="notif_daily_summary" <%= s.getBool("notif_daily_summary") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🧹 <span data-i18n="notif_sterilize">Sterilization Complete</span></h4><p data-i18n="notif_sterilize_sub">Notify when OT sterilization is finished</p></div><label class="toggle-switch"><input type="checkbox" name="notif_sterilization" <%= s.getBool("notif_sterilization") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_save_prefs">💾 Save Preferences</button></div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ SECURITY TAB ═══════════ -->
                    <div class="settings-section <%= "security".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">⏱️</div><div><div class="s-card-title" data-i18n="session_status_title">Live Session Status</div><div class="s-card-sub" data-i18n="session_status_sub">Real-time session information</div></div></div>
                            <div class="s-card-body">
                                <div class="session-timer-card">
                                    <div class="timer-ring">
                                        <svg width="80" height="80" viewBox="0 0 80 80">
                                            <circle cx="40" cy="40" r="34" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="6"/>
                                            <circle id="timerArc" cx="40" cy="40" r="34" fill="none" stroke="#34d399" stroke-width="6" stroke-linecap="round" stroke-dasharray="213.6" stroke-dashoffset="0"/>
                                        </svg>
                                        <div class="timer-ring-text">
                                            <div class="timer-ring-min" id="timerMin">--</div>
                                            <div class="timer-ring-lbl">min left</div>
                                        </div>
                                    </div>
                                    <div class="timer-info">
                                        <h3 data-i18n="session_active_title">Session Active</h3>
                                        <p><span data-i18n="logged_in">Logged in</span>: <%= loginTimeStr %></p>
                                        <div class="timer-badges">
                                            <div class="timer-badge"><span class="dot"></span>IP: <%= loginIp %></div>
                                            <div class="timer-badge">🔐 <span data-i18n="secured">Secured</span></div>
                                            <div class="timer-badge" id="sessionDuration"><span data-i18n="duration">Duration</span>: --</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="security-stats">
                                    <div class="sec-stat"><div class="sec-stat-num green"><%= loginHistory.size() %></div><div class="sec-stat-lbl" data-i18n="total_logins">Total Logins</div></div>
                                    <div class="sec-stat"><div class="sec-stat-num green"><%= loginHistory.stream().filter(h -> "SUCCESS".equals(h.get("status"))).count() %></div><div class="sec-stat-lbl" data-i18n="successful">Successful</div></div>
                                    <div class="sec-stat"><div class="sec-stat-num red"><%= loginHistory.stream().filter(h -> "FAILED".equals(h.get("status"))).count() %></div><div class="sec-stat-lbl" data-i18n="failed_attempts">Failed Attempts</div></div>
                                </div>
                            </div>
                        </div>

                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">🔒</div><div><div class="s-card-title" data-i18n="sec_settings_title">Security Settings</div><div class="s-card-sub" data-i18n="sec_settings_sub">Manage access and security preferences</div></div></div>
                            <div class="s-card-body">
                                <form method="post" action="${pageContext.request.contextPath}/settings">
                                    <input type="hidden" name="action" value="security">
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label" data-i18n="session_timeout">Session Timeout</label><select name="sec_session_timeout" class="form-control"><option value="15" <%= "15".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>15 minutes</option><option value="30" <%= "30".equals(s.get("sec_session_timeout","30")) ? "selected" : "" %>>30 minutes</option><option value="60" <%= "60".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>60 minutes</option><option value="0" <%= "0".equals(s.get("sec_session_timeout")) ? "selected" : "" %>>Never</option></select></div>
                                        <div class="form-group"><label class="form-label" data-i18n="max_attempts">Max Login Attempts</label><select name="sec_max_login_attempts" class="form-control"><option value="3" <%= "3".equals(s.get("sec_max_login_attempts")) ? "selected" : "" %>>3 attempts</option><option value="5" <%= "5".equals(s.get("sec_max_login_attempts","5")) ? "selected" : "" %>>5 attempts</option><option value="10" <%= "10".equals(s.get("sec_max_login_attempts")) ? "selected" : "" %>>10 attempts</option></select></div>
                                    </div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>🔔 <span data-i18n="login_notif">Login Notifications</span></h4><p data-i18n="login_notif_sub">Alert on new login</p></div><label class="toggle-switch"><input type="checkbox" name="sec_login_notify" <%= s.getBool("sec_login_notify") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="toggle-row"><div class="toggle-info"><h4>📝 <span data-i18n="activity_log">Activity Logging</span></h4><p data-i18n="activity_log_sub">Log all user actions for audit trail</p></div><label class="toggle-switch"><input type="checkbox" name="sec_activity_log" <%= s.getBool("sec_activity_log") ? "checked" : "" %>><span class="toggle-slider"></span></label></div>
                                    <div class="save-bar"><button type="submit" class="btn btn-primary" data-i18n="btn_save">💾 Save Changes</button></div>
                                </form>
                            </div>
                        </div>

                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon blue">📋</div><div><div class="s-card-title" data-i18n="login_history_title">Login History</div><div class="s-card-sub" data-i18n="login_history_sub">Last 10 login attempts</div></div></div>
                            <div class="s-card-body" style="padding:0">
                                <% if (loginHistory.isEmpty()) { %>
                                    <div style="text-align:center;padding:24px;color:#64748b;font-size:13px" data-i18n="no_history">No login history found</div>
                                <% } else { %>
                                    <table class="history-table">
                                        <thead><tr><th data-i18n="th_datetime">Date & Time</th><th data-i18n="th_ip">IP Address</th><th data-i18n="th_status">Status</th></tr></thead>
                                        <tbody>
                                        <% for (java.util.Map<String, String> h : loginHistory) { %>
                                            <tr><td><%= h.get("time") %></td><td><%= h.get("ip") %></td><td><span class="status-badge <%= "SUCCESS".equals(h.get("status")) ? "status-success" : "status-failed" %>"><%= h.get("status") %></span></td></tr>
                                        <% } %>
                                        </tbody>
                                    </table>
                                <% } %>
                            </div>
                        </div>

                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon red">⚠️</div><div><div class="s-card-title" data-i18n="danger_zone">Danger Zone</div><div class="s-card-sub" data-i18n="danger_zone_sub">Irreversible actions</div></div></div>
                            <div class="s-card-body">
                                <div class="danger-item">
                                    <div class="danger-info"><h4 data-i18n="reset_title">Reset System to Default</h4><p data-i18n="reset_sub">Reset all settings to factory defaults.</p></div>
                                    <button class="btn-danger-outline" onclick="if(confirm('Reset all settings?')) window.location.href='${pageContext.request.contextPath}/settings?action=reset'">⚙️ <span data-i18n="btn_reset">Reset</span></button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ═══════════ ABOUT TAB ═══════════ -->
                    <div class="settings-section <%= "about".equals(activeTab) ? "active" : "" %>">
                        <div class="s-card">
                            <div class="s-card-header"><div class="s-card-icon green">ℹ️</div><div><div class="s-card-title" data-i18n="about_title">About Smart Surgery System</div><div class="s-card-sub" data-i18n="about_sub">System information and version details</div></div></div>
                            <div class="s-card-body">
                                <div class="about-logo"><div class="about-logo-icon">🏥</div><div class="about-logo-text"><h2>Smart Surgery Scheduling</h2><p>Risk Analysis & Surgical Management System</p></div></div>
                                <div class="about-grid">
                                    <div class="about-item"><div class="about-item-label" data-i18n="sys_name">System Name</div><div class="about-item-value">Smart Surgery System</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="version">Version</div><div class="about-item-value">v1.0.0 (2026)</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="hospital_label">Hospital</div><div class="about-item-value"><%= s.get("hospital_code","KYAMCH") %></div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="platform">Platform</div><div class="about-item-value">Jakarta EE / Tomcat</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="database">Database</div><div class="about-item-value">MySQL 8.0</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="framework">Framework</div><div class="about-item-value">Java Servlets + JSP</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="build_date">Build Date</div><div class="about-item-value">May 2026</div></div>
                                    <div class="about-item"><div class="about-item-label" data-i18n="license">License</div><div class="about-item-value">Academic Project</div></div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
// ════════════════════════════════════════════════════
//  i18n — Translation strings (English & Bengali)
// ════════════════════════════════════════════════════
var TRANSLATIONS = {
    English: {
        settings: 'Settings',
        settings_sub: 'Manage your Smart Surgery System preferences',
        nav_profile: '👤 Profile',
        nav_hospital: '🏥 Hospital',
        nav_system: '🖥️ System',
        nav_risk: '📊 Risk Settings',
        nav_notif: '🔔 Notifications',
        nav_security: '🔒 Security',
        nav_about: 'ℹ️ About',
        profile_title: 'Profile Information',
        profile_sub: 'Your personal account details',
        profile_desc: 'Smart Surgery System User',
        avatar_color: 'Avatar Color',
        label_fullname: 'Full Name',
        label_role: 'Role',
        btn_save_profile: '💾 Save Profile',
        login_info_title: 'Login & Session Info',
        login_info_sub: 'Last login details and current session',
        last_login: 'Last Login Time',
        login_ip: 'Login IP Address',
        session_duration: 'Session Duration',
        session_active: 'Currently active',
        session_timeout_label: 'Session Timeout',
        session_remaining: 'Remaining time',
        pass_title: 'Change Password',
        pass_sub: 'Update your login credentials',
        current_pass: 'Current Password',
        new_pass: 'New Password',
        pc_len: '8+ chars',
        pc_upper: 'Uppercase',
        pc_num: 'Number',
        pc_sym: 'Symbol',
        pass_hint: 'Enter new password',
        confirm_pass: 'Confirm New Password',
        btn_update_pass: '🔑 Update Password',
        hospital_title: 'Hospital Information',
        hospital_sub: 'Hospital details and branding',
        hospital_logo: 'Hospital Logo',
        logo_upload_hint: 'Click to upload\nPNG/JPG/SVG',
        btn_remove_logo: '🗑️ Remove',
        hospital_name_label: 'Hospital Name',
        hospital_name_hint: 'Name shown in dashboard & reports',
        dashboard_sync_hint: 'Hospital name changes will automatically update the Dashboard header.',
        qr_placeholder: 'QR will appear here',
        qr_title: 'Hospital QR Code',
        qr_sub: 'Scan to get hospital information. Updates live as you type the name.',
        btn_gen_qr: '📱 Generate QR',
        btn_dl_qr: '⬇️ Download',
        hospital_code: 'Hospital Code',
        hospital_license: 'License Number',
        hospital_address: 'Address',
        hospital_phone: 'Phone',
        hospital_email: 'Email',
        total_ot: 'Total OT Rooms',
        max_surgeries: 'Max Surgeries/Day',
        btn_save: '💾 Save Changes',
        dark_mode_title: 'Dark Mode',
        dark_mode_sub: 'Switch between light and dark theme — applies to all pages instantly',
        font_size_title: 'Font Size',
        font_size_sub: 'Adjust text size — applies everywhere in real-time',
        font_preview: 'Smart Surgery System — Preview Text আব্দুল্লাহ রহমান',
        current_size: 'Current size',
        small: 'Small (12px)',
        normal: 'Normal (14px)',
        large: 'Large (18px)',
        sys_prefs_title: 'System Preferences',
        sys_prefs_sub: 'Configure system-wide settings',
        timezone: 'Timezone',
        date_format: 'Date Format',
        language: 'Language',
        preview: 'Preview',
        time_format: 'Time Format',
        ot_start: 'OT Start Time',
        ot_end: 'OT End Time',
        ot_sync_hint: 'OT Start/End times will reflect on the Dashboard automatically after save.',
        risk_title: 'Risk Score Thresholds',
        risk_sub: 'Define risk level boundaries',
        weight_factors: 'Score Weight Factors',
        asa_weight: 'ASA Grade Weight',
        age_weight: 'Age Factor Weight',
        comorbidity_weight: 'Comorbidity Weight',
        bmi_weight: 'BMI Factor Weight',
        notif_title: 'Notification Preferences',
        notif_sub: 'Control what alerts you receive',
        notif_critical: 'Critical Risk Alerts',
        notif_critical_sub: 'Notify when a patient reaches critical risk level',
        notif_surgery: 'Surgery Reminders',
        notif_surgery_sub: 'Remind 1 hour before scheduled surgery',
        notif_ot: 'OT Conflict Alerts',
        notif_ot_sub: 'Alert when OT scheduling conflict is detected',
        notif_surgeon: 'Surgeon Unavailability',
        notif_surgeon_sub: 'Notify when assigned surgeon becomes unavailable',
        notif_preop: 'Pre-op Checklist Incomplete',
        notif_preop_sub: 'Alert when pre-op items are incomplete',
        notif_daily: 'Daily Summary Report',
        notif_daily_sub: 'Send daily surgery summary at end of day',
        notif_sterilize: 'Sterilization Complete',
        notif_sterilize_sub: 'Notify when OT sterilization is finished',
        btn_save_prefs: '💾 Save Preferences',
        session_status_title: 'Live Session Status',
        session_status_sub: 'Real-time session information',
        session_active_title: 'Session Active',
        logged_in: 'Logged in',
        secured: 'Secured',
        duration: 'Duration',
        total_logins: 'Total Logins',
        successful: 'Successful',
        failed_attempts: 'Failed Attempts',
        sec_settings_title: 'Security Settings',
        sec_settings_sub: 'Manage access and security preferences',
        session_timeout: 'Session Timeout',
        max_attempts: 'Max Login Attempts',
        login_notif: 'Login Notifications',
        login_notif_sub: 'Alert on new login',
        activity_log: 'Activity Logging',
        activity_log_sub: 'Log all user actions for audit trail',
        login_history_title: 'Login History',
        login_history_sub: 'Last 10 login attempts',
        no_history: 'No login history found',
        th_datetime: 'Date & Time',
        th_ip: 'IP Address',
        th_status: 'Status',
        danger_zone: 'Danger Zone',
        danger_zone_sub: 'Irreversible actions',
        reset_title: 'Reset System to Default',
        reset_sub: 'Reset all settings to factory defaults.',
        btn_reset: 'Reset',
        about_title: 'About Smart Surgery System',
        about_sub: 'System information and version details',
        sys_name: 'System Name',
        version: 'Version',
        hospital_label: 'Hospital',
        platform: 'Platform',
        database: 'Database',
        framework: 'Framework',
        build_date: 'Build Date',
        license: 'License',
    },
    Bengali: {
        settings: 'সেটিংস',
        settings_sub: 'আপনার স্মার্ট সার্জারি সিস্টেমের পছন্দ পরিচালনা করুন',
        nav_profile: '👤 প্রোফাইল',
        nav_hospital: '🏥 হাসপাতাল',
        nav_system: '🖥️ সিস্টেম',
        nav_risk: '📊 ঝুঁকি সেটিংস',
        nav_notif: '🔔 বিজ্ঞপ্তি',
        nav_security: '🔒 নিরাপত্তা',
        nav_about: 'ℹ️ সম্পর্কে',
        profile_title: 'প্রোফাইল তথ্য',
        profile_sub: 'আপনার ব্যক্তিগত অ্যাকাউন্টের বিবরণ',
        profile_desc: 'স্মার্ট সার্জারি সিস্টেম ব্যবহারকারী',
        avatar_color: 'অবতার রঙ',
        label_fullname: 'পুরো নাম',
        label_role: 'ভূমিকা',
        btn_save_profile: '💾 প্রোফাইল সংরক্ষণ করুন',
        login_info_title: 'লগইন ও সেশন তথ্য',
        login_info_sub: 'সর্বশেষ লগইনের বিবরণ এবং বর্তমান সেশন',
        last_login: 'সর্বশেষ লগইনের সময়',
        login_ip: 'লগইন আইপি ঠিকানা',
        session_duration: 'সেশনের সময়কাল',
        session_active: 'বর্তমানে সক্রিয়',
        session_timeout_label: 'সেশন টাইমআউট',
        session_remaining: 'বাকি সময়',
        pass_title: 'পাসওয়ার্ড পরিবর্তন করুন',
        pass_sub: 'আপনার লগইন তথ্য আপডেট করুন',
        current_pass: 'বর্তমান পাসওয়ার্ড',
        new_pass: 'নতুন পাসওয়ার্ড',
        pc_len: '৮+ অক্ষর',
        pc_upper: 'বড় হাতের',
        pc_num: 'সংখ্যা',
        pc_sym: 'প্রতীক',
        pass_hint: 'নতুন পাসওয়ার্ড লিখুন',
        confirm_pass: 'নতুন পাসওয়ার্ড নিশ্চিত করুন',
        btn_update_pass: '🔑 পাসওয়ার্ড আপডেট করুন',
        hospital_title: 'হাসপাতালের তথ্য',
        hospital_sub: 'হাসপাতালের বিবরণ এবং ব্র্যান্ডিং',
        hospital_logo: 'হাসপাতালের লোগো',
        logo_upload_hint: 'আপলোড করতে ক্লিক করুন\nPNG/JPG/SVG',
        btn_remove_logo: '🗑️ সরান',
        hospital_name_label: 'হাসপাতালের নাম',
        hospital_name_hint: 'ড্যাশবোর্ড ও রিপোর্টে প্রদর্শিত নাম',
        dashboard_sync_hint: 'হাসপাতালের নাম পরিবর্তন স্বয়ংক্রিয়ভাবে ড্যাশবোর্ড হেডার আপডেট করবে।',
        qr_placeholder: 'এখানে QR কোড দেখাবে',
        qr_title: 'হাসপাতালের QR কোড',
        qr_sub: 'হাসপাতালের তথ্য পেতে স্ক্যান করুন। নাম টাইপ করার সাথে সাথে আপডেট হয়।',
        btn_gen_qr: '📱 QR তৈরি করুন',
        btn_dl_qr: '⬇️ ডাউনলোড',
        hospital_code: 'হাসপাতালের কোড',
        hospital_license: 'লাইসেন্স নম্বর',
        hospital_address: 'ঠিকানা',
        hospital_phone: 'ফোন',
        hospital_email: 'ইমেইল',
        total_ot: 'মোট OT কক্ষ',
        max_surgeries: 'প্রতিদিন সর্বোচ্চ অস্ত্রোপচার',
        btn_save: '💾 পরিবর্তন সংরক্ষণ করুন',
        dark_mode_title: 'ডার্ক মোড',
        dark_mode_sub: 'লাইট ও ডার্ক থিমের মধ্যে স্যুইচ করুন — সব পেজে তাৎক্ষণিকভাবে প্রযোজ্য',
        font_size_title: 'ফন্ট সাইজ',
        font_size_sub: 'টেক্সটের আকার সামঞ্জস্য করুন — সব জায়গায় রিয়েল-টাইমে প্রযোজ্য',
        font_preview: 'স্মার্ট সার্জারি সিস্টেম — প্রিভিউ টেক্সট Smart Surgery Preview',
        current_size: 'বর্তমান আকার',
        small: 'ছোট (১২px)',
        normal: 'স্বাভাবিক (১৪px)',
        large: 'বড় (১৮px)',
        sys_prefs_title: 'সিস্টেম পছন্দ',
        sys_prefs_sub: 'সিস্টেম-ব্যাপী সেটিংস কনফিগার করুন',
        timezone: 'টাইমজোন',
        date_format: 'তারিখের ফরম্যাট',
        language: 'ভাষা',
        preview: 'প্রিভিউ',
        time_format: 'সময়ের ফরম্যাট',
        ot_start: 'OT শুরুর সময়',
        ot_end: 'OT শেষের সময়',
        ot_sync_hint: 'OT শুরু/শেষের সময় সংরক্ষণের পরে ড্যাশবোর্ডে স্বয়ংক্রিয়ভাবে প্রতিফলিত হবে।',
        risk_title: 'ঝুঁকি স্কোরের থ্রেশহোল্ড',
        risk_sub: 'ঝুঁকির মাত্রার সীমানা নির্ধারণ করুন',
        weight_factors: 'স্কোর ওজন ফ্যাক্টর',
        asa_weight: 'ASA গ্রেড ওজন',
        age_weight: 'বয়স ফ্যাক্টর ওজন',
        comorbidity_weight: 'কমরবিডিটি ওজন',
        bmi_weight: 'BMI ফ্যাক্টর ওজন',
        notif_title: 'বিজ্ঞপ্তি পছন্দ',
        notif_sub: 'আপনি কোন সতর্কতা পাবেন তা নিয়ন্ত্রণ করুন',
        notif_critical: 'জটিল ঝুঁকির সতর্কতা',
        notif_critical_sub: 'রোগী জটিল ঝুঁকির মাত্রায় পৌঁছলে জানান',
        notif_surgery: 'অস্ত্রোপচারের অনুস্মারক',
        notif_surgery_sub: 'নির্ধারিত অস্ত্রোপচারের ১ ঘন্টা আগে মনে করিয়ে দিন',
        notif_ot: 'OT দ্বন্দ্বের সতর্কতা',
        notif_ot_sub: 'OT শিডিউলিং দ্বন্দ্ব শনাক্ত হলে সতর্ক করুন',
        notif_surgeon: 'সার্জন অনুপলব্ধতা',
        notif_surgeon_sub: 'নির্ধারিত সার্জন অনুপলব্ধ হলে জানান',
        notif_preop: 'প্রি-অপ চেকলিস্ট অসম্পূর্ণ',
        notif_preop_sub: 'প্রি-অপ আইটেম অসম্পূর্ণ হলে সতর্ক করুন',
        notif_daily: 'দৈনিক সারাংশ প্রতিবেদন',
        notif_daily_sub: 'দিনের শেষে দৈনিক অস্ত্রোপচারের সারাংশ পাঠান',
        notif_sterilize: 'স্টেরিলাইজেশন সম্পন্ন',
        notif_sterilize_sub: 'OT স্টেরিলাইজেশন শেষ হলে জানান',
        btn_save_prefs: '💾 পছন্দ সংরক্ষণ করুন',
        session_status_title: 'লাইভ সেশন স্ট্যাটাস',
        session_status_sub: 'রিয়েল-টাইম সেশনের তথ্য',
        session_active_title: 'সেশন সক্রিয়',
        logged_in: 'লগইন সময়',
        secured: 'সুরক্ষিত',
        duration: 'সময়কাল',
        total_logins: 'মোট লগইন',
        successful: 'সফল',
        failed_attempts: 'ব্যর্থ প্রচেষ্টা',
        sec_settings_title: 'নিরাপত্তা সেটিংস',
        sec_settings_sub: 'অ্যাক্সেস ও নিরাপত্তা পছন্দ পরিচালনা করুন',
        session_timeout: 'সেশন টাইমআউট',
        max_attempts: 'সর্বোচ্চ লগইন প্রচেষ্টা',
        login_notif: 'লগইন বিজ্ঞপ্তি',
        login_notif_sub: 'নতুন লগইনে সতর্ক করুন',
        activity_log: 'কার্যকলাপ লগিং',
        activity_log_sub: 'অডিট ট্রেইলের জন্য সব ব্যবহারকারীর কার্যকলাপ লগ করুন',
        login_history_title: 'লগইন ইতিহাস',
        login_history_sub: 'সর্বশেষ ১০টি লগইন প্রচেষ্টা',
        no_history: 'কোনো লগইন ইতিহাস পাওয়া যায়নি',
        th_datetime: 'তারিখ ও সময়',
        th_ip: 'আইপি ঠিকানা',
        th_status: 'স্ট্যাটাস',
        danger_zone: 'বিপদ অঞ্চল',
        danger_zone_sub: 'অপরিবর্তনীয় কার্যক্রম',
        reset_title: 'সিস্টেম ডিফল্টে রিসেট করুন',
        reset_sub: 'সব সেটিংস ফ্যাক্টরি ডিফল্টে রিসেট করুন।',
        btn_reset: 'রিসেট',
        about_title: 'স্মার্ট সার্জারি সিস্টেম সম্পর্কে',
        about_sub: 'সিস্টেমের তথ্য ও সংস্করণের বিবরণ',
        sys_name: 'সিস্টেমের নাম',
        version: 'সংস্করণ',
        hospital_label: 'হাসপাতাল',
        platform: 'প্ল্যাটফর্ম',
        database: 'ডেটাবেজ',
        framework: 'ফ্রেমওয়ার্ক',
        build_date: 'নির্মাণের তারিখ',
        license: 'লাইসেন্স',
    }
};

var currentLang = localStorage.getItem('sss_language') || 'English';

function applyLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('sss_language', lang);
    var t = TRANSLATIONS[lang] || TRANSLATIONS['English'];
    document.querySelectorAll('[data-i18n]').forEach(function(el) {
        var key = el.getAttribute('data-i18n');
        if (t[key]) el.textContent = t[key];
    });
    document.querySelectorAll('[data-i18n-nav]').forEach(function(el) {
        var key = el.getAttribute('data-i18n-nav');
        if (t[key]) el.textContent = t[key];
    });
    // Update lang sample preview
    var sample = document.getElementById('langSampleText');
    if (sample) {
        sample = lang === 'Bengali'
            ? (document.getElementById('langSampleText').textContent = 'ড্যাশবোর্ড / সেটিংস / রোগী')
            : (document.getElementById('langSampleText').textContent = 'Dashboard / Settings / Patients');
    }
}

function changeLanguage(lang) {
    applyLanguage(lang);
    showToast('🌐 ' + (lang === 'Bengali' ? 'ভাষা পরিবর্তিত হয়েছে!' : 'Language changed!'), 'success');
}

// ════════════════════════════════════════════════════
//  LIVE CLOCK — timezone aware
// ════════════════════════════════════════════════════
var currentTimezone = localStorage.getItem('sss_timezone') || 'Asia/Dhaka';
var currentTimeFormat = localStorage.getItem('sss_timeformat') || '12';

function updateClock() {
    var now = new Date();
    var opts12 = { hour:'2-digit', minute:'2-digit', second:'2-digit', hour12: true, timeZone: currentTimezone };
    var opts24 = { hour:'2-digit', minute:'2-digit', second:'2-digit', hour12: false, timeZone: currentTimezone };
    var timeOpts = currentTimeFormat === '24' ? opts24 : opts12;
    var timeStr = now.toLocaleTimeString('en-US', timeOpts);
    var dateStr = now.toLocaleDateString('en-US', { weekday:'long', year:'numeric', month:'short', day:'numeric', timeZone: currentTimezone });
    var el = document.getElementById('liveClock');
    var del = document.getElementById('liveDate');
    if (el) el.textContent = timeStr;
    if (del) del.textContent = dateStr;
}
setInterval(updateClock, 1000);
updateClock();

function updateClockTimezone(tz) {
    currentTimezone = tz;
    localStorage.setItem('sss_timezone', tz);
    updateClock();
    showToast('🕐 Timezone updated!', 'success');
}

function saveTimeFormat(fmt) {
    currentTimeFormat = fmt;
    localStorage.setItem('sss_timeformat', fmt);
    updateClock();
}

// ════════════════════════════════════════════════════
//  DARK MODE
// ════════════════════════════════════════════════════
function toggleDarkMode(isDark) {
    var html = document.getElementById('htmlRoot');
    if (isDark) { html.classList.add('dark'); localStorage.setItem('sss_dark','1'); }
    else { html.classList.remove('dark'); localStorage.setItem('sss_dark','0'); }
    showToast(isDark ? '🌙 Dark mode on!' : '☀️ Light mode on!', 'success');
}

// ════════════════════════════════════════════════════
//  FONT SIZE
// ════════════════════════════════════════════════════
function changeFontSize(size) {
    document.documentElement.style.setProperty('--font-size', size + 'px');
    var preview = document.getElementById('previewText');
    var label = document.getElementById('fontSizeLabel');
    if (preview) preview.style.fontSize = size + 'px';
    if (label) label.textContent = size + 'px';
    var slider = document.getElementById('fontSizeSlider');
    if (slider) {
        var pct = ((size - 12) / (18 - 12)) * 100;
        slider.style.background = 'linear-gradient(to right,#007a63 0%,#007a63 '+pct+'%,#c8d8e8 '+pct+'%,#c8d8e8 100%)';
    }
    localStorage.setItem('sss_fontsize', size);
}

// ════════════════════════════════════════════════════
//  AVATAR — color swatches
// ════════════════════════════════════════════════════
var AVATAR_COLORS = [
    {name:'Teal',       val:'linear-gradient(135deg,#007a63,#1560a8)'},
    {name:'Emerald',    val:'linear-gradient(135deg,#059669,#34d399)'},
    {name:'Royal Blue', val:'linear-gradient(135deg,#1560a8,#3b82f6)'},
    {name:'Purple',     val:'linear-gradient(135deg,#6d28d9,#a78bfa)'},
    {name:'Crimson',    val:'linear-gradient(135deg,#dc2626,#f87171)'},
    {name:'Amber',      val:'linear-gradient(135deg,#d97706,#fbbf24)'},
    {name:'Rose',       val:'linear-gradient(135deg,#be185d,#f472b6)'},
    {name:'Slate',      val:'linear-gradient(135deg,#334155,#64748b)'},
    {name:'Cyan',       val:'linear-gradient(135deg,#0891b2,#22d3ee)'},
    {name:'Lime',       val:'linear-gradient(135deg,#15803d,#4ade80)'},
];
var SWATCH_SOLID = [
    '#007a63','#059669','#1560a8','#6d28d9',
    '#dc2626','#d97706','#be185d','#334155','#0891b2','#15803d'
];

function buildSwatches() {
    var wrap = document.getElementById('colorSwatches');
    if (!wrap) return;
    var saved = localStorage.getItem('sss_avatarColor') || '0';
    SWATCH_SOLID.forEach(function(color, i) {
        var sw = document.createElement('div');
        sw.className = 'color-swatch' + (i == saved ? ' selected' : '');
        sw.style.background = color;
        sw.title = AVATAR_COLORS[i].name;
        sw.onclick = function() {
            document.querySelectorAll('.color-swatch').forEach(function(s){ s.classList.remove('selected'); });
            sw.classList.add('selected');
            var gradient = AVATAR_COLORS[i].val;
            document.getElementById('bigAvatar').style.background = gradient;
            document.getElementById('sbAvatar').style.background = gradient;
            localStorage.setItem('sss_avatarColor', i);
            localStorage.setItem('sss_avatarGradient', gradient);
        };
        wrap.appendChild(sw);
    });
    // Apply saved gradient
    var savedGrad = localStorage.getItem('sss_avatarGradient');
    if (savedGrad) {
        var bigAv = document.getElementById('bigAvatar');
        var sbAv = document.getElementById('sbAvatar');
        if (bigAv) bigAv.style.background = savedGrad;
        if (sbAv) sbAv.style.background = savedGrad;
    }
}

function updateAvatarPreview(name) {
    if (!name.trim()) return;
    var parts = name.trim().split(' ');
    var ini = parts.length >= 2
        ? (parts[0][0] + parts[1][0]).toUpperCase()
        : name.substring(0, 2).toUpperCase();
    var bigAv = document.getElementById('bigAvatar');
    var sbAv  = document.getElementById('sbAvatar');
    var nameEl = document.getElementById('avatarName');
    if (bigAv) bigAv.textContent = ini;
    if (sbAv)  sbAv.textContent  = ini;
    if (nameEl) nameEl.textContent = name;
}

// ════════════════════════════════════════════════════
//  PASSWORD STRENGTH METER
// ════════════════════════════════════════════════════
function checkPassStrength() {
    var pass = document.getElementById('newPass').value;
    var bar  = document.getElementById('passBar');
    var hint = document.getElementById('passHint');
    var pcLen   = document.getElementById('pc-len');
    var pcUpper = document.getElementById('pc-upper');
    var pcNum   = document.getElementById('pc-num');
    var pcSym   = document.getElementById('pc-sym');
    if (!pass) {
        bar.style.width='0%';
        [pcLen,pcUpper,pcNum,pcSym].forEach(function(e){ if(e) e.classList.remove('ok'); });
        return;
    }
    var hasLen   = pass.length >= 8;
    var hasUpper = /[A-Z]/.test(pass);
    var hasNum   = /[0-9]/.test(pass);
    var hasSym   = /[^A-Za-z0-9]/.test(pass);
    if (pcLen)   pcLen.classList.toggle('ok',   hasLen);
    if (pcUpper) pcUpper.classList.toggle('ok', hasUpper);
    if (pcNum)   pcNum.classList.toggle('ok',   hasNum);
    if (pcSym)   pcSym.classList.toggle('ok',   hasSym);
    var strength = [hasLen,hasUpper,hasNum,hasSym].filter(Boolean).length;
    var colors = ['#e24b4a','#e67e22','#f1c40f','#007a63'];
    var labels = ['Weak','Fair','Good','Strong'];
    var widths = ['25%','50%','75%','100%'];
    var i = Math.max(0, strength - 1);
    bar.style.width = widths[i];
    bar.style.background = colors[i];
    hint.textContent = 'Password strength: ' + labels[i];
    hint.style.color = colors[i];
}

function checkConfirm() {
    var p1 = document.getElementById('newPass').value;
    var p2 = document.getElementById('confirmPass').value;
    var hint = document.getElementById('confirmHint');
    if (!p2) { hint.textContent=''; return; }
    if (p1 === p2) { hint.textContent='✅ Passwords match'; hint.style.color='#007a63'; }
    else { hint.textContent='❌ Passwords do not match'; hint.style.color='#dc2626'; }
}

// ════════════════════════════════════════════════════
//  SESSION TIMER
// ════════════════════════════════════════════════════
var sessionTimeoutSec = <%= session.getMaxInactiveInterval() %>;
var loginTimeMs = <%= loginTime != null ? loginTime : System.currentTimeMillis() %>;
var circumference = 2 * Math.PI * 34;

function updateTimer() {
    var now = Date.now();
    var elapsedSec = Math.floor((now - loginTimeMs) / 1000);
    var remainingSec = Math.max(0, sessionTimeoutSec - elapsedSec);
    var min = Math.floor(remainingSec / 60);
    var sec = remainingSec % 60;
    var timerMin = document.getElementById('timerMin');
    if (timerMin) timerMin.textContent = min;
    var progress = sessionTimeoutSec > 0 ? remainingSec / sessionTimeoutSec : 1;
    var offset = circumference * (1 - progress);
    var arc = document.getElementById('timerArc');
    if (arc) {
        arc.style.strokeDashoffset = offset;
        arc.style.stroke = progress > 0.5 ? '#34d399' : progress > 0.25 ? '#f59e0b' : '#ef4444';
    }
    var elapsedMin = Math.floor(elapsedSec / 60);
    var elapsedS   = elapsedSec % 60;
    var durText = elapsedMin + 'm ' + (elapsedS < 10 ? '0' : '') + elapsedS + 's';
    var secDur = document.getElementById('sessionDuration');
    var profDur = document.getElementById('profileSessionDur');
    var profLeft = document.getElementById('profileTimeLeft');
    if (secDur) secDur.textContent = 'Duration: ' + durText;
    if (profDur) profDur.textContent = durText;
    if (profLeft) profLeft.textContent = min + 'm ' + (sec < 10?'0':'') + sec + 's';
    if (remainingSec <= 0) window.location.href = '${pageContext.request.contextPath}/logout';
}
setInterval(updateTimer, 1000);
updateTimer();

// ════════════════════════════════════════════════════
//  HOSPITAL LOGO UPLOAD
// ════════════════════════════════════════════════════
function handleLogoUpload(input) {
    if (!input.files || !input.files[0]) return;
    var file = input.files[0];
    var reader = new FileReader();
    reader.onload = function(e) {
        var img = document.getElementById('logoPreview');
        var placeholder = document.getElementById('logoPlaceholder');
        img.src = e.target.result;
        img.style.display = 'block';
        if (placeholder) placeholder.style.display = 'none';
        localStorage.setItem('sss_hospitalLogo', e.target.result);
        showToast('🏥 Logo uploaded!', 'success');
    };
    reader.readAsDataURL(file);
}

function clearLogo() {
    var img = document.getElementById('logoPreview');
    var placeholder = document.getElementById('logoPlaceholder');
    var input = document.getElementById('logoFileInput');
    img.src = '';
    img.style.display = 'none';
    if (placeholder) placeholder.style.display = 'flex';
    if (input) input.value = '';
    localStorage.removeItem('sss_hospitalLogo');
    showToast('🗑️ Logo removed', 'success');
}

// Restore saved logo
function restoreLogo() {
    var saved = localStorage.getItem('sss_hospitalLogo');
    if (saved) {
        var img = document.getElementById('logoPreview');
        var placeholder = document.getElementById('logoPlaceholder');
        if (img) { img.src = saved; img.style.display = 'block'; }
        if (placeholder) placeholder.style.display = 'none';
    }
}

// ════════════════════════════════════════════════════
//  CHARACTER COUNTER
// ════════════════════════════════════════════════════
function updateCharCounter(input, counterId, max) {
    var counter = document.getElementById(counterId);
    if (!counter) return;
    var len = input.value.length;
    counter.textContent = len + '/' + max;
    counter.className = 'char-counter';
    if (len > max * 0.8) counter.classList.add('warn');
    if (len >= max) counter.classList.add('over');
}

// ════════════════════════════════════════════════════
//  QR CODE GENERATOR
// ════════════════════════════════════════════════════
var qrInstance = null;

function generateQR() {
    var nameInput = document.getElementById('hospitalNameInput');
    var name = nameInput ? nameInput.value.trim() : 'Smart Surgery Hospital';
    var qrText = 'Hospital: ' + name + ' | Smart Surgery System v1.0 | KYAMCH 2026';
    var box = document.getElementById('qrCodeBox');
    if (!box) return;
    box.innerHTML = '';
    try {
        qrInstance = new QRCode(box, {
            text: qrText,
            width: 110,
            height: 110,
            colorDark: '#0a3d2e',
            colorLight: '#ffffff',
            correctLevel: QRCode.CorrectLevel.H
        });
        showToast('📱 QR Code generated!', 'success');
    } catch(e) {
        box.innerHTML = '<span style="font-size:11px;color:#aaa;padding:8px;text-align:center">QR library not loaded</span>';
    }
}

function updateQR() {
    // Auto-regenerate if QR was already generated
    if (document.getElementById('qrCodeBox') && document.getElementById('qrCodeBox').querySelector('canvas')) {
        generateQR();
    }
}

function downloadQR() {
    var canvas = document.querySelector('#qrCodeBox canvas');
    if (!canvas) { showToast('❌ Generate QR first!', 'error'); return; }
    var link = document.createElement('a');
    link.download = 'hospital-qr.png';
    link.href = canvas.toDataURL('image/png');
    link.click();
    showToast('⬇️ QR downloaded!', 'success');
}

// ════════════════════════════════════════════════════
//  DASHBOARD SYNC (localStorage bridge)
// ════════════════════════════════════════════════════
function syncHospitalName() {
    var nameInput = document.getElementById('hospitalNameInput');
    if (nameInput) {
        localStorage.setItem('sss_hospitalName', nameInput.value);
        document.getElementById('hospitalNameHidden').value = nameInput.value;
    }
}

function saveDashboardOT() {
    var start = document.getElementById('otStart');
    var end   = document.getElementById('otEnd');
    if (start) localStorage.setItem('sss_otStart', start.value);
    if (end)   localStorage.setItem('sss_otEnd',   end.value);
    showToast('🕐 OT times saved to dashboard!', 'success');
}

// ════════════════════════════════════════════════════
//  TOAST
// ════════════════════════════════════════════════════
function showToast(msg, type) {
    var toast = document.getElementById('toast');
    toast.textContent = msg;
    toast.className = 'toast ' + (type || 'success');
    toast.classList.add('show');
    clearTimeout(toast._t);
    toast._t = setTimeout(function(){ toast.classList.remove('show'); }, 3000);
}

// ════════════════════════════════════════════════════
//  INIT — runs on DOMContentLoaded
// ════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function() {

    // 1. Dark mode
    if (localStorage.getItem('sss_dark') === '1') {
        document.getElementById('htmlRoot').classList.add('dark');
        var t = document.getElementById('darkModeToggle');
        if (t) t.checked = true;
    }

    // 2. Font size
    var savedFont = localStorage.getItem('sss_fontsize');
    if (savedFont) {
        var slider = document.getElementById('fontSizeSlider');
        if (slider) { slider.value = savedFont; changeFontSize(savedFont); }
    }

    // 3. Timezone & time format
    var savedTz = localStorage.getItem('sss_timezone');
    if (savedTz) {
        currentTimezone = savedTz;
        var tzSel = document.getElementById('timezoneSelect');
        if (tzSel) tzSel.value = savedTz;
    }
    var savedFmt = localStorage.getItem('sss_timeformat');
    if (savedFmt) {
        currentTimeFormat = savedFmt;
        var fmtSel = document.getElementById('timeFormatSelect');
        if (fmtSel) fmtSel.value = savedFmt;
    }

    // 4. Language
    var savedLang = localStorage.getItem('sss_language');
    if (savedLang) {
        currentLang = savedLang;
        var langSel = document.getElementById('languageSelect');
        if (langSel) langSel.value = savedLang;
    }
    applyLanguage(currentLang);

    // 5. Avatar swatches & color
    buildSwatches();

    // 6. Hospital logo restore
    restoreLogo();

    // 7. Character counter init
    var hn = document.getElementById('hospitalNameInput');
    if (hn) updateCharCounter(hn, 'hospitalNameCounter', 80);

    // 8. Toast from URL msg
    <% if (msg != null && !msg.isEmpty()) { %>
    var toastMsg = '';
    var toastType = 'success';
    <% if ("saved".equals(msg)) { %>toastMsg='✅ Settings saved!';
    <% } else if ("error".equals(msg)) { %>toastMsg='❌ Failed to save!'; toastType='error';
    <% } else if ("pass_saved".equals(msg)) { %>toastMsg='✅ Password updated!';
    <% } else if ("pass_mismatch".equals(msg)) { %>toastMsg='❌ Passwords do not match!'; toastType='error';
    <% } else if ("pass_wrong".equals(msg)) { %>toastMsg='❌ Current password incorrect!'; toastType='error';
    <% } %>
    if (toastMsg) showToast(toastMsg, toastType);
    <% } %>

    // 9. Drag-drop logo support
    var dropArea = document.getElementById('logoDropArea');
    if (dropArea) {
        dropArea.addEventListener('dragover', function(e){ e.preventDefault(); dropArea.style.borderColor='#007a63'; });
        dropArea.addEventListener('dragleave', function(){ dropArea.style.borderColor=''; });
        dropArea.addEventListener('drop', function(e){
            e.preventDefault();
            dropArea.style.borderColor='';
            var file = e.dataTransfer.files[0];
            if (file && file.type.startsWith('image/')) {
                var fi = document.getElementById('logoFileInput');
                // simulate
                var reader = new FileReader();
                reader.onload = function(ev) {
                    var img = document.getElementById('logoPreview');
                    var ph  = document.getElementById('logoPlaceholder');
                    img.src = ev.target.result;
                    img.style.display = 'block';
                    if (ph) ph.style.display = 'none';
                    localStorage.setItem('sss_hospitalLogo', ev.target.result);
                    showToast('🏥 Logo uploaded!', 'success');
                };
                reader.readAsDataURL(file);
            }
        });
    }
});
</script>
</body>
</html>
