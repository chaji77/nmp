<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderActVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
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
Logger logger = Logger.getLogger("CONFIRM_CYCLN_ORDER");

/********** 로그인 확인 **********/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
int    intCpyId    = Integer.parseInt(strCpyId);
String strApprUser = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN"));

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

/********** 승인할 수 있는 건인지 **********/
/* 거래당사자가 아니면 프로시저가 null 을 돌려준다. 역할과 상태도 여기서 본다. */
CyclnBean bean = new CyclnBean();
CyclnOrderDetailVO detail = bean.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (detail==null) {
  out.print("{\"result\":\"error\",\"msg\":\"열람권한이 없습니다.\"}");
  return;
}
if (!detail.canConfirm()) {
  out.print("{\"result\":\"error\",\"msg\":\"지금 상태에서는 승인할 수 없습니다. 화면을 새로 고치십시오.\"}");
  return;
}

/********** 요청납기일 **********/
/* 화면에서 yyyy-MM-dd 로 온다. 오늘 이후만 받는다. */
String strToday      = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
String strReqDlvDate = StrUtil.nvl(request.getParameter("reqdlvdate")).replaceAll("[^0-9]", "");
if (strReqDlvDate.length()!=8 || strReqDlvDate.compareTo(strToday)<0) {
  out.print("{\"result\":\"error\",\"msg\":\"요청납기일을 다시 선택해주세요.\"}");
  return;
}

/********** 제품정보 **********/
/* SEQNO 는 CYCLN_ORDER_ITEM 의 키다. 화면이 숨은 칸으로 함께 보낸다.
   화면의 줄과 등록된 제품이 어긋나면 금액이 엉뚱한 줄에 들어가므로 여기서 막는다. */
String[] arrSeqNos = request.getParameterValues("seqno");
String[] arrQtys   = request.getParameterValues("qty");
String[] arrPrices = request.getParameterValues("price");
String[] arrSupply = request.getParameterValues("supplyamt");
String[] arrTaxes  = request.getParameterValues("taxamt");
String[] arrTotals = request.getParameterValues("totalamt");
String[] arrDescs  = request.getParameterValues("description");

if (arrSeqNos==null || arrSeqNos.length!=detail.ITEMS.size()) {
  out.print("{\"result\":\"error\",\"msg\":\"제품정보가 바뀌었습니다. 화면을 새로 고친 뒤 다시 승인하십시오.\"}");
  return;
}

ArrayList<CyclnOrderDetailVO.ItemVO> arrItems = new ArrayList<CyclnOrderDetailVO.ItemVO>();
BigDecimal bdPurcPric = BigDecimal.ZERO;
for (int i=0; i<arrSeqNos.length; i++) {
  String strSeqNo = StrUtil.nvl(at(arrSeqNos, i)).trim();
  if (!strSeqNo.equals(StrUtil.nvl(detail.ITEMS.get(i).SEQNO).trim())) {
    out.print("{\"result\":\"error\",\"msg\":\"제품정보가 바뀌었습니다. 화면을 새로 고친 뒤 다시 승인하십시오.\"}");
    return;
  }
  CyclnOrderDetailVO.ItemVO item = new CyclnOrderDetailVO.ItemVO();
  item.SEQNO       = strSeqNo;
  item.QTY         = num(at(arrQtys,   i));
  item.PRICE       = num(at(arrPrices, i));
  item.SUPPLYAMT   = num(at(arrSupply, i));
  item.TAXAMT      = num(at(arrTaxes,  i));
  item.TOTALAMT    = num(at(arrTotals, i));
  item.DESCRIPTION = StrUtil.xss(at(arrDescs, i)).trim();

  if (new BigDecimal(item.QTY).signum()<=0 || new BigDecimal(item.TOTALAMT).signum()<=0) {
    out.print("{\"result\":\"error\",\"msg\":\"납품수량과 총액을 확인하십시오.\"}");
    return;
  }
  bdPurcPric = bdPurcPric.add(new BigDecimal(item.TOTALAMT));
  arrItems.add(item);
}

/********** 승인 **********/
/* 승인은 CL080 의 등록(01) 전문이다. 변경(02)·취소(03)도 같은 프로시저를 쓴다.
   전문에 실을 대표품목과 매매금액은 여기서 정해 넘긴다. */
CyclnOrderActVO act = new CyclnOrderActVO();
act.ORDERNO    = strOrderNo;
act.CPY_ID     = intCpyId;
act.USERID     = strApprUser;
act.STATUS_NOW = detail.STATUS;
act.STATUS_CF  = CyclnOrderVO.STATUS_CONFIRMED;
act.TRX_CLS    = CyclnOrderVO.TRX_REGIST;
act.REQDLVDATE = strReqDlvDate;
act.PURC_ITEM  = detail.getPurcItem();
act.PURC_PRIC  = bdPurcPric.setScale(0, java.math.RoundingMode.HALF_UP).toPlainString();
act.ITEM_XML   = CyclnOrderDetailVO.setXml(arrItems);

String[] arrResult = bean.CYCLN_CL080_PROC(act);
if (!arrResult[0].equals("ok")) {
  logger.error("FAIL TO CONFIRM CYCLN ORDER : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);  String strMsg = arrResult[1].equals("")
                ? "승인에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다."
                : arrResult[1];
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
  return;
}
session.removeAttribute("csrf_token"); // 새로고침으로 두 번 승인되는 것을 막는다.
logger.debug("CONFIRMED CYCLN ORDER : " + strOrderNo + ", TMSG_SEQ=" + arrResult[1]);
if (StrUtil.isOnlyNumeric(detail.CPYBUYER)) {
  CyclnSms.send(Integer.parseInt(detail.CPYBUYER), CyclnSms.MSG_ORDER_CONFIRM.replace("#{CPY_NAME}", detail.SC_NAME)); // 구매기업에 납품확정 알림
}
out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\",\"tmsg_seq\":\"" + js(arrResult[1]) + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\"}");
%>
