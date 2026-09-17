<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.sales.MastOffCommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("MastOffCommissionRegProc.jsp");

MastOffCommissionVO pvo = new MastOffCommissionVO();
pvo.COMM_ID    = Integer.parseInt(StrUtil.nvl(request.getParameter("commid"), "0"));
pvo.CTID       = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));
pvo.END_MONEY  = StrUtil.extractInteger(StrUtil.nvl(request.getParameter("money"), "0"));
pvo.WRITE_ID   = (String) pageContext.getAttribute("SESS_LOGIN_ID");
int intSeq     = new CommissionBean().MAST_OFF_COMMISSION_ADD_PROC(pvo);
out.print(intSeq);
%>