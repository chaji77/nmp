<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.baroservice.ws.KakaotalkTemplate" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.kakaotalk.*" %>
<%@ page import="kr.co.funology.fw.mail.MailSend" %>
<%!
String send(TalkCtrl t, HashMap<String, String> map, String strTemplateCode, String strReceiverNumber, String strTitle, List<String[]> params) {
  strReceiverNumber = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? "01056075313" : strReceiverNumber; ///////////////////////////////////////// FOR TEST MODE CHECK
  if (strReceiverNumber.length()>10) {
    String result = t.send(map.get(strTemplateCode), strReceiverNumber, "담당자", strTitle, params); 
    if (Pattern.compile("^-[0-9]{5}").matcher(result).matches()) return result;
    else if (result.equals("9999")) return "BLOCKED";
    else if (result.equals("9998")) return "SERVICE-ERROR";
    else return "SUCCESS";
  } else return "WRONG PHONE NUMBER : " + strReceiverNumber;
}
void sendMail(String strTemplateName, String strEmail, String strReceiver, String strTitle, List<String[]> arrReplace) {
  strEmail = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? "ryan@funology.kr" : strEmail; ///////////////////////////////////////// FOR TEST MODE CHECK
  if (StrUtil.isValidEmail(strEmail)) {
    String strSender       = ConfigurationMgr.getInstance().getString("MAIL_ID");
    String strSenderName   = ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM");
    String strSenderPw     = ConfigurationMgr.getInstance().getString("MAIL_PW");
    String strContents = StrUtil.templateToString("mail/" + strTemplateName + ".htm");
    if (arrReplace.size()>0) {
      for (String[] s : arrReplace) {
        strContents = strContents.replaceAll(s[0], s[1]);
      }
    }
    MailSend.sendMail(strSender, strSenderName, strSenderPw, strEmail, strReceiver, strTitle, strContents, 1);
  }
}
%>
<%
// 오류코드 참조 : https://dev.barobill.co.kr/docs/references/%EB%B0%94%EB%A1%9C%EB%B9%8C-API-%EC%98%A4%EB%A5%98%EC%BD%94%EB%93%9C

HashMap<String, String> map = new HashMap<>();
map.put("M001", "Registration");        //MP1회원가입
/*map.put("M002", "mpContractAuthorization"); //MP1(구매)승인완료*/
map.put("M003", "TaxInvoiceIssuance");      //MP1(구,판매)결제완료_수수료 COMPLETED : @callby /mgr/etax/TaxPublishProc.jsp
map.put("M004", "MaturityRepayment7days");  // MP1(구매)결제완료_만기7일 COMPLETED // : @callby /WEB-INF/MaturityNotification.sh
map.put("M005", "MaturityRepayment");       // MP1(구매)결제완료_만기당일 COMPLETED  // : @callby /WEB-INF/MaturityNotification.sh
map.put("M006", "PaymentDueDate");      //MP1(구매)결제예정일
map.put("M007", "ContractCancellation");  // MP1(구매) 계약취소안내 //COMPLETED : @callby /web/trade/ContractCancelProc.jsp
/*map.put("M008", "MP1(구매) 계약승인안내");*/
map.put("M009", "mpReverseOrder");        // MP1(판매)승인요청//COMPLETED : @callby /web/trade/ContractRegProc.jsp
map.put("M010", "mpCollectionComplete");  // MP1(판매)은행추심
map.put("M011", "PaymentCompleted");        // MP1(판매)결제완료 안내 //COMPLETED : @callby /mgr/etax/TaxPublishProc.jsp
/*
map.put("M012", "이상거래 안내");
map.put("M013", "이상거래 안내_동일 IP");
map.put("M014", "담보보증서 연장 안내");
*/ 
map.put("M015", "LoginTemporaryPassword");  // 아이디 비밀번호 재발급 // COMPLETED : @callby /mgr/customer/Company.jsp 
map.put("M016", "mpCollectionComplete");  //추심안내
map.put("M017", "mpContractAuthorization");  // ContractAuthorization COMPLETED : @callby kodit/loan/emtnet/EmtNetB311.java
map.put("M018", "SellerReverseOrder");    //판매계약서전송 ReverseOrder

/* 메일탬플릿 @see /static/template/mail */
String mailTemplates = "M007,M009,M010,M011,M017";

Logger logger = Logger.getLogger("KAKAOTALK ISSUANCE CENTER");

