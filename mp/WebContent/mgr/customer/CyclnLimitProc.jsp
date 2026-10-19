<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnLimitVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
/* JSON 문자열 값에 넣을 수 있게 따옴표를 막는다. */
String js(String s) {
  return StrUtil.nvl(s).replace("\\", "\\\\").replace("\"", "\\\"").replaceAll("[\r\n]", " ");
}
%>
<%
/*
 * 싸이클론 한도조회(CL120).
 * tmsg_seq 없이 부르면 전문을 등록하고 일련번호를 돌려준다.
 * tmsg_seq 를 넘기면 응답을 읽는다. 응답 전이면 result=wait 이고 화면이 다시 부른다.
 */
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("CYCLN_CL120");

String strCpyId = request.getParameter("cpy_id");
if (!IntegerCryptoUtil.isEncrypted(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"회원을 찾을 수 없습니다.\"}");
  return;
}
int intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(strCpyId));

CyclnBean bean = new CyclnBean();
String strTmsgSeq = StrUtil.nvl(request.getParameter("tmsg_seq")).trim();
String strReqYmd  = StrUtil.nvl(request.getParameter("req_ymd")).trim();

/********** 전문 등록 **********/
if (strTmsgSeq.equals("")) {
  String[] arrResult = bean.CYCLN_CL120_PROC(intCpyId);
  if (!arrResult[0].equals("ok")) {
    logger.error("FAIL TO SEND CL120 : CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);
    String strMsg = arrResult[1].equals("") ? "한도조회 요청에 실패했습니다." : arrResult[1];
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
    return;
  }
  out.print("{\"result\":\"sent\",\"tmsg_seq\":\"" + js(arrResult[1]) + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\"}");
  return;
}

/********** 응답 읽기 **********/
ArrayList<CyclnLimitVO> arr = bean.CYCLN_CL120_RESULT_PROC(strTmsgSeq, strReqYmd);
if (arr.size()==0) {
  out.print("{\"result\":\"error\",\"msg\":\"한도조회 전문을 찾을 수 없습니다.\"}");
  return;
}
CyclnLimitVO first = arr.get(0);
if (first.STATUS.equals(CyclnLimitVO.STATUS_FAIL)) {
  out.print("{\"result\":\"error\",\"msg\":\"은행 전송에 실패했습니다. 잠시 후 다시 조회하십시오.\"}");
  return;
}
if (!first.STATUS.equals(CyclnLimitVO.STATUS_DONE)) {
  out.print("{\"result\":\"wait\"}");
  return;
}
/* 응답은 왔는데 레코드가 없으면 은행 메시지를 보인다. */
if (first.TRX_CLS.equals("")) {
  String strMsg = first.RES_MSG.equals("") ? "조회된 한도가 없습니다." : first.RES_MSG;
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
  return;
}

StringBuilder sb = new StringBuilder();
sb.append("<h4 style='margin-top:0;padding-top:0;'>싸이클론 한도조회결과</h4>");
sb.append("<table class='detail'><thead><tr>");
sb.append("<th class='center'>거래구분</th><th class='center'>신규일</th><th class='center'>만기일</th><th class='right'>약정한도</th><th class='right'>대출잔액</th><th class='right'>한도여유액</th>");
sb.append("</tr></thead><tbody>");
for (CyclnLimitVO t : arr) {
  sb.append("<tr>");
  sb.append("<td class='center'>").append(t.getTrxClsName()).append("</td>");
  sb.append("<td class='center'>").append(t.NEW_YMD).append("</td>");
  sb.append("<td class='center'>").append(t.MTR_YMD).append("</td>");
  sb.append("<td class='right'>").append(StrUtil.addComma(t.LIMIT_AMT)).append("원</td>");
  sb.append("<td class='right'>").append(StrUtil.addComma(t.LOAN_AMT)).append("원</td>");
  sb.append("<td class='right' style='color:red;'>").append(StrUtil.addComma(t.SPARE_AMT)).append("원</td>");
  sb.append("</tr>");
}
sb.append("</tbody></table>");
out.print("{\"result\":\"ok\",\"msg\":\"" + js(sb.toString()) + "\"}");
%>
