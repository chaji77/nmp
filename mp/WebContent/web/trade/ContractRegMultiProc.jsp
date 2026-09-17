<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
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
<%@ page import="kr.co.mp.kakaotalk.TalkCtrl" %>
<%@ page import="kr.co.soap.controll.A312VO" %>
<%@ page import="kr.co.mp.mgr.sales.MpFeeCalcurator" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
/*********************************************************
이 파일은 임시저장된 매매계약서의 다중처리를 위한 것이다.
직발주의 경우, step=send
판매사승인요청(020)의 경우, step=complete
나머지는 msg를 포함해 리턴한다.
*********************************************************/

/* VARIABLES */
TradeBean bean = new TradeBean();
CtHeaderVO headerVo = new CtHeaderVO();           // Header for save
ArrayList<CtItemVO> arrItems = new ArrayList<>(); // Items for save
int intSignSeq = 0;                               // Key for sign table
CtHeaderVO rvo = null;                            // Result
boolean isTemporarySaveMode   = false;            // Temporary storage mode
boolean isAbnormalCheckExcept = false;            // Excluding abnormal transaction verification option

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
Logger logger = Logger.getLogger("REGIST_CONTRACT_MULTIFUL");

int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
if (intCtId==0) {
  out.print("{\"step\":\"error\",\"msg\":\"선택된 매매계약서가 없습니다.\"}");
  return;
}

headerVo = bean.CT_HEADER_DETAIL_PROC(intCtId); // 매매계약서 불러오기
arrItems = bean.CT_ITEM_LIST_PROC(intCtId);     // 품목 불러오기
logger.debug(headerVo.toString());
logger.debug("----------------------------- START OF CONTRACT REGISTRATION ------------------------");

/********** SAVE SIGN-DATA & CHECK SIGN ************/
String sessionSignSeq = StrUtil.nvl((String)session.getAttribute("signseq"), "0");
if (sessionSignSeq.equals("0") && StrUtil.nvl(request.getParameter("sgn_id")).equals("0000")) {
   String strSignData = StrUtil.nvl(request.getParameter("signdata"));
   if (strSignData.length()>0) {
     intSignSeq = bean.SIGNINFO_ADD_PROC(strSignData);
     session.setAttribute("signseq", Integer.toString(intSignSeq));
   }
} else intSignSeq = Integer.parseInt(sessionSignSeq);

String SIGN_EXCLUDE_YN = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (!SIGN_EXCLUDE_YN.equals("Y") && intSignSeq==0) {
  out.print("{\"step\":\"session\",\"msg\":\"전자서명이 필요합니다.\"}");
  return;
}

if (intSignSeq>0) { // 서명정보가 있으면 업데이트한다.
  bean.CT_HEADER_ADD_SGN_PROC(intCtId, intSignSeq);
}

String strCtrlCode = (headerVo.PAY_ID.equals("") && headerVo.BNK_CD.equals("")) ? "S" : "B"; // 판매계약서작성페이지에서 작성된 매매계약서는 결제은행/상품코드가 존재하지 않음
logger.debug("strCtrlCode : " + strCtrlCode);         // B : 구매계약서작성페이지, S : 판매계약서작성페이지
logger.debug("headerVO.CTTYPE : " + headerVo.CTTYPE); // S : 판매계약서, B : 구매계약서

/********** CHECK COMMISSION ************/
if (!isTemporarySaveMode && strCtrlCode.equals("B") && !new MpFeeCalcurator().isCommissionInfo(Integer.parseInt(headerVo.CTID))) { // 임시저장모드가 아니고 수수료정보가 없으면
  logger.error("FAIL TO READ COMMISSION");
  out.print("{\"step\":\"nocommission\",\"msg\":\"수수료정보를 읽을 수 없습니다.\"}");
  return;
}

/********** CHECH ABNORMAL TRANSACTION ************/
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

/********** CHANGE STATUS TO SENT IF NOT IN DRAFT **********/
rvo = bean.CT_HEADER_SEND_PROC(Integer.parseInt(headerVo.CTID)); // CREATE CTNO, CHANGE STATUS TO 020
logger.debug("AFTER CT_HEADER_SEND_PROC : " + rvo.CTID + "____" + rvo.CTNO + "____" + rvo.STATUS + "____" + rvo.DIRTYPE);
String enid   = IntegerCryptoUtil.crypt(rvo.CTID);
String token = CryptoDESUtil.encrypt(rvo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "");

if (strCtrlCode.equals("B") && StrUtil.nvl(rvo.DIRTYPE).equals("F")) { // 구매계약서이고 직발주이면 바로 전송
  logger.debug("SEND DIRECT");
  out.print("{\"step\":\"send\",\"msg\":\""+ rvo.CTID + "____" + enid + "____" + token+"\"}");
  return;
}
if (strCtrlCode.equals("B") && headerVo.CTTYPE.equals("S")) { // 판매계약서이고 구매사가 서명한 경우 (여기서는 해당사항없음)
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

/********** SUCCESSFUL RETURN **********/
try {
  if (Integer.parseInt(rvo.CTID) > 0) {
    if (strCtrlCode.equals("B")) TalkCtrl.sendBySystem("M009", 0, Integer.parseInt(rvo.CTID), 0);
    else TalkCtrl.sendBySystem("M018", 0, Integer.parseInt(rvo.CTID), 0); // REVERSE-ORDER 
  }
} catch (Exception e) {}

out.print("{\"step\":\"complete\"}");

logger.debug("----------------------------- END OF CONTRACT REGISTRATION ------------------------");

// session.removeAttribute("csrf_token");
%>