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
strMid        = (IntegerCryptoUtil.isEncrypted(strMid)) ? IntegerCryptoUtil.crypt(strMid) : null;

SalesrepVO pvo = new SalesrepVO();
pvo.NM          = StrUtil.xss(request.getParameter("name"));
pvo.PHONE_NO    = StrUtil.xss(request.getParameter("phone_no"));
pvo.FAX_NO      = StrUtil.xss(request.getParameter("fax_no"));
pvo.EMAIL       = StrUtil.xss(request.getParameter("email"));
pvo.REG_ID      = (int) pageContext.getAttribute("SESS_MGR_ID");

SalesrepBean bean = new SalesrepBean();

if (strMid!=null) {
  pvo.SALESREP_ID = Integer.parseInt(strMid);
  intResult       = bean.M_SALESREP_MOD_PROC(pvo);
} else {
  pvo.NM  = StrUtil.xss(request.getParameter("name"));
  intResult          = bean.M_SALESREP_ADD_PROC(pvo);
}
out.print(intResult);
%>