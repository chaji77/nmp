<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.EmtNetB315" %>
<%@ page import="kr.co.soap.controll.CommonElement" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");
String strCtId   = StrUtil.nvl(IntegerCryptoUtil.crypt(request.getParameter("ctid")), "0");

Logger logger = Logger.getLogger(this.getClass());

int intCtId  = 0;
if (StrUtil.isOnlyNumeric(strCtId))  intCtId  = Integer.parseInt(strCtId);
try {

  EmtNetSenderVO vo = new EmtNetSenderVO();
  vo.xmlGubn = "B315";
  vo.ctId = intCtId;
  
  Object resObj = EmtNetService.execute(vo);
  CommonElement commonElement = (CommonElement) resObj;
    
  //EmtNetB315 b315 = new EmtNetB315();
  //CommonElement commonElement = b315.executeB315(intCtId);
  if (commonElement.getResponseCode().equals("0000")) {
    logger.debug("{\"is\":true,\"msg\":\"취소완료되었습니다.\"}");
    out.print("{\"is\":true,\"msg\":\"취소완료되었습니다.\"}");
  } else {
    logger.debug("{\"is\":false,\"msg\":\""+commonElement.getResponseMessage().replaceAll("\\", "/").replaceAll("\"", "'")+"\"}");
    out.print("{\"is\":false,\"msg\":\""+commonElement.getResponseMessage().replaceAll("\\", "/").replaceAll("\"", "'")+"\"}");
  }
} catch(Exception e) {
  out.print("{\"is\":false,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
}
%>