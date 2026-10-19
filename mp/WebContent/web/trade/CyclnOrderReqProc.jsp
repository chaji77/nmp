<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
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
/* 상대 회사에 문자를 보낸다. 회사 ID 가 숫자가 아니면 보내지 않는다. */
void sms(String strCpyId, String strMsg) {
  if (StrUtil.isOnlyNumeric(StrUtil.nvl(strCpyId).trim())) CyclnSms.send(Integer.parseInt(strCpyId.trim()), strMsg);
}
%>
<%
/*
 * 판매기업 승인(CL080 등록) 뒤의 변경·취소.
 *   CHGREQ - 변경요청. 고친 내용을 저장하고 상태를 020(구매사)·025(판매사)로 바꾼다. 전문은 나가지 않는다.
 *            상대가 다시 고쳐 변경요청할 수 있고, 상대가 승인해야 전문이 나간다.
 *   CHGCFM - 변경승인. 저장된 내용으로 CL080 변경(02) 전문을 보낸다. 상태는 변경요청 그대로 둔다.
 *   CANREQ - 취소요청. 상대 승인 없이 취소(03) 전문을 보내고 상태를 030(판매사)·035(구매사)로 바꾼다.
 *            CL090 이 나가 있으면 CL090 부터 취소하고, 그 취소가 끝나면 다시 불러 CL080 을 취소한다.
 * 어떤 전문을 보낼 수 있는지는 CyclnOrderDetailVO 가 판단한다. 화면도 같은 판단으로 버튼을 보인다.
 */
Logger logger = Logger.getLogger("REQ_CYCLN_ORDER");

/********** 로그인 확인 **********/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
int    intCpyId = Integer.parseInt(strCpyId);
String strUser  = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN")).trim();

/********** 세션 확인 **********/
String csrf_token = StrUtil.nvl(request.getParameter("csrf_token"));
if (!request.getMethod().equals("POST") || csrf_token.equals("")
    || !StrUtil.nvl((String)session.getAttribute("csrf_token")).equals(csrf_token)) {
  out.print("{\"result\":\"error\",\"msg\":\"세션이 종료되었습니다. 화면을 새로 고친 뒤 다시 시도하십시오.\"}");
  return;
}

String strAction  = StrUtil.nvl(request.getParameter("action")).trim();
String strOrderNo = StrUtil.nvl(request.getParameter("orderno")).trim();
if (strOrderNo.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"발주계약서를 찾을 수 없습니다.\"}");
  return;
}

/* 거래당사자가 아니면 프로시저가 null 을 돌려준다. */
CyclnBean bean = new CyclnBean();
CyclnOrderDetailVO detail = bean.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (detail==null) {
  out.print("{\"result\":\"error\",\"msg\":\"열람권한이 없습니다.\"}");
  return;
}
boolean isSeller    = detail.isSeller();
String  strMyName   = isSeller ? "판매기업 " + detail.SC_NAME : "구매기업 " + detail.BC_NAME;
String  strOtherCpy = isSeller ? detail.CPYBUYER : detail.CPYSELLER;
String  strRetry    = "지금 상태에서는 처리할 수 없습니다. 화면을 새로 고치십시오.";

CyclnOrderActVO act = new CyclnOrderActVO();
act.ORDERNO    = strOrderNo;
act.CPY_ID     = intCpyId;
act.STATUS_NOW = detail.STATUS;

/********** 변경요청 **********/
if (strAction.equals("CHGREQ")) {
  if (!detail.canChgReq()) {
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strRetry) + "\"}");
    return;
  }
  /* 처리자 기록 시각(*_CHGDELTIME)으로 승인 대기를 가리므로 처리자가 꼭 있어야 한다. */
  if (strUser.equals("")) {
    out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
    return;
  }

  String strToday      = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
  String strReqDlvDate = StrUtil.nvl(request.getParameter("reqdlvdate")).replaceAll("[^0-9]", "");
  if (strReqDlvDate.length()!=8 || strReqDlvDate.compareTo(strToday)<0) {
    out.print("{\"result\":\"error\",\"msg\":\"요청납기일을 다시 선택해주세요.\"}");
    return;
  }

  /* 판매기업 승인과 같은 방식이다. 화면의 줄과 등록된 제품이 어긋나면 막는다. */
  String[] arrSeqNos = request.getParameterValues("seqno");
  String[] arrQtys   = request.getParameterValues("qty");
  String[] arrPrices = request.getParameterValues("price");
  String[] arrSupply = request.getParameterValues("supplyamt");
  String[] arrTaxes  = request.getParameterValues("taxamt");
  String[] arrTotals = request.getParameterValues("totalamt");
  String[] arrDescs  = request.getParameterValues("description");

  if (arrSeqNos==null || arrSeqNos.length!=detail.ITEMS.size()) {
    out.print("{\"result\":\"error\",\"msg\":\"제품정보가 바뀌었습니다. 화면을 새로 고친 뒤 다시 요청하십시오.\"}");
    return;
  }
  ArrayList<CyclnOrderDetailVO.ItemVO> arrItems = new ArrayList<CyclnOrderDetailVO.ItemVO>();
  for (int i=0; i<arrSeqNos.length; i++) {
    String strSeqNo = StrUtil.nvl(at(arrSeqNos, i)).trim();
    if (!strSeqNo.equals(StrUtil.nvl(detail.ITEMS.get(i).SEQNO).trim())) {
      out.print("{\"result\":\"error\",\"msg\":\"제품정보가 바뀌었습니다. 화면을 새로 고친 뒤 다시 요청하십시오.\"}");
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
    arrItems.add(item);
  }

  act.USERID       = strUser;
  act.STATUS_CF    = detail.getChgReqStatus(); // 구매기업 020, 판매기업 025
  act.REQDLVDATE   = strReqDlvDate;
  act.DLV_ITEM_XML = CyclnOrderDetailVO.setXml(arrItems);

  String[] arrResult = bean.CYCLN_ORDER_MOD_PROC(act);
  if (!arrResult[0].equals("ok")) {
    logger.error("FAIL TO REQUEST CHANGE : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);
    String strMsg = arrResult[1].equals("") ? "변경요청에 실패했습니다. 잠시 후 다시 시도하십시오." : arrResult[1];
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
    return;
  }
  session.removeAttribute("csrf_token");
  logger.debug("REQUESTED CHANGE : " + strOrderNo + ", STATUS=" + act.STATUS_CF);
  sms(strOtherCpy, (isSeller ? CyclnSms.MSG_SELLER_CHGREQ : CyclnSms.MSG_BUYER_CHGREQ).replace("#{CPY_NAME}", isSeller ? detail.SC_NAME : detail.BC_NAME));
  out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\"}");
  return;
}

