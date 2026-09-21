<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.memo.CommentVO" %>
<%@ page import="kr.co.mp.mgr.memo.CommentBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

CommentVO pvo = new CommentVO();
pvo.ACTIVE_ID    = Integer.parseInt(StrUtil.nvl(request.getParameter("aid"), "0"));
pvo.WRITE_ID     = (String) pageContext.getAttribute("SESS_LOGIN_ID");
pvo.COMMENT_DESC = StrUtil.xss(StrUtil.nvl(request.getParameter("comment_desc")).replaceAll("\r\n", "<br>").replaceAll("\n", "<br>")).replaceAll("\\s*<br>\\s*", "<br>");

out.print(new CommentBean().ACTIVE_COMMENT_ADD_PROC(pvo));
%>