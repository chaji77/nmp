<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%
request.setCharacterEncoding("utf-8");

int intResult = -1;

String year = request.getParameter("year");
String startDate = year + "-01-01";
String endDate = year + "-12-31";

/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("holiday/Holidays.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

// 전년도 마지막 BIZSEQ 가져오기
String lastDate = DateTimeUtil.diff(startDate, 1, "-");
String strLastDate = lastDate.replaceAll("-", "");

HolidayVO vo = new HolidayVO();
HolidayBean bean = new HolidayBean();

StringBuffer xml = new StringBuffer();
try {
	StringBuffer sb = new StringBuffer();
	
	while(DateTimeUtil.diff(startDate, endDate, "-") >= 0) {
		String day = DateTimeUtil.getWeekEnglish(startDate, "-");	// 요일 구하기 
		
		String date_kind = "";	
		String date_name = "";
		
		if (day == "SUN" || day == "SAT") date_kind = "LAW";
		else date_kind = "BIZ";
		
		sb.append("<NODE DATE='"+startDate.replaceAll("-", "")+"' DATE_KIND='"+date_kind+"' DATE_NAME='"+date_name+"'/>");
	
		startDate = DateTimeUtil.diff(startDate, -1, "-");
	}
	
	xml = sb;
} catch(Exception e) {}

intResult = bean.M_HOLIDAY_TB_YEARLY_ADD_PROC(xml.toString());
out.println("{\"success\": \"" + intResult + "\", \"year\": \"" + year + "\"}");
%>