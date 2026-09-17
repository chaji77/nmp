<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationVO" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("DirectRelationRegProc.jsp");

DirectRelationVO pvo = new DirectRelationVO();
pvo.SELL_COMPANY = Integer.parseInt(StrUtil.nvl(request.getParameter("sellerCid"), "0"));
pvo.BUY_COMPANY  = Integer.parseInt(StrUtil.nvl(request.getParameter("buyerCid"), "0"));
pvo.USE_YN		 = StrUtil.nvl(request.getParameter("useYN"));
out.println((!pvo.USE_YN.equals(""))?new DirectRelationBean().M_DIRECT_RELATION_MOD_PROC(pvo):new DirectRelationBean().M_DIRECT_RELATION_ADD_PROC(pvo));
%>