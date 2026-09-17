<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.EmtNetB311" %>
<%@ page import="kr.co.soap.controll.CommonElement" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");
String strCtId   = StrUtil.nvl(IntegerCryptoUtil.crypt(request.getParameter("ctid")), "0");
String strVal    = StrUtil.nvl(request.getParameter("token"), "");
String strCalVal = CryptoDESUtil.encrypt(strCtId+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "");
System.out.println(strCtId + ":::" + strVal + ":::" + strCalVal);
String strEditSettleDueDateYN = StrUtil.nvl(request.getParameter("edit_settle_due_date_yn"), "N"); // 결제예정일을 오늘로 지정하려면 Y로 설정

Logger logger = Logger.getLogger(this.getClass());

if (!strVal.equals(strCalVal)) {
  out.print("{\"is\":false,\"msg\":\"거래검증생략은 허용되지 않습니다.\"}");
} else {
  int intCtId  = 0;
  if (StrUtil.isOnlyNumeric(strCtId)) intCtId = Integer.parseInt(strCtId);
  try {
    new TradeBean().CT_HEADER_CHANGE_STATUS_PROC(intCtId, 0, "707", "", "Y");
    
    EmtNetSenderVO vo = new EmtNetSenderVO();
    vo.xmlGubn = "B311";
    vo.ctId = intCtId;
    vo.editGubun = strEditSettleDueDateYN;
    
    Object resObj = EmtNetService.execute(vo);
    CommonElement commonElement = (CommonElement) resObj;
    
    //EmtNetB311 b311 = new EmtNetB311();
    //CommonElement commonElement = b311.executeB311(intCtId, strEditSettleDueDateYN);
    // System.out.println(commonElement.getResponseCode() + ":" + commonElement.getResponseMessage());
    if (commonElement.getResponseCode().equals("0000")) {
      out.print("{\"is\":true,\"msg\":\"전송완료되었습니다.\"}");
    } else {
      logger.debug("{\"is\":false,\"msg\":\""+commonElement.getResponseMessage()+"\"}");
      out.print("{\"is\":false,\"msg\":\""+ConfigurationMgr.getInstance().getString("ERR_B311_MSG")+"\"}");
      
    }
  } catch(Exception e) {
    out.print("{\"is\":false,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
    logger.error("{\"is\":false,\"msg\":\"보증기관 및 은행과의 통신이 원할하지 않습니다.\"}");
  }
}
%>