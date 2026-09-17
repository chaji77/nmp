<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = StrUtil.nvl(request.getParameter("cid"));
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cid")));
else return;

String strBuyCpyId = StrUtil.nvl(request.getParameter("buyCid"));
strBuyCpyId = (IntegerCryptoUtil.isEncrypted(strBuyCpyId)) ? strBuyCpyId : null;
int intBuyCpyId = 0;
if (strBuyCpyId!=null) intBuyCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("buyCid")));
else return;

BusinessPersonVO cvo = new BusinessPersonVO();
cvo.CPY_ID = intCpyId;
cvo.BUY_CPY_ID = intBuyCpyId;
cvo.PRS_ID = Integer.parseInt(request.getParameter("prs_id"));

int intResult = new MgrCustomerBean().M_BUSINESS_PERSON_DROP_PROC(cvo);
out.print(intResult);
%>