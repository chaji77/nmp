<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
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
<%@ page import="kr.co.mp.kakaotalk.*" %>
<%@ page import="kr.co.soap.controll.A312VO" %>
<%@ page import="kr.co.mp.mgr.sales.MpFeeCalcurator" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
/* VARIABLES */
TradeBean bean = new TradeBean();
CtHeaderVO headerVo = new CtHeaderVO();           // Header for save
ArrayList<CtItemVO> arrItems = new ArrayList<>(); // Items for save
int intSignSeq = 0;                               // Key for sign table
CtHeaderVO rvo = null;                            // Result
boolean isTemporarySaveMode   = true;             // Temporary storage mode
boolean isAbnormalCheckExcept = false;            // Excluding abnormal transaction verification option

isTemporarySaveMode      = ((StrUtil.nvl(request.getParameter("temp_save"), "0")).equals("1")) ? true : false; // Temporary storage options
String strErrorMsgPrefix = AbnormalConfiguration.getInstance().getString("ERR_HEADER"); // Message header for transaction suspension due to abnormal transaction monitoring

/********** CHECH LOGIN STATUS ************/
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int    intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else {
  out.print("{\"step\":\"session\",\"msg\":\"다시 로그인하십시오.\"}");
  return;
}
String strBizNo = (String)pageContext.getAttribute("CPY_BIZ_NO");

Logger logger = Logger.getLogger("REGIST_CONTRACT");
logger.debug("----------------------------- START OF CONTRACT REGISTRATION ------------------------");

/********** PRINT PARAMERS FOR DEVELOPMENT ************
ArrayList<String> parameterNames = new ArrayList<String>();
Enumeration<String> enumeration = request.getParameterNames();
while (enumeration.hasMoreElements()) {
  String strParameter = (String) enumeration.nextElement();
  logger.debug(strParameter +" : " + request.getParameter(strParameter));
}
*/

/********** CHECK SESSION ************/
String csrf_token = StrUtil.nvl(request.getParameter("csrf_token"));
if (!request.getMethod().equals("POST") || csrf_token.equals("") || !(StrUtil.nvl((String)session.getAttribute("csrf_token"))).equals(csrf_token)) {
  out.print("{\"step\":\"session\",\"msg\":\"세선이 종료되었습니다. 다시 작성하십시오.\"}");
  return;
}

/********** SAVE SIGN-DATA & CHECK SIGN ************/
if (StrUtil.nvl(request.getParameter("sgn_id")).equals("0000")) {
  String strSignData = StrUtil.nvl(request.getParameter("signdata"));
  if (strSignData.length()>0) {
    intSignSeq = bean.SIGNINFO_ADD_PROC(strSignData);
  }
}
String SIGN_EXCLUDE_YN = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (!isTemporarySaveMode && !SIGN_EXCLUDE_YN.equals("Y") && intSignSeq==0) {
  out.print("{\"step\":\"session\",\"msg\":\"전자서명이 필요합니다.\"}");
  return;
}

/********** SET VARIABLES ************/
String strCtrlCode  = StrUtil.nvl(request.getParameter("from_code"), "B"); // REVERSE-ORDER OPTION : S=FROM SELLER'S CONTRACT.
String strNonWarrantyYN   = StrUtil.nvl(request.getParameter("non_warranty"), "N"); // NON-GUARANTEED TRANSACTION OR NOT
headerVo.CTID       = StrUtil.nvl(request.getParameter("seq"), "0"); // 매매계약ID


/* BASIC CODES */
headerVo.TRADEDATE  = ""; // 거래일자(전송일자)
headerVo.CONTRACTDATE = StrUtil.nvl(request.getParameter("bill_ymd"), DateTimeUtil.getCurrentDate("")).replaceAll("-", "").replaceAll("/", ""); // 작성일자 = 계약일자
headerVo.CTTYPE     = StrUtil.nvl(request.getParameter("cttype"), "B"); // 매매계약서구분(B-구매,S-판매)
headerVo.REGUSER    = (String)pageContext.getAttribute("USER_LOGIN"); // 작성자
headerVo.TAXBIZTYPE = StrUtil.nvl(request.getParameter("tax_biz_type"), "G"); // 사업자구분(G-일반, S-영세, E-면세)
headerVo.MPPAYCPY   = StrUtil.nvl(request.getParameter("mp_pay_cpy"), "2"); // 수수료징수구분코드(1-판매기업, 2-구매기업)
headerVo.CU_USE_YN  = StrUtil.nvl(request.getParameter("scrap_yn"), "N"); // 구리,철 스크랩 거래 여부

