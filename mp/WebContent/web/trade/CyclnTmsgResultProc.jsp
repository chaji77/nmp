<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ page import="kr.co.mp.sms.CyclnSms" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%!
/* JSON 문자열 값에 넣을 수 있게 따옴표를 막는다. */
String js(String s) {
  return StrUtil.nvl(s).replace("\\", "\\\\").replace("\"", "\\\"").replaceAll("[\r\n]", " ");
}
%>
<%
/*
 * 싸이클론 CL080(승인)·CL090(결제접수) 은행 응답 확인.
 * 응답 전이면 result=wait 이고 화면이 다시 부른다.
 * CL080 등록(승인)이 은행에서 실패하면 구매기업에 문자를 보낸다.
 */
Logger logger = Logger.getLogger("CYCLN_TMSG_RESULT");

/********** 로그인 확인 **********/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
int intCpyId = Integer.parseInt(strCpyId);

String strKncd    = StrUtil.nvl(request.getParameter("kncd")).trim();
String strTmsgSeq = StrUtil.nvl(request.getParameter("tmsg_seq")).trim();
String strReqYmd  = StrUtil.nvl(request.getParameter("req_ymd")).trim();

/********** 응답 읽기 **********/
CyclnBean bean = new CyclnBean();
String[] arr = bean.CYCLN_TMSG_RESULT_PROC(strKncd, strTmsgSeq, strReqYmd);
if (arr==null) {
  out.print("{\"result\":\"error\",\"msg\":\"전문을 찾을 수 없습니다.\"}");
  return;
}
String strStatus = arr[0], strResMsg = arr[2], strOrderNo = arr[3], strTrxCls = arr[4];

/* 거래당사자만 결과를 볼 수 있다. 아니면 프로시저가 null 을 돌려준다. */
CyclnOrderDetailVO detail = bean.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (detail==null) {
  out.print("{\"result\":\"error\",\"msg\":\"열람권한이 없습니다.\"}");
  return;
}

if (strStatus.equals("2")) {
  out.print("{\"result\":\"ok\"}");
  return;
}
if (!strStatus.equals("9")) {
  out.print("{\"result\":\"wait\"}");
  return;
}

/********** 은행 처리 실패 **********/
logger.error("CYCLN " + strKncd + " FAILED AT BANK : ORDERNO=" + strOrderNo + ", TMSG_SEQ=" + strTmsgSeq + ", RESP_CD=" + arr[1] + ", MSG=" + strResMsg);

/* 승인(CL080 등록) 실패만 구매기업에 알린다. 다시 불려도 한 번만 보내도록 세션에 표시한다. */
String strSentKey = "CYCLN_SMS_" + strKncd + "_" + strReqYmd + "_" + strTmsgSeq;
if (strKncd.equals("CL080") && strTrxCls.equals(CyclnOrderVO.TRX_REGIST)
    && session.getAttribute(strSentKey)==null && StrUtil.isOnlyNumeric(detail.CPYBUYER)) {
  session.setAttribute(strSentKey, "Y");
  CyclnSms.send(Integer.parseInt(detail.CPYBUYER), CyclnSms.MSG_CONFIRM_FAIL.replace("#{CPY_NAME}", detail.SC_NAME));
}

String strMsg = "은행 처리에 실패했습니다." + (strResMsg.equals("") ? "" : "<br/>" + strResMsg);
out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
%>
