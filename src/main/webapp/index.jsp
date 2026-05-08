<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirect root to dashboard or login
    String contextPath = request.getContextPath();
    Object user = session.getAttribute("user");
    if (user != null) {
        response.sendRedirect(contextPath + "/dashboard");
    } else {
        response.sendRedirect(contextPath + "/login");
    }
%>
