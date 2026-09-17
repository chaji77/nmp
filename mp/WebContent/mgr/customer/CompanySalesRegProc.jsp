<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.c.CompanySalesVO" %>
<%
request.setCharacterEncoding("utf-8");
CompanySalesVO pvo = new CompanySalesVO();
pvo.CPY_ID    = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.YYYY      = StrUtil.nvl(request.getParameter("yyyy"));
pvo.SALES_AMT = StrUtil.nvl(request.getParameter("amt"));
pvo.CREUSER   = (String)session.getAttribute("SESS_LOGIN_ID");
int intResult = new CustomerBean().COMPANY_SALES_ADD_PROC(pvo);
out.print(intResult);
%>