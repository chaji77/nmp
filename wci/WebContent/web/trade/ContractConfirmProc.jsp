<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.CtItemVO" %>
<%@ page import="kr.co.mp.trade.SignVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.AbnormalConfiguration" %>
<%@ page import="kr.co.mp.trade.AbnormalTransactionCheck" %>
<%@ page import="kr.co.mp.mgr.sales.MpFeeCalcurator" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
/* VARIABLES */
TradeBean bean     = new TradeBean();
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int    intCpyId    = 0;
int    intResult   = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else {
  out.print("{\"step\":\"session\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
String strBuyerCpyId = StrUtil.nvl(request.getParameter("intBuyerCpyId"));
String strLoginId  = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN"));
String strRemoteIP = LoginUtil.getClientIpAddr(request);
String strErrorMsgPrefix = AbnormalConfiguration.getInstance().getString("ERR_HEADER"); // Message header for transaction suspension due to abnormal transaction monitoring
try {

  /********** SAVE SIGN-DATA & CHECK SIGN ************/
  int intSignSeq = 0;
  if (StrUtil.nvl(request.getParameter("sgn_id")).equals("0000")) {
    String strSignData = StrUtil.nvl(request.getParameter("signdata"));
    if (strSignData.length()>0) {
      intSignSeq = bean.SIGNINFO_ADD_PROC(strSignData);
    }
  }
  String SIGN_EXCLUDE_YN = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
  if (!SIGN_EXCLUDE_YN.equals("Y") && intSignSeq==0) {
    out.print("{\"step\":\"sign\",\"msg\":\"전자서명이 필요합니다.\"}");
    return;
  }

  /********** CHECK COMMISSION (2025/04/14) ************/
  int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0")); // 매매계약ID
  if (!new MpFeeCalcurator().isCommissionInfo(intCtId)) {
    // TO-DO : 수수료정보를 읽을 수 없을 때 상태값을 어떻게 할지 결정해야 함
    out.print("{\"step\":\"nocommission\",\"msg\":\"수수료정보를 읽을 수 없습니다.\"}");
    return;
  }
  
  /********** CONFIRM ACTION WITH ABNORMAL TRANSACTION CHECK ************/
  String strResult = new TradeBean().confirm(intCtId, intCpyId, strLoginId, strRemoteIP, intSignSeq, "N");
  if (strResult.contains("SUCCESS____025____")) {
    String token = CryptoDESUtil.encrypt(Integer.toString(intCtId)+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "");
    if (strResult.contains("SUCCESS____025____Y")) { // 확인결제이면
      if (strCpyId.equals(strBuyerCpyId)) out.print("{\"step\":\"send\",\"msg\":\""+token+"\"}"); // 구매사이면 전송
      else out.print("{\"step\":\"confirm\",\"msg\":\"승인되었습니다.\"}"); // 판매사이면 승인
    } else { // 확인결제가 아니면 전송
      out.print("{\"step\":\"send\",\"msg\":\""+token+"\"}");
    }
  } else { // CAUGHT IN ABNORMAL TRANSACTION MONITORING
    out.print(strResult);
    return;
  }
  
} catch (Exception e) {
  Logger l = Logger.getLogger(this.getClass());
  l.error(e.toString());
}
%>