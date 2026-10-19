<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderActVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
/* JSON 문자열 값에 넣을 수 있게 따옴표를 막는다. */
String js(String s) {
  return StrUtil.nvl(s).replace("\\", "\\\\").replace("\"", "\\\"").replaceAll("[\r\n]", " ");
}
/* 0 으로 채워 저장된 금액(0000033016500)을 등록 때처럼 자리수 없는 숫자문자열로 되돌린다. */
String num(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("")) return "0";
  try {
    return new BigDecimal(s).toPlainString();
  } catch (NumberFormatException e) {
    return "0";
  }
}
%>
<%
/*
 * 관리자 싸이클론 전문 처리. kncd 로 CL080(매매계약정보) / CL090(결제예정정보)을 고른다.
 *   STATUS - 상태값 변경. 구매사 취소요청(035)·판매사 취소요청(030)으로 바꾸면서 마지막 전문을 취소(03)로 다시 보낸다.
 *            CL090 이 은행에 살아 있으면 CL080 은 취소할 수 없다.
 *   RESEND - 은행 처리에 실패한 마지막 전문을 같은 내용으로 다시 보낸다.
 * 프로시저가 거래당사자를 확인하므로 CPY_ID 는 구매기업으로 넘긴다.
 * 처리자는 비워 넘겨 구매·판매기업의 승인자 기록을 덮어쓰지 않는다. 관리자 아이디는 로그에 남긴다.
 */
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("CYCLN_MGR_STATUS");

if (!request.getMethod().equals("POST")) {
  out.print("{\"result\":\"error\",\"msg\":\"잘못된 요청입니다.\"}");
  return;
}

String strAction  = StrUtil.nvl(request.getParameter("action")).trim();
String strOrderNo = StrUtil.nvl(request.getParameter("orderno")).trim();
String strKncd    = StrUtil.nvl(request.getParameter("kncd")).trim();
String strMgrId   = StrUtil.nvl((String)pageContext.getAttribute("SESS_LOGIN_ID"));

if (!strKncd.equals("CL080") && !strKncd.equals("CL090")) {
  out.print("{\"result\":\"error\",\"msg\":\"잘못된 요청입니다.\"}");
  return;
}

CyclnBean bean = new CyclnBean();
CyclnOrderDetailVO detail = strOrderNo.equals("") ? null : bean.CYCLN_ORDER_DETAIL_PROC(strOrderNo);
if (detail==null || !StrUtil.isOnlyNumeric(StrUtil.nvl(detail.CPYBUYER).trim())) {
  out.print("{\"result\":\"error\",\"msg\":\"주문 정보를 찾을 수 없습니다.\"}");
  return;
}

String[] arrResult;

/********** 재전송 **********/
if (strAction.equals("RESEND")) {
  if (!detail.isTmsgFailed(strKncd)) {
    out.print("{\"result\":\"error\",\"msg\":\"실패한 전문이 아닙니다. 화면을 새로 고치십시오.\"}");
    return;
  }
  arrResult = bean.CYCLN_TMSG_RESEND_PROC(strOrderNo, strKncd);

/********** 상태값 변경(취소요청) **********/
} else if (strAction.equals("STATUS")) {
  String strStatusCf = StrUtil.nvl(request.getParameter("status")).trim();
  if (!strStatusCf.equals(CyclnOrderVO.STATUS_BUYER_CANREQ) && !strStatusCf.equals(CyclnOrderVO.STATUS_SELLER_CANREQ)) {
    out.print("{\"result\":\"error\",\"msg\":\"구매사 취소요청 또는 판매사 취소요청만 고를 수 있습니다.\"}");
    return;
  }
  String strWhy = detail.getAdminCancelError(strKncd);
  if (!strWhy.equals("")) {
    out.print("{\"result\":\"error\",\"msg\":\"" + js(strWhy) + "\"}");
    return;
  }

  CyclnOrderActVO act = new CyclnOrderActVO();
  act.ORDERNO    = strOrderNo;
  act.CPY_ID     = Integer.parseInt(detail.CPYBUYER.trim());
  act.STATUS_NOW = detail.STATUS;
  act.STATUS_CF  = strStatusCf;
  act.TRX_CLS    = CyclnOrderVO.TRX_CANCEL;
  act.PURC_ITEM  = detail.getPurcItem();

  /* 마지막으로 나간 전문의 값을 그대로 싣는다. 납품기한은 프로시저가 주문의 요청납기일로 채운다. */
  if (strKncd.equals("CL090")) {
    CyclnOrderDetailVO.Cl090VO r = detail.CL090.get(detail.CL090.size()-1);
    act.PURC_PRIC     = num(r.PURC_PRIC);
    act.SETL_PLN_PRIC = num(r.SETL_PLN_PRIC);
    act.SETL_PLN_YMD  = StrUtil.nvl(r.SETL_PLN_YMD).trim();
    act.TAX_ISSU_YMD  = StrUtil.nvl(r.TAX_ISSU_YMD).trim();
    arrResult = bean.CYCLN_CL090_PROC(act);
  } else {
    CyclnOrderDetailVO.Cl080VO r = detail.CL080.get(detail.CL080.size()-1);
    act.PURC_ITEM = StrUtil.nvl(r.PURC_ITEM).trim();
    act.PURC_PRIC = num(r.PURC_PRIC);
    arrResult = bean.CYCLN_CL080_PROC(act);
  }

} else {
  out.print("{\"result\":\"error\",\"msg\":\"잘못된 요청입니다.\"}");
  return;
}

if (!arrResult[0].equals("ok")) {
  logger.error("FAIL " + strAction + " " + strKncd + " : ORDERNO=" + strOrderNo + ", MGR=" + strMgrId + ", MSG=" + arrResult[1]);
  String strMsg = arrResult[1].equals("") ? "전문 등록에 실패했습니다." : arrResult[1];
  out.print("{\"result\":\"error\",\"msg\":\"" + js(strMsg) + "\"}");
  return;
}
logger.info(strAction + " " + strKncd + " : ORDERNO=" + strOrderNo + ", MGR=" + strMgrId + ", STATUS=" + request.getParameter("status") + ", TMSG_SEQ=" + arrResult[1]);
out.print("{\"result\":\"ok\",\"tmsg_seq\":\"" + js(arrResult[1]) + "\",\"req_ymd\":\"" + js(arrResult[2]) + "\"}");
%>
