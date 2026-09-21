<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoVO" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

SalesMemoVO pvo = new SalesMemoVO();
pvo.CPY_ID   = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.WRITE_ID = (String)session.getAttribute("SESS_LOGIN_ID");
pvo.CONTENTS = StrUtil.nvl(request.getParameter("contents_html"));

int intResult = new SalesMemoBean().SALES_MEMO_ADD_PROC(pvo);
out.print(intResult);
%>