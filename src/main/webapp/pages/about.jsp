<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("currentPage", "about");
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About — Smart Surgery System</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Space Grotesk', sans-serif;
            background: #f4f6f8;
            display: flex;
            height: 100vh;
            overflow: hidden;
            color: #1a1a2e;
        }

        .shell { display: flex; height: 100vh; overflow: hidden; width: 100%; }

        .main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            min-width: 0;
        }

        /* ── TOPBAR ── */
        .topbar {
            background: #fff;
            border-bottom: 1px solid #e8ecf0;
            padding: 0 32px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .topbar-greeting { font-size: 18px; font-weight: 700; color: #1a1a2e; }
        .topbar-greeting span { color: #2ecc71; }

        .topbar-right { display: flex; align-items: center; gap: 12px; }

        .topbar-icon-btn {
            width: 38px; height: 38px;
            border: 1px solid #e8ecf0;
            border-radius: 8px;
            background: #fff;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            color: #666;
            font-size: 15px;
            position: relative;
            text-decoration: none;
            transition: border-color 0.2s;
        }
        .topbar-icon-btn:hover { border-color: #2ecc71; color: #2ecc71; }

        .topbar-date {
            background: #f4f6f8;
            border: 1px solid #e8ecf0;
            border-radius: 8px;
            padding: 6px 14px;
            font-size: 13px;
            color: #555;
            font-weight: 500;
        }

        /* ── PAGE CONTENT ── */
        .page-content {
            padding: 32px;
            flex: 1;
        }

        .page-header {
            margin-bottom: 28px;
        }

        .page-title {
            font-size: 22px;
            font-weight: 700;
            color: #1a1a2e;
        }

        .page-subtitle {
            font-size: 13px;
            color: #888;
            margin-top: 4px;
        }

        /* ── CARDS ── */
        .card {
            background: #fff;
            border-radius: 14px;
            border: 1px solid #e8ecf0;
            padding: 28px;
            margin-bottom: 20px;
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f0f2f5;
        }

        .card-icon {
            width: 40px; height: 40px;
            border-radius: 10px;
            background: #eafaf1;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
            color: #2ecc71;
        }

        .card-title {
            font-size: 15px;
            font-weight: 700;
            color: #1a1a2e;
        }

        .card-desc {
            font-size: 12px;
            color: #999;
            margin-top: 1px;
        }

        /* ── APP OVERVIEW ── */
        .app-overview {
            display: flex;
            align-items: flex-start;
            gap: 24px;
        }

        .app-logo {
            width: 72px; height: 72px;
            background: #1a3c2e;
            border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px;
            flex-shrink: 0;
        }

        .app-info h2 {
            font-size: 20px;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 4px;
        }

        .app-tagline {
            font-size: 13px;
            color: #2ecc71;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .app-description {
            font-size: 13.5px;
            color: #555;
            line-height: 1.7;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-green { background: #eafaf1; color: #1e8449; }
        .badge-blue  { background: #eaf2ff; color: #1a5faa; }
        .badge-gray  { background: #f4f6f8; color: #555; }

        .badges { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }

        /* ── VERSION INFO ── */
        .version-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .version-item {
            background: #f8fafb;
            border: 1px solid #e8ecf0;
            border-radius: 10px;
            padding: 16px;
        }

        .version-label {
            font-size: 11px;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .version-value {
            font-size: 16px;
            font-weight: 700;
            color: #1a1a2e;
        }

        .version-value.green { color: #2ecc71; }

        /* ── TECH STACK ── */
        .tech-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .tech-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 16px;
            background: #f8fafb;
            border: 1px solid #e8ecf0;
            border-radius: 10px;
        }

        .tech-icon {
            width: 38px; height: 38px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }

        .tech-name { font-size: 13px; font-weight: 600; color: #1a1a2e; }
        .tech-role { font-size: 11px; color: #999; margin-top: 1px; }

        /* ── TEAM ── */
        .team-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .team-card {
            background: #f8fafb;
            border: 1px solid #e8ecf0;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .team-card:hover {
            border-color: #2ecc71;
            box-shadow: 0 4px 16px rgba(46,204,113,0.1);
        }

        .team-card.leader {
            border-color: #2ecc71;
            background: #f0fdf6;
        }

        .team-avatar {
            width: 80px; height: 80px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
            font-weight: 700;
            margin: 0 auto 12px;
            overflow: hidden;
        }

        .avatar-green { background: #1a3c2e; color: #2ecc71; }
        .avatar-teal  { background: #e0f7f4; color: #0d9488; }
        .avatar-blue  { background: #e0eeff; color: #1d4ed8; }

        .team-name { font-size: 14px; font-weight: 700; color: #1a1a2e; margin-bottom: 4px; }
        .team-role-badge {
            font-size: 11px;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 20px;
            display: inline-block;
            margin-bottom: 10px;
        }

        .role-leader { background: #1a3c2e; color: #2ecc71; }
        .role-member { background: #eaf2ff; color: #1a5faa; }

        .team-dept { font-size: 12px; color: #888; }
        .team-univ { font-size: 11px; color: #aaa; margin-top: 2px; }

        /* ── CONTACT ── */
        .contact-list { display: flex; flex-direction: column; gap: 12px; }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 16px;
            background: #f8fafb;
            border: 1px solid #e8ecf0;
            border-radius: 10px;
        }

        .contact-icon {
            width: 38px; height: 38px;
            border-radius: 8px;
            background: #eafaf1;
            display: flex; align-items: center; justify-content: center;
            color: #2ecc71;
            font-size: 16px;
            flex-shrink: 0;
        }

        .contact-label { font-size: 11px; color: #999; font-weight: 600; text-transform: uppercase; letter-spacing: 0.8px; }
        .contact-value { font-size: 13.5px; font-weight: 600; color: #1a1a2e; margin-top: 2px; }
        .contact-value a { color: #2ecc71; text-decoration: none; }
        .contact-value a:hover { text-decoration: underline; }

        /* ── TERMS ── */
        .terms-list { display: flex; flex-direction: column; gap: 10px; }

        .terms-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px 16px;
            background: #f8fafb;
            border-radius: 8px;
            border-left: 3px solid #2ecc71;
        }

        .terms-item i { color: #2ecc71; margin-top: 2px; font-size: 13px; }
        .terms-text { font-size: 13px; color: #444; line-height: 1.6; }

        /* ── TWO COLUMN LAYOUT ── */
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

        @media (max-width: 900px) {
            .two-col { grid-template-columns: 1fr; }
            .tech-grid { grid-template-columns: 1fr; }
            .team-grid { grid-template-columns: 1fr; }
            .version-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="shell">
<%@ include file="sidebar.jsp" %>

<!-- ════════ MAIN ════════ -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-greeting">About <span>the System</span></div>
        <div class="topbar-right">
            <div class="topbar-date"><i class="fas fa-calendar-alt" style="margin-right:6px;color:#2ecc71;"></i>9 May 2026</div>
        </div>
    </div>

    <!-- Page Content -->
    <div class="page-content">

        <div class="page-header">
            <div class="page-title">About Smart Surgery Scheduling</div>
            <div class="page-subtitle">System information, team details & technical documentation</div>
        </div>

        <!-- ── App Overview ── -->
        <div class="card">
            <div class="card-header">
                <div class="card-icon"><i class="fas fa-hospital-symbol"></i></div>
                <div>
                    <div class="card-title">Application Overview</div>
                    <div class="card-desc">What this system does</div>
                </div>
            </div>
            <div class="app-overview">
                <div class="app-logo">🏥</div>
                <div class="app-info">
                    <h2>Smart Surgery Scheduling System</h2>
                    <div class="app-tagline">Risk Analysis & Operation Theater Management</div>
                    <div class="app-description">
                        A comprehensive hospital surgery management platform designed to streamline the scheduling of operations,
                        manage surgeon availability, monitor operation theater usage, and assess patient risk levels in real time.
                        The system enables hospital administrators to make informed decisions, reduce scheduling conflicts,
                        and prioritize high-risk patients with precision and efficiency.
                    </div>
                    <div class="badges">
                        <span class="badge badge-green"><i class="fas fa-circle" style="font-size:7px;"></i> Active</span>
                        <span class="badge badge-blue"><i class="fas fa-graduation-cap"></i> University Project</span>
                        <span class="badge badge-gray"><i class="fas fa-code"></i> v1.0.0</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Version & Tech Stack ── -->
        <div class="two-col">

            <!-- Version Info -->
            <div class="card">
                <div class="card-header">
                    <div class="card-icon"><i class="fas fa-tag"></i></div>
                    <div>
                        <div class="card-title">Version & Release</div>
                        <div class="card-desc">Build information</div>
                    </div>
                </div>
                <div class="version-grid">
                    <div class="version-item">
                        <div class="version-label">Version</div>
                        <div class="version-value green">v1.5.0</div>
                    </div>
                    <div class="version-item">
                        <div class="version-label">Release Year</div>
                        <div class="version-value">2026</div>
                    </div>
                    <div class="version-item">
                        <div class="version-label">Status</div>
                        <div class="version-value green">Stable</div>
                    </div>
                </div>
                <div style="margin-top:14px;padding:12px 16px;background:#f8fafb;border-radius:8px;border:1px solid #e8ecf0;">
                    <div style="font-size:11px;color:#999;font-weight:600;text-transform:uppercase;letter-spacing:1px;margin-bottom:4px;">Submitted for</div>
                    <div style="font-size:13px;font-weight:600;color:#1a1a2e;">CSE Second Year Project — 2026</div>
                    <div style="font-size:12px;color:#888;margin-top:2px;">Khwaja Yunus Ali University</div>
                </div>
            </div>

            <!-- Tech Stack -->
            <div class="card">
                <div class="card-header">
                    <div class="card-icon"><i class="fas fa-layer-group"></i></div>
                    <div>
                        <div class="card-title">Technology Stack</div>
                        <div class="card-desc">Tools & frameworks used</div>
                    </div>
                </div>
                <div class="tech-grid">
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#fff3e0;font-size:22px;">☕</div>
                        <div>
                            <div class="tech-name">Java (Servlets)</div>
                            <div class="tech-role">Backend Logic</div>
                        </div>
                    </div>
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#e8f5e9;font-size:22px;">📄</div>
                        <div>
                            <div class="tech-name">JSP + JSTL</div>
                            <div class="tech-role">Frontend / View Layer</div>
                        </div>
                    </div>
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#e3f2fd;font-size:22px;">🗄️</div>
                        <div>
                            <div class="tech-name">MySQL</div>
                            <div class="tech-role">Database</div>
                        </div>
                    </div>
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#fce4ec;font-size:22px;">🐱</div>
                        <div>
                            <div class="tech-name">Apache Tomcat</div>
                            <div class="tech-role">Application Server</div>
                        </div>
                    </div>
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#f3e5f5;font-size:22px;">📦</div>
                        <div>
                            <div class="tech-name">Maven</div>
                            <div class="tech-role">Build Tool</div>
                        </div>
                    </div>
                    <div class="tech-item">
                        <div class="tech-icon" style="background:#e0f7fa;font-size:22px;">🎨</div>
                        <div>
                            <div class="tech-name">CSS3</div>
                            <div class="tech-role">Styling</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Team ── -->
        <div class="card">
            <div class="card-header">
                <div class="card-icon"><i class="fas fa-users"></i></div>
                <div>
                    <div class="card-title">Development Team</div>
                    <div class="card-desc">The people behind this project</div>
                </div>
            </div>
            <div class="team-grid">

                <!-- Leader -->
                <div class="team-card leader">
                    <div class="team-avatar avatar-green">
                        <img src="${pageContext.request.contextPath}/images/alif.jpg"
                             alt="Md. Montasir Monir Alif"
                             style="width:100%;height:100%;object-fit:cover;border-radius:50%;object-position:top;">
                    </div>
                    <div class="team-name">Md. Montasir Monir Alif</div>
                    <span class="team-role-badge role-leader">Team Leader</span>
                    <div class="team-dept">B.Sc. in CSE</div>
                    <div class="team-univ">Khwaja Yunus Ali University</div>
                </div>

                <!-- Member 2 -->
                <div class="team-card">
                    <div class="team-avatar avatar-teal">
                        <img src="${pageContext.request.contextPath}/images/maream.jpg"
                             alt="Maream"
                             style="width:100%;height:100%;object-fit:cover;border-radius:50%;object-position:top;">
                    </div>
                    <div class="team-name">Maream</div>
                    <span class="team-role-badge role-member">Team Member</span>
                    <div class="team-dept">B.Sc. in CSE</div>
                    <div class="team-univ">Khwaja Yunus Ali University</div>
                </div>

                <!-- Member 3 -->
                <div class="team-card">
                    <div class="team-avatar avatar-blue">
                        <img src="${pageContext.request.contextPath}/images/siam.jpg"
                             alt="Abu Sowad Mohammad Ali Siam"
                             style="width:100%;height:100%;object-fit:cover;border-radius:50%;object-position:top;">
                    </div>
                    <div class="team-name">Abu Sowad Mohammad Ali Siam</div>
                    <span class="team-role-badge role-member">Team Member</span>
                    <div class="team-dept">B.Sc. in CSE</div>
                    <div class="team-univ">Khwaja Yunus Ali University</div>
                </div>

            </div>
        </div>

        <!-- ── Team Name Banner ── -->
        <div style="background:linear-gradient(135deg,#0a3d2e 0%,#0d5c3a 60%,#1a6b4a 100%);border-radius:16px;padding:28px 32px;margin-bottom:20px;position:relative;overflow:hidden;">
            <div style="position:absolute;top:-40px;right:-40px;width:160px;height:160px;border-radius:50%;background:rgba(52,211,153,0.08);pointer-events:none;"></div>
            <div style="position:absolute;bottom:-30px;left:-30px;width:120px;height:120px;border-radius:50%;background:rgba(52,211,153,0.06);pointer-events:none;"></div>
            <div style="position:relative;z-index:1;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px;">
                <div style="display:flex;align-items:center;gap:16px;">
                    <img src="${pageContext.request.contextPath}/images/kyau-logo.png"
                         alt="KYAU Logo"
                         style="width:52px;height:52px;border-radius:14px;object-fit:cover;flex-shrink:0;background:#fff;padding:2px;">
                    <div>
                        <div style="font-size:11px;color:rgba(255,255,255,0.5);text-transform:uppercase;letter-spacing:1.5px;font-weight:600;margin-bottom:4px;">Khwaja Yunus Ali University · CSE</div>
                        <div style="font-size:22px;font-weight:800;color:#ffffff;letter-spacing:-0.5px;">Team - Scalpel <span style="color:#34d399;">&amp;</span> Syntax</div>
                        <div style="font-size:12px;color:rgba(255,255,255,0.55);margin-top:4px;">Built with precision. Coded with passion.</div>
                    </div>
                </div>
                <div style="text-align:right;">
                    <div style="font-size:11px;color:rgba(255,255,255,0.45);margin-bottom:6px;">Smart Surgery Scheduling System</div>
                    <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(52,211,153,0.15);border:1px solid rgba(52,211,153,0.3);border-radius:20px;padding:6px 14px;">
                        <span style="width:6px;height:6px;border-radius:50%;background:#34d399;display:inline-block;"></span>
                        <span style="font-size:12px;color:#34d399;font-weight:600;">v1.5.0 · 2026</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Contact & Terms ── -->
        <div class="two-col">

            <!-- Contact -->
            <div class="card">
                <div class="card-header">
                    <div class="card-icon"><i class="fas fa-envelope"></i></div>
                    <div>
                        <div class="card-title">Contact & Support</div>
                        <div class="card-desc">Get in touch</div>
                    </div>
                </div>
                <div class="contact-list">
                    <div class="contact-item">
                        <div class="contact-icon"><i class="fas fa-envelope"></i></div>
                        <div>
                            <div class="contact-label">Email</div>
                            <div class="contact-value"><a href="mailto:mr.alifpm16@gmail.com">mr.alifpm16@gmail.com</a></div>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon"><i class="fas fa-university"></i></div>
                        <div>
                            <div class="contact-label">Institution</div>
                            <div class="contact-value">Khwaja Yunus Ali University</div>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon"><i class="fas fa-code-branch"></i></div>
                        <div>
                            <div class="contact-label">Department</div>
                            <div class="contact-value">Computer Science & Engineering</div>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon"><i class="fas fa-clock"></i></div>
                        <div>
                            <div class="contact-label">Support Hours</div>
                            <div class="contact-value">Academic Hours (9 AM – 5 PM)</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Terms & Privacy -->
            <div class="card">
                <div class="card-header">
                    <div class="card-icon"><i class="fas fa-shield-alt"></i></div>
                    <div>
                        <div class="card-title">Terms & Privacy</div>
                        <div class="card-desc">Usage policy</div>
                    </div>
                </div>
                <div class="terms-list">
                    <div class="terms-item">
                        <i class="fas fa-check-circle"></i>
                        <div class="terms-text">This system is developed for academic purposes as a university final year project and is not intended for commercial use.</div>
                    </div>
                    <div class="terms-item">
                        <i class="fas fa-check-circle"></i>
                        <div class="terms-text">All patient and surgery data stored in this system is strictly confidential and accessible only to authorized hospital staff.</div>
                    </div>
                    <div class="terms-item">
                        <i class="fas fa-check-circle"></i>
                        <div class="terms-text">Data is used solely for scheduling and risk analysis purposes. No data is shared with third parties.</div>
                    </div>
                    <div class="terms-item">
                        <i class="fas fa-check-circle"></i>
                        <div class="terms-text">Users are responsible for maintaining the confidentiality of their login credentials.</div>
                    </div>
                    <div class="terms-item">
                        <i class="fas fa-check-circle"></i>
                        <div class="terms-text">&copy; 2026 Smart Surgery Scheduling System. All rights reserved by the development team.</div>
                    </div>
                </div>
            </div>
        </div>

    </div><!-- /page-content -->
</div><!-- /main -->
</div><!-- /shell -->

</body>
</html>
