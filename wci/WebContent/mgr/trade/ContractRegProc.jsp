<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.CtItemVO" %>
<%@ page import="kr.co.mp.trade.SignVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.ValidateCheck" %>
<%@ page import="kr.co.mp.trade.AbnormalConfiguration" %>
<%@ page import="kr.co.mp.trade.AbnormalTransactionCheck" %>
<%@ page import="kr.co.soap.controll.A312VO" %>
<%
request.setCharacterEncoding("utf-8");

/* VARIABLES */
TradeBean bean = new TradeBean();
CtHeaderVO headerVo = new CtHeaderVO();           // Header for save
ArrayList<CtItemVO> arrItems = new ArrayList<>(); // Items for save
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id")));

/********** BASIC VERIFICATION ***********/
String strBillBuyerBizNo = StrUtil.nvl(request.getParameter("bill_buyer_biz_no"));
String strBillSellerBizNo = StrUtil.nvl(request.getParameter("bill_seller_biz_no"));

/********** SET VARIABLES ************/
headerVo.CTID       = StrUtil.nvl(request.getParameter("seq"), "0"); // 매매계약ID


/* BASIC CODES */
headerVo.TRADEDATE  = ""; // 거래일자(전송일자)
headerVo.CONTRACTDATE = DateTimeUtil.getCurrentDate(""); // 계약일자
headerVo.CTTYPE     = StrUtil.nvl(request.getParameter("cttype"), "B"); // 매매계약서구분(B-구매,S-판매) : to-do : 역주문일 경우 반대
headerVo.REGUSER    = StrUtil.nvl(request.getParameter("reg_id")); // 작성자
headerVo.TAXBIZTYPE = StrUtil.nvl(request.getParameter("tax_biz_type"), "G"); // 사업자구분(G-일반, S-영세, E-면세)
headerVo.MPPAYCPY   = StrUtil.nvl(request.getParameter("mp_pay_cpy"), "2"); // 수수료징수구분코드(1-판매기업, 2-구매기업)
headerVo.CU_USE_YN  = StrUtil.nvl(request.getParameter("scrap_yn"), "N"); // 구리,철 스크랩 거래 여부

/* LOAN INFORMATION */
String strBankAndPayId = StrUtil.nvl(request.getParameter("bnk_pay_id"));
if (strBankAndPayId.indexOf("____")>-1) {
  headerVo.PAY_ID = strBankAndPayId.split("____")[1]; // 결제수단
  headerVo.BNK_CD = strBankAndPayId.split("____")[0]; // 은행코드
} else {
  out.print("{\"step\":\"validate\",\"msg\":\"은행/결제수단선택이 잘못되었습니다.\"}");
  return;
}
headerVo.MTYDATE = StrUtil.nvl(request.getParameter("maturity_ymd")).replaceAll("-", "").replaceAll("/", ""); // 만기일

headerVo.BUYER_IP  = StrUtil.nvl(request.getParameter("buyer_ip")); // 구매사아이피
headerVo.SELLER_IP = StrUtil.nvl(request.getParameter("seller_ip")); // 판매사아이피
headerVo.SGN_ID    = StrUtil.nvl(request.getParameter("buyer_sgn_id"));
headerVo.SELLER_APP_SGN_ID = StrUtil.nvl(request.getParameter("seller_sgn_id"));

if (headerVo.CTTYPE.equals("B")) {
  headerVo.CPYBUYER  = Integer.toString(intCpyId); // 구매기업ID
  headerVo.CPYSELLER = StrUtil.nvl(request.getParameter("seller_cpy_id")).split("____")[0];
} else { // REVERSE-ORDER
  headerVo.CPYBUYER  = StrUtil.nvl(request.getParameter("buyer_cpy_id")).split("____")[0]; // to-do
  headerVo.CPYSELLER = Integer.toString(intCpyId); // 판매기업ID
}

/* TAX INVOICE */
headerVo.SBILL_SEQ        = StrUtil.nvl(request.getParameter("sbill_seq")); // 전자세금계산서 일련번호
headerVo.TAXAPPROVALNO    = StrUtil.nvl(request.getParameter("bill_app_no")); // 전자세금계산서 승인번호
headerVo.BILL_DT          = StrUtil.nvl(request.getParameter("bill_ymd")).replaceAll("-", "").replaceAll("/", ""); // 작성일자