TalkCtrl t = TalkCtrl.getInstance();
String strTemplateCode = StrUtil.nvl(request.getParameter("tcd"), "M000");
int intCpyId   = Integer.parseInt(StrUtil.nvl(request.getParameter("cpyid"), "0"));    // 회원사아이디
int intCtId    = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));     // 매매계약아이디
int intBillSeq = Integer.parseInt(StrUtil.nvl(request.getParameter("billseq"), "0"));  // MP세금계산서아이디

/* M015 변수 */
String strLoginId = StrUtil.nvl(request.getParameter("loginId"));  //로그인ID

String strResult = "WRONG MESSAGE-ID : " + strTemplateCode;
String strTitle = "";
String strReceiverNumber = "";
List<String[]> params = new ArrayList<>();

if (strTemplateCode.equals("M000")) {
  logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
} else if (strTemplateCode.equals("M001")) {
  ArrayList<ParametersVO> arr = new ParametersBean().TALK_FOR_SETTLED_PROC(intBillSeq);
  ParametersVO v = arr.remove(0);
  params = new ArrayList<>(); //params 초기화 추가
  strReceiverNumber = StrUtil.nvl(v.MOBILE_NO).replaceAll("[^0-9]", "");
  strTitle = "#{CPY_NAME}회원가입안내".replaceAll("\\#\\{CPY_NAME\\}", StrUtil.nvl(v.CPY_NAME)); // 강조표기문구탬플릿과 일치해야 함
  params.add(new String[] {"\\#\\{CPY_NAME\\}", StrUtil.nvl(v.CPY_NAME)});
  strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
  logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
} else if (strTemplateCode.equals("M003")) { // COMPLETED : @callby /mgr/etax/TaxPublishProc.jsp
  ArrayList<ParametersVO> arr = new ParametersBean().TALK_FOR_SETTLED_PROC(intBillSeq);
  if (arr!=null && arr.size()>0) {
    for (int i=0; i<arr.size();) {
      ParametersVO v = arr.remove(0); 
      params = new ArrayList<>(); //params 초기화 추가
      strTitle = "MP이용수수료발행안내"; // 강조표기문구탬플릿과 일치해야 함
      if ("1".equals(v.MPPAYCPY)){
    	strReceiverNumber = StrUtil.nvl(v.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
        params.add(new String[] {"\\#\\{MPPAYCPY\\}", StrUtil.nvl(v.CPY_NAME)});
        params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(v.SELLER_NM)});
        params.add(new String[] {"\\#\\{EMAIL\\}", StrUtil.nvl(v.SELLER_EMAIL)});
      } else if ("2".equals(v.MPPAYCPY)){
      	strReceiverNumber = StrUtil.nvl(v.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
        params.add(new String[] {"\\#\\{MPPAYCPY\\}", StrUtil.nvl(v.CPY_NAME)});
        params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(v.SELLER_NM)});
        params.add(new String[] {"\\#\\{EMAIL\\}", StrUtil.nvl(v.BUYER_EMAIL)});
      }
      strResult = send(t, map, "M003", strReceiverNumber, strTitle, params);
      logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    }
  }
} else if (strTemplateCode.equals("M004")) { // COMPLETED : @callby /WEB-INF/MaturityNotification.sh
  ArrayList<MaturityNotificationVO> arr = new MaturityNotificationBean().BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC();
  if (arr!=null && arr.size()>0) {
    for (int i=0; i<arr.size();) {
      MaturityNotificationVO v = arr.remove(0);
      params = new ArrayList<>(); //params 초기화 추가
      strReceiverNumber = StrUtil.nvl(v.PRS_MOBILE_NO).replaceAll("[^0-9]", "");
      strTitle = "#{BANK}은행 만기상환7일안내".replaceAll("\\#\\{BANK\\}", StrUtil.nvl(v.BNK_SNAME)); // 강조표기문구탬플릿과 일치해야 함
      params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(v.CPY_NAME)});
      params.add(new String[] {"\\#\\{BANK\\}", StrUtil.nvl(v.BNK_SNAME)});
      params.add(new String[] {"\\#\\{MTYDATE\\}", FormatUtil.addSeparatorDate(StrUtil.nvl(v.MTYDATE))});
      params.add(new String[] {"\\#\\{CNT\\}", StrUtil.nvl(v.CNT)}); // 
      params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(StrUtil.extractInteger(v.AMT))});
      strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
      logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    }
  }
} else if (strTemplateCode.equals("M005")) { // COMPLETED : @callby /WEB-INF/MaturityNotification.sh
  ArrayList<MaturityNotificationVO> arr = new MaturityNotificationBean().BAT_0_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC();
  if (arr!=null && arr.size()>0) {
    for (int i=0; i<arr.size();) {
      MaturityNotificationVO v = arr.remove(0);
      params = new ArrayList<>(); //params 초기화 추가
      strReceiverNumber = StrUtil.nvl(v.PRS_MOBILE_NO).replaceAll("[^0-9]", "");
      strTitle = "#{BANK}은행 만기상환일안내".replaceAll("\\#\\{BANK\\}", StrUtil.nvl(v.BNK_SNAME)); // 강조표기문구탬플릿과 일치해야 함
      params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(v.CPY_NAME)});
      params.add(new String[] {"\\#\\{BANK\\}", StrUtil.nvl(v.BNK_SNAME)});
      params.add(new String[] {"\\#\\{MTYDATE\\}", FormatUtil.addSeparatorDate(StrUtil.nvl(v.MTYDATE))});
      params.add(new String[] {"\\#\\{CNT\\}", StrUtil.nvl(v.CNT)}); // 
      params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(StrUtil.extractInteger(v.AMT))});
      strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
      logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    }
  }
} else if (strTemplateCode.equals("M006")) { // COMPLETED : @callby /WEB-INF/MaturityNotification.sh
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{SELLER} 결제일안내".replaceAll("\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)); // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M007")) { // COMPLETED : @callby /web/trade/ContractCancelProc.jsp /WEB-INF/src/kr/co/soap/emtnet/EmtNetB315.java
  ParametersVO vo = new ParametersBean().TALK_FOR_CANCEL_CONTRACT_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{SELLER} 계약취소안내".replaceAll("\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)); // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.BUYER_EMAIL), StrUtil.nvl(vo.BUYER_NM), strTitle, params);
    }
    
    params = new ArrayList<>();
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{BUYER} 계약취소안내".replaceAll("\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)); // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.SELLER_EMAIL), StrUtil.nvl(vo.SELLER_NM), strTitle, params);
    }
  }
} else if (strTemplateCode.equals("M009")) { // COMPLETED : @callby /web/trade/ContractRegProc.jsp
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{BUYER} 매매계약서안내".replaceAll("\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM));
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.nvl(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.SELLER_EMAIL), StrUtil.nvl(vo.SELLER_NM), strTitle, params);
    }
  }
} else if (strTemplateCode.equals("M010")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{BUYER} 거래추심안내".replaceAll("\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)); // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{BANK\\}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.SELLER_EMAIL), StrUtil.nvl(vo.SELLER_NM), strTitle, params);
    }
  }
} else if (strTemplateCode.equals("M011")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{BUYER} 결제완료안내".replaceAll("\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)); // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.SELLER_EMAIL), StrUtil.nvl(vo.SELLER_NM), strTitle, params);
    }
  }
} else if (strTemplateCode.equals("M015")) { // COMPLETED : @callby /mgr/customer/Company.jsp
  ParametersVO vo = new ParametersBean().TALK_FOR_RESET_PASSWORD_PROC(strLoginId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strTitle = "로그인 임시 비밀번안내";
    strReceiverNumber = StrUtil.nvl(vo.MOBILE_NO).replaceAll("[^0-9]", "");
    params.add(new String[] {"\\#\\{CPY_NAME\\}", StrUtil.nvl(vo.CPY_NAME)});
    params.add(new String[] {"\\#\\{PRS_LOGIN\\}", StrUtil.nvl(vo.PRS_LOGIN)});
    params.add(new String[] {"\\#\\{PRS_PASSWD\\}", CryptoDESUtil.decrypt(StrUtil.nvl(vo.PRS_PASSWD))});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M016")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{BUYER} 거래추심안내".replaceAll("\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM));
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{BANK\\}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M017")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{SELLER} 계약승인안내".replaceAll("\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM));
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{BANK\\}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.BUYER_EMAIL), StrUtil.nvl(vo.BUYER_NM), strTitle, params);
    }
  }
} else if (strTemplateCode.equals("M018")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "#{SELLER} 판매계약서안내".replaceAll("\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM));
    params.add(new String[] {"\\#\\{BUYER\\}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"\\#\\{SELLER\\}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"\\#\\{CONTRACTAMT\\}", StrUtil.nvl(vo.TOTALCONTRACTAMT)});
    strResult = send(t, map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
}

out.print(strResult);
%>