<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.mp.mgr.DailyRevenueVO" %>
<%@ page import="kr.co.mp.mgr.DailyRevenueBean" %>
<%@ include file="./ManagerLoginCheck.jsp" %>
<%
LocalDate today = LocalDate.now();
LocalDate oneYearAgo = today.minusYears(1);
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMM");

String strStartYm = oneYearAgo.format(formatter);
String strEndYm   = DateTimeUtil.getCurrentDate("").substring(0,6);

String strSYm     = StrUtil.nvl(request.getParameter("s"), strStartYm).replaceAll("-", "");
String strEYm     = StrUtil.nvl(request.getParameter("e"), strEndYm).replaceAll("-", "");

ArrayList<DailyRevenueVO> arr = DailyRevenueBean.DAILY_REVENUE_PROC(strSYm, strEYm);
HashMap<String, String> map = new HashMap<>();
HashMap<String, Long> monthTotal = new HashMap<>();
HashMap<String, Integer> monthDayCount = new HashMap<>();
if (arr!=null && arr.size()>0) {
  for (DailyRevenueVO v : arr) {
    map.put(v.D, v.B);
    String ymKey = v.D.length()>=6 ? v.D.substring(0,6) : "";
    long b = 0;
    String bStr = v.B;
    if (bStr.indexOf(".") >= 0) bStr = bStr.substring(0, bStr.indexOf("."));
    try { b = Long.parseLong(bStr); } catch (Exception e) {}
    monthTotal.put(ymKey, monthTotal.getOrDefault(ymKey, 0L) + b);
    monthDayCount.put(ymKey, monthDayCount.getOrDefault(ymKey, 0) + 1);
  }
}

ArrayList<YearMonth> yms = new ArrayList<>();
YearMonth ymCursor = YearMonth.parse(strSYm, DateTimeFormatter.ofPattern("yyyyMM"));
YearMonth ymEnd    = YearMonth.parse(strEYm, DateTimeFormatter.ofPattern("yyyyMM"));
while (!ymCursor.isAfter(ymEnd)) {
  yms.add(ymCursor);
  ymCursor = ymCursor.plusMonths(1);
}

String strDisplayStartYm = strSYm.substring(0,4)+"-"+strSYm.substring(4,6);
String strDisplayEndYm   = strEYm.substring(0,4)+"-"+strEYm.substring(4,6);
%>
<%@ include file="./Header.jsp" %>
<!-- page head block -->
<title>일별수수료</title>
<!-- // page head block -->
<%@ include file="./Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>일별수수료</span>
  <span class='more'>

  </span>
</div>

<form name='frm' method="post">
  <div style='margin:10px 0;'>
    <input type="month" name="s" min="2020-01" max="<%=(strEndYm.substring(0,4)+"-"+strEndYm.substring(4,6)) %>" value="<%=strDisplayStartYm%>" style='width:120px;'>
    <input type="month" name="e" min="2020-01" max="<%=(strEndYm.substring(0,4)+"-"+strEndYm.substring(4,6)) %>" value="<%=strDisplayEndYm%>"   style='width:120px;'>
    <a onclick='document.frm.submit();' class='btn' style='padding:7px;'>검색</a>
  </div>
</form>

<table class='detail'>
<thead>
  <tr>
    <th class='left'>일자</th>
<%
for (YearMonth ym : yms) {
  out.print("<th class='right'>"+ym.getYear()+"."+String.format("%02d", ym.getMonthValue())+"</th>");
}
%>
  </tr>
</thead>
<tbody>
<%
for (int day=1; day<=31; day++) {
  out.println("<tr><th class='left'>"+day+"일</th>");
  for (YearMonth ym : yms) {
    if (day > ym.lengthOfMonth()) {
      out.println("<td class='right'>-</td>");
    } else {
      String key = String.format("%04d%02d%02d", ym.getYear(), ym.getMonthValue(), day);
      String val = map.get(key);
      if (val==null || val.length()==0) {
        out.println("<td class='right'>-</td>");
      } else {
        out.println("<td class='right'>"+StrUtil.addCommaAfterRound(val)+"</td>");
      }
    }
  }
  out.println("</tr>");
}
out.println("<tr><th class='left' style='font-weight:bold;border-top:3px double #e5e5e5;'>합계</th>");
for (YearMonth ym : yms) {
  String ymKey = String.format("%04d%02d", ym.getYear(), ym.getMonthValue());
  long total = monthTotal.getOrDefault(ymKey, 0L);
  out.println("<td class='right' style='font-weight:bold;border-top:3px double #e5e5e5;'>"+StrUtil.addComma(String.valueOf(total))+"</td>");
}
out.println("</tr>");
out.println("<tr><th class='left' style='font-weight:bold;'>영업일수</th>");
for (YearMonth ym : yms) {
  String ymKey = String.format("%04d%02d", ym.getYear(), ym.getMonthValue());
  int dayCnt = monthDayCount.getOrDefault(ymKey, 0);
  out.println("<td class='right' style='font-weight:bold;'>"+dayCnt+"일</td>");
}
out.println("</tr>");
%>
</tbody>
</table>

<%@ include file="./Footer.jsp" %>
