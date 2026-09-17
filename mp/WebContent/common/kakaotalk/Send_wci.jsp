<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.baroservice.ws.KakaotalkTemplate" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.sms.*" %>
<%@ page import="kr.co.mp.kakaotalk.*" %>
<%@ page import="kr.co.funology.fw.mail.MailSend" %>
<%!
String send(HashMap<String, String> map, String strTemplateCode, String strReceiverNumber, String strTitle, List<String[]> params) {
  strReceiverNumber = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? "01056075313" : strReceiverNumber; ///////////////////////////////////////// FOR TEST MODE CHECK
  if (strReceiverNumber != null && strReceiverNumber.length() > 10) {
   String strContents = TalkCtrl.getInstance().getTemplate(strTemplateCode);

   if (params != null && params.size() > 0) {
     for (String[] s : params) {
       if (s != null && s.length >= 2 && s[0] != null && s[1] != null) {
          // strContents = strContents.replaceAll(Pattern.quote(s[0]), s[1]);
    	   strContents = strContents.replace(s[0], s[1]);
       }
     }
   }
   System.out.println("치환 후 strContents: [" + strContents + "]");
   int result = SendSMS.SEND_SMS_PROC(strReceiverNumber, strContents, 90);
   return String.valueOf(result);
  }
  return "SUCCESS";
}
void sendMail(String strTemplateName, String strEmail, String strReceiver, String strTitle, List<String[]> arrReplace) {
  strEmail = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? "ryan@funology.kr" : strEmail; ///////////////////////////////////////// FOR TEST MODE CHECK
  if (StrUtil.isValidEmail(strEmail)) {
    String strSender       = ConfigurationMgr.getInstance().getString("MAIL_ID");
    String strSenderName   = ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM");
    String strSenderPw     = ConfigurationMgr.getInstance().getString("MAIL_PW");
    String strContents = StrUtil.templateToString("mail/" + strTemplateName + ".htm");
    if (arrReplace != null && arrReplace.size()>0) {
      for (String[] s : arrReplace) {
   	    if (s != null && s.length >= 2 && s[0] != null && s[1] != null) {
           strContents = strContents.replaceAll(Pattern.quote(s[0]), s[1]);
        }
      }
    }
    MailSend.sendMail(strSender, strSenderName, strSenderPw, strEmail, strReceiver, strTitle, strContents, 1);
  }
}
%>
<%
// 오류코드 참조 : https://dev.barobill.co.kr/docs/references/%EB%B0%94%EB%A1%9C%EB%B9%8C-API-%EC%98%A4%EB%A5%98%EC%BD%94%EB%93%9C

HashMap<String, String> map = new HashMap<>();
map.put("M001", "Registration"); //웰캠프 회원가입 완료되었습니다.\n다음 진행을 위해 고객센터로 연락주세요.\nT.02-542-3230\n\nFrom. 02-542-3230
map.put("M017", "mpContractAuthorization");  //거래은행에서 #{SELLER}건을 결제하시기 바랍니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M004", "MaturityRepayment7days");  //#{MTYDATE} 날짜에 만기 도래건 #{CNT}건이 있습니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M006", "PaymentDueDate"); //#{SELLER}/ #{CONTRACTAMT}원 오늘까지 결제 가능합니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M007", "ContractCancellation"); //#{BUYER}의 진행중인 결제건이 취소되었습니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M015", "LoginTemporaryPassword"); //아이디와 임시비밀번호를 안내드립니다.\n아이디 : #{PRS_LOGIN}\n비밀번호 : #{PRS_PASSWD}\n[웰캠프]\n\nFrom. 02-542-3230
map.put("M009", "mpReverseOrder"); //#{BUYER}의 매매계약서를 확인하시기 바랍니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M010", "mpCollectionComplete");//거래은행에서 #{BUYER}건을 추심 진행 바랍니다.[웰캠프]\n\nFrom. 02-542-3230
map.put("M011", "PaymentCompleted"); //#{BUYER}로부터 #{CONTRACTAMT}원이 결제되었습니다.[웰캠프]\n\nFrom. 02-542-3230

/* 메일탬플릿 @see /static/template/mail */
String mailTemplates = "M007,M009,M010,M011,M017";

