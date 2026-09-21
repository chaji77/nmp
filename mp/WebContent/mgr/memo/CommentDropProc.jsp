<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.memo.CommentBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

int intCommentId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String strManagerId = (String) pageContext.getAttribute("SESS_LOGIN_ID");

out.print(new CommentBean().ACTIVE_COMMENT_DROP_PROC(intCommentId, strManagerId));
%>