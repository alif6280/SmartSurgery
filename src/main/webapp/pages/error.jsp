<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error — Smart Surgery System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div style="min-height: 100vh; display: flex; align-items: center; justify-content: center;
     background: var(--bg-base);">
    <div style="text-align: center; max-width: 500px; padding: 40px;">
        <div style="font-size: 64px; margin-bottom: 20px;">⚠️</div>
        <h1 style="font-size: 24px; color: var(--text-primary); margin-bottom: 12px;">Something went wrong</h1>
        <p style="color: var(--text-muted); margin-bottom: 24px;">
            ${error != null ? error : "An unexpected error occurred. Please try again."}
        </p>
        <div style="display: flex; gap: 12px; justify-content: center;">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                🏠 Go to Dashboard
            </a>
            <a href="javascript:history.back()" class="btn btn-secondary">← Go Back</a>
        </div>
    </div>
</div>
</body>
</html>
