<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("RegistProc.jsp");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCpyId    = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

int intResult   = 0;
boolean isError = false;
String strErrorMsg = "";
PersonVO  pvo = new PersonVO();
try {
  pvo.PRS_ID = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("prs_id")));
  pvo.PRS_LOGIN = StrUtil.xss(request.getParameter("login_id"));
  pvo.PRS_PASSWD = CryptoDESUtil.encrypt(StrUtil.nvl(request.getParameter("login_pw")));
  pvo.PRS_NAME = StrUtil.xss(request.getParameter("login_nm"));
  pvo.PRS_TEL = StrUtil.xss(request.getParameter("login_tel"));
  pvo.PRS_MOBILE_NO = StrUtil.xss(request.getParameter("login_cell_tel"));
  pvo.PRS_SMS = StrUtil.nvl(request.getParameter("sms_yn"), "0");
  pvo.PRS_EMAIL = StrUtil.xss(request.getParameter("login_email"));

  CustomerBean bean = new CustomerBean();
  if (StrUtil.isOnlyNumeric(pvo.PRS_ID)) {
    if (pvo.PRS_ID.equals("0")) intResult = bean.PERSON_ADD_PROC(intCpyId, pvo);
    else intResult = bean.PERSON_MOD_PROC(intCpyId, pvo);
  } else {
    isError = true;
    strErrorMsg = "처리할 수 없습니다. 문제가 지속되면 고객센터로 문의바랍니다.";
  }
} catch (Exception e) {
  logger.error(e.toString());
  isError = true;
  strErrorMsg = "수정할 수 없습니다. 다시 시도하십시오. 문제가 지속되면 고객센터로 문의바랍니다.";
}

if (isError) {
  logger.error(strErrorMsg);
  logger.error(pvo.toString());
}
%>
<script>
parent.btnSubmitIsClicked = false;
parent.hideLoading();
<% if (isError) { %>
parent.toast("<%=strErrorMsg%>", 3000);
<% } else { %>
parent.callback();
<% } %>
</script>