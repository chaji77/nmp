<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String title = StrUtil.nvl(request.getParameter("title"));
if (title=="") return;

String strMid = (String) session.getAttribute("SESS_MAN_ID");
strMid        = (IntegerCryptoUtil.isEncrypted(strMid)) ? IntegerCryptoUtil.crypt(strMid) : null;
CompanyVO pvo = new CompanyVO();
pvo.CPY_ID       = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
int intResult = 0;

switch (title) {
  case "settle":
    pvo.CONFIRM_SETTLE_YN = StrUtil.nvl(request.getParameter("useYN"));
    intResult = new MgrCustomerBean().M_COMPANY_CONFIRM_SETTLE_MOD_PROC(pvo);
    break;
  case "mptax":
	pvo.MPTAX_MONTH_USE_YN = StrUtil.nvl(request.getParameter("useYN"), "N");
	pvo.MPTAX_MONTH_USE_ID = strMid;
	intResult = new MgrCustomerBean().M_COMPANY_MPTAX_MONTH_USE_YN_MOD_PROC(pvo);
	break;
  case "scrap":
    pvo.CU_USE_YN = StrUtil.nvl(request.getParameter("useYN"));
    intResult = new MgrCustomerBean().M_COMPANY_CU_USE_MOD_PROC(pvo);
    break;
  case "mobile":
    pvo.MOBILE_YN = StrUtil.nvl(request.getParameter("useYN"));
    intResult = new MgrCustomerBean().M_COMPANY_MOBILE_YN_MOD_PROC(pvo);
    break;
  case "reverse":
    pvo.REVERSE_YN = StrUtil.nvl(request.getParameter("useYN"));
    intResult = new MgrCustomerBean().M_COMPANY_REVERSE_YN_MOD_PROC(pvo);
    break;
  case "sign":
    pvo.SIGN_EXCLUDE_YN = StrUtil.nvl(request.getParameter("useYN"));
    intResult = new MgrCustomerBean().M_COMPANY_SIGN_EXCLUDE_YN_MOD_PROC(pvo);
    break;
}
out.print(intResult);
%>