<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

MemoVO pvo = new MemoVO();
pvo.ACTIVE_KIND = StrUtil.nvl(request.getParameter("active_kind"));
pvo.WRITE_ID    = (String) pageContext.getAttribute("SESS_LOGIN_ID");
pvo.CPY_ID      = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.ACTIVE_ID   = StrUtil.nvl(request.getParameter("aid"), "0");
pvo.CALL_TYPE   = StrUtil.nvl(request.getParameter("call_type"));
pvo.ACTIVE_DESC = StrUtil.xss(request.getParameter("active_desc"));
pvo.TO_USER_ID  = StrUtil.nvl(request.getParameter("to_user_id"));

if (pvo.ACTIVE_ID.equals("0")) out.println(new MemoBean().ACTIVE_MANAGEMENT_ADD_PROC(pvo));
else out.println(new MemoBean().ACTIVE_MANAGEMENT_MOD_PROC(pvo));
%>