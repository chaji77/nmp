<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoVO" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

SalesMemoVO pvo = new SalesMemoVO();
pvo.MEMO_ID  = Integer.parseInt(StrUtil.nvl(request.getParameter("mid"), "0"));
pvo.DEL_DATE = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

int intResult = new SalesMemoBean().SALES_MEMO_MOD_PROC(pvo);
out.print(intResult);
%>