<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.UUID" %>
<%
String csrf_token = UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrf_token);
out.print(csrf_token);
%>