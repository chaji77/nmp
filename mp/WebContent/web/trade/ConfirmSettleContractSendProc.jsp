<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.trade.SignVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.ValidateCheck" %>
<%@ page import="kr.co.mp.trade.AbnormalTransactionCheck" %>
<%@ page import="kr.co.soap.controll.A312VO" %>
<%@ page import="kr.co.mp.mgr.sales.MpFeeCalcurator" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
/*********************************************************
이 파일은 확인결제 다중 처리를 위한 것이다.
이미 이상거래검증이 완료되어 있는 상태이므로, 서명정보만 업데이트하고 step을 send로 리턴한다.
나머지는 msg를 포함해 리턴한다.
*********************************************************/

/********** CHECH LOGIN STATUS ************/
TradeBean bean  = new TradeBean();
int intSignSeq  = 0;                               // Key for sign table
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int    intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else {
  out.print("{\"step\":\"session\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}

int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
if (intCtId==0) {
  out.print("{\"step\":\"error\",\"msg\":\"선택된 매매계약서가 없습니다.\"}");
  return;
}

/********** SAVE SIGN-DATA & CHECK SIGN ************/
String sessionSignSeq = StrUtil.nvl((String)session.getAttribute("signseq"), "0");
if (sessionSignSeq.equals("0") && StrUtil.nvl(request.getParameter("sgn_id")).equals("0000")) {
   String strSignData = StrUtil.nvl(request.getParameter("signdata"));
   if (strSignData.length()>0) {
     intSignSeq = bean.SIGNINFO_ADD_PROC(strSignData);
     session.setAttribute("signseq", Integer.toString(intSignSeq));
   }
} else intSignSeq = Integer.parseInt(sessionSignSeq);

if (intSignSeq>0) { // 서명정보가 있으면 업데이트한다.
  bean.CT_HEADER_ADD_SGN_PROC(intCtId, intSignSeq);
}

String strCtId = Integer.toString(intCtId);
String enid    = IntegerCryptoUtil.crypt(strCtId);
String token   = CryptoDESUtil.encrypt(strCtId+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "");
out.print("{\"step\":\"send\",\"msg\":\""+ strCtId + "____" + enid + "____" + token+"\"}");
%>