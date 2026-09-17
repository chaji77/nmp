<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%
request.setCharacterEncoding("utf-8");
CompanyVO pvo = new CompanyVO();
pvo.CPY_ID       = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.CPY_DISHONOR = StrUtil.nvl(request.getParameter("category"));
int intResult = new MgrCustomerBean().M_COMPANY_DISHONOR_MOD_PROC(pvo);
out.print(intResult);
%>