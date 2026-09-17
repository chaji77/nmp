<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
System.out.println("ManagerRegProc");
int intResult = -1;
String strMid = request.getParameter("mid");
strMid        = (IntegerCryptoUtil.isEncrypted(strMid)) ? IntegerCryptoUtil.crypt(strMid) : null;

ManagerVO pvo = new ManagerVO();
pvo.LOGIN_PW  = StrUtil.xss(request.getParameter("login_pw"));
pvo.USER_NM   = StrUtil.xss(request.getParameter("user_nm"));
pvo.REG_ID    = (int) pageContext.getAttribute("SESS_MGR_ID");

ManagerBean bean = new ManagerBean();

if (strMid!=null) {
  pvo.MAN_ID = Integer.parseInt(strMid);
  intResult  = bean.M_MANAGER_MOD_PROC(pvo);
} else {
  pvo.LOGIN_ID = StrUtil.xss(request.getParameter("login_id"));
  intResult    = bean.M_MANAGER_ADD_PROC(pvo);
}
out.print(intResult);
%>