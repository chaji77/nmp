<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.PersonVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = StrUtil.nvl(request.getParameter("cid"));
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

PersonVO pvo = new PersonVO();
pvo.PRS_ID = IntegerCryptoUtil.crypt(request.getParameter("pid"));

new CustomerBean().PERSON_DROP_PROC(intCpyId, pvo);
out.print(1);
%>