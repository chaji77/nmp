<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.mail.MailSend" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
if (!StrUtil.nvl(request.getParameter("to")).contains("____")) {
  out.print(0);
  return;
}
String[] strTo         = StrUtil.xss(request.getParameter("to")).split("____");
String strEmail        = strTo[1];
String strReceiver     = strTo[0];
String strMailTitle    = StrUtil.xss(request.getParameter("title"));
String strMailBody     = StrUtil.xss(request.getParameter("body"));
String strSender       = ConfigurationMgr.getInstance().getString("MAIL_ID");
String strSenderName   = ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM");
String strSenderPw     = ConfigurationMgr.getInstance().getString("MAIL_PW");

String strMailSign     = "<p><br><br><br><br>본 메일은 발신전용입니다.<br>문의사항은 " 
                       + ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM") + " 고객센터(" 
                       + ConfigurationMgr.getInstance().getString("OWNER_TEL") +")로 문의바랍니다.</p>";

if (strEmail!=null && strEmail.length()>0 && strEmail.contains("@")) {
  MailSend.sendMail(strSender, strSenderName, strSenderPw, strEmail, strReceiver, strMailTitle, strMailBody + strMailSign, 1);

  MemoVO pvo      = new MemoVO();
  pvo.ACTIVE_KIND = StrUtil.nvl(request.getParameter("active_kind"));
  pvo.WRITE_ID    = (String) pageContext.getAttribute("SESS_LOGIN_ID");
  pvo.CPY_ID      = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
  pvo.CALL_TYPE   = "1";
  pvo.ACTIVE_DESC = "[메일전송] " + strMailBody;
  pvo.TO_USER_ID  = "";

  MemoBean bean = new MemoBean();
  out.print(new MemoBean().ACTIVE_MANAGEMENT_ADD_PROC(pvo));
} else {
  out.print(0);
}

%>