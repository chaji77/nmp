<%@ page contentType="text/plain;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.TaxPublishBean" %>
<%
// 서버 내 cron -> curl 로 호출되는 세금계산서 자동발행 트리거.
// 로그인 세션이 없는 호출이므로 ManagerLoginCheck.jsp를 include하지 않고,
// 대신 고정 토큰으로 접근을 제한한다.
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("TAX-AUTO-PUBLISH");

String strToken = StrUtil.nvl(request.getParameter("token"));
String strExpectedToken = ConfigurationMgr.getInstance().getString("TAX_AUTO_PUBLISH_TOKEN");

if (StrUtil.isEmpty(strExpectedToken) || !strExpectedToken.equals(strToken)) {
  response.setStatus(403);
  out.print("FORBIDDEN");
  return;
}

String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));

// T_BILL_AUTO_STANDBY_PROC 는 현재 DB에서 TOP 1 로 걸려 있음 (검증 후 전체로 확대 예정).
// 여기 코드는 반환 건수와 무관하게 그대로 동작함.
ArrayList<InvoiceVO> arr = new InvoiceDAO().T_BILL_AUTO_STANDBY_PROC(strSenderKey);
String[] billSeqs = new String[arr.size()];
for (int i=0; i<arr.size(); i++) {
  billSeqs[i] = arr.get(i).BILL_SEQ;
}

logger.info("TaxAutoPublishTrigger 호출됨 - senderKey=" + strSenderKey + ", 대상건수=" + billSeqs.length);

TaxPublishBean.PublishResult result = new TaxPublishBean().publish(billSeqs);

logger.info("TaxAutoPublishTrigger 완료 - 대상=" + billSeqs.length + ", 성공=" + result.successCount + ", 실패=" + result.failCount);

out.print("OK - target=" + billSeqs.length + ", success=" + result.successCount + ", fail=" + result.failCount);
%>
