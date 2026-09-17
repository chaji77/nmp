<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%
String strMgrUserId = StrUtil.nvl((String) session.getAttribute("SESS_MAN_ID")).trim();

if (strMgrUserId==null || strMgrUserId.equals("") || !strMgrUserId.contains("M")) {
	out.println("<script>");
	out.println("if(opener==null || typeof(opener)==='undefined') {top.location.href = '"+ request.getContextPath() + "/mgr/index.jsp';}");
	out.println("else {opener.location.href = '"+ request.getContextPath() + "/mgr/index.jsp';self.close();}");
	out.println("</script>");
	if (true) return;
}
pageContext.setAttribute("SESS_MGR_ID", Integer.parseInt(IntegerCryptoUtil.crypt(strMgrUserId)));
pageContext.setAttribute("SESS_LOGIN_ID", StrUtil.nvl((String) session.getAttribute("SESS_LOGIN_ID")).trim());
pageContext.setAttribute("SESS_MGR_NM", StrUtil.nvl((String) session.getAttribute("SESS_USER_NM")).trim());
%>