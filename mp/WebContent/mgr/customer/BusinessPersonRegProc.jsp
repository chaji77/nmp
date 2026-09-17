<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

BusinessPersonVO pvo = new BusinessPersonVO();
MgrCustomerBean bean = new MgrCustomerBean();
int intResult = -1;

pvo.CPY_ID = Integer.parseInt(request.getParameter("cid"));
pvo.BUY_CPY_ID = Integer.parseInt(request.getParameter("buy_cid"));
pvo.PRS_ID = Integer.parseInt(request.getParameter("prs_id"));

if (StrUtil.nvl(request.getParameter("action")).equals("edit")) {
  pvo.ORIGIN_BUY_CPY_ID = Integer.parseInt(request.getParameter("origin_buy_cid"));
  intResult = bean.M_BUSINESS_PERSON_MOD_PROC(pvo); 
} else intResult = bean.M_BUSINESS_PERSON_ADD_PROC(pvo);

out.print(intResult);
%>