headerVo.TOTALCONTRACTAMT = StrUtil.extractDigits(StrUtil.nvl(request.getParameter("contract_amt")), 17); // 총계약금액
headerVo.SUPPLYAMT        = headerVo.TOTALCONTRACTAMT; // 공급가액
headerVo.TAXAMT           = "0";
if (headerVo.TAXBIZTYPE.equals("G") || headerVo.CU_USE_YN.equals("Y")) {
  Double f = Double.parseDouble(headerVo.TOTALCONTRACTAMT);
  Double t = f/1.1;
  headerVo.SUPPLYAMT = StrUtil.convertNumberFormat("0", t);
  headerVo.TAXAMT    = StrUtil.convertNumberFormat("0", (f-t));
  if (headerVo.CU_USE_YN.equals("Y")) headerVo.TAXAMT = "0";
}

/* ITEMS */
String[] arrItemNames = request.getParameterValues("item_nm");
String[] arrItemCnts  = request.getParameterValues("item_qty");
String[] arrItemUnits = request.getParameterValues("item_unit");
String[] arrItemSums  = request.getParameterValues("item_sum");

if (arrItemNames.length>0) {
  for (int i=0; i<arrItemNames.length; i++) {
    CtItemVO itemVo = new CtItemVO();
    itemVo.SEQNO    = (i<100) ? Integer.toString(1000+(i+1)).substring(1) : Integer.toString(i);
    itemVo.ITEMNAME = StrUtil.xss(arrItemNames[i]).replaceAll(" 외", "");
    itemVo.UNIT     = StrUtil.xss(arrItemUnits[i]);
    itemVo.QTY      = StrUtil.extractDigits(StrUtil.nvl(arrItemCnts[i], "0").replaceAll(",", ""), 17);
    itemVo.SIZE     = "";
    itemVo.TOTALAMT = StrUtil.extractDigits(StrUtil.nvl(arrItemSums[i], "0").replaceAll(",", ""), 17);
    itemVo.SUPPLYAMT = itemVo.TOTALAMT;
    Double f = Double.parseDouble(itemVo.TOTALAMT);
    if (headerVo.TAXBIZTYPE.equals("G") || headerVo.CU_USE_YN.equals("Y")) {
      Double t = f/1.1;
      itemVo.SUPPLYAMT = StrUtil.convertNumberFormat("0", t);
      itemVo.TAXAMT    = StrUtil.convertNumberFormat("0", (f-t));
      if (headerVo.CU_USE_YN.equals("Y")) itemVo.TAXAMT = "0";
    } else itemVo.TAXAMT = "0";
    if (itemVo.QTY.equals("0")) itemVo.QTY = "1";
    Double g = Double.parseDouble(itemVo.SUPPLYAMT)/Double.parseDouble(itemVo.QTY);
    itemVo.UNITPRICE = StrUtil.convertNumberFormat("0.##", g);
    arrItems.add(itemVo);
  }
}
String strItemXml = CtItemVO.setXml(arrItems);

System.out.println(headerVo.toString());
System.out.println(strBillBuyerBizNo);
System.out.println(strBillSellerBizNo);

ValidateCheck validateCheck = new ValidateCheck();
if (validateCheck.initialize(headerVo, strBillBuyerBizNo, strBillSellerBizNo)) {
  String strValidateResult = validateCheck.execute("CHECK_STEP_VALIDATE");
  if (!strValidateResult.equals("00000")) {
    out.print("{\"step\":\"validate\",\"msg\":\""+strValidateResult+"\"}");
    return;
  }
} else {
  out.print("{\"step\":\"validate\",\"msg\":\"거래 검증에 실패했습니다.\"}");
  return;
}

/********** CHECH ABNORMAL TRANSACTION ************
AbnormalTransactionCheck abnormal = new AbnormalTransactionCheck();
boolean start = abnormal.initialize(intCpyId, headerVo, arrItems);
if (start && !abnormal.initLimit().equals("0000")) {
  out.print("{\"step\":\"abnormal\",\"msg\":\""+ abnormal.getFailMsgInitLimit() +"\"}");
  return;
}
if (start) {
  String msg = StrUtil.nvl(abnormal.execute("CHECK_STEP_WRITE"));
  if (!msg.equals("00000")) {
    out.print("{\"step\":\"abnormal\",\"msg\":\""+ abnormal.getErrorMsg(msg)+"\"}");
    return;
  }
  msg = StrUtil.nvl(abnormal.execute("CHECK_STEP_CONFIRM"));
  if (!msg.equals("00000")) {
    out.print("{\"step\":\"abnormal\",\"msg\":\""+ abnormal.getErrorMsg(msg)+"\"}");
    return;
  }
} else {
  out.print("{\"step\":\"abnormal\",\"msg\":\"거래 검증에 실패했습니다.\"}");
  return;
}
*/

/********** INSERT DATABASE AS DRAFT : If the basic rules are passed, temporary storage will be attempted before abnormal transaction monitoring. **********/
bean.CT_HEADER_MOD_PROC(headerVo, strItemXml);
out.print(headerVo.CTID);

%>