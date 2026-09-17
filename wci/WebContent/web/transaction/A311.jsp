<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.EmtNetA311" %>
<%@ page import="kr.co.soap.controll.A312VO" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");

response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

String strCpyId  = StrUtil.nvl(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
String strBankCd = StrUtil.nvl(request.getParameter("bank_cd"), "KU");
String strPayCd  = StrUtil.nvl(request.getParameter("pay_cd"), "54");

System.out.println("strCpyId : "+ strCpyId);
if (strCpyId.equals("0")) strCpyId = StrUtil.nvl(request.getParameter("cpy_origin_id"), "0");

System.out.println("strCpyId : "+ strCpyId);
System.out.println("strBnkCd : "+ strBankCd);
System.out.println("strPayCd : "+ strPayCd);
System.out.println("################################");

int intCpyId = 0;
int intPayCd = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
if (StrUtil.isOnlyNumeric(strPayCd)) intPayCd = Integer.parseInt(strPayCd);

Logger logger = Logger.getLogger(this.getClass());

try {
	
  EmtNetSenderVO vo = new EmtNetSenderVO();
  vo.xmlGubn = "A311";
  vo.cpyId = intCpyId;
  vo.payId = intPayCd;
  vo.bnkCd = strBankCd;
  vo.amt = 0.0;	
  
  Object resObj = EmtNetService.execute(vo);
  A312VO tranVo = (A312VO) resObj;

  System.out.println("##################################");
  System.out.println("##################################");
  System.out.println(tranVo.getCommonElement().getResponseCode());
  System.out.println(tranVo.getBankLimitAMT());
  System.out.println(tranVo.getBankLimitAMT());
  System.out.println(tranVo.getBankLimitSpare());
  
  System.out.println("##################################");
  System.out.println("##################################");
  
  //EmtNetA311 a311 = new EmtNetA311(intCpyId, strBankCd, intPayCd, 0.0);
  //A312VO tranVo = a311.executeA311();
  
  if (tranVo.getCommonElement().getResponseCode().equals("0000")) {
    String rtn = "<ul>";
    // rtn += "<li>"+tranVo.getBuyerBusinessNO()+"</li>";
    // rtn += "<li>"+tranVo.getBuyerSettlementType()+"</li>";
    // rtn += "<li>"+tranVo.getBankLimitYN()+"</li>";
    
    long lngLimtAmt   = Long.parseLong(StrUtil.nvl(tranVo.getBankLimitAMT(), "0"));
    long lngLimtSpace = Long.parseLong(StrUtil.nvl(tranVo.getBankLimitSpare(), "0"));

    //long lngLimtAmt   = Long.parseLong(tranVo.getBankLimitAMT());
    //long lngLimtSpace = Long.parseLong(tranVo.getBankLimitSpare());
    rtn += "<li>한도총액 : "+StrUtil.addComma(lngLimtAmt)+"원</li>";
    rtn += "<li>한도잔액 : "+StrUtil.addComma(lngLimtSpace)+"원</li>";
    // rtn += "<li>"+tranVo.getSellerBusinessNO()+"</li>";
    rtn += "</ul>";
    rtn = "{\"is\":true,\"limit\":\""+lngLimtAmt+"\",\"msg\":\""+rtn+"\"}";
    out.print(rtn);
    logger.debug(rtn);
  } else {
    out.print("{\"is\":false,\"limit\":0,\"msg\":\""+tranVo.getCommonElement().getResponseMessage().replaceAll("\"", "'")+"\"}");
    logger.debug("{\"is\":false,\"limit\":0,\"msg\":\""+tranVo.getCommonElement().getResponseMessage().replaceAll("\"", "'")+"\"}");
  }
} catch(Exception e) {
  out.print("{\"is\":false,\"limit\":0,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
  logger.error("{\"is\":false,\"limit\":0,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
}
%>
