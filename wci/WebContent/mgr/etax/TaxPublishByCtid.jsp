<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
int intCtid = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));
out.print((intCtid>0) ? TaxPublish.run(intCtid, (int)pageContext.getAttribute("SESS_MGR_ID")) : 0);
%>