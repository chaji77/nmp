<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.EmtNetA181OfB311" %>
<%@ page import="kr.co.soap.controll.CommonElement" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");
String strCtId  = StrUtil.nvl(IntegerCryptoUtil.crypt(request.getParameter("ctid")), "122228");
String strSeqNo  = StrUtil.nvl(request.getParameter("seqno"), "122228");

Logger logger = Logger.getLogger(this.getClass());

int intCtId  = 0;
if (StrUtil.isOnlyNumeric(strCtId))  intCtId  = Integer.parseInt(strCtId);
try {
	
  EmtNetSenderVO vo = new EmtNetSenderVO();
  vo.xmlGubn = "A181";
  vo.ctId = intCtId;
  vo.seqNo = strSeqNo;
  
  Object resObj = EmtNetService.execute(vo);
  CommonElement commonElement = (CommonElement) resObj;
	
	//EmtNetA181OfB311 A181OfB311 = new EmtNetA181OfB311(intCtId, strSeqNo);
	//CommonElement commonElement = A181OfB311.executeA181OfB311();
  if (commonElement.getResponseCode().equals("0000")) {
    out.print("{\"is\":true,\"msg\":\"전송완료되었습니다.\"}");
  } else {
    logger.debug("{\"is\":false,\"msg\":\""+commonElement.getResponseMessage()+"\"}");
    out.print("{\"is\":false,\"msg\":\""+commonElement.getResponseMessage().replaceAll("\"", "'")+"\"}");
  }
} catch(Exception e) {
  out.print("{\"is\":false,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
}
%>