/* LOAN INFORMATION */
String strBankAndPayId = StrUtil.nvl(request.getParameter("bnk_pay_id"));
if (strBankAndPayId.indexOf("____")>-1) {
  headerVo.PAY_ID = strBankAndPayId.split("____")[1]; // 결제수단
  headerVo.BNK_CD = strBankAndPayId.split("____")[0]; // 은행코드
} else {
  if (strCtrlCode.equals("B")) { // 판매계약서에는 은행/결제수단이 없음
    out.print("{\"step\":\"validate\",\"msg\":\"은행/결제수단선택이 잘못되었습니다.\"}");
    return;
  }
}
headerVo.MTYDATE = StrUtil.nvl(request.getParameter("maturity_ymd")).replaceAll("-", "").replaceAll("/", ""); // 만기일

String strBuyerBizNo  = strBizNo;
String strSellerBizNo = strBizNo;

if (strCtrlCode.equals("B")) {
  headerVo.CPYBUYER  = strCpyId; // 구매기업ID
  headerVo.CPYSELLER = StrUtil.nvl(request.getParameter("seller_cpy_id")).split("____")[0];
  headerVo.BUYER_IP  = LoginUtil.getClientIpAddr(request); // 구매사아이피
  headerVo.SGN_ID    = Integer.toString(intSignSeq); // 구매사서명아이디(SIGNINFO)
  strSellerBizNo     = StrUtil.nvl(request.getParameter("seller_cpy_id")).split("____")[1];
} else { // REVERSE-ORDER
  headerVo.CPYBUYER  = StrUtil.nvl(request.getParameter("buyer_cpy_id")).split("____")[0];
  headerVo.CPYSELLER = strCpyId; // 판매기업ID
  headerVo.SELLER_IP = LoginUtil.getClientIpAddr(request); // 판매사아이피
  headerVo.SELLER_APP_SGN_ID = Integer.toString(intSignSeq); // 판매사서명아이디(SIGNINFO)
  strBuyerBizNo      = StrUtil.nvl(request.getParameter("buyer_cpy_id")).split("____")[1];
}

/* AMOUNT */
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

/* TAX INVOICE */
String strItemXml = "";
headerVo.SBILL_SEQ        = StrUtil.nvl(request.getParameter("sbill_seq"), "0"); // 전자세금계산서 일련번호
headerVo.TAXAPPROVALNO    = StrUtil.nvl(request.getParameter("bill_app_no")); // 전자세금계산서 승인번호
headerVo.BILL_DT          = StrUtil.nvl(request.getParameter("bill_ymd"), DateTimeUtil.getCurrentDate("")).replaceAll("-", "").replaceAll("/", ""); // 작성일자

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
strItemXml = CtItemVO.setXml(arrItems);

logger.debug(headerVo.toString());
logger.debug(strItemXml);


/********** BASIC VERIFICATION ***********/
if (strCtrlCode.equals("B")) { // 판매계약서는 세금계산서를 첨부하지 않으므로 생략
  String strBillBuyerBizNo = StrUtil.nvl(request.getParameter("bill_buyer_biz_no")); // 첨부한 세금계산서의 공급받는자 사업자번호
  String strBillSellerBizNo = StrUtil.nvl(request.getParameter("bill_seller_biz_no")); // 첨부한 세금계산서의 공급자 사업자번호
  if (headerVo.TAXAPPROVALNO.equals("") && strNonWarrantyYN.equals("Y")) { // 비보증이고 세금계산서가 첨부되지 않았다면, 판매사와 구매사의 사업자번호를 가져온다
    strBillBuyerBizNo = strBuyerBizNo;
    strBillSellerBizNo = strSellerBizNo;
  }
  ValidateCheck validateCheck = new ValidateCheck();
  if (validateCheck.initialize(headerVo, strBillBuyerBizNo, strBillSellerBizNo)) {
    String strValidateResult = validateCheck.execute("CHECK_STEP_VALIDATE");
    if (!strValidateResult.equals("00000")) {
      logger.error(strValidateResult);
      out.print("{\"step\":\"validate\",\"msg\":\""+strValidateResult+"<br/>고객센터로 문의바랍니다.\"}");
      return;
    }
  } else {
    logger.error("FAIL TO INITIALIZE VALIDATECHECK");
    out.print("{\"step\":\"validate\",\"msg\":\"기본 거래 검증에 실패했습니다.<br/>고객센터로 문의바랍니다.\"}");
    return;
  }
}

/********** INSERT DATABASE AS DRAFT : 기본검증이 끝나면 이상거래모니터링전에 데이터를 임시저장상태로 저장 **********/
if (headerVo.CTID.equals("0")) { // INSERT
  rvo = bean.CT_HEADER_ADD_PROC(headerVo, strItemXml);
  headerVo.CTID = rvo.CTID;
} else { // UPDATE
  rvo = bean.CT_HEADER_MOD_PROC(headerVo, strItemXml);
}
if (rvo==null) {
  logger.error("FAIL TO SAVE DATABASE");
  out.print("{\"step\":\"validate\",\"msg\":\"데이터베이스 저장에 실패했습니다. 잠시 후 다시 시도하십시오.<br/>문제가 지속되면 고객센터로 문의바랍니다.\"}");
  return;
}

