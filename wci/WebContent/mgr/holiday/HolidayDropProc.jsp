<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intResult = -1;

/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("holiday/Holidays.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

String strId = request.getParameter("id");
strId = strId!="" ? strId : null;
if (strId!=null) {
	HolidayVO pvo = new HolidayVO();
	intResult  = new HolidayBean().M_HOLIDAY_DROP_PROC(strId);
}
out.print(intResult);
%>