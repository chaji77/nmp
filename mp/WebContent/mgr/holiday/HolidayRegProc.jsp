<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
int intResult = -1;

String strId = StrUtil.nvl(request.getParameter("id"));
HolidayVO pvo = new HolidayVO();
HolidayBean bean = new HolidayBean();
pvo.DATE = StrUtil.nvl(request.getParameter("date")).replaceAll(strDateSeparator, "").replaceAll("-", "");
pvo.DATE_NAME = StrUtil.xss(StrUtil.nvl(request.getParameter("date_name"), "대체휴일"));
pvo.MOD_DATE = strId;
out.println((!strId.equals(""))?bean.M_HOLIDAY_MOD_PROC(pvo):bean.M_HOLIDAY_ADD_PROC(pvo));
%>
