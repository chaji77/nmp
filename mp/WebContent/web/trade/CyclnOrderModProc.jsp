<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderActVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderRegVO" %>
<%@ page import="kr.co.mp.sms.CyclnSms" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%!
/* 화면에서 온 금액/수량은 쉼표가 섞여 온다. 숫자만 남긴다. 비어 있으면 0. */
String num(String s) {
  s = StrUtil.nvl(s).replaceAll(",", "").trim();
  if (s.equals("")) return "0";
  try {
    return new BigDecimal(s).toPlainString();
  } catch (NumberFormatException e) {
    return "0";
  }
}
/* 길이가 어긋난 파라미터 배열에서도 안전하게 꺼낸다. */
String at(String[] arr, int i) {
  return (arr!=null && i<arr.length) ? StrUtil.nvl(arr[i]) : "";
}
/* JSON 문자열 값에 넣을 수 있게 따옴표를 막는다. */
String js(String s) {
  return StrUtil.nvl(s).replace("\\", "\\\\").replace("\"", "\\\"").replaceAll("[\r\n]", " ");
}
%>
<%
Logger logger = Logger.getLogger("MODIFY_CYCLN_ORDER");

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

/* MOD-수정, CANCEL-취소. 둘 다 판매기업 승인 전에만 된다. */
String strAction = StrUtil.nvl(request.getParameter("action"), "MOD").trim();
if (!strAction.equals("MOD") && !strAction.equals("CANCEL")) strAction = "MOD";

String strOrderNo = StrUtil.nvl(request.getParameter("orderno")).trim();
if (strOrderNo.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"발주계약서를 찾을 수 없습니다.\"}");
  return;
}

/********** 처리할 수 있는 건인지 **********/
/* 거래당사자가 아니면 프로시저가 null 을 돌려준다. 역할과 상태도 여기서 본다.
   수정은 발주계약서를 쓴 구매기업만, 취소는 양쪽 다 할 수 있다. */
CyclnBean bean = new CyclnBean();
CyclnOrderDetailVO detail = bean.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (detail==null) {
  out.print("{\"result\":\"error\",\"msg\":\"열람권한이 없습니다.\"}");
  return;
}
if (strAction.equals("CANCEL") ? !detail.canCancel() : !detail.canModify()) {
  String strWhy = detail.isCancelled() ? "이미 취소된 발주계약서입니다."
                : !detail.isBeforeConfirm() ? "판매기업이 승인한 건은 여기서 처리할 수 없습니다."
                : "지금 상태에서는 처리할 수 없습니다. 화면을 새로 고치십시오.";
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strWhy) + "\"}");
  return;
}

CyclnOrderActVO act = new CyclnOrderActVO();
act.ORDERNO    = strOrderNo;
act.CPY_ID     = intCpyId;
act.USERID     = strUser;
act.STATUS_NOW = detail.STATUS;

/********** 취소는 상태만 바꾸고 끝난다 **********/
if (strAction.equals("CANCEL")) {
  act.STATUS_CF = detail.getCancelStatus(); // 구매기업 090, 판매기업 095

  String[] arrCancel = bean.CYCLN_ORDER_MOD_PROC(act);
  if (!arrCancel[0].equals("ok")) {
    logger.error("FAIL TO CANCEL CYCLN ORDER : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrCancel[1]);
    String strCancelMsg = arrCancel[1].equals("")
                        ? "취소에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다."
                        : arrCancel[1];
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strCancelMsg) + "\"}");
    return;
  }
  session.removeAttribute("csrf_token");
  logger.debug("CANCELLED CYCLN ORDER : " + strOrderNo + ", STATUS=" + act.STATUS_CF);
  /* 취소한 쪽의 회사명으로 상대 회사에 알린다. */
  if (detail.isSeller()) {
    if (StrUtil.isOnlyNumeric(detail.CPYBUYER)) {
      CyclnSms.send(Integer.parseInt(detail.CPYBUYER), CyclnSms.MSG_SELLER_CANCEL.replace("#{CPY_NAME}", detail.SC_NAME));
    }
  } else if (StrUtil.isOnlyNumeric(detail.CPYSELLER)) {
    CyclnSms.send(Integer.parseInt(detail.CPYSELLER), CyclnSms.MSG_BUYER_CANCEL.replace("#{CPY_NAME}", detail.BC_NAME));
  }
  out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\"}");
  return;
}

