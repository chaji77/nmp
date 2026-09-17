<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.mail.MailSend" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String strBizNo   = StrUtil.xss(request.getParameter("bizno")).replaceAll("-", "");
String strUserId  = StrUtil.xss(request.getParameter("userid"));
String strEmail   = "";
String strComName = "";
String[] str      = new LoginBean().C_ACCOUNT_EMAIL_PROC(strBizNo, strUserId);
if (str.length==2) {
	strEmail   = str[0];
	strComName = str[1];
}

// generate a key for password reissue
String strEnKey  = CryptoDESUtil.encrypt(strBizNo+"____"+strUserId+"____"+strEmail);

// reset page
String strUrl    = ConfigurationMgr.getInstance().getString("DOMAIN_URL")
                 + ConfigurationMgr.getInstance().getString("CONTEXT_PATH")
                 + ConfigurationMgr.getInstance().getString("PASSWORD_RESET_URL")
                 + strEnKey;

// set mail title
String strMailTitle = "비밀번호 재발급 안내";

// set mail body
String strMailBody = StrUtil.templateToString("ResetPassword.htm");
strMailBody = strMailBody.replaceAll("%%OWNER_URL_MAIN%%",   ConfigurationMgr.getInstance().getString("DOMAIN_URL") + ConfigurationMgr.getInstance().getString("OWNER_URL_MAIN"));
strMailBody = strMailBody.replaceAll("%%NEW_PASSWORD_URL%%", strUrl);
strMailBody = strMailBody.replaceAll("%%OWNER_BRAND_NM%%",   ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM"));
strMailBody = strMailBody.replaceAll("%%OWNER_NM%%",         ConfigurationMgr.getInstance().getString("OWNER_NM"));
strMailBody = strMailBody.replaceAll("%%OWNER_TEL%%",        ConfigurationMgr.getInstance().getString("OWNER_TEL"));

String strSender       = ConfigurationMgr.getInstance().getString("MAIL_ID");
String strSenderName   = ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM");
String strSenderPw     = ConfigurationMgr.getInstance().getString("MAIL_PW");
String strTitle        = ConfigurationMgr.getInstance().getString("PASSWORD_RESET_TITLE");

if (strEmail!=null && strEmail.length()>0 && strEmail.contains("@")) {
  MailSend.sendMail(strSender, strSenderName, strSenderPw, strEmail, StrUtil.nvl(strComName), strTitle, strMailBody, 1);
  out.print(strEmail);
} else {
  out.print("");
}
%>