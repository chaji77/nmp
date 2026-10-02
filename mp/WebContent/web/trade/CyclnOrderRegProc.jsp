<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderRegVO" %>
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
    return new java.math.BigDecimal(s).toPlainString();
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
Logger logger = Logger.getLogger("REGIST_CYCLN_ORDER");

/********** 로그인 확인 **********/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) {
  out.print("{\"result\":\"error\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
int intCpyId = Integer.parseInt(strCpyId);

/********** 세션 확인 **********/
String csrf_token = StrUtil.nvl(request.getParameter("csrf_token"));
if (!request.getMethod().equals("POST") || csrf_token.equals("")
    || !StrUtil.nvl((String)session.getAttribute("csrf_token")).equals(csrf_token)) {
  out.print("{\"result\":\"error\",\"msg\":\"세션이 종료되었습니다. 다시 작성하십시오.\"}");
  return;
}

/********** 계약기본정보 **********/
CyclnOrderRegVO vo = new CyclnOrderRegVO();
vo.CPYBUYER   = intCpyId;
vo.ORDERNAME  = StrUtil.xss(StrUtil.nvl(request.getParameter("order_name"))).trim();
vo.REQDLVDATE = StrUtil.nvl(request.getParameter("reqdlvdate")).replaceAll("[^0-9]", "");
vo.DLVADDRESS = StrUtil.xss(StrUtil.nvl(request.getParameter("addr"))).trim();
vo.CREUSER    = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN"));

// 판매기업은 'CPY_ID____사업자번호' 로 온다.
String strSeller = StrUtil.nvl(request.getParameter("seller_cpy_id"));
if (strSeller.indexOf("____")>0) strSeller = strSeller.substring(0, strSeller.indexOf("____"));
if (StrUtil.isOnlyNumeric(strSeller)) vo.CPYSELLER = Integer.parseInt(strSeller);

// 계산서 종류는 정의된 값만 받는다.
String strEstimateType = StrUtil.nvl(request.getParameter("estimate_type"), "1");
if (!strEstimateType.equals("1") && !strEstimateType.equals("2") && !strEstimateType.equals("3")) strEstimateType = "1";
vo.ESTIMATE_TYPE = strEstimateType;

if (vo.ORDERNAME.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"발주계약서명을 입력하십시오.\"}");
  return;
}
if (vo.REQDLVDATE.length()!=8) {
  out.print("{\"result\":\"error\",\"msg\":\"요청납기일을 선택하십시오.\"}");
  return;
}
if (vo.CPYSELLER==0) {
  out.print("{\"result\":\"error\",\"msg\":\"판매기업을 선택하십시오.\"}");
  return;
}
if (vo.CPYSELLER==vo.CPYBUYER) {
  out.print("{\"result\":\"error\",\"msg\":\"자기 회사에는 발주할 수 없습니다.\"}");
  return;
}
if (vo.DLVADDRESS.equals("")) {
  out.print("{\"result\":\"error\",\"msg\":\"도착지를 입력하십시오.\"}");
  return;
}

/********** 제품정보 **********/
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
  if (new java.math.BigDecimal(item.REQQTY).signum()<=0 || new java.math.BigDecimal(item.TOTALAMT).signum()<=0) {
    out.print("{\"result\":\"error\",\"msg\":\"요청수량과 총액을 확인하십시오.\"}");
    return;
  }
  vo.ITEMS.add(item);
}

/********** 저장 **********/
String strOrderNo = new CyclnBean().CYCLN_ORDER_REG_PROC(vo);
if (strOrderNo.equals("")) {
  logger.error("FAIL TO SAVE CYCLN ORDER : CPY_ID=" + intCpyId + ", SELLER=" + vo.CPYSELLER);
  out.print("{\"result\":\"error\",\"msg\":\"저장에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다.\"}");
  return;
}
session.removeAttribute("csrf_token"); // 새로고침으로 두 번 등록되는 것을 막는다.
logger.debug("REGISTERED CYCLN ORDER : " + strOrderNo);
out.print("{\"result\":\"ok\",\"orderno\":\"" + js(strOrderNo) + "\"}");
%>