/********** 계약기본정보 **********/
String strToday = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());

act.ORDERNAME  = StrUtil.xss(StrUtil.nvl(request.getParameter("order_name"))).trim();
act.REQDLVDATE = StrUtil.nvl(request.getParameter("reqdlvdate")).replaceAll("[^0-9]", "");
act.DLVADDRESS = StrUtil.xss(StrUtil.nvl(request.getParameter("addr"))).trim();

// 계산서 종류는 정의된 값만 받는다.
String strEstimateType = StrUtil.nvl(request.getParameter("estimate_type"), "1");
if (!strEstimateType.equals("1") && !strEstimateType.equals("2") && !strEstimateType.equals("3")) strEstimateType = "1";
act.ESTIMATE_TYPE = strEstimateType;

if (act.ORDERNAME.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"발주계약서명을 입력하십시오.\"}");
  return;
}
if (act.REQDLVDATE.length()!=8 || act.REQDLVDATE.compareTo(strToday)<0) {
  out.print("{\"result\":\"error\",\"msg\":\"요청납기일을 다시 선택해주세요.\"}");
  return;
}
if (act.DLVADDRESS.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"도착지를 입력하십시오.\"}");
  return;
}

/********** 제품정보 **********/
/* 제품정보는 통째로 다시 쓰므로 SEQNO 를 001 부터 새로 매긴다. */
String[] arrNames  = request.getParameterValues("prd_title");
String[] arrQtys   = request.getParameterValues("reqqty");
String[] arrUnits  = request.getParameterValues("unit");
String[] arrPrices = request.getParameterValues("reqprice");
String[] arrSupply = request.getParameterValues("supplyamt");
String[] arrTaxes  = request.getParameterValues("taxamt");
String[] arrTotals = request.getParameterValues("totalamt");
String[] arrDescs  = request.getParameterValues("description");

if (arrNames==null || arrNames.length==0) {
  out.print("{\"result\":\"error\",\"msg\":\"제품정보를 입력하십시오.\"}");
  return;
}

ArrayList<CyclnOrderRegVO.ItemVO> arrItems = new ArrayList<CyclnOrderRegVO.ItemVO>();
for (int i=0; i<arrNames.length; i++) {
  CyclnOrderRegVO.ItemVO item = new CyclnOrderRegVO.ItemVO();
  item.SEQNO       = (i<999) ? Integer.toString(1000+(i+1)).substring(1) : Integer.toString(i+1); // 001 부터
  item.PRD_TITLE   = StrUtil.xss(at(arrNames, i)).trim();
  item.UNIT        = StrUtil.xss(at(arrUnits, i)).trim();
  item.REQQTY      = num(at(arrQtys,   i));
  item.REQPRICE    = num(at(arrPrices, i));
  item.SUPPLYAMT   = num(at(arrSupply, i));
  item.TAXAMT      = num(at(arrTaxes,  i));
  item.TOTALAMT    = num(at(arrTotals, i));
  item.DESCRIPTION = StrUtil.xss(at(arrDescs, i)).trim();

  if (item.PRD_TITLE.equals("")) {
    out.print("{\"result\":\"error\",\"msg\":\"제품명을 입력하십시오.\"}");
    return;
  }
  if (new BigDecimal(item.REQQTY).signum()<=0 || new BigDecimal(item.TOTALAMT).signum()<=0) {
    out.print("{\"result\":\"error\",\"msg\":\"요청수량과 총액을 확인하십시오.\"}");
    return;
  }
  arrItems.add(item);
}
act.ITEM_XML = CyclnOrderRegVO.setXml(arrItems);

/********** 저장 **********/
String[] arrResult = bean.CYCLN_ORDER_MOD_PROC(act);
if (!arrResult[0].equals("ok")) {
  logger.error("FAIL TO MODIFY CYCLN ORDER : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);
  String strMsg = arrResult[1].equals("")
                ? "수정에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다."
                : arrResult[1];
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
  return;
}
session.removeAttribute("csrf_token"); // 새로고침으로 두 번 저장되는 것을 막는다.
logger.debug("MODIFIED CYCLN ORDER : " + strOrderNo);
out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\"}");
%>
