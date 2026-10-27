<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.mp.sms.CyclnSms" %>
<%
/*
 * 싸이클론 대출상환 안내문자. 서버 cron 이 매일 09:00 에 부른다. (WEB-INF/CyclnMaturitySms.sh)
 * days=7 이면 7일전 안내, days=0 이면 당일 안내.
 * 로그인 없이 열리므로 서버 자신(localhost)에서 온 요청만 받는다.
 */
Logger logger = Logger.getLogger("CYCLN_MATURITY_SMS");

String strAddr = request.getRemoteAddr();
if (!"127.0.0.1".equals(strAddr) && !"0:0:0:0:0:0:0:1".equals(strAddr) && !"::1".equals(strAddr)) {
  logger.error("REJECTED CYCLN MATURITY SMS : REMOTE_ADDR=" + strAddr);
  response.sendError(HttpServletResponse.SC_FORBIDDEN);
  return;
}

String strDays = request.getParameter("days");
if (!"7".equals(strDays) && !"0".equals(strDays)) {
  out.print("ERROR : days=7 또는 days=0");
  return;
}

out.print("SENT : " + CyclnSms.sendMaturity(Integer.parseInt(strDays)));
%>
