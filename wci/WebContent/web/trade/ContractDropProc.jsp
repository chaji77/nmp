<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
/* VARIABLES */
TradeBean bean = new TradeBean();
String strCpyId  = (String)pageContext.getAttribute("CPY_ID");
int    intCpyId  = 0;
int    intResult = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else {
  out.print(0);
  return;
}
String strLoginId = StrUtil.nvl((String)pageContext.getAttribute("USER_LOGIN"));

try {
  int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0")); // 매매계약ID
  intResult = new TradeBean().CT_HEADER_CHANGE_STATUS_PROC(intCtId, intCpyId, "090", strLoginId, "N");
} catch (Exception e) {
  Logger l = Logger.getLogger(this.getClass());
  l.error(e.toString());
}
out.print(intResult);
%>