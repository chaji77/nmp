<%@page language="java" contentType="text/javascript;charset=UTF-8"%>
<%@page import="kr.co.funology.fw.util.StrUtil"%>
<%@page import="kr.co.funology.fw.util.DateTimeUtil"%>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%
String str          = "";
int    intYear      = Integer.parseInt(StrUtil.nvl(request.getParameter("y"), "0"));
int    intMonth     = Integer.parseInt(StrUtil.nvl(request.getParameter("m"), "0"));
String strSeparator = StrUtil.nvl(request.getParameter("s"), ".");

if (intYear>1970 && intMonth>0 && intMonth<13) {
  ScheduleCtrl ctrl = new ScheduleCtrl();
  try {
    str = ctrl.getSchedule(intYear, intMonth, strSeparator);
    if (!str.equals("")) out.println("saveSchedule("+str+");");
  } catch(Exception e) {}
}
%>