/********** CHECK COMMISSION (2025/04/14) ************/
if (!isTemporarySaveMode && strCtrlCode.equals("B") && !new MpFeeCalcurator().isCommissionInfo(Integer.parseInt(rvo.CTID))) { // 임시저장모드가 아니고 수수료정보가 없으면
  logger.error("FAIL TO READ COMMISSION");
  out.print("{\"step\":\"nocommission\",\"msg\":\"수수료정보를 읽을 수 없습니다.\"}");
  return;
}

/********** CHECH ABNORMAL TRANSACTION ************/
if (!isTemporarySaveMode) { // 임시저장모드가 아닌 경우, 이상거래모니터링 실시
  if (!isAbnormalCheckExcept && strCtrlCode.equals("B")) { //이상거래모니터링을 생략(configuration에서 설정)하지 않고 구매계약서인 경우
    AbnormalTransactionCheck abnormal = new AbnormalTransactionCheck();
    boolean start = abnormal.initialize(intCpyId, headerVo, arrItems);
    if (start && !abnormal.initLimit().equals("0000")) {
      logger.error(strErrorMsgPrefix);
      out.print("{\"step\":\"abnormal\",\"msg\":\""+ strErrorMsgPrefix + abnormal.getFailMsgInitLimit() +"\"}");
      return;
    }
    if (start) {
      String msg = StrUtil.nvl(abnormal.execute("CHECK_STEP_WRITE"));
      if (!msg.equals("00000")) { // CAUGHT IN ABNORMAL TRANSACTION MONITORING
        logger.error(strErrorMsgPrefix);
        out.print("{\"step\":\"abnormal\",\"msg\":\""+ strErrorMsgPrefix + abnormal.getErrorMsgAndSave(msg)+"\"}");
        return;
      }
    } else {
      logger.error("FAIL TO CHECK ABNORMAL");
      out.print("{\"step\":\"abnormal\",\"msg\":\"거래 검증에 실패했습니다. 고객센터로 문의바랍니다.\"}");
      return;
    }
  }
}

/********** CHANGE STATUS TO SENT IF NOT IN DRAFT **********/
logger.debug("strCtrlCode : " + strCtrlCode);         // B : 구매계약서작성페이지, S : 판매계약서작성페이지
logger.debug("headerVO.CTTYPE : " + headerVo.CTTYPE); // S : 판매계약서, B : 구매계약서
if (!isTemporarySaveMode) { // IS NOT TEMPORARY SAVE MODE(010)
  rvo = bean.CT_HEADER_SEND_PROC(Integer.parseInt(rvo.CTID)); // CREATE CTNO, CHANGE STATUS TO 020
  logger.debug("AFTER CT_HEADER_SEND_PROC : " + rvo.CTID + "____" + rvo.CTNO + "____" + rvo.STATUS + "____" + rvo.DIRTYPE);
  String enid   = IntegerCryptoUtil.crypt(rvo.CTID);
  String token = CryptoDESUtil.encrypt(rvo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "");
  
  if (strCtrlCode.equals("B") && StrUtil.nvl(rvo.DIRTYPE).equals("F")) { // 구매계약서이고 직발주이면 바로 전송
    logger.debug("SEND DIRECT");
    out.print("{\"step\":\"send\",\"msg\":\""+ rvo.CTID + "____" + enid + "____" + token+"\"}");
    return;
  }
  if (strCtrlCode.equals("B") && headerVo.CTTYPE.equals("S")) { // 판매계약서이고 구매사가 서명한 경우
    // CONFIRM ACTION WITH ABNORMAL TRANSACTION CHECK
    String strResult = bean.confirm(Integer.parseInt(rvo.CTID), intCpyId, StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN")), LoginUtil.getClientIpAddr(request), intSignSeq, "N");
    if (strResult.contains("SUCCESS____025____")) {
      logger.debug("SEND REVERSE-ORDER");
      out.print("{\"step\":\"send\",\"msg\":\""+ rvo.CTID + "____" + enid + "____" + token+"\"}");
      return;
    } else { // CAUGHT IN ABNORMAL TRANSACTION MONITORING
      out.print(strResult);
      return;
    }
  }
}

/********** SUCCESSFUL RETURN **********/
if (Integer.parseInt(rvo.CTID) > 0 && !isTemporarySaveMode) {
  if (strCtrlCode.equals("B")) TalkCtrl.sendBySystem("M009", 0, Integer.parseInt(rvo.CTID), 0);
  else TalkCtrl.sendBySystem("M018", 0, Integer.parseInt(rvo.CTID), 0);	// REVERSE-ORDER 
}
out.print(rvo.CTID);

logger.debug("----------------------------- END OF CONTRACT REGISTRATION ------------------------");

// session.removeAttribute("csrf_token");
%>