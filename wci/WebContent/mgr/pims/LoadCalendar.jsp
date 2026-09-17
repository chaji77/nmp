<%@ page language="java" contentType="text/javascript;charset=UTF-8"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.CalendarUtil" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%
String[] arrDate  = DateTimeUtil.getCurrentDate("-").split("-");
int      intYear  = Integer.parseInt(arrDate[0]);
int      intMonth = Integer.parseInt(arrDate[1]);

String strYear = StrUtil.nvl(request.getParameter("year"), Integer.toString(intYear));
String strMon  = StrUtil.nvl(request.getParameter("mon"),  Integer.toString(intMonth));

String strTargetDate = strYear + ((strMon.length() < 2) ? "0" + strMon : strMon) + "10";
HashMap<String, String> holidays = new ScheduleCtrl().getAdditionalHolidy(strTargetDate);

String str = CalendarUtil.getCalendar(
  Integer.parseInt(strYear),
  Integer.parseInt(strMon),
  StrUtil.nvl(request.getParameter("s"), "."),
  holidays
);
%>
saveCalendar(<%=str%>);
