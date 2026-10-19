<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderActVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
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
Logger logger = Logger.getLogger("PAY_CYCLN_ORDER");

/********** 로그인 확인 **********/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
int    intCpyId = Integer.parseInt(strCpyId);
String strUser  = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN"));

/********** 세션 확인 **********/
String csrf_token = StrUtil.nvl(request.getParameter("csrf_token"));
if (!request.getMethod().equals("POST") || csrf_token.equals("")
    || !StrUtil.nvl((String)session.getAttribute("csrf_token")).equals(csrf_token)) {
  out.print("{\"result\":\"error\",\"msg\":\"세션이 종료되었습니다. 화면을 새로 고친 뒤 다시 시도하십시오.\"}");
  return;
}

String strOrderNo = StrUtil.nvl(request.getParameter("orderno")).trim();
if (strOrderNo.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"발주계약서를 찾을 수 없습니다.\"}");
  return;
}

/********** 접수할 수 있는 건인지 **********/
/* 거래당사자가 아니면 프로시저가 null 을 돌려준다. 역할과 단계도 여기서 본다. */
CyclnBean bean = new CyclnBean();
CyclnOrderDetailVO detail = bean.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (detail==null) {
  out.print("{\"result\":\"error\",\"msg\":\"열람권한이 없습니다.\"}");
  return;
}
if (!detail.canPay()) {
  String strWhy = detail.isPaymentSent() ? "이미 은행에 접수된 건입니다."
                : !detail.isConfirmed()  ? "발주가 확정된 뒤에 결제할 수 있습니다."
                : "지금 상태에서는 결제할 수 없습니다. 화면을 새로 고치십시오.";
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strWhy) + "\"}");
  return;
}

/********** 날짜 **********/
/* 화면에서 yyyy-MM-dd 로 온다.
   결제예정일은 오늘부터 7일 이내만 받는다. 세금계산서 발행일은 지난 날짜도 받는다 —
   월 정산으로 묶어 보내는 거래는 발행일이 접수일보다 앞선다. */
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd");
String strToday  = sdf.format(new java.util.Date());
String strDays7  = sdf.format(new java.util.Date(System.currentTimeMillis() + 7L*24L*60L*60L*1000L));

String strSetlPlnYmd = StrUtil.nvl(request.getParameter("setl_pln_ymd")).replaceAll("[^0-9]", "");
if (strSetlPlnYmd.length()!=8 || strSetlPlnYmd.compareTo(strToday)<0 || strSetlPlnYmd.compareTo(strDays7)>0) {
  out.print("{\"result\":\"error\",\"msg\":\"결제예정일을 다시 선택해주세요.\"}");
  return;
}

String strTaxIssuYmd = StrUtil.nvl(request.getParameter("tax_issu_ymd")).replaceAll("[^0-9]", "");
if (strTaxIssuYmd.length()!=8) {
  out.print("{\"result\":\"error\",\"msg\":\"세금계산서 발행일을 선택해주세요.\"}");
  return;
}

/********** 은행 접수 **********/
/* 결제예정금액은 발주계약금액 전액으로 둔다. 부분결제가 필요하면 화면에서 받아 넘기면 된다. */

CyclnOrderActVO act = new CyclnOrderActVO();
act.ORDERNO       = strOrderNo;
act.CPY_ID        = intCpyId;
act.USERID        = strUser;
act.STATUS_NOW    = detail.STATUS;
act.TRX_CLS       = CyclnOrderVO.TRX_REGIST;
act.PURC_ITEM     = detail.getPurcItem();
act.PURC_PRIC     = StrUtil.nvl(detail.PURC_PRIC).trim();
act.SETL_PLN_PRIC = act.PURC_PRIC;
act.SETL_PLN_YMD  = strSetlPlnYmd;
act.TAX_ISSU_YMD  = strTaxIssuYmd;

String[] arrResult = bean.CYCLN_CL090_PROC(act);
if (!arrResult[0].equals("ok")) {
  logger.error("FAIL TO PAY CYCLN ORDER : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);
  String strMsg = arrResult[1].equals("")
                ? "은행 접수에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다."
                : arrResult[1];
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
  return;
}
session.removeAttribute("csrf_token"); // 새로고침으로 두 번 접수되는 것을 막는다.
logger.debug("PAID CYCLN ORDER : " + strOrderNo + ", TMSG_SEQ=" + arrResult[1]);
out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\",\"tmsg_seq\":\"" + js(arrResult[1]) + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\"}");
%>
