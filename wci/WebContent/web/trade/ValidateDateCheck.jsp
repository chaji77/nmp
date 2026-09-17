<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%
String strDate = StrUtil.nvl(request.getParameter("strDate"), DateTimeUtil.getCurrentDate("-"));
// System.out.println(strDate);
if (DateTimeUtil.isCorrectDate(strDate, "-")) {
  HolidayVO vo   = HolidayBean.M_HOLIDAY_MATURITY_PROC(strDate);
  if (vo!=null && vo.DATE_KIND!=null) {
    out.print("{\"kind\":\""+vo.DATE_KIND+"\",\"nm\":\""+vo.DATE_NAME+"\",\"cnt\":\""+vo.CNT+"\"}");
  } else out.print("{\"kind\":\"OVER\",\"nm\":\"\",\"cnt\":\"0\"}");
  
  return;
} 
out.print("{\"kind\":\"OVER\",\"nm\":\"\",\"cnt\":\"0\"}");
%>
