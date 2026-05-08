<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("currentPage", "dashboard");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "Admin";
    String role = (String) session.getAttribute("role");
    if (role == null) role = "User";
    String[] np = fullName.trim().split(" ");
    String initials = np.length >= 2
        ? ("" + np[0].charAt(0) + np[1].charAt(0)).toUpperCase()
        : fullName.substring(0, Math.min(2, fullName.length())).toUpperCase();
    String firstName = np[0];
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard — Smart Surgery System</title>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{height:100%;overflow:hidden;font-family:'Space Grotesk',sans-serif;background:#f5f7f5}
.shell{display:flex;height:100vh;overflow:hidden}

/* ══ SIDEBAR ══ */
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
.sb-dot{width:5px;height:5px;border-radius:50%;background:#34d399;margin-left:auto;animation:bl 2s infinite;flex-shrink:0;transition:opacity 0.2s}
.sb.col .sb-dot{opacity:0}
@keyframes bl{0%,100%{opacity:1}50%{opacity:0.2}}
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

/* ══ MAIN AREA ══ */
.area{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}

/* ══ TOPBAR ══ */
.topbar{background:#fff;border-bottom:1px solid #e2e8e2;padding:0 20px;height:56px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
.tb-greet{font-size:18px;font-weight:800;color:#0a2318;letter-spacing:-0.5px}
.tb-right{display:flex;align-items:center;gap:8px}
.srch-wrap{position:relative}
.srch-box{display:flex;align-items:center;gap:7px;background:#f4f7f4;border:1px solid #dde8dd;border-radius:9px;padding:7px 12px;cursor:text;width:160px}
.srch-box svg{width:13px;height:13px;stroke:#94a3b8;fill:none;stroke-width:2;flex-shrink:0}
.srch-box input{border:none;outline:none;background:transparent;font-family:'Space Grotesk',sans-serif;font-size:12px;color:#0a2318;width:100%}
.srch-box input::placeholder{color:#94a3b8}
.srch-panel{display:none;position:absolute;top:calc(100% + 6px);right:0;width:280px;background:#fff;border:1px solid #dde8dd;border-radius:13px;box-shadow:0 16px 48px rgba(0,0,0,0.1);z-index:9999;overflow:hidden}
.srch-panel.show{display:block}
.srch-ri{display:flex;align-items:center;gap:10px;padding:9px 14px;cursor:pointer;border-bottom:1px solid #f4f7f4;transition:background 0.12s;text-decoration:none}
.srch-ri:last-child{border-bottom:none}
.srch-ri:hover{background:rgba(5,150,105,0.04)}
.srch-av{width:28px;height:28px;border-radius:8px;background:linear-gradient(135deg,#059669,#34d399);display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#fff;flex-shrink:0}
.srch-rn{font-size:12px;font-weight:600;color:#0a2318}
.srch-rs{font-size:10px;color:#94a3b8;margin-top:1px}
.srch-empty{padding:14px;text-align:center;color:#94a3b8;font-size:12px}
.tb-icon{width:34px;height:34px;background:#f4f7f4;border:1px solid #dde8dd;border-radius:9px;display:flex;align-items:center;justify-content:center;cursor:pointer;position:relative;flex-shrink:0}
.tb-icon svg{width:14px;height:14px;stroke:#64748b;fill:none;stroke-width:2}
.tb-ndot{position:absolute;top:-2px;right:-2px;width:7px;height:7px;background:#ef4444;border-radius:50%;border:1.5px solid #fff}
.tb-lbl{display:flex;align-items:center;gap:6px;padding:7px 13px;border-radius:9px;background:#f4f7f4;border:1px solid #dde8dd;font-size:11.5px;color:#334155;white-space:nowrap;cursor:pointer}
.tb-lbl svg{width:13px;height:13px;stroke:#64748b;fill:none;stroke-width:2}
.btn-export{display:flex;align-items:center;gap:6px;padding:8px 16px;border-radius:9px;background:linear-gradient(135deg,#059669,#34d399);color:#fff;font-family:'Space Grotesk',sans-serif;font-size:12.5px;font-weight:700;border:none;cursor:pointer;box-shadow:0 3px 10px rgba(5,150,105,0.28);transition:all 0.18s;white-space:nowrap;text-decoration:none}
.btn-export:hover{transform:translateY(-1px);box-shadow:0 6px 18px rgba(5,150,105,0.36)}
.btn-export svg{width:13px;height:13px;stroke:#fff;fill:none;stroke-width:2.5}
.tb-av{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#059669,#34d399);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:800;color:#fff;cursor:pointer;flex-shrink:0}

/* ══ BODY ══ */
.body{flex:1;display:flex;overflow:hidden;min-width:0}
.scroll{flex:1;overflow-y:auto;overflow-x:hidden;padding:16px 18px;display:flex;flex-direction:column;gap:13px;min-width:0;width:0}
.scroll::-webkit-scrollbar{width:4px}
.scroll::-webkit-scrollbar-thumb{background:#c8d8c8;border-radius:4px}

/* ══ STAT CARDS ══ */
.stat-row{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;width:100%}
.sc{background:#fff;border:1px solid #e2e8e2;border-radius:14px;padding:16px 18px;position:relative;overflow:hidden;cursor:pointer;transition:transform 0.18s,box-shadow 0.18s}
.sc:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.08)}
.sc-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:6px}
.sc-num{font-size:30px;font-weight:800;color:#0a2318;letter-spacing:-1px}
.sc-lbl{font-size:10px;color:#64748b;text-transform:uppercase;letter-spacing:0.07em;margin-top:3px}
.sc-ch{font-size:10px;font-weight:700;margin-top:3px}
.sc-ch.up{color:#059669}.sc-ch.dn{color:#ef4444}
.sc-more{font-size:15px;color:#94a3b8;letter-spacing:1px;cursor:pointer}

/* ══ MAIN GRID ══ */
.main-grid{display:grid;grid-template-columns:1fr 1fr;gap:13px;width:100%}

/* ══ PANEL ══ */
.panel{background:#fff;border:1px solid #e2e8e2;border-radius:14px;overflow:hidden}
.ph{padding:13px 16px;border-bottom:1px solid #f0f4f0;display:flex;align-items:center;justify-content:space-between}
.ph-t{font-size:12.5px;font-weight:700;color:#0a2318;display:flex;align-items:center;gap:7px}
.live-dot{width:7px;height:7px;border-radius:50%;background:#059669;animation:bl 2s infinite;flex-shrink:0}
.ph-lk{font-size:10.5px;color:#059669;font-weight:600;cursor:pointer;text-decoration:none}
.ph-lk:hover{opacity:0.7}

/* ══ TIMELINE ══ */
.tl-item{display:flex;gap:11px;padding:10px 12px;background:#f8fbf8;border:1px solid #e2e8e2;border-radius:11px;margin-bottom:7px;transition:all 0.18s}
.tl-item:last-child{margin-bottom:0}
.tl-item:hover{background:rgba(5,150,105,0.04);border-color:rgba(5,150,105,0.18);transform:translateX(3px)}
.tl-time{font-size:12px;font-weight:700;color:#059669;min-width:44px;font-family:monospace;padding-top:2px}
.tl-name{font-size:13px;font-weight:600;color:#0a2318}
.tl-meta{font-size:11px;color:#64748b;margin-top:2px}

/* ══ OT GRID ══ */
.ot-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
.ot-card{padding:10px 12px;border-radius:11px;border:1px solid #e2e8e2;background:#f8fbf8;transition:all 0.18s;cursor:pointer}
.ot-card:hover{transform:translateY(-2px);box-shadow:0 6px 16px rgba(0,0,0,0.07)}
.ot-card.available{border-color:rgba(5,150,105,0.25);background:rgba(5,150,105,0.04)}
.ot-card.occupied{border-color:rgba(220,38,38,0.25);background:rgba(220,38,38,0.04)}
.ot-card.maintenance{border-color:rgba(217,119,6,0.25);background:rgba(217,119,6,0.04)}
.ot-num{font-size:10px;font-weight:700;color:#94a3b8;margin-bottom:3px;font-family:monospace}
.ot-nm{font-size:11.5px;font-weight:600;color:#0a2318;margin-bottom:5px}
.ot-sdot{width:6px;height:6px;border-radius:50%;display:inline-block;margin-right:4px;animation:bl 2s infinite}
.ot-sdot.green{background:#059669}.ot-sdot.red{background:#dc2626}.ot-sdot.yellow{background:#d97706}
.ot-stxt{font-size:10.5px;color:#64748b}

/* ══ QUICK ACTIONS — GLASSMORPHISM DARK ══ */
.qa-bg {
  background: linear-gradient(160deg, #0a3d2e 0%, #0d5c3a 55%, #0a4a2e 100%);
  border-radius: 13px;
  padding: 11px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  position: relative;
  overflow: hidden;
}
.qa-bg::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: radial-gradient(rgba(52,211,153,0.08) 1px, transparent 1px);
  background-size: 20px 20px;
  pointer-events: none;
  z-index: 0;
}
.qa-bg::after {
  content: '';
  position: absolute;
  top: -40px; right: -40px;
  width: 120px; height: 120px;
  border-radius: 50%;
  background: rgba(52,211,153,0.08);
  pointer-events: none;
  z-index: 0;
}
.qa-card {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 10px 13px;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.14);
  border-radius: 11px;
  cursor: pointer;
  transition: all 0.18s;
  text-decoration: none;
  position: relative;
  z-index: 1;
  overflow: hidden;
}
.qa-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.1), transparent 60%);
  pointer-events: none;
  border-radius: inherit;
  opacity: 0;
  transition: opacity 0.18s;
}
.qa-card:hover {
  background: rgba(255,255,255,0.15);
  border-color: rgba(52,211,153,0.4);
  transform: translateX(4px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.18);
}
.qa-card:hover::before { opacity: 1; }
.qa-card:active { transform: translateX(2px) scale(0.99); }
.qa-ico {
  width: 32px;
  height: 32px;
  border-radius: 9px;
  background: rgba(255,255,255,0.12);
  border: 1px solid rgba(255,255,255,0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 15px;
  flex-shrink: 0;
  transition: transform 0.22s;
  position: relative;
  z-index: 1;
}
.qa-card:hover .qa-ico { transform: rotate(-8deg) scale(1.18); }
.qa-lbl {
  flex: 1;
  font-size: 12px;
  font-weight: 600;
  color: rgba(255,255,255,0.88);
  position: relative;
  z-index: 1;
  letter-spacing: 0.01em;
}
.qa-arr {
  font-size: 17px;
  color: rgba(255,255,255,0.3);
  transition: transform 0.18s, color 0.18s;
  position: relative;
  z-index: 1;
  line-height: 1;
}
.qa-card:hover .qa-arr {
  transform: translateX(5px);
  color: #34d399;
}

/* ══ RISK GUIDE ══ */
.rg-row{display:flex;align-items:center;justify-content:space-between;padding:8px 11px;border-radius:9px;margin-bottom:5px;cursor:pointer;transition:transform 0.15s}
.rg-row:last-child{margin-bottom:0}
.rg-row:hover{transform:translateX(4px)}
.rg-desc{font-size:11px;color:#64748b}

/* ══ RIGHT PANEL ══ */
.rp {
  width: 262px;
  flex-shrink: 0;
  background: #eef2ef;
  border-left: 1px solid #dde5de;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 14px 13px 20px;
  display: flex;
  flex-direction: column;
  gap: 18px;
}
.rp::-webkit-scrollbar{width:3px}
.rp::-webkit-scrollbar-thumb{background:#c0d4c6;border-radius:4px}

.rp-search {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255,255,255,0.7);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.95);
  border-radius: 12px;
  padding: 9px 12px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.rp-search svg { flex-shrink: 0; }
.rp-search span { font-size: 12px; color: #a0b0a8; }

.rp-sec-hd {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}
.rp-sec-title {
  font-size: 13px;
  font-weight: 700;
  color: #1a2e22;
}
.rp-see-all {
  font-size: 11px;
  color: #059669;
  font-weight: 600;
  text-decoration: none;
}
.rp-see-all:hover { text-decoration: underline; }

.doc-card-new {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  background: rgba(255,255,255,0.68);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.92);
  border-radius: 14px;
  margin-bottom: 7px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  transition: transform 0.14s, box-shadow 0.14s;
  cursor: pointer;
}
.doc-card-new:last-child { margin-bottom: 0; }
.doc-card-new:hover {
  transform: translateY(-1px);
  box-shadow: 0 5px 18px rgba(0,0,0,0.08);
}
.doc-info { flex: 1; min-width: 0; }
.doc-name-new {
  font-size: 12px;
  font-weight: 700;
  color: #1a2e22;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.doc-spec-new {
  font-size: 10px;
  color: #7a9485;
  margin-top: 1px;
}
.doc-badge-avail {
  font-size: 9px;
  font-weight: 700;
  padding: 3px 9px;
  border-radius: 20px;
  background: #dcfce7;
  color: #16a34a;
  border: 1px solid #bbf7d0;
  white-space: nowrap;
  flex-shrink: 0;
}
.doc-badge-busy {
  font-size: 9px;
  font-weight: 700;
  padding: 3px 9px;
  border-radius: 20px;
  background: #fee2e2;
  color: #dc2626;
  border: 1px solid #fecaca;
  white-space: nowrap;
  flex-shrink: 0;
}

.pt-grid-new {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}
.pt-card-new {
  background: rgba(255,255,255,0.68);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.92);
  border-radius: 14px;
  padding: 11px 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  transition: transform 0.14s, box-shadow 0.14s;
  cursor: pointer;
}
.pt-card-new:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(0,0,0,0.09);
}
.pt-card-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 1px;
}
.pt-time-new {
  font-size: 11px;
  font-weight: 700;
  color: #059669;
}
.pt-dots-new {
  font-size: 13px;
  color: #c4cfc9;
  letter-spacing: 1px;
  line-height: 1;
  cursor: pointer;
}
.pt-slot-new {
  font-size: 9px;
  color: #94a3b8;
  margin-bottom: 9px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.pt-name-new {
  font-size: 11px;
  font-weight: 700;
  color: #1a2e22;
  white-space: normal;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}
.pt-sub-new {
  font-size: 9px;
  color: #94a3b8;
  margin-top: 3px;
}

/* ══ EMPTY ══ */
.empty{text-align:center;padding:28px 16px}
.empty-ico{font-size:34px;opacity:0.35;margin-bottom:8px}
.empty-txt{color:#64748b;font-size:12px;margin-bottom:12px}
.btn-green{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;border-radius:9px;background:linear-gradient(135deg,#059669,#34d399);color:#fff;font-family:'Space Grotesk',sans-serif;font-size:12px;font-weight:700;text-decoration:none;border:none;cursor:pointer;box-shadow:0 3px 10px rgba(5,150,105,0.28)}

/* ══ BADGES ══ */
.badge{display:inline-flex;padding:2px 7px;border-radius:5px;font-size:9.5px;font-weight:700}
.priority-high,.priority-critical{background:#fff5f5;color:#dc2626}
.priority-medium{background:#fffbeb;color:#d97706}
.priority-low{background:#ecfdf5;color:#059669}
.status-scheduled{background:#eff6ff;color:#2563eb}
.status-inprogress,.status-in_progress{background:#fefce8;color:#ca8a04}
.status-completed{background:#ecfdf5;color:#059669}
.status-cancelled{background:#f9fafb;color:#64748b}
.risk-low{background:#ecfdf5;color:#059669}
.risk-medium{background:#fffbeb;color:#d97706}
.risk-high{background:#fff5f5;color:#dc2626}
.risk-critical{background:#fef2f2;color:#b91c1c}
</style>
</head>
<body>
<div class="shell">

  <!-- ════ SIDEBAR ════ -->
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
      <a href="${pageContext.request.contextPath}/dashboard" class="sb-item on">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        <span class="sb-txt">Dashboard</span><span class="sb-dot"></span>
        <span class="sb-tip">Dashboard</span>
      </a>
      <div class="sb-sec">Management</div>
      <a href="${pageContext.request.contextPath}/patients" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        <span class="sb-txt">Patients</span><span class="sb-tip">Patients</span>
      </a>
      <a href="${pageContext.request.contextPath}/surgeries" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
        <span class="sb-txt">Surgeries</span><span class="sb-tip">Surgeries</span>
      </a>
      <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="sb-item">
        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span class="sb-txt">Schedule Surgery</span><span class="sb-tip">Schedule Surgery</span>
      </a>
      <div class="sb-sec">Resources</div>
      <a href="${pageContext.request.contextPath}/surgeons" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M20 7H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><path d="M16 3H8l-2 4h12z"/></svg>
        <span class="sb-txt">Surgeons</span><span class="sb-tip">Surgeons</span>
      </a>
      <a href="${pageContext.request.contextPath}/ot" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
        <span class="sb-txt">Operation Theaters</span><span class="sb-tip">OT Rooms</span>
      </a>
      <div class="sb-div"></div>
      <div class="sb-sec">Tools</div>
      <a href="${pageContext.request.contextPath}/patients" class="sb-item">
        <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        <span class="sb-txt">Risk Analysis</span><span class="sb-tip">Risk Analysis</span>
      </a>
      <a href="#" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/></svg>
        <span class="sb-txt">Reports</span><span class="sb-tip">Reports</span>
      </a>
      <div class="sb-div"></div>
      <div class="sb-sec">Account</div>
      <a href="#" class="sb-item">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        <span class="sb-txt">Settings</span><span class="sb-tip">Settings</span>
      </a>
      <a href="${pageContext.request.contextPath}/logout" class="sb-item">
        <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        <span class="sb-txt">Logout</span><span class="sb-tip">Logout</span>
      </a>
    </div>
    <div class="sb-bot">
      <div class="sb-user">
        <div class="sb-av"><%= initials %></div>
        <div class="sb-ui"><div class="sb-un"><%= fullName %></div><div class="sb-ur"><%= role %></div></div>
        <button class="sb-lo" onclick="location.href='${pageContext.request.contextPath}/logout'">
          <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        </button>
      </div>
    </div>
  </div>

  <!-- ════ MAIN AREA ════ -->
  <div class="area">

    <!-- TOPBAR -->
    <div class="topbar">
      <div class="tb-greet">Good morning, <%= firstName %> 👋</div>
      <div class="tb-right">
        <div class="srch-wrap">
          <div class="srch-box">
            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
            <input type="text" id="srchInput" placeholder="Search...">
          </div>
          <div class="srch-panel" id="srchPanel"><div id="srchResults"></div></div>
        </div>
        <div class="tb-icon">
          <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
          <span class="tb-ndot"></span>
        </div>
        <div class="tb-icon">
          <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div class="tb-lbl">
          <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
          New Report
        </div>
        <div class="tb-lbl">
          <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
          <%= new java.text.SimpleDateFormat("d MMM yyyy").format(new java.util.Date()) %>
        </div>
        <a href="#" class="btn-export">
          <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7,10 12,15 17,10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Export
        </a>
        <div class="tb-av"><%= initials %></div>
      </div>
    </div>

    <!-- BODY -->
    <div class="body">
      <div class="scroll">

        <!-- STAT CARDS ROW 1 -->
        <div class="stat-row">
          <div class="sc">
            <div class="sc-top"><div><div class="sc-num" id="c0">0</div><div class="sc-lbl">Total Patients</div></div><span class="sc-more">···</span></div>
            <div class="sc-ch up">Registered in system</div>
          </div>
          <div class="sc">
            <div class="sc-top"><div><div class="sc-num" id="c1">0</div><div class="sc-lbl">High Risk Patients</div></div><span class="sc-more">···</span></div>
            <div class="sc-ch dn">Need priority attention</div>
          </div>
          <div class="sc">
            <div class="sc-top"><div><div class="sc-num" id="c2">0</div><div class="sc-lbl">Available Surgeons</div></div><span class="sc-more">···</span></div>
            <div class="sc-ch up">Ready for operations</div>
          </div>
        </div>

        <!-- STAT CARDS ROW 2 -->
        <div class="stat-row">
          <div class="sc">
            <div class="sc-top"><div><div class="sc-num" id="c3">0</div><div class="sc-lbl">Today's Surgeries</div></div><span class="sc-more">···</span></div>
            <div class="sc-ch up">Scheduled for today</div>
          </div>
          <div class="sc">
            <div class="sc-top"><div><div class="sc-num" id="c4">0</div><div class="sc-lbl">Upcoming Surgeries</div></div><span class="sc-more">···</span></div>
            <div class="sc-ch up">Total scheduled</div>
          </div>
          <div class="sc">
            <div class="sc-top">
              <div>
                <div class="sc-num" id="c5">
                  <c:set var="availOT" value="0"/>
                  <c:forEach var="ot" items="${operationTheaters}">
                    <c:if test="${ot.status == 'AVAILABLE' || ot.status == 'Available'}">
                      <c:set var="availOT" value="${availOT + 1}"/>
                    </c:if>
                  </c:forEach>
                  ${availOT}
                </div>
                <div class="sc-lbl">OT Rooms Available</div>
              </div>
              <span class="sc-more">···</span>
            </div>
            <div class="sc-ch up">of ${empty operationTheaters ? 0 : operationTheaters.size()} total rooms</div>
          </div>
        </div>

        <!-- MAIN GRID -->
        <div class="main-grid">
          <!-- LEFT -->
          <div style="display:flex;flex-direction:column;gap:13px">
            <div class="panel">
              <div class="ph">
                <div class="ph-t"><div class="live-dot"></div>Today's Surgery Schedule</div>
                <a href="${pageContext.request.contextPath}/surgeries" class="ph-lk">View All →</a>
              </div>
              <div style="padding:13px 15px">
                <c:choose>
                  <c:when test="${empty todaySurgeries}">
                    <div class="empty">
                      <div class="empty-ico">🗓️</div>
                      <div class="empty-txt">No surgeries scheduled for today</div>
                      <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="btn-green">+ Schedule Now</a>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="s" items="${todaySurgeries}">
                      <div class="tl-item">
                        <div class="tl-time"><fmt:formatDate value="${s.scheduledTime}" pattern="HH:mm"/></div>
                        <div style="flex:1">
                          <div class="tl-name">${s.surgeryType}</div>
                          <div class="tl-meta">👤 ${s.patientName} &nbsp;·&nbsp; 👨‍⚕️ ${s.surgeonName}</div>
                          <div style="display:flex;gap:4px;margin-top:5px;flex-wrap:wrap">
                            <span class="badge priority-${s.priorityLevel.toLowerCase()}">${s.priorityLevel}</span>
                            <span class="badge status-${s.status.toLowerCase().replace('_','')}">${s.status}</span>
                            <span class="badge risk-${s.patientRiskLevel.toLowerCase()}">${s.patientRiskLevel} RISK</span>
                          </div>
                        </div>
                      </div>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <div class="panel">
              <div class="ph">
                <div class="ph-t">🏨 OT Room Status</div>
                <a href="${pageContext.request.contextPath}/ot" class="ph-lk">Manage →</a>
              </div>
              <div style="padding:13px 15px">
                <c:choose>
                  <c:when test="${empty operationTheaters}">
                    <div class="empty"><div class="empty-ico">🏨</div><div class="empty-txt">No operation theaters found</div></div>
                  </c:when>
                  <c:otherwise>
                    <div class="ot-grid">
                      <c:forEach var="ot" items="${operationTheaters}">
                        <c:choose>
                          <c:when test="${ot.status == 'AVAILABLE' || ot.status == 'Available'}">
                            <c:set var="otClass" value="available"/><c:set var="otDot" value="green"/><c:set var="otLbl" value="Available"/>
                          </c:when>
                          <c:when test="${ot.status == 'IN_USE' || ot.status == 'OCCUPIED' || ot.status == 'Occupied'}">
                            <c:set var="otClass" value="occupied"/><c:set var="otDot" value="red"/><c:set var="otLbl" value="Occupied"/>
                          </c:when>
                          <c:when test="${ot.status == 'MAINTENANCE' || ot.status == 'Maintenance'}">
                            <c:set var="otClass" value="maintenance"/><c:set var="otDot" value="yellow"/><c:set var="otLbl" value="Maintenance"/>
                          </c:when>
                          <c:otherwise>
                            <c:set var="otClass" value="available"/><c:set var="otDot" value="green"/><c:set var="otLbl" value="${ot.status}"/>
                          </c:otherwise>
                        </c:choose>
                        <div class="ot-card ${otClass}" onclick="location.href='${pageContext.request.contextPath}/ot'">
                          <div class="ot-num">${ot.otNumber}</div>
                          <div class="ot-nm">${ot.otName}</div>
                          <div class="ot-stxt"><span class="ot-sdot ${otDot}"></span>${otLbl}</div>
                        </div>
                      </c:forEach>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <!-- RIGHT col -->
          <div style="display:flex;flex-direction:column;gap:13px">

            <!-- ══ QUICK ACTIONS — GLASSMORPHISM DARK ══ -->
            <div class="panel">
              <div class="ph">
                <div class="ph-t">⚡ Quick Actions</div>
              </div>
              <div style="padding:10px 12px">
                <div class="qa-bg">

                  <a href="${pageContext.request.contextPath}/patients?action=add" class="qa-card">
                    <div class="qa-ico">➕</div>
                    <span class="qa-lbl">Register New Patient</span>
                    <span class="qa-arr">›</span>
                  </a>

                  <a href="${pageContext.request.contextPath}/surgeries?action=schedule" class="qa-card">
                    <div class="qa-ico">📅</div>
                    <span class="qa-lbl">Schedule Surgery</span>
                    <span class="qa-arr">›</span>
                  </a>

                  <a href="${pageContext.request.contextPath}/patients" class="qa-card">
                    <div class="qa-ico">📊</div>
                    <span class="qa-lbl">Patient Risk Reports</span>
                    <span class="qa-arr">›</span>
                  </a>

                  <a href="${pageContext.request.contextPath}/ot" class="qa-card">
                    <div class="qa-ico">🏨</div>
                    <span class="qa-lbl">Check OT Availability</span>
                    <span class="qa-arr">›</span>
                  </a>

                  <a href="${pageContext.request.contextPath}/surgeons" class="qa-card">
                    <div class="qa-ico">👨‍⚕️</div>
                    <span class="qa-lbl">Surgeon Availability</span>
                    <span class="qa-arr">›</span>
                  </a>

                </div>
              </div>
            </div>

            <div class="panel">
              <div class="ph"><div class="ph-t">📈 Risk Level Guide</div></div>
              <div style="padding:11px 13px">
                <div class="rg-row" style="background:rgba(5,150,105,0.06)"><span class="badge risk-low">LOW</span><span class="rg-desc">Score 0–25 · Routine</span></div>
                <div class="rg-row" style="background:rgba(217,119,6,0.06)"><span class="badge risk-medium">MEDIUM</span><span class="rg-desc">Score 26–50 · Monitor</span></div>
                <div class="rg-row" style="background:rgba(220,38,38,0.06)"><span class="badge risk-high">HIGH</span><span class="rg-desc">Score 51–75 · Priority</span></div>
                <div class="rg-row" style="background:rgba(185,28,28,0.06)"><span class="badge risk-critical">CRITICAL</span><span class="rg-desc">Score 76+ · Immediate</span></div>
              </div>
            </div>

            <div class="panel">
              <div class="ph"><div class="ph-t">📋 Today's Summary</div></div>
              <div style="padding:13px 15px;display:flex;flex-direction:column;gap:8px">
                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;background:#f0fdf4;border:1px solid #a7f3d0;border-radius:10px">
                  <span style="font-size:12px;color:#064e3b;font-weight:600">Total Patients</span>
                  <span style="font-size:16px;font-weight:800;color:#059669">${totalPatients}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;background:#fff5f5;border:1px solid #fecaca;border-radius:10px">
                  <span style="font-size:12px;color:#7f1d1d;font-weight:600">High Risk</span>
                  <span style="font-size:16px;font-weight:800;color:#dc2626">${highRiskCount}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px">
                  <span style="font-size:12px;color:#1e3a5f;font-weight:600">Surgeons Available</span>
                  <span style="font-size:16px;font-weight:800;color:#2563eb">${totalSurgeons}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;background:#fffbeb;border:1px solid #fde68a;border-radius:10px">
                  <span style="font-size:12px;color:#713f12;font-weight:600">Today's Operations</span>
                  <span style="font-size:16px;font-weight:800;color:#d97706">${todayCount}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;background:#f5f3ff;border:1px solid #ddd6fe;border-radius:10px">
                  <span style="font-size:12px;color:#3b0764;font-weight:600">Upcoming Scheduled</span>
                  <span style="font-size:16px;font-weight:800;color:#7c3aed">${scheduledCount}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- ════ RIGHT PANEL ════ -->
      <div class="rp">

        <div style="position:relative">
          <div class="rp-search" onclick="document.getElementById('rpSearchInput').focus()" style="cursor:text">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#a0b0a8" stroke-width="2.5" style="flex-shrink:0"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
            <input type="text" id="rpSearchInput" placeholder="Search patients..."
              style="border:none;outline:none;background:transparent;font-family:'Space Grotesk',sans-serif;font-size:12px;color:#1a2e22;width:100%;padding:0"
              oninput="rpSearch(this.value)">
          </div>
          <div id="rpSearchPanel" style="display:none;position:absolute;top:calc(100% + 6px);left:0;right:0;background:#fff;border:1px solid #e2e8e2;border-radius:13px;box-shadow:0 8px 24px rgba(0,0,0,0.1);z-index:9999;overflow:hidden;max-height:200px;overflow-y:auto">
            <div id="rpSearchResults"></div>
          </div>
        </div>

        <!-- Doctor's Schedule -->
        <div>
          <div class="rp-sec-hd">
            <span class="rp-sec-title">Doctor's Schedule</span>
            <a href="${pageContext.request.contextPath}/surgeons" class="rp-see-all">See all</a>
          </div>
          <c:choose>
            <c:when test="${empty surgeons}">
              <div style="text-align:center;padding:14px;color:#94a3b8;font-size:11px;background:rgba(255,255,255,0.55);border-radius:12px">No doctors found</div>
            </c:when>
            <c:otherwise>
              <c:forEach var="doc" items="${surgeons}" end="3" varStatus="ds">
                <c:set var="avi" value="${ds.index % 3}"/>
                <div class="doc-card-new">
                  <c:choose>
                    <c:when test="${doc.gender == 'FEMALE'}">
                      <c:choose>
                        <c:when test="${avi == 0}">
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#d1fae5"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#059669"/>
                            <circle cx="20" cy="16" r="7" fill="#fde68a"/>
                            <ellipse cx="13" cy="18" rx="3" ry="6" fill="#b45309"/>
                            <ellipse cx="27" cy="18" rx="3" ry="6" fill="#b45309"/>
                            <ellipse cx="20" cy="11" rx="7.5" ry="4" fill="#b45309"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <path d="M16.5 15.2 Q17.5 14.5 18.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M21.5 15.2 Q22.5 14.5 23.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M17.5 20 Q20 22 22.5 20" stroke="#e879a0" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#059669" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:when>
                        <c:when test="${avi == 1}">
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#ede9fe"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#7c3aed"/>
                            <circle cx="20" cy="16" r="7" fill="#fed7aa"/>
                            <circle cx="20" cy="9" r="4" fill="#4c1d95"/>
                            <ellipse cx="20" cy="12" rx="7" ry="3" fill="#4c1d95"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <path d="M16.5 15.2 Q17.5 14.5 18.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M21.5 15.2 Q22.5 14.5 23.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M17.5 20 Q20 22 22.5 20" stroke="#e879a0" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#7c3aed" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:when>
                        <c:otherwise>
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#dbeafe"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#2563eb"/>
                            <circle cx="20" cy="16" r="7" fill="#fcd34d"/>
                            <ellipse cx="13.5" cy="19" rx="2.5" ry="5.5" fill="#92400e"/>
                            <ellipse cx="26.5" cy="19" rx="2.5" ry="5.5" fill="#92400e"/>
                            <ellipse cx="20" cy="11" rx="7.5" ry="3.5" fill="#92400e"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <path d="M16.5 15.2 Q17.5 14.5 18.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M21.5 15.2 Q22.5 14.5 23.5 15.2" stroke="#1a2e22" stroke-width="0.7" fill="none"/>
                            <path d="M17.5 20 Q20 22 22.5 20" stroke="#e879a0" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#2563eb" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    <c:otherwise>
                      <c:choose>
                        <c:when test="${avi == 0}">
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#d1fae5"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#059669"/>
                            <circle cx="20" cy="16" r="7" fill="#fde68a"/>
                            <ellipse cx="20" cy="11.5" rx="7" ry="3.5" fill="#b45309"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <path d="M17.5 20 Q20 21.5 22.5 20" stroke="#92400e" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#059669" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:when>
                        <c:when test="${avi == 1}">
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#dbeafe"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#2563eb"/>
                            <circle cx="20" cy="16" r="7" fill="#fcd34d"/>
                            <path d="M13 14 Q14 9 20 9 Q27 9 27 14 Q25 11 13 14Z" fill="#1d4ed8"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <path d="M17.5 20 Q20 21.5 22.5 20" stroke="#92400e" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#2563eb" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:when>
                        <c:otherwise>
                          <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0">
                            <circle cx="20" cy="20" r="20" fill="#fef9c3"/>
                            <ellipse cx="20" cy="28" rx="11" ry="7" fill="#d97706"/>
                            <circle cx="20" cy="16" r="7" fill="#fed7aa"/>
                            <ellipse cx="20" cy="11.5" rx="7" ry="3.5" fill="#92400e"/>
                            <circle cx="17.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <circle cx="22.5" cy="16.5" r="1.2" fill="#1a2e22"/>
                            <ellipse cx="20" cy="21.5" rx="5" ry="2.5" fill="#92400e"/>
                            <path d="M17.5 20 Q20 21 22.5 20" stroke="#92400e" stroke-width="1" fill="none" stroke-linecap="round"/>
                            <rect x="17" y="28" width="6" height="4" rx="1" fill="white"/>
                            <path d="M19 29.5h2M20 29v3" stroke="#d97706" stroke-width="1" stroke-linecap="round"/>
                          </svg>
                        </c:otherwise>
                      </c:choose>
                    </c:otherwise>
                  </c:choose>
                  <div class="doc-info">
                    <div class="doc-name-new">${doc.fullName}</div>
                    <div class="doc-spec-new">${doc.specialization}</div>
                  </div>
                  <c:choose>
                    <c:when test="${doc.available}"><span class="doc-badge-avail">Available</span></c:when>
                    <c:otherwise><span class="doc-badge-busy">Unavailable</span></c:otherwise>
                  </c:choose>
                </div>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Today's Patients -->
        <div>
          <div class="rp-sec-hd">
            <span class="rp-sec-title">Today Patient's</span>
            <a href="${pageContext.request.contextPath}/patients" class="rp-see-all">See all</a>
          </div>
          <c:choose>
            <c:when test="${empty todaySurgeries}">
              <div style="text-align:center;padding:14px;color:#94a3b8;font-size:11px;background:rgba(255,255,255,0.55);border-radius:12px">No patients today</div>
            </c:when>
            <c:otherwise>
              <div class="pt-grid-new">
                <c:forEach var="s" items="${todaySurgeries}" end="3" varStatus="ps">
                  <c:set var="pavi" value="${ps.index % 6}"/>
                  <div class="pt-card-new">
                    <div class="pt-card-top">
                      <div class="pt-time-new"><fmt:formatDate value="${s.scheduledTime}" pattern="hh:mm a"/></div>
                      <span class="pt-dots-new">···</span>
                    </div>
                    <div class="pt-slot-new">${s.surgeryType}</div>
                    <c:choose>
                      <c:when test="${pavi == 0}">
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#dcfce7"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#059669"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#fde68a"/>
                          <ellipse cx="16" cy="9" rx="5.5" ry="2.8" fill="#b45309"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 17 18 15.5" stroke="#b45309" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:when>
                      <c:when test="${pavi == 1}">
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#dbeafe"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#2563eb"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#fcd34d"/>
                          <ellipse cx="16" cy="8.5" rx="5.8" ry="3" fill="#1d4ed8"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 16.5 18 15.5" stroke="#92400e" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:when>
                      <c:when test="${pavi == 2}">
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#ede9fe"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#7c3aed"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#fed7aa"/>
                          <ellipse cx="16" cy="9" rx="5.5" ry="2.5" fill="#4c1d95"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 16.5 18 15.5" stroke="#92400e" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:when>
                      <c:when test="${pavi == 3}">
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#fef9c3"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#d97706"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#fde68a"/>
                          <ellipse cx="16" cy="9" rx="5.5" ry="2.8" fill="#92400e"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 16.5 18 15.5" stroke="#92400e" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:when>
                      <c:when test="${pavi == 4}">
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#fee2e2"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#dc2626"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#fca5a5"/>
                          <ellipse cx="16" cy="9" rx="5.5" ry="2.5" fill="#991b1b"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 16.5 18 15.5" stroke="#7f1d1d" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:when>
                      <c:otherwise>
                        <svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="margin-bottom:5px">
                          <circle cx="16" cy="16" r="16" fill="#cffafe"/>
                          <ellipse cx="16" cy="22" rx="9" ry="5.5" fill="#0891b2"/>
                          <circle cx="16" cy="12.5" r="5.5" fill="#a5f3fc"/>
                          <ellipse cx="16" cy="9" rx="5.5" ry="2.5" fill="#164e63"/>
                          <circle cx="14" cy="13" r="0.9" fill="#1a2e22"/><circle cx="18" cy="13" r="0.9" fill="#1a2e22"/>
                          <path d="M14 15.5 Q16 16.5 18 15.5" stroke="#164e63" stroke-width="0.8" fill="none" stroke-linecap="round"/>
                        </svg>
                      </c:otherwise>
                    </c:choose>
                    <div class="pt-name-new">${s.patientName}</div>
                    <div class="pt-sub-new"><span class="badge risk-${s.patientRiskLevel.toLowerCase()}">${s.patientRiskLevel}</span></div>
                  </div>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

      </div>
    </div>
  </div>
</div>

<script>
var CP = '<%= request.getContextPath() %>';
var patients = [
  <c:forEach var="p" items="${patients}" varStatus="st">
  {id:<c:out value="${p.id}"/>,name:'<c:out value="${p.fullName}"/>',pid:'<c:out value="${p.patientId}"/>',risk:'<c:out value="${p.riskLevel}"/>',age:<c:out value="${p.age}"/>}<c:if test="${!st.last}">,</c:if>
  </c:forEach>
];
var surgeons = [
  <c:forEach var="doc" items="${surgeons}" varStatus="st">
  {id:<c:out value="${doc.id}"/>,name:'<c:out value="${doc.fullName}"/>',sid:'<c:out value="${doc.surgeonId}"/>',spec:'<c:out value="${doc.specialization}"/>',avail:${doc.available},gender:'<c:out value="${doc.gender}"/>'}<c:if test="${!st.last}">,</c:if>
  </c:forEach>
];

/* Right panel search */
function rpSearch(val) {
  var q = val.trim().toLowerCase();
  var panel = document.getElementById('rpSearchPanel');
  var results = document.getElementById('rpSearchResults');
  if (!q) { panel.style.display = 'none'; results.innerHTML = ''; return; }

  var matchedPatients = patients.filter(function(p) {
    return p.name.toLowerCase().indexOf(q) !== -1 || p.pid.toLowerCase().indexOf(q) !== -1;
  }).slice(0, 4);

  var matchedDoctors = surgeons.filter(function(d) {
    return d.name.toLowerCase().indexOf(q) !== -1 || d.spec.toLowerCase().indexOf(q) !== -1 || d.sid.toLowerCase().indexOf(q) !== -1;
  }).slice(0, 3);

  panel.style.display = 'block';

  if (!matchedPatients.length && !matchedDoctors.length) {
    results.innerHTML = '<div style="padding:12px;text-align:center;color:#94a3b8;font-size:12px">No results found</div>';
    return;
  }

  var html = '';
  if (matchedDoctors.length) {
    html += '<div style="padding:6px 12px 4px;font-size:9px;font-weight:700;color:#94a3b8;text-transform:uppercase;letter-spacing:0.08em">Doctors</div>';
    matchedDoctors.forEach(function(d) {
      var emoji = d.gender === 'FEMALE' ? '👩‍⚕️' : '👨‍⚕️';
      var avail = d.avail
        ? '<span style="font-size:9px;background:#dcfce7;color:#16a34a;padding:1px 6px;border-radius:10px;font-weight:700">Available</span>'
        : '<span style="font-size:9px;background:#fef9c3;color:#a16207;padding:1px 6px;border-radius:10px;font-weight:700">Busy</span>';
      html += '<a href="'+CP+'/surgeons" style="display:flex;align-items:center;gap:9px;padding:8px 12px;text-decoration:none;border-bottom:1px solid #f4f7f4" onmouseover="this.style.background=\'#f8fbf8\'" onmouseout="this.style.background=\'\'">'
        +'<div style="width:26px;height:26px;border-radius:50%;background:linear-gradient(135deg,#059669,#34d399);display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0">'+emoji+'</div>'
        +'<div style="flex:1;min-width:0"><div style="font-size:12px;font-weight:600;color:#1a2e22;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">'+d.name+'</div>'
        +'<div style="font-size:10px;color:#94a3b8;margin-top:1px">'+d.spec+'</div></div>'
        + avail + '</a>';
    });
  }

  if (matchedPatients.length) {
    html += '<div style="padding:6px 12px 4px;font-size:9px;font-weight:700;color:#94a3b8;text-transform:uppercase;letter-spacing:0.08em">Patients</div>';
    matchedPatients.forEach(function(p) {
      var c = p.risk==='CRITICAL'?'#b91c1c':p.risk==='HIGH'?'#dc2626':p.risk==='MEDIUM'?'#d97706':'#059669';
      html += '<a href="'+CP+'/patients?action=view&id='+p.id+'" style="display:flex;align-items:center;gap:9px;padding:8px 12px;text-decoration:none;border-bottom:1px solid #f4f7f4" onmouseover="this.style.background=\'#f8fbf8\'" onmouseout="this.style.background=\'\'">'
        +'<div style="width:26px;height:26px;border-radius:7px;background:linear-gradient(135deg,#059669,#34d399);display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#fff;flex-shrink:0">'+p.name.charAt(0)+'</div>'
        +'<div><div style="font-size:12px;font-weight:600;color:#1a2e22">'+p.name+'</div>'
        +'<div style="font-size:10px;color:#94a3b8">'+p.pid+' · '+p.age+' yrs · <span style="color:'+c+'">'+p.risk+'</span></div></div></a>';
    });
  }
  results.innerHTML = html;
}

document.addEventListener('click', function(e) {
  var panel = document.getElementById('rpSearchPanel');
  var wrap = document.getElementById('rpSearchInput');
  if (panel && wrap && !wrap.contains(e.target) && !panel.contains(e.target)) {
    panel.style.display = 'none';
  }
});

var srchPanel = document.getElementById('srchPanel');
var srchResults = document.getElementById('srchResults');
srchInput.addEventListener('input', function() {
  var q = this.value.trim().toLowerCase();
  if (!q) { srchResults.innerHTML = ''; srchPanel.classList.remove('show'); return; }
  var res = patients.filter(function(p) {
    return p.name.toLowerCase().indexOf(q) !== -1 || p.pid.toLowerCase().indexOf(q) !== -1;
  }).slice(0, 5);
  srchPanel.classList.add('show');
  if (!res.length) { srchResults.innerHTML = '<div class="srch-empty">No patients found</div>'; return; }
  var html = '';
  res.forEach(function(p) {
    var c = p.risk==='CRITICAL'?'#b91c1c':p.risk==='HIGH'?'#dc2626':p.risk==='MEDIUM'?'#d97706':'#059669';
    html += '<a href="'+CP+'/patients?action=view&id='+p.id+'" class="srch-ri">'
      +'<div class="srch-av">'+p.name.charAt(0)+'</div>'
      +'<div><div class="srch-rn">'+p.name+'</div>'
      +'<div class="srch-rs">'+p.pid+' · '+p.age+' yrs · <span style="color:'+c+'">'+p.risk+'</span></div></div></a>';
  });
  srchResults.innerHTML = html;
});

document.addEventListener('click', function(e) {
  if (!document.querySelector('.srch-wrap').contains(e.target)) srchPanel.classList.remove('show');
});

/* Count animation */
function countUp(id, target, delay) {
  setTimeout(function() {
    var el = document.getElementById(id);
    if (!el || target === 0) { if (el) el.textContent = '0'; return; }
    var cur = 0, step = target / (800/16);
    var t = setInterval(function() {
      cur += step;
      if (cur >= target) { el.textContent = target; clearInterval(t); }
      else el.textContent = Math.floor(cur);
    }, 16);
  }, delay);
}
countUp('c0', ${totalPatients},  100);
countUp('c1', ${highRiskCount},  200);
countUp('c2', ${totalSurgeons},  300);
countUp('c3', ${todayCount},     400);
countUp('c4', ${scheduledCount}, 500);
</script>
</body>
</html>
