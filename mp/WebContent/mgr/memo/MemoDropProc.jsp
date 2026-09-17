<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

MemoVO pvo = new MemoVO();
pvo.ACTIVE_ID   = StrUtil.nvl(request.getParameter("aid"));
MemoBean bean = new MemoBean();
out.print(new MemoBean().ACTIVE_MANAGEMENT_DROP_PROC(Integer.parseInt(pvo.ACTIVE_ID)));
%>