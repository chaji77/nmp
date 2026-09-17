<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%
session.invalidate();
response.sendRedirect("index.jsp");
%>