/********** 변경승인 **********/
if (strAction.equals("CHGCFM")) {
  if (!detail.canChgCfm()) {
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strRetry) + "\"}");
    return;
  }
  /* 변경요청 때 저장된 제품정보와 요청납기일을 그대로 싣는다. 매매금액은 총액 합계다. */
  BigDecimal bdPurcPric = BigDecimal.ZERO;
  for (CyclnOrderDetailVO.ItemVO r : detail.ITEMS) bdPurcPric = bdPurcPric.add(new BigDecimal(num(r.TOTALAMT)));

  act.USERID    = strUser;
  act.TRX_CLS   = CyclnOrderVO.TRX_CHANGE;
  act.PURC_ITEM = detail.getPurcItem();
  act.PURC_PRIC = bdPurcPric.setScale(0, java.math.RoundingMode.HALF_UP).toPlainString();

  String[] arrResult = bean.CYCLN_CL080_PROC(act);
  if (!arrResult[0].equals("ok")) {
    logger.error("FAIL TO CONFIRM CHANGE : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", MSG=" + arrResult[1]);
    String strMsg = arrResult[1].equals("") ? "변경승인에 실패했습니다. 잠시 후 다시 시도하십시오." : arrResult[1];
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
    return;
  }
  session.removeAttribute("csrf_token");
  logger.debug("CONFIRMED CHANGE : " + strOrderNo + ", TMSG_SEQ=" + arrResult[1]);
  sms(strOtherCpy, CyclnSms.MSG_CHG_CONFIRM.replace("#{CPY_NAME}", strMyName));
  out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\",\"kncd\":\"CL080\",\"tmsg_seq\":\"" + js(arrResult[1]) + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\"}");
  return;
}

/********** 취소요청 **********/
if (strAction.equals("CANREQ")) {
  String strKncd = detail.getCancelKncd();
  if (strKncd.equals("")) {
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strRetry) + "\"}");
    return;
  }
  boolean isFirst = !detail.isCancelRequested(); // 처음 누를 때만 상태가 바뀌고 문자가 나간다

  /* 처리자는 비워 넘긴다. 승인·결제접수한 사람의 기록을 덮어쓰지 않는다. 누른 사람은 로그에 남긴다. */
  act.TRX_CLS   = CyclnOrderVO.TRX_CANCEL;
  act.STATUS_CF = detail.getCancelReqStatus(); // 구매기업 035, 판매기업 030. 이어서 보낼 때는 그대로
  act.PURC_ITEM = detail.getPurcItem();
  act.PURC_PRIC = num(detail.PURC_PRIC);

  String[] arrResult;
  if (strKncd.equals("CL090")) {
    /* 마지막으로 접수한 결제예정정보를 그대로 싣는다. */
    act.SETL_PLN_PRIC = num(detail.SETL_PLN_PRIC);
    act.SETL_PLN_YMD  = StrUtil.nvl(detail.SETL_PLN_YMD).trim();
    act.TAX_ISSU_YMD  = StrUtil.nvl(detail.TAX_ISSU_YMD).trim();
    arrResult = bean.CYCLN_CL090_PROC(act);
  } else {
    arrResult = bean.CYCLN_CL080_PROC(act);
  }
  if (!arrResult[0].equals("ok")) {
    logger.error("FAIL TO CANCEL " + strKncd + " : ORDERNO=" + strOrderNo + ", CPY_ID=" + intCpyId + ", USER=" + strUser + ", MSG=" + arrResult[1]);
    String strMsg = arrResult[1].equals("") ? "취소요청에 실패했습니다. 잠시 후 다시 시도하십시오." : arrResult[1];
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
    return;
  }
  logger.debug("CANCEL " + strKncd + " : " + strOrderNo + ", USER=" + strUser + ", TMSG_SEQ=" + arrResult[1]);
  if (isFirst) sms(strOtherCpy, CyclnSms.MSG_CANCEL_REQ.replace("#{CPY_NAME}", strMyName));

  /* CL090 취소가 끝나면 화면이 CL080 취소를 이어서 부른다. 그때 쓸 토큰을 새로 준다. */
  String strNextToken = "";
  if (strKncd.equals("CL090")) {
    strNextToken = UUID.randomUUID().toString();
    session.setAttribute("csrf_token", strNextToken);
  } else {
    session.removeAttribute("csrf_token");
  }
  out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\",\"kncd\":\"" + strKncd + "\",\"tmsg_seq\":\"" + js(arrResult[1])
          + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\",\"csrf_token\":\"" + js(strNextToken) + "\"}");
  return;
}

out.print("{\"result\":\"error\",\"msg\":\"잘못된 요청입니다.\"}");
%>
