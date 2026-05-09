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
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>Patients — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        html, body { margin: 0; padding: 0; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        .shell { overflow-x: hidden; }
        html, body { height: 100%; overflow: hidden; font-family: 'Space Grotesk', sans-serif; background: #f5f7f5; }
        .shell { display: flex; height: 100vh; overflow: hidden; gap: 0; }
        .area { flex: 1; display: flex; flex-direction: column; overflow: hidden; min-width: 0; }
        .topbar { background: #E1F5EE; border-left: none; margin-left: 0; border-bottom: 2px solid #1D9E75; padding: 0 24px; height: 56px; display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
        .topbar-title { font-size: 16px; font-weight: 700; color: #085041; }
        .topbar-sub { font-size: 12px; color: #0F6E56; margin-top: 2px; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .scroll-area { flex: 1; overflow-y: auto; overflow-x: hidden; }
        .scroll-area::-webkit-scrollbar { width: 4px; }
        .scroll-area::-webkit-scrollbar-thumb { background: #c8d8c8; border-radius: 4px; }

        /* ── Analytics Strip ── */
        .analytics-strip { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; padding: 16px 16px 0; }
        .analytics-strip .stat-card { border-radius: 16px; padding: 16px; display: flex; flex-direction: column; gap: 4px; border: none; box-shadow: 0 4px 16px rgba(0,0,0,0.12); position: relative; overflow: hidden; transition: transform 0.2s, box-shadow 0.2s; cursor: default; }
        .analytics-strip .stat-card::after { content: ''; position: absolute; right: -16px; bottom: -16px; width: 70px; height: 70px; background: rgba(255,255,255,0.12); border-radius: 50%; }
        .analytics-strip .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 28px rgba(0,0,0,0.18); }
        .analytics-strip .stat-label { font-size: 10px; font-weight: 700; color: rgba(255,255,255,0.80); text-transform: uppercase; letter-spacing: 0.07em; }
        .analytics-strip .stat-value { font-size: 30px; font-weight: 800; line-height: 1; color: #fff; letter-spacing: -1px; }
        .analytics-strip .stat-sub { font-size: 11px; color: rgba(255,255,255,0.60); margin-top: 2px; }
        .analytics-strip .stat-total    { background: linear-gradient(135deg, #007a63, #005f4d); }
        .analytics-strip .stat-critical { background: linear-gradient(135deg, #a80028, #7a001e); }
        .analytics-strip .stat-high     { background: linear-gradient(135deg, #c03a1a, #8a2910); }
        .analytics-strip .stat-medium   { background: linear-gradient(135deg, #a86200, #7a4800); }
        .analytics-strip .stat-low      { background: linear-gradient(135deg, #2e7d32, #1b5e20); }
        .analytics-strip .stat-scheduled{ background: linear-gradient(135deg, #1560a8, #0f4d8a); }

        /* ── Alert Banner ── */
        .alert-banner { margin: 14px 16px 0; background: #fff5f5; border: 1px solid #fecaca; border-left: 4px solid #e24b4a; border-radius: 12px; padding: 12px 16px; display: flex; align-items: flex-start; gap: 10px; cursor: pointer; transition: background 0.2s; }
        .alert-banner:hover { background: #fee2e2; }
        .alert-banner-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
        .alert-banner-body { flex: 1; }
        .alert-banner-title { font-size: 13px; font-weight: 700; color: #b91c1c; }
        .alert-banner-list { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
        .alert-banner-list.collapsed { display: none; }
        .ab-patient-pill { font-size: 11px; font-weight: 600; background: #fecaca; color: #b91c1c; border-radius: 999px; padding: 3px 10px; }
        .alert-banner-toggle { font-size: 12px; color: #b91c1c; font-weight: 600; flex-shrink: 0; align-self: center; padding: 4px 10px; background: #fecaca; border-radius: 8px; user-select: none; }

        /* ── Filter Bar ── */
        .filter-bar { margin: 14px 16px 0; display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
        .search-wrap { position: relative; flex: 1; min-width: 220px; }
        .search-wrap .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); font-size: 14px; pointer-events: none; }
        .search-input { width: 100%; padding: 9px 12px 9px 36px; border: 1px solid #c8d8e8; border-radius: 12px; font-size: 13px; background: #fff; color: #0a1628; font-family: 'Space Grotesk', sans-serif; outline: none; transition: border-color 0.2s, box-shadow 0.2s; }
        .search-input:focus { border-color: #007a63; box-shadow: 0 0 0 3px rgba(0,122,99,0.12); }
        .filter-select { padding: 9px 14px; border: 1px solid #c8d8e8; border-radius: 12px; font-size: 13px; background: #fff; color: #0a1628; font-family: 'Space Grotesk', sans-serif; outline: none; cursor: pointer; }
        .filter-select:focus { border-color: #007a63; }
        .view-toggle { display: flex; gap: 2px; background: #f0f4f8; border-radius: 10px; padding: 3px; border: 1px solid #c8d8e8; }
        .vt-btn { padding: 6px 12px; border-radius: 8px; border: none; background: transparent; font-size: 14px; cursor: pointer; color: #5a7a90; font-family: 'Space Grotesk', sans-serif; }
        .vt-btn.active { background: #fff; color: #0a1628; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .action-row { margin: 10px 16px 0; display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap; }
        .results-count { font-size: 12px; color: #5a7a90; }
        .results-count strong { color: #0a1628; }
        .sort-wrap { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #5a7a90; }
        .btn-export { display: flex; align-items: center; gap: 6px; padding: 7px 14px; border: 1px solid #c8d8e8; border-radius: 10px; background: #fff; font-size: 12px; font-weight: 600; color: #0a1628; font-family: 'Space Grotesk', sans-serif; cursor: pointer; transition: background 0.15s; }
        .btn-export:hover { background: #e2eaf2; }

        /* ── Patient Grid ── */
        .patients-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 16px; padding: 14px 16px 60px; }
        .patients-list-view { display: flex; flex-direction: column; gap: 8px; padding: 14px 16px 24px; }
        .patients-list-view .patient-card { flex-direction: row !important; align-items: center !important; border-radius: 14px !important; gap: 14px !important; padding: 12px 16px !important; }
        .patients-list-view .patient-card .pc-divider { display: none !important; }
        .patients-list-view .patient-card:hover { transform: translateX(6px) !important; box-shadow: 0 4px 16px rgba(0,0,0,0.10) !important; }
        .patients-list-view .patient-card .pc-top { flex: 0 0 220px !important; }
        .patients-list-view .patient-card .preop-row { display: none !important; }

        /* ── Patient Card ── */
        .patient-card { background: #fff; border: 1px solid #c8d8e8; border-left: 4px solid #c8d8e8; border-radius: 20px; padding: 16px; display: flex; flex-direction: column; gap: 10px; cursor: pointer; position: relative; transition: box-shadow 0.25s ease, transform 0.25s cubic-bezier(0.34,1.56,0.64,1); animation: cardIn 0.3s ease both; }
        @keyframes cardIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .patient-card:hover { box-shadow: 0 24px 60px rgba(0,0,0,0.25); transform: scale(1.06); z-index: 100; }
        .patient-card.hidden { display: none !important; }
        .pc-top { display: flex; align-items: flex-start; gap: 12px; }
        .pc-avatar { width: 44px; height: 44px; min-width: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 17px; font-weight: 700; }
        .pc-avatar.female { background: linear-gradient(135deg, #fbeaf0, #f4c0d1); color: #993556; }
        .pc-avatar.male   { background: linear-gradient(135deg, #e6f1fb, #b5d4f4); color: #185fa5; }
        .pc-info { flex: 1; min-width: 0; }
        .pc-name { font-size: 14px; font-weight: 700; color: #0a1628; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .pc-id   { font-size: 11px; color: #007a63; margin-top: 2px; font-weight: 600; }
        .pc-meta { font-size: 12px; color: #5a7a90; margin-top: 1px; }
        .pc-blood { font-size: 11px; font-weight: 700; border-radius: 999px; padding: 4px 10px; background: linear-gradient(135deg, rgba(0,122,99,0.15), rgba(0,122,99,0.08)); color: #007a63; border: 1px solid rgba(0,122,99,0.30); white-space: nowrap; align-self: flex-start; }
        .pc-divider { height: 1px; background: #c8d8e8; }
        .pc-row { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #5a7a90; }
        .pc-row strong { color: #0a1628; font-weight: 600; }
        .pc-comorbid { display: flex; flex-wrap: wrap; gap: 5px; align-items: center; }
        .cm-pill { font-size: 10px; font-weight: 700; border-radius: 999px; padding: 3px 9px; background: linear-gradient(135deg, rgba(168,0,40,0.12), rgba(168,0,40,0.06)); color: #a80028; border: 1px solid rgba(168,0,40,0.25); position: relative; display: inline-flex; align-items: center; cursor: default; }
        .cm-pill .cm-tooltip { visibility: hidden; opacity: 0; background: #0a1628; color: #fff; font-size: 11px; border-radius: 8px; padding: 5px 10px; white-space: nowrap; position: absolute; bottom: calc(100% + 7px); left: 50%; transform: translateX(-50%); transition: opacity 0.18s; pointer-events: none; z-index: 99; }
        .cm-pill .cm-tooltip::after { content: ''; position: absolute; top: 100%; left: 50%; transform: translateX(-50%); border: 5px solid transparent; border-top-color: #0a1628; }
        .cm-pill:hover .cm-tooltip { visibility: visible; opacity: 1; }
        .preop-row { display: flex; align-items: center; gap: 8px; font-size: 11px; color: #5a7a90; }
        .preop-steps { display: flex; gap: 3px; }
        .preop-dot { width: 8px; height: 8px; border-radius: 50%; background: #c8d8e8; }
        .preop-dot.done { background: linear-gradient(135deg, #007a63, #2e7d32); box-shadow: 0 1px 3px rgba(0,122,99,0.40); }
        .preop-dot.pending { background: linear-gradient(135deg, #a86200, #c03a1a); }
        .countdown-badge { display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 700; border-radius: 999px; padding: 3px 10px; background: rgba(168,98,0,0.08); color: #a86200; border: 1px solid rgba(168,98,0,0.25); }
        .countdown-badge.urgent { background: rgba(192,58,26,0.08); color: #c03a1a; border-color: rgba(192,58,26,0.25); }
        .countdown-badge.today  { background: rgba(168,0,40,0.10); color: #a80028; border-color: rgba(168,0,40,0.30); animation: pulseRed 1.2s ease infinite; }
        @keyframes pulseRed { 0%,100%{box-shadow:0 0 0 0 rgba(168,0,40,0.35);} 50%{box-shadow:0 0 0 6px rgba(168,0,40,0);} }
        .surgeon-chip { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 600; background: #f0f4f8; color: #0a1628; border: 1px solid #c8d8e8; border-radius: 999px; padding: 3px 10px; }
        .surgeon-chip-dot { width: 6px; height: 6px; border-radius: 50%; background: #007a63; }
        .ot-chip { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 600; background: rgba(0,122,99,0.08); color: #007a63; border-radius: 999px; padding: 3px 10px; border: 1px solid rgba(0,122,99,0.25); }
        .pc-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 2px; gap: 8px; }
        .pc-status { display: flex; align-items: center; gap: 5px; font-size: 12px; font-weight: 600; }
        .pc-dot { width: 7px; height: 7px; border-radius: 50%; }
        .pc-actions { display: flex; gap: 5px; }
        .pc-actions a, .pc-actions button { width: 30px; height: 30px; border-radius: 8px; border: 1px solid #c8d8e8; background: #f0f4f8; display: flex; align-items: center; justify-content: center; font-size: 13px; text-decoration: none; cursor: pointer; transition: background 0.15s, transform 0.15s; color: inherit; font-family: 'Space Grotesk', sans-serif; }
        .pc-actions a:hover, .pc-actions button:hover { background: #e2eaf2; transform: scale(1.1); }

        /* ── FIX: was broken with duplicate properties outside braces ── */
        .btn-schedule { display: inline-flex; align-items: center; gap: 4px; padding: 0 10px; height: 30px; border-radius: 8px; background: linear-gradient(135deg, #007a63, #005f4d); color: #fff; font-size: 10px; font-weight: 700; border: none; cursor: pointer; text-decoration: none; font-family: 'Space Grotesk', sans-serif; box-shadow: 0 2px 8px rgba(0,122,99,0.30); transition: box-shadow 0.15s, transform 0.15s; white-space: nowrap; }
        .btn-schedule:hover { box-shadow: 0 4px 16px rgba(0,122,99,0.40); transform: scale(1.03); }

        .risk-bar-bg2  { height: 4px; border-radius: 2px; background: #c8d8e8; width: 70px; }
        .risk-bar-fill2{ height: 4px; border-radius: 2px; background: var(--fill-color, #007a63); }
        .no-results { padding: 48px 24px; text-align: center; color: #5a7a90; }
        .no-results .nr-icon { font-size: 40px; margin-bottom: 10px; }
        .no-results p { font-size: 14px; }
        .empty-state { text-align: center; padding: 60px 20px; color: #5a7a90; }
        .empty-state .empty-icon { font-size: 48px; margin-bottom: 14px; opacity: 0.4; }
        .empty-state p { font-size: 14px; margin-bottom: 16px; }

        /* ── Badges ── */
        .badge { display: inline-flex; padding: 2px 8px; border-radius: 6px; font-size: 10px; font-weight: 700; text-transform: uppercase; }
        .risk-low      { background: rgba(0,122,99,0.10);  color: #007a63; border: 1px solid rgba(0,122,99,0.30); }
        .risk-medium   { background: rgba(168,98,0,0.10);  color: #a86200; border: 1px solid rgba(168,98,0,0.30); }
        .risk-high     { background: rgba(192,58,26,0.10); color: #c03a1a; border: 1px solid rgba(192,58,26,0.30); }
        .risk-critical { background: rgba(168,0,40,0.10);  color: #a80028; border: 1px solid rgba(168,0,40,0.30); }

        /* ── Buttons ── */
        .btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; font-family: 'Space Grotesk', sans-serif; cursor: pointer; transition: all 0.18s; border: 1px solid transparent; text-decoration: none; white-space: nowrap; }
        .btn-primary { background: #007a63; color: #fff; border-color: #007a63; }
        .btn-primary:hover { background: #005f4d; color: #fff; }
        .btn-sm { padding: 5px 10px; font-size: 12px; }

        /* ── Alerts ── */
        .alert { padding: 12px 16px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; display: flex; align-items: center; gap: 10px; border: 1px solid; }
        .alert-success { background: rgba(0,122,99,0.08); border-color: rgba(0,122,99,0.30); color: #007a63; }
        .alert-warning { background: rgba(168,98,0,0.08); border-color: rgba(168,98,0,0.30); color: #a86200; }

        /* ── Modals ── */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.45); z-index: 1000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border: 1px solid #c8d8e8; border-radius: 20px; padding: 28px 32px; min-width: 320px; box-shadow: 0 8px 40px rgba(0,0,0,0.14); animation: modalIn 0.25s ease; }
        @keyframes modalIn { from{opacity:0;transform:scale(0.92);}to{opacity:1;transform:scale(1);} }
        .modal-title { font-size: 16px; font-weight: 700; margin-bottom: 18px; color: #0a1628; }
        .modal-actions { display: flex; flex-direction: column; gap: 10px; margin-top: 18px; }
        .modal-btn { padding: 11px 0; border-radius: 12px; border: 1px solid #c8d8e8; background: #f0f4f8; font-size: 13px; font-weight: 600; font-family: 'Space Grotesk', sans-serif; color: #2a4060; cursor: pointer; width: 100%; text-align: center; }
        .modal-btn:hover { background: #e2eaf2; }
        .modal-btn.primary { background: #007a63; color: #fff; border-color: #007a63; }
        .modal-btn.primary:hover { background: #005f4d; }
        .modal-close { float: right; font-size: 18px; cursor: pointer; color: #5a7a90; }
        .pm-box { max-width: 580px !important; width: 95% !important; padding: 0 !important; border-radius: 20px !important; overflow: hidden !important; max-height: 90vh !important; display: flex !important; flex-direction: column !important; }
        .pm-header { display: flex; align-items: center; justify-content: space-between; padding: 20px 24px 16px; border-bottom: 1px solid #c8d8e8; background: #fff; }
        .pm-header-left { display: flex; align-items: center; gap: 14px; }
        .pm-avatar { width: 52px; height: 52px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 700; flex-shrink: 0; }
        .pm-avatar.female { background: linear-gradient(135deg,#fbeaf0,#f4c0d1); color: #993556; }
        .pm-avatar.male   { background: linear-gradient(135deg,#e6f1fb,#b5d4f4); color: #185fa5; }
        .pm-name  { font-size: 17px; font-weight: 700; color: #0a1628; }
        .pm-pid   { font-size: 12px; color: #007a63; font-weight: 600; margin-top: 2px; }
        .pm-meta  { font-size: 12px; color: #5a7a90; margin-top: 1px; }
        .pm-blood { font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 999px; background: linear-gradient(135deg,rgba(0,122,99,0.15),rgba(0,122,99,0.08)); color: #007a63; border: 1px solid rgba(0,122,99,0.30); }
        .pm-close { width: 30px; height: 30px; border-radius: 8px; border: 1px solid #c8d8e8; background: #f0f4f8; cursor: pointer; font-size: 13px; color: #5a7a90; display: flex; align-items: center; justify-content: center; }
        .pm-close:hover { background: #e2eaf2; }
        .pm-body  { padding: 20px 24px; overflow-y: auto; flex: 1; }
        .pm-divider { height: 1px; background: #c8d8e8; margin: 14px 0; }
        .pm-section-label { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #5a7a90; margin-bottom: 6px; display: block; }
        .pm-risk-row { display: flex; gap: 12px; align-items: stretch; margin-bottom: 4px; }
        .pm-risk-box { background: #f0f4f8; border-radius: 14px; padding: 14px 18px; min-width: 110px; text-align: center; border: 1px solid #c8d8e8; }
        .pm-risk-score { font-size: 34px; font-weight: 800; line-height: 1; font-family: monospace; }
        .pm-risk-sublabel { font-size: 10px; color: #5a7a90; margin-top: 3px; margin-bottom: 8px; text-transform: uppercase; }
        .pm-rbar-bg   { height: 5px; border-radius: 3px; background: #c8d8e8; }
        .pm-rbar-fill { height: 5px; border-radius: 3px; transition: width 0.6s ease; }
        .pm-risk-badges { flex: 1; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
        .pm-risk-badges > div { background: #f0f4f8; border-radius: 12px; padding: 10px 12px; border: 1px solid #c8d8e8; display: flex; flex-direction: column; gap: 5px; }
        .pm-row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 12px; }
        .pm-info-box { background: #f0f4f8; border-radius: 12px; padding: 10px 14px; border: 1px solid #c8d8e8; }
        .pm-info-box-label { font-size: 10px; font-weight: 700; color: #5a7a90; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 3px; }
        .pm-info-box-value { font-size: 13px; font-weight: 600; color: #0a1628; }
        .pm-comorbids { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 4px; }
        .pm-co-pill { font-size: 11px; font-weight: 700; border-radius: 999px; padding: 4px 12px; background: linear-gradient(135deg,rgba(168,0,40,0.12),rgba(168,0,40,0.06)); color: #a80028; border: 1px solid rgba(168,0,40,0.25); }
        .pm-co-none { font-size: 13px; color: #5a7a90; }
        .pm-preop-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 7px; }
        .pm-preop-item { display: flex; align-items: center; gap: 9px; background: #f0f4f8; border-radius: 10px; padding: 9px 12px; border: 1px solid #c8d8e8; font-size: 12px; font-weight: 500; color: #5a7a90; }
        .pm-preop-item.done { background: rgba(0,122,99,0.06); border-color: rgba(0,122,99,0.25); color: #0a1628; }
        .pm-preop-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; background: #c8d8e8; }
        .pm-preop-item.done .pm-preop-dot { background: linear-gradient(135deg,#007a63,#2e7d32); }
        .pm-actions { display: flex; gap: 8px; flex-wrap: wrap; }
        .pm-btn { flex: 1; min-width: 110px; padding: 9px 14px; border-radius: 10px; font-size: 12px; font-weight: 600; text-align: center; text-decoration: none; border: none; cursor: pointer; font-family: 'Space Grotesk', sans-serif; transition: all 0.15s; }
        .pm-btn-primary   { background: #1560a8; color: #fff; }
        .pm-btn-primary:hover { background: #0f4d8a; color: #fff; }
        .pm-btn-secondary { background: #f0f4f8; color: #0a1628; border: 1px solid #c8d8e8; }
        .pm-btn-secondary:hover { background: #e2eaf2; }
        .pm-btn-teal { background: linear-gradient(135deg,#007a63,#005f4d); color: #fff; box-shadow: 0 2px 8px rgba(0,122,99,0.30); }
        .pm-btn-teal:hover { box-shadow: 0 4px 14px rgba(0,122,99,0.40); color: #fff; }
    </style>
</head>
<body>
<div class="shell">
    <%@ include file="sidebar.jsp" %>

    <div class="area">
        <div class="topbar">
            <div>
                <div class="topbar-title">🧑‍⚕️ Patient Management</div>
                <div class="topbar-sub">Risk analysis, scheduling & patient records</div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/patients?action=add" class="btn btn-primary btn-sm">➕ Register Patient</a>
            </div>
        </div>

        <div class="scroll-area">

            <c:if test="${param.msg == 'added'}"><div class="alert alert-success" style="margin:12px 16px 0;">✅ Patient registered successfully!</div></c:if>
            <c:if test="${param.msg == 'updated'}"><div class="alert alert-success" style="margin:12px 16px 0;">✅ Patient updated successfully!</div></c:if>
            <c:if test="${param.msg == 'deleted'}"><div class="alert alert-warning" style="margin:12px 16px 0;">🗑️ Patient deleted.</div></c:if>

            <c:if test="${not empty patients}">
                <div class="analytics-strip" id="analyticsStrip">
                    <div class="stat-card stat-total"><div class="stat-label">Total Patients</div><div class="stat-value">${patients.size()}</div><div class="stat-sub">All registered</div></div>
                    <div class="stat-card stat-critical"><div class="stat-label">&#128308; Critical Risk</div><div class="stat-value" id="cntCritical">—</div><div class="stat-sub">Risk &gt; 75</div></div>
                    <div class="stat-card stat-high"><div class="stat-label">&#128992; High Risk</div><div class="stat-value" id="cntHigh">—</div><div class="stat-sub">Risk 51–75</div></div>
                    <div class="stat-card stat-medium"><div class="stat-label">&#128993; Medium Risk</div><div class="stat-value" id="cntMedium">—</div><div class="stat-sub">Risk 26–50</div></div>
                    <div class="stat-card stat-low"><div class="stat-label">&#128994; Low Risk</div><div class="stat-value" id="cntLow">—</div><div class="stat-sub">Risk ≤ 25</div></div>
                    <div class="stat-card stat-scheduled"><div class="stat-label">&#128197; Scheduled</div><div class="stat-value" id="cntScheduled">—</div><div class="stat-sub">Upcoming surgeries</div></div>
                </div>

                <div class="alert-banner" id="alertBanner" onclick="toggleAlertList()" style="display:none;">
                    <div class="alert-banner-icon">🚨</div>
                    <div class="alert-banner-body">
                        <div class="alert-banner-title" id="alertBannerTitle">Critical/High risk patients with no surgery scheduled</div>
                        <div class="alert-banner-list collapsed" id="alertBannerList"></div>
                    </div>
                    <div class="alert-banner-toggle" id="alertToggleBtn">Show ▾</div>
                </div>

                <div class="filter-bar">
                    <div class="search-wrap">
                        <span class="search-icon">🔍</span>
                        <input type="text" class="search-input" id="searchInput" placeholder="Search by name, ID, blood group…" oninput="filterPatients()">
                    </div>
                    <select class="filter-select" id="filterRisk" onchange="filterPatients()">
                        <option value="">All Risk Levels</option>
                        <option value="critical">🔴 Critical (&gt;75)</option>
                        <option value="high">🟠 High (51–75)</option>
                        <option value="medium">🟡 Medium (26–50)</option>
                        <option value="low">🟢 Low (≤25)</option>
                    </select>
                    <select class="filter-select" id="filterStatus" onchange="filterPatients()">
                        <option value="">All Statuses</option>
                        <option value="scheduled">📅 Scheduled</option>
                        <option value="in_progress">🔵 In Progress</option>
                        <option value="completed">✅ Completed</option>
                        <option value="cancelled">❌ Cancelled</option>
                        <option value="not_scheduled">⭕ Not Scheduled</option>
                    </select>
                    <select class="filter-select" id="filterComorbid" onchange="filterPatients()">
                        <option value="">All Conditions</option>
                        <option value="dm">Diabetes (DM)</option>
                        <option value="htn">Hypertension (HTN)</option>
                        <option value="cvd">Heart Disease (CVD)</option>
                        <option value="ckd">Kidney Disease (CKD)</option>
                        <option value="smk">Smoker</option>
                    </select>
                    <div class="view-toggle">
                        <button class="vt-btn active" id="btnGrid" onclick="setView('grid');return false;">⊞</button>
                        <button class="vt-btn" id="btnList" onclick="setView('list');return false;">☰</button>
                    </div>
                </div>

                <div class="action-row">
                    <div class="results-count">Showing <strong id="visibleCount">${patients.size()}</strong> of <strong>${patients.size()}</strong> patients</div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <div class="sort-wrap">
                            Sort by:
                            <select class="filter-select" id="sortBy" onchange="sortPatients()" style="padding:6px 10px;">
                                <option value="newest">Newest First</option>
                                <option value="risk_desc">Risk (High→Low)</option>
                                <option value="risk_asc">Risk (Low→High)</option>
                                <option value="name_asc">Name (A→Z)</option>
                                <option value="name_desc">Name (Z→A)</option>
                                <option value="age_desc">Age (Old→Young)</option>
                                <option value="age_asc">Age (Young→Old)</option>
                                <option value="id_asc">ID (PAT-001 first)</option>
                                <option value="date_asc">Surgery Date (Nearest)</option>
                            </select>
                        </div>
                        <button class="btn-export" onclick="openExportModal()">📤 Export</button>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty patients}">
                <div class="empty-state">
                    <div class="empty-icon">🧑‍⚕️</div>
                    <p>No patients registered yet</p>
                    <a href="${pageContext.request.contextPath}/patients?action=add" class="btn btn-primary btn-sm">Register First Patient</a>
                </div>
            </c:if>

            <c:if test="${not empty patients}">
                <div class="patients-grid" id="patientsContainer">
                    <c:forEach var="p" items="${patients}" varStatus="vs">
                        <div class="patient-card"
                             onclick="openPatientModal(this)"
                             data-name="${p.fullName}" data-id="${p.patientId}" data-dbid="${p.id}"
                             data-blood="${p.bloodGroup}" data-risk="${p.riskScore}" data-risk-level="${p.riskLevel}"
                             data-status="${p.lastSurgeryStatus}"
                             data-surgery-date="<fmt:formatDate value="${p.lastSurgeryDate}" pattern="yyyy-MM-dd"/>"
                             data-dm="${p.hasDiabetes}" data-htn="${p.hasHypertension}" data-cvd="${p.hasHeartDisease}"
                             data-ckd="${p.hasKidneyDisease}" data-smk="${p.smoker}" data-age="${p.age}"
                             data-fullname="${p.fullName}" data-pid="${p.patientId}" data-gender="${p.gender}"
                             data-asa="${p.asaGrade}" data-risklevel="${p.riskLevel}" data-contact="${p.contactNumber}"
                             data-surgeon="${p.assignedSurgeon}" data-otroom="${p.otRoom}"
                             data-preop-labs="${p.labsDone}" data-preop-ecg="${p.ecgDone}"
                             data-preop-consent="${p.consentSigned}" data-preop-anaes="${p.anaesthesiaDone}"
                             data-preop-npo="${p.npoDone}"
                             style="border-left:4px solid <c:choose><c:when test="${p.riskScore > 75}">#e24b4a</c:when><c:when test="${p.riskScore > 50}">#ef9f27</c:when><c:when test="${p.riskScore > 25}">#ba7517</c:when><c:otherwise>#639922</c:otherwise></c:choose>;animation-delay:${vs.index * 40}ms;">

                            <div class="pc-top">
                                <div class="pc-avatar ${p.gender == 'Female' ? 'female' : 'male'}">${p.fullName.substring(0,1)}</div>
                                <div class="pc-info">
                                    <div class="pc-name" title="${p.fullName}">${p.fullName}</div>
                                    <div class="pc-id">${p.patientId}</div>
                                    <div class="pc-meta">${p.age} yrs · ${p.gender}</div>
                                </div>
                                <span class="pc-blood">${p.bloodGroup}</span>
                            </div>
                            <div class="pc-divider"></div>
                            <div class="pc-row">🏥 ASA:&nbsp;
                                <span class="badge <c:choose><c:when test="${p.asaGrade <= 1}">risk-low</c:when><c:when test="${p.asaGrade == 2}">risk-medium</c:when><c:when test="${p.asaGrade == 3}">risk-high</c:when><c:otherwise>risk-critical</c:otherwise></c:choose>">Grade ${p.asaGrade}</span>
                            </div>
                            <div class="pc-row">📊 Risk:&nbsp;
                                <strong style="color:<c:choose><c:when test="${p.riskScore > 75}">var(--risk-critical,#a80028)</c:when><c:when test="${p.riskScore > 50}">var(--risk-high,#c03a1a)</c:when><c:when test="${p.riskScore > 25}">var(--risk-medium,#a86200)</c:when><c:otherwise>var(--risk-low,#007a63)</c:otherwise></c:choose>;">
                                    <fmt:formatNumber value="${p.riskScore}" maxFractionDigits="1"/>
                                </strong>&nbsp;
                                <span class="badge risk-${p.riskLevel.toLowerCase()}">${p.riskLevel}</span>
                                <div class="risk-bar-bg2"><div class="risk-bar-fill2" style="width:${p.riskScore}%;--fill-color:<c:choose><c:when test="${p.riskScore > 75}">#a80028</c:when><c:when test="${p.riskScore > 50}">#c03a1a</c:when><c:when test="${p.riskScore > 25}">#a86200</c:when><c:otherwise>#007a63</c:otherwise></c:choose>;"></div></div>
                            </div>
                            <c:if test="${not empty p.assignedSurgeon}">
                                <div class="pc-row"><span class="surgeon-chip"><span class="surgeon-chip-dot"></span>Dr. ${p.assignedSurgeon}</span></div>
                            </c:if>
                            <c:if test="${not empty p.otRoom}">
                                <div class="pc-row"><span class="ot-chip">🏠 OT ${p.otRoom}</span></div>
                            </c:if>
                            <div class="pc-comorbid">
                                <span style="font-size:12px;color:#5a7a90;">🩺</span>
                                <c:if test="${p.hasDiabetes}"><span class="cm-pill">DM<span class="cm-tooltip">Diabetes Mellitus</span></span></c:if>
                                <c:if test="${p.hasHypertension}"><span class="cm-pill">HTN<span class="cm-tooltip">Hypertension</span></span></c:if>
                                <c:if test="${p.hasHeartDisease}"><span class="cm-pill">CVD<span class="cm-tooltip">Cardiovascular Disease</span></span></c:if>
                                <c:if test="${p.hasKidneyDisease}"><span class="cm-pill">CKD<span class="cm-tooltip">Chronic Kidney Disease</span></span></c:if>
                                <c:if test="${p.smoker}"><span class="cm-pill">SMK<span class="cm-tooltip">Smoker</span></span></c:if>
                                <c:if test="${!p.hasDiabetes && !p.hasHypertension && !p.hasHeartDisease && !p.hasKidneyDisease && !p.smoker}"><span style="color:#5a7a90;font-size:12px;">None</span></c:if>
                            </div>
                            <div class="preop-row">
                                <span>Pre-op:</span>
                                <div class="preop-steps">
                                    <div class="preop-dot ${p.labsDone ? 'done' : 'pending'}" title="Labs"></div>
                                    <div class="preop-dot ${p.ecgDone ? 'done' : 'pending'}" title="ECG"></div>
                                    <div class="preop-dot ${p.consentSigned ? 'done' : 'pending'}" title="Consent"></div>
                                    <div class="preop-dot ${p.anaesthesiaDone ? 'done' : 'pending'}" title="Anaesthesia"></div>
                                    <div class="preop-dot ${p.npoDone ? 'done' : 'pending'}" title="NPO"></div>
                                </div>
                                <span>
                                    <c:set var="preOpCount" value="${(p.labsDone?1:0)+(p.ecgDone?1:0)+(p.consentSigned?1:0)+(p.anaesthesiaDone?1:0)+(p.npoDone?1:0)}"/>
                                    ${preOpCount}/5 done
                                </span>
                            </div>
                            <c:if test="${p.lastSurgeryStatus == 'SCHEDULED' && not empty p.lastSurgeryDate}">
                                <div class="pc-row" id="countdown-${p.id}" data-surgery-date="<fmt:formatDate value="${p.lastSurgeryDate}" pattern="yyyy-MM-dd"/>"></div>
                            </c:if>
                            <div class="pc-divider"></div>
                            <div class="pc-footer">
                                <div>
                                    <c:choose>
                                        <c:when test="${p.lastSurgeryStatus == 'IN_PROGRESS'}"><div class="pc-status" style="color:#185fa5;"><div class="pc-dot" style="background:#185fa5;"></div>In Progress</div></c:when>
                                        <c:when test="${p.lastSurgeryStatus == 'SCHEDULED'}"><div class="pc-status" style="color:#854f0b;"><div class="pc-dot" style="background:#ba7517;"></div>📅 <fmt:formatDate value="${p.lastSurgeryDate}" pattern="dd MMM"/></div></c:when>
                                        <c:when test="${p.lastSurgeryStatus == 'COMPLETED'}"><div class="pc-status" style="color:#3b6d11;"><div class="pc-dot" style="background:#639922;"></div>Completed</div></c:when>
                                        <c:when test="${p.lastSurgeryStatus == 'CANCELLED'}"><div class="pc-status" style="color:#a32d2d;"><div class="pc-dot" style="background:#e24b4a;"></div>Cancelled</div></c:when>
                                        <c:otherwise><a href="${pageContext.request.contextPath}/surgeries?action=schedule&patientId=${p.id}" class="btn-schedule">📅 Schedule Surgery</a></c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="pc-actions">
                                    <a href="${pageContext.request.contextPath}/patients?action=view&id=${p.id}" title="View">👁️</a>
                                    <a href="${pageContext.request.contextPath}/patients?action=edit&id=${p.id}" title="Edit">✏️</a>
                                    <button title="Print" onclick="event.stopPropagation();printPatient(this)">🖨️</button>
                                    <a href="${pageContext.request.contextPath}/patients?action=delete&id=${p.id}" title="Delete" onclick="event.stopPropagation();return confirm('Delete patient ${p.fullName}?')">🗑️</a>
                                </div>
                            </div>
                            <c:if test="${not empty p.lastUpdated}">
                                <div style="font-size:10px;color:#5a7a90;text-align:right;">Updated: <fmt:formatDate value="${p.lastUpdated}" pattern="dd MMM, HH:mm"/></div>
                            </c:if>
                        </div>
                    </c:forEach>
                    <div class="no-results" id="noResults" style="display:none;grid-column:1/-1;">
                        <div class="nr-icon">🔍</div>
                        <p>No patients match your search or filters.</p>
                        <button class="btn btn-primary btn-sm" onclick="clearFilters()">Clear Filters</button>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Patient Detail Modal -->
<div class="modal-overlay" id="patientModal" onclick="handleModalClick(event)">
    <div class="modal-box pm-box" id="patientModalBox">
        <div class="pm-header">
            <div class="pm-header-left">
                <div class="pm-avatar" id="pmAvatar"></div>
                <div>
                    <div class="pm-name" id="pmName"></div>
                    <div class="pm-pid" id="pmPid"></div>
                    <div class="pm-meta" id="pmMeta"></div>
                </div>
            </div>
            <div style="display:flex;gap:8px;align-items:center;">
                <span class="pm-blood" id="pmBlood"></span>
                <button class="pm-close" onclick="closePatientModal()">✕</button>
            </div>
        </div>
        <div class="pm-body">
            <div class="pm-risk-row">
                <div class="pm-risk-box">
                    <div class="pm-risk-score" id="pmRiskScore"></div>
                    <div class="pm-risk-sublabel">Risk Score</div>
                    <div class="pm-rbar-bg"><div class="pm-rbar-fill" id="pmRiskBar"></div></div>
                </div>
                <div class="pm-risk-badges">
                    <div><div class="pm-section-label">Risk Level</div><span id="pmRiskBadge" class="badge"></span></div>
                    <div><div class="pm-section-label">ASA Grade</div><span id="pmAsaBadge" class="badge"></span></div>
                    <div><div class="pm-section-label">Surgery</div><div id="pmStatus"></div></div>
                </div>
            </div>
            <div class="pm-divider"></div>
            <div class="pm-row2" id="pmSurgeonRow" style="display:none;">
                <div class="pm-info-box" id="pmSurgeonBox"></div>
                <div class="pm-info-box" id="pmOtBox" style="display:none;"></div>
            </div>
            <div class="pm-section-label" style="margin-bottom:6px;">🩺 Comorbidities</div>
            <div class="pm-comorbids" id="pmComorbids"></div>
            <div class="pm-divider"></div>
            <div class="pm-section-label" style="margin-bottom:8px;">✅ Pre-operative Checklist</div>
            <div class="pm-preop-grid" id="pmPreop"></div>
            <div class="pm-divider"></div>
            <div class="pm-actions">
                <a id="pmViewBtn" href="#" class="pm-btn pm-btn-primary">👁️ View Full Profile</a>
                <a id="pmEditBtn" href="#" class="pm-btn pm-btn-secondary">✏️ Edit Patient</a>
                <button id="pmPrintBtn" class="pm-btn pm-btn-secondary" onclick="printFromModal()">🖨️ Print</button>
                <a id="pmScheduleBtn" href="#" class="pm-btn pm-btn-teal" style="display:none;">📅 Schedule Surgery</a>
            </div>
        </div>
    </div>
</div>

<!-- Export Modal -->
<div class="modal-overlay" id="exportModal">
    <div class="modal-box">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:4px;">
            <div class="modal-title">📤 Export Patients</div>
            <span class="modal-close" onclick="closeExportModal()">✕</span>
        </div>
        <p style="font-size:13px;color:#5a7a90;margin-bottom:4px;">Only currently visible/filtered patients will be exported.</p>
        <div class="modal-actions">
            <button class="modal-btn primary" onclick="exportCSV()">📊 Export as CSV</button>
            <button class="modal-btn" onclick="exportPrint()">🖨️ Print Patient List</button>
            <button class="modal-btn" onclick="closeExportModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
const allCards = () => Array.from(document.querySelectorAll('.patient-card[data-name]'));

document.addEventListener('DOMContentLoaded', () => {
    computeAnalytics(); buildAlertBanner(); renderCountdowns(); filterPatients();
    const saved = localStorage.getItem('patientView');
    if (saved === 'list') setView('list'); else setView('grid');
});

function computeAnalytics() {
    const cards = allCards();
    let critical=0,high=0,medium=0,low=0,scheduled=0;
    cards.forEach(c => {
        const r = parseFloat(c.dataset.risk||0);
        const st = (c.dataset.status||'').toUpperCase();
        if(r>75)critical++; else if(r>50)high++; else if(r>25)medium++; else low++;
        if(st==='SCHEDULED')scheduled++;
    });
    setText('cntCritical',critical); setText('cntHigh',high);
    setText('cntMedium',medium); setText('cntLow',low); setText('cntScheduled',scheduled);
}
function setText(id,val){const el=document.getElementById(id);if(el)el.textContent=val;}

function buildAlertBanner() {
    const cards = allCards();
    const danger = cards.filter(c => {
        const r = parseFloat(c.dataset.risk||0);
        const st = (c.dataset.status||'').toUpperCase();
        return r>50 && (!st||st==='NOT_SCHEDULED'||st==='NULL');
    });
    const banner = document.getElementById('alertBanner');
    const list = document.getElementById('alertBannerList');
    const title = document.getElementById('alertBannerTitle');
    if(!banner||danger.length===0)return;
    title.textContent='⚠️ '+danger.length+' High/Critical risk patient'+(danger.length>1?'s':'')+' with no surgery scheduled';
    danger.forEach(c=>{
        const pill=document.createElement('span');
        pill.className='ab-patient-pill';
        pill.textContent=c.dataset.name+' ('+parseFloat(c.dataset.risk).toFixed(1)+')';
        list.appendChild(pill);
    });
    banner.style.display='flex';
}

let alertOpen=false;
function toggleAlertList(){
    alertOpen=!alertOpen;
    const list=document.getElementById('alertBannerList');
    const btn=document.getElementById('alertToggleBtn');
    if(list)list.classList.toggle('collapsed',!alertOpen);
    if(btn)btn.textContent=alertOpen?'Hide ▴':'Show ▾';
}

function renderCountdowns(){
    const today=new Date();today.setHours(0,0,0,0);
    document.querySelectorAll('[id^="countdown-"]').forEach(el=>{
        const dateStr=el.dataset.surgeryDate;
        if(!dateStr||dateStr==='null'||dateStr==='')return;
        const sDate=new Date(dateStr);sDate.setHours(0,0,0,0);
        const diff=Math.round((sDate-today)/86400000);
        let html='';
        if(diff===0)html='<span class="countdown-badge today">TODAY</span>';
        else if(diff===1)html='<span class="countdown-badge urgent">Tomorrow</span>';
        else if(diff>0&&diff<=3)html='<span class="countdown-badge urgent">In '+diff+' days</span>';
        else if(diff>0)html='<span class="countdown-badge">In '+diff+' days</span>';
        else html='<span class="countdown-badge" style="background:#f0f4f8;color:#5a7a90;">Past date</span>';
        el.innerHTML=html;
    });
}

function filterPatients(){
    const q=(document.getElementById('searchInput')?.value||'').toLowerCase().trim();
    const risk=document.getElementById('filterRisk')?.value||'';
    const status=document.getElementById('filterStatus')?.value||'';
    const comorbid=document.getElementById('filterComorbid')?.value||'';
    const cards=allCards();let visible=0;
    cards.forEach(c=>{
        const name=(c.dataset.name||'').toLowerCase();
        const id=(c.dataset.id||'').toLowerCase();
        const blood=(c.dataset.blood||'').toLowerCase();
        const r=parseFloat(c.dataset.risk||0);
        const st=(c.dataset.status||'').toLowerCase();
        const matchQ=!q||name.includes(q)||id.includes(q)||blood.includes(q);
        let matchRisk=true;
        if(risk==='critical')matchRisk=r>75;
        else if(risk==='high')matchRisk=r>50&&r<=75;
        else if(risk==='medium')matchRisk=r>25&&r<=50;
        else if(risk==='low')matchRisk=r<=25;
        let matchStatus=true;
        if(status){if(status==='not_scheduled')matchStatus=!st||st==='not_scheduled'||st==='';else matchStatus=st===status;}
        let matchCo=true;
        if(comorbid==='dm')matchCo=c.dataset.dm==='true';
        else if(comorbid==='htn')matchCo=c.dataset.htn==='true';
        else if(comorbid==='cvd')matchCo=c.dataset.cvd==='true';
        else if(comorbid==='ckd')matchCo=c.dataset.ckd==='true';
        else if(comorbid==='smk')matchCo=c.dataset.smk==='true';
        const show=matchQ&&matchRisk&&matchStatus&&matchCo;
        c.classList.toggle('hidden',!show);
        if(show)visible++;
    });
    const vc=document.getElementById('visibleCount');if(vc)vc.textContent=visible;
    const nr=document.getElementById('noResults');if(nr)nr.style.display=visible===0?'block':'none';
}

function clearFilters(){
    ['searchInput','filterRisk','filterStatus','filterComorbid'].forEach(id=>{
        const el=document.getElementById(id);if(el)el.value='';
    });
    filterPatients();
}

function sortPatients(){
    const by=document.getElementById('sortBy')?.value||'risk_desc';
    const container=document.getElementById('patientsContainer');
    const cards=allCards();
    cards.sort((a,b)=>{
        if(by==='newest')return(b.dataset.dbid||0)-(a.dataset.dbid||0);
        if(by==='risk_desc')return parseFloat(b.dataset.risk)-parseFloat(a.dataset.risk);
        if(by==='risk_asc')return parseFloat(a.dataset.risk)-parseFloat(b.dataset.risk);
        if(by==='name_asc')return(a.dataset.name||'').localeCompare(b.dataset.name||'');
        if(by==='name_desc')return(b.dataset.name||'').localeCompare(a.dataset.name||'');
        if(by==='age_desc')return parseInt(b.dataset.age||0)-parseInt(a.dataset.age||0);
        if(by==='age_asc')return parseInt(a.dataset.age||0)-parseInt(b.dataset.age||0);
        if(by==='id_asc')return(a.dataset.id||'').localeCompare(b.dataset.id||'');
        if(by==='date_asc'){const da=a.dataset.surgeryDate||'9999';const db=b.dataset.surgeryDate||'9999';return da.localeCompare(db);}
        return 0;
    });
    const nr=document.getElementById('noResults');
    cards.forEach(c=>container.insertBefore(c,nr));
}

function setView(mode){
    const container=document.getElementById('patientsContainer');
    const btnGrid=document.getElementById('btnGrid');
    const btnList=document.getElementById('btnList');
    if(!container)return;
    if(mode==='list'){container.className='patients-list-view';btnList?.classList.add('active');btnGrid?.classList.remove('active');}
    else{container.className='patients-grid';btnGrid?.classList.add('active');btnList?.classList.remove('active');}
    localStorage.setItem('patientView',mode);
}

function printPatient(btn){
    var card=btn.closest('.patient-card');
    var d=card.dataset;
    var name=d.fullname||d.name||'';var pid=d.pid||'';var age=d.age||'';var gender=d.gender||'';
    var blood=d.blood||'';var asa=d.asa||'';var risk=parseFloat(d.risk||0).toFixed(1);
    var riskLvl=d.risklevel||d.riskLevel||'';var contact=d.contact||'';var surgeon=d.surgeon||'';
    var otroom=d.otroom||'';var status=d.status||'Not Scheduled';
    var dm=d.dm==='true',htn=d.htn==='true',cvd=d.cvd==='true',ckd=d.ckd==='true',smk=d.smk==='true';
    var labs=d.preopLabs==='true',ecg=d.preopEcg==='true',consent=d.preopConsent==='true',anaes=d.preopAnaes==='true',npo=d.preopNpo==='true';
    var comorbids=[];
    if(dm)comorbids.push('Diabetes Mellitus (DM)');if(htn)comorbids.push('Hypertension (HTN)');
    if(cvd)comorbids.push('Heart Disease (CVD)');if(ckd)comorbids.push('Kidney Disease (CKD)');if(smk)comorbids.push('Smoker');
    function dot(done){return'<span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:'+(done?'#007a63':'#c8d8e8')+';margin-right:3px;"></span>';}
    function badge(label,color,bg){return'<span style="display:inline-block;padding:2px 10px;border-radius:999px;font-size:11px;font-weight:600;background:'+bg+';color:'+color+';margin-right:4px;">'+label+'</span>';}
    function riskColor(lvl){if(lvl==='CRITICAL')return'#a80028';if(lvl==='HIGH')return'#c03a1a';if(lvl==='MEDIUM')return'#a86200';return'#007a63';}
    var rc=riskColor(riskLvl.toUpperCase());
    var win=window.open('','_blank','width=700,height=820');
    win.document.write('<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Patient Summary - '+name+'</title><style>*{box-sizing:border-box;margin:0;padding:0;}body{font-family:"Space Grotesk",sans-serif;background:#f0f4f8;padding:32px;}.card{background:#fff;border-radius:16px;padding:32px;max-width:620px;margin:0 auto;box-shadow:0 4px 24px rgba(0,0,0,0.10);}.header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;}.logo-icon{width:38px;height:38px;background:linear-gradient(135deg,#007a63,#1560a8);border-radius:9px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:18px;font-weight:700;margin-right:10px;}.logo-name{font-size:12px;font-weight:700;color:#0a1628;text-transform:uppercase;}.logo-sub{font-size:10px;color:#5a7a90;}.print-date{font-size:11px;color:#5a7a90;}h1{font-size:20px;font-weight:700;color:#0a1628;margin-bottom:2px;}.subtitle{font-size:12px;color:#5a7a90;margin-bottom:20px;}hr{border:none;border-top:1px solid #c8d8e8;margin:16px 0;}.grid2{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px;}.grid3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-bottom:14px;}.box{background:#f0f4f8;border-radius:10px;padding:10px 14px;}.box-label{font-size:10px;font-weight:700;color:#5a7a90;text-transform:uppercase;margin-bottom:3px;}.box-value{font-size:14px;font-weight:600;color:#0a1628;}.section-title{font-size:11px;font-weight:700;text-transform:uppercase;color:#5a7a90;margin:14px 0 8px;}.print-btn{width:100%;padding:12px;background:#007a63;color:#fff;border:none;border-radius:10px;font-size:14px;font-weight:600;cursor:pointer;margin-top:20px;}@media print{body{background:#fff;padding:0;}.print-btn{display:none;}}</style></head><body><div class="card"><div class="header"><div style="display:flex;align-items:center;"><div class="logo-icon">+</div><div><div class="logo-name">Smart Surgery System</div><div class="logo-sub">Risk Analysis & Scheduling</div></div></div><div class="print-date">Printed: '+new Date().toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'})+'</div></div><h1>Patient Summary</h1><div class="subtitle">Patient ID: '+pid+'</div><hr><div class="section-title">Basic Information</div><div class="grid3"><div class="box"><div class="box-label">Full Name</div><div class="box-value">'+name+'</div></div><div class="box"><div class="box-label">Age / Gender</div><div class="box-value">'+age+' yrs / '+gender+'</div></div><div class="box"><div class="box-label">Blood Group</div><div class="box-value">'+blood+'</div></div></div><div class="grid2"><div class="box"><div class="box-label">Contact</div><div class="box-value">'+(contact||'—')+'</div></div><div class="box"><div class="box-label">Surgery Status</div><div class="box-value">'+status+'</div></div></div><hr><div class="section-title">Risk Assessment</div><div class="grid3"><div class="box"><div class="box-label">Risk Score</div><div class="box-value" style="color:'+rc+';font-size:22px;">'+risk+'</div></div><div class="box"><div class="box-label">Risk Level</div><div class="box-value" style="color:'+rc+';">'+riskLvl+'</div></div><div class="box"><div class="box-label">ASA Grade</div><div class="box-value">Grade '+asa+'</div></div></div><div class="section-title">Comorbidities</div><div style="padding:10px 14px;background:#f0f4f8;border-radius:10px;margin-bottom:14px;">'+(comorbids.length>0?comorbids.map(function(c){return badge(c,'#a80028','#fbeaf0');}).join(''):'<span style="font-size:13px;color:#5a7a90;">None reported</span>')+'</div>'+(surgeon?'<div class="grid2"><div class="box"><div class="box-label">Assigned Surgeon</div><div class="box-value">Dr. '+surgeon+'</div></div>'+(otroom?'<div class="box"><div class="box-label">OT Room</div><div class="box-value">'+otroom+'</div></div>':'')+'</div>':'')+'<hr><div class="section-title">Pre-operative Checklist</div><div style="padding:12px 14px;background:#f0f4f8;border-radius:10px;display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:4px;"><div>'+dot(labs)+' <span style="font-size:13px;">Lab Tests</span></div><div>'+dot(ecg)+' <span style="font-size:13px;">ECG / Echo</span></div><div>'+dot(consent)+' <span style="font-size:13px;">Consent Signed</span></div><div>'+dot(anaes)+' <span style="font-size:13px;">Anaesthesia Review</span></div><div>'+dot(npo)+' <span style="font-size:13px;">NPO Status</span></div></div><button class="print-btn" onclick="window.print()">Print / Save as PDF</button></div></body></html>');
    win.document.close();
}

function openExportModal(){document.getElementById('exportModal').classList.add('open');}
function closeExportModal(){document.getElementById('exportModal').classList.remove('open');}

function exportCSV(){
    const cards=allCards().filter(c=>!c.classList.contains('hidden'));
    const rows=[['Name','Patient ID','Age','Gender','Blood Group','Risk Score','Risk Level','Status','Diabetes','Hypertension','CVD','CKD','Smoker']];
    cards.forEach(c=>{rows.push([c.dataset.name,c.dataset.id,c.dataset.age,'',c.dataset.blood,parseFloat(c.dataset.risk).toFixed(1),c.dataset.riskLevel,c.dataset.status,c.dataset.dm==='true'?'Yes':'No',c.dataset.htn==='true'?'Yes':'No',c.dataset.cvd==='true'?'Yes':'No',c.dataset.ckd==='true'?'Yes':'No',c.dataset.smk==='true'?'Yes':'No']);});
    const csv=rows.map(function(r){return r.map(function(v){return'"'+(v||'').toString().replace(/"/g,'""')+'"';}).join(',');}).join('\n');
    const blob=new Blob([csv],{type:'text/csv'});
    const a=document.createElement('a');a.href=URL.createObjectURL(blob);
    a.download='patients_'+new Date().toISOString().slice(0,10)+'.csv';a.click();
    closeExportModal();
}
function exportPrint(){closeExportModal();setTimeout(()=>window.print(),300);}
document.getElementById('exportModal')?.addEventListener('click',function(e){if(e.target===this)closeExportModal();});

var _currentModalCard=null;
function openPatientModal(card){
    _currentModalCard=card;
    var d=card.dataset;
    var ctx=document.querySelector('meta[name="ctx"]')?document.querySelector('meta[name="ctx"]').content:'';
    var name=d.fullname||d.name||'';var pid=d.pid||'';var age=d.age||'';
    var gender=(d.gender||'').toUpperCase();var blood=d.blood||'';var asa=d.asa||'';
    var risk=parseFloat(d.risk||0).toFixed(1);var riskLvl=(d.risklevel||d.riskLevel||'').toUpperCase();
    var surgeon=d.surgeon||'';var otroom=d.otroom||'';var status=d.status||'';var dbId=d.dbid||'';
    var dm=d.dm==='true',htn=d.htn==='true',cvd=d.cvd==='true',ckd=d.ckd==='true',smk=d.smk==='true';
    var labs=d.preopLabs==='true',ecg=d.preopEcg==='true',consent=d.preopConsent==='true',anaes=d.preopAnaes==='true',npo=d.preopNpo==='true';

    var av=document.getElementById('pmAvatar');
    av.textContent=name.charAt(0).toUpperCase();
    av.className='pm-avatar '+(gender==='FEMALE'?'female':'male');
    document.getElementById('pmName').textContent=name;
    document.getElementById('pmPid').textContent=pid;
    document.getElementById('pmMeta').textContent=age+' yrs · '+gender.charAt(0)+gender.slice(1).toLowerCase();
    document.getElementById('pmBlood').textContent=blood;

    var rc=riskLvl==='CRITICAL'?'#a80028':riskLvl==='HIGH'?'#c03a1a':riskLvl==='MEDIUM'?'#a86200':'#007a63';
    var rsEl=document.getElementById('pmRiskScore');rsEl.textContent=risk;rsEl.style.color=rc;
    var bar=document.getElementById('pmRiskBar');bar.style.width='0%';bar.style.background=rc;
    setTimeout(function(){bar.style.width=parseFloat(risk)+'%';},80);

    var rb=document.getElementById('pmRiskBadge');rb.textContent=riskLvl;rb.className='badge risk-'+riskLvl.toLowerCase();
    var ab=document.getElementById('pmAsaBadge');
    var asaClass=parseInt(asa)<=1?'risk-low':parseInt(asa)==2?'risk-medium':parseInt(asa)==3?'risk-high':'risk-critical';
    ab.textContent='Grade '+asa;ab.className='badge '+asaClass;

    var stEl=document.getElementById('pmStatus');
    var stMap={'SCHEDULED':'📅 Scheduled','IN_PROGRESS':'🔵 In Progress','COMPLETED':'✅ Completed','CANCELLED':'❌ Cancelled'};
    stEl.textContent=stMap[status.toUpperCase()]||'⭕ Not Scheduled';

    var surgRow=document.getElementById('pmSurgeonRow');
    if(surgeon){
        surgRow.style.display='grid';
        document.getElementById('pmSurgeonBox').innerHTML='<div class="pm-info-box-label">Assigned Surgeon</div><div class="pm-info-box-value">Dr. '+surgeon+'</div>';
        var otBox=document.getElementById('pmOtBox');
        if(otroom){otBox.style.display='block';otBox.innerHTML='<div class="pm-info-box-label">OT Room</div><div class="pm-info-box-value">'+otroom+'</div>';}
        else{otBox.style.display='none';}
    }else{surgRow.style.display='none';}

    var cos=[];
    if(dm)cos.push('Diabetes (DM)');if(htn)cos.push('Hypertension (HTN)');
    if(cvd)cos.push('Heart Disease (CVD)');if(ckd)cos.push('Kidney Disease (CKD)');if(smk)cos.push('Smoker');
    document.getElementById('pmComorbids').innerHTML=cos.length>0?cos.map(function(c){return'<span class="pm-co-pill">'+c+'</span>';}).join(''):'<span class="pm-co-none">None reported</span>';

    var steps=[{label:'Lab Tests (CBC/LFT/RFT)',done:labs},{label:'ECG / Echo',done:ecg},{label:'Consent Signed',done:consent},{label:'Anaesthesia Review',done:anaes},{label:'NPO Status',done:npo}];
    document.getElementById('pmPreop').innerHTML=steps.map(function(s){return'<div class="pm-preop-item '+(s.done?'done':'')+'"><div class="pm-preop-dot"></div>'+s.label+'</div>';}).join('');

    document.getElementById('pmViewBtn').href=ctx+'/patients?action=view&id='+dbId;
    document.getElementById('pmEditBtn').href=ctx+'/patients?action=edit&id='+dbId;
    var schedBtn=document.getElementById('pmScheduleBtn');
    if(!status||status.toUpperCase()==='NOT_SCHEDULED'||status===''){schedBtn.style.display='block';schedBtn.href=ctx+'/surgeries?action=schedule&patientId='+dbId;}
    else{schedBtn.style.display='none';}

    document.getElementById('patientModal').classList.add('open');
    document.body.style.overflow='hidden';
}

function closePatientModal(){
    document.getElementById('patientModal').classList.remove('open');
    document.body.style.overflow='';_currentModalCard=null;
}
function handleModalClick(e){if(e.target===document.getElementById('patientModal'))closePatientModal();}
function printFromModal(){if(_currentModalCard)printPatient({closest:function(){return _currentModalCard;}});}

document.addEventListener('click',function(e){
    var actionEl=e.target.closest('.pc-actions,.btn-export');
    if(actionEl)e.stopPropagation();
    var schedBtn=e.target.closest('.btn-schedule');
    if(schedBtn){
        e.stopPropagation();
        window.location.href=schedBtn.href;
    }
},true);
document.addEventListener('keydown',function(e){
    if(e.key==='Escape'){closePatientModal();closeExportModal();}
});
</script>
</body>
</html>
