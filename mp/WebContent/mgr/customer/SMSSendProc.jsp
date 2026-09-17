<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.sms.SendSMS" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strTo           = StrUtil.xss(request.getParameter("to")).replaceAll("-", "");
String strBody         = StrUtil.nvl(request.getParameter("msg"));

if (strTo!=null && strTo.length()>10) {
  SendSMS.SEND_SMS_PROC(strTo, strBody.replaceAll("\r\n", System.lineSeparator()), 86);

  MemoVO pvo      = new MemoVO();
  pvo.ACTIVE_KIND = StrUtil.nvl(request.getParameter("active_kind"));
  pvo.WRITE_ID    = (String) pageContext.getAttribute("SESS_LOGIN_ID");
  pvo.CPY_ID      = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
  pvo.CALL_TYPE   = "2";
  pvo.ACTIVE_DESC = "[SMS전송 : "+strTo+"] " + strBody.replaceAll("\r\n", "<br/>");
  pvo.TO_USER_ID  = "";

  MemoBean bean = new MemoBean();
  out.print(new MemoBean().ACTIVE_MANAGEMENT_ADD_PROC(pvo));
} else {
  out.print(0);
}

%>