Logger logger = Logger.getLogger("SMS ISSUANCE CENTER");

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
  strTitle = "회원가입안내"; // 강조표기문구탬플릿과 일치해야 함
  params.add(new String[] {"#{CPY_NAME}", StrUtil.nvl(v.CPY_NAME)});
  strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
  logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
}/*  else if (strTemplateCode.equals("M003")) { // COMPLETED : @callby /mgr/etax/TaxPublishProc.jsp
  ArrayList<ParametersVO> arr = new ParametersBean().TALK_FOR_SETTLED_PROC(intBillSeq);
  if (arr!=null && arr.size()>0) {
    for (int i=0; i<arr.size();) {
      ParametersVO v = arr.remove(0); 
      params = new ArrayList<>(); //params 초기화 추가
      strTitle = "MP이용수수료발행안내"; // 강조표기문구탬플릿과 일치해야 함
      if ("1".equals(v.MPPAYCPY)){
    	strReceiverNumber = StrUtil.nvl(v.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
        params.add(new String[] {"#{MPPAYCPY}", StrUtil.nvl(v.CPY_NAME)});
        params.add(new String[] {"#{SELLER}", StrUtil.nvl(v.SELLER_NM)});
        params.add(new String[] {"#{EMAIL}", StrUtil.nvl(v.SELLER_EMAIL)});
      } else if ("2".equals(v.MPPAYCPY)){
      	strReceiverNumber = StrUtil.nvl(v.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
        params.add(new String[] {"#{MPPAYCPY}", StrUtil.nvl(v.CPY_NAME)});
        params.add(new String[] {"#{SELLER}", StrUtil.nvl(v.SELLER_NM)});
        params.add(new String[] {"#{EMAIL}", StrUtil.nvl(v.BUYER_EMAIL)});
      }
      strResult = send(map, "M003", strReceiverNumber, strTitle, params);
      logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    }
  }
} */ else if (strTemplateCode.equals("M004")) { // COMPLETED : @callby /WEB-INF/MaturityNotification.sh
  ArrayList<MaturityNotificationVO> arr = new MaturityNotificationBean().BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC();
  if (arr!=null && arr.size()>0) {
    for (int i=0; i<arr.size();) {
      MaturityNotificationVO v = arr.remove(0);
      params = new ArrayList<>(); //params 초기화 추가
      strReceiverNumber = StrUtil.nvl(v.PRS_MOBILE_NO).replaceAll("[^0-9]", "");
      strTitle = "만기상환7일안내"; // 강조표기문구탬플릿과 일치해야 함
      params.add(new String[] {"#{MTYDATE}", FormatUtil.addSeparatorDate(StrUtil.nvl(v.MTYDATE))});
      params.add(new String[] {"#{CNT}", StrUtil.nvl(v.CNT)}); // 
      strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
      strTitle = "만기상환일안내"; // 강조표기문구탬플릿과 일치해야 함
      params.add(new String[] {"#{MTYDATE}", FormatUtil.addSeparatorDate(StrUtil.nvl(v.MTYDATE))});
      params.add(new String[] {"#{CNT}", StrUtil.nvl(v.CNT)}); // 
      params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(StrUtil.extractInteger(v.AMT))});
      params.add(new String[] {"#{BANK}", StrUtil.nvl(v.BNK_SNAME)});
      strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
      logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    }
  }
} else if (strTemplateCode.equals("M006")) { // COMPLETED : @callby /WEB-INF/MaturityNotification.sh
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "결제일안내"; // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M007")) { // COMPLETED : @callby /web/trade/ContractCancelProc.jsp /WEB-INF/src/kr/co/soap/emtnet/EmtNetB315.java
  ParametersVO vo = new ParametersBean().TALK_FOR_CANCEL_CONTRACT_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "계약취소안내"; // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
    
    if (mailTemplates.contains(strTemplateCode)) {
      sendMail(map.get(strTemplateCode), StrUtil.nvl(vo.BUYER_EMAIL), StrUtil.nvl(vo.BUYER_NM), strTitle, params);
    }
    
    params = new ArrayList<>();
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "계약취소안내"; // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
    strTitle = "매매계약서안내";
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.nvl(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
    strTitle = "거래추심안내"; // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{BANK}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
    strTitle = "결제완료안내"; // 강조표기문구탬플릿과 일치해야 함
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.nvl(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
    params.add(new String[] {"#{CPY_NAME}", StrUtil.nvl(vo.CPY_NAME)});
    params.add(new String[] {"#{PRS_LOGIN}", StrUtil.nvl(vo.PRS_LOGIN)});
    params.add(new String[] {"#{PRS_PASSWD}", CryptoDESUtil.decrypt(StrUtil.nvl(vo.PRS_PASSWD))});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M016")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.SELLER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "거래추심안내";
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{BANK}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
} else if (strTemplateCode.equals("M017")) {
  ParametersVO vo = new ParametersBean().TALK_FOR_TRANSACTION_INFO_PROC(intCtId);
  if (vo!=null) {
    params = new ArrayList<>(); //params 초기화 추가
    strReceiverNumber = StrUtil.nvl(vo.BUYER_MOBILE_NO).replaceAll("[^0-9]", "");
    strTitle = "계약승인안내";
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{BANK}", StrUtil.nvl(vo.BNK_SNAME)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.addComma(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
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
    strTitle = "판매계약서안내";
    params.add(new String[] {"#{BUYER}", StrUtil.nvl(vo.BUYER_NM)});
    params.add(new String[] {"#{SELLER}", StrUtil.nvl(vo.SELLER_NM)});
    params.add(new String[] {"#{CONTRACTAMT}", StrUtil.nvl(vo.TOTALCONTRACTAMT)});
    strResult = send(map, strTemplateCode, strReceiverNumber, strTitle, params);
    logger.debug(strTemplateCode + ":" + strReceiverNumber + ":" + strResult);
  }
}

out.print(strResult);
%>