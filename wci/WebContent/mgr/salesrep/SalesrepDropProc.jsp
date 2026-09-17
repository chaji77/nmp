<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepVO" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intResult = -1;
String strMid = request.getParameter("mid");
strMid = (IntegerCryptoUtil.isEncrypted(strMid)) ? IntegerCryptoUtil.crypt(strMid) : null;
if (strMid!=null) {
  SalesrepVO pvo = new SalesrepVO();
  pvo.SALESREP_ID = Integer.parseInt(strMid);
  pvo.REG_ID = (int) pageContext.getAttribute("SESS_MGR_ID");
  intResult  = new SalesrepBean().M_SALESREP_DROP_PROC(pvo);
}
out.print(intResult);
%>