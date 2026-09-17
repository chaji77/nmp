<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
System.out.println("ManagerDropProc");
int intResult = -1;
String strMid = request.getParameter("mid");
strMid = (IntegerCryptoUtil.isEncrypted(strMid)) ? IntegerCryptoUtil.crypt(strMid) : null;
if (strMid!=null) {
  ManagerVO pvo = new ManagerVO();
  pvo.MAN_ID = Integer.parseInt(strMid);
  pvo.REG_ID = (int) pageContext.getAttribute("SESS_MGR_ID");
  intResult  = new ManagerBean().M_MANAGER_DROP_PROC(pvo);
}
out.print(intResult);
%>