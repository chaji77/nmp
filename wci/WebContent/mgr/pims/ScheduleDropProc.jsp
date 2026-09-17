<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
  request.setCharacterEncoding("utf-8");
  String plan_id          = StrUtil.nvl(request.getParameter("plan_id"), "0");
  new ScheduleCtrl().P_PLAN_DROP_PROC(plan_id);
%>