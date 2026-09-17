<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.mp.mgr.StaticVO" %>
<%@ page import="kr.co.mp.mgr.StaticBean" %>
<%@ include file="./ManagerLoginCheck.jsp" %>
<%
LocalDate today = LocalDate.now();
LocalDate oneYearAgo = today.minusYears(1);
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMM");

String strStartYm = oneYearAgo.format(formatter);
String strEndYm   = DateTimeUtil.getCurrentDate("").substring(0,6);

String strSYm     = StrUtil.nvl(request.getParameter("s"), strStartYm).replaceAll("-", "");
String strEYm     = StrUtil.nvl(request.getParameter("e"), strEndYm).replaceAll("-", "");

ArrayList<StaticVO> arr = StaticBean.STAT_PROC(strSYm, strEYm);
ArrayList<String> yms = new ArrayList<>();
ArrayList<String> gubuns = new ArrayList<>();
if (arr!=null && arr.size()>0) {
  for (StaticVO v : arr) {
    String s = v.Y;
    boolean is = false;
    for (int i=0; i<yms.size(); i++) {
      if (yms.get(i).equals(v.Y)) is = true;
    }
    if (!is) yms.add(s);
  }
  for (StaticVO v : arr) {
    String s = v.GUBUN;
    boolean is = false;
    for (int i=0; i<gubuns.size(); i++) {
      if (gubuns.get(i).equals(v.GUBUN)) is = true;
    }
    if (!is) gubuns.add(s);
  }
}
if (yms!=null && yms.size()>0) Collections.sort(yms);

String strDisplayStartYm = strSYm.substring(0,4)+"-"+strSYm.substring(4,6);
String strDisplayEndYm   = strEYm.substring(0,4)+"-"+strEYm.substring(4,6);
%>
<%@ include file="./Header.jsp" %>
<!-- page head block -->
<title>월별통계</title>
<!-- // page head block -->
<%@ include file="./Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>월별통계</span>
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
    <th class='left'>구분</th>
<%
if (yms!=null && yms.size()>0) {
  for (String ym : yms) {
    out.print("<th class='right'>"+ym.substring(0,4)+"."+ym.substring(4,6)+"</th>");
  }
}
%>
  </tr>
</thead>
<tbody>
<%
if (gubuns!=null && gubuns.size()>0) {
  for (String gubun : gubuns) {
    for (int i=0; i<2; i++) {
      String gName = gubun;
      if (gubun.equals("REVENUE")  && i==0) gName = "매출건수";
      if (gubun.equals("REVENUE")  && i==1) gName = "매출액";
      if (gubun.equals("CONTRACT") && i==0) gName = "거래건수";
      if (gubun.equals("CONTRACT") && i==1) gName = "거래금액";
      if (gubun.equals("COMPANY")  && i==0) gName = "가입회원수";
      if (gubun.equals("COMPANY")  && i==1) gName = "로그인수";
      if (gubun.equals("CALL")     && i==0) gName = "고객상담수";
      if (gubun.equals("CALL")     && i==1) gName = "고객상담회원수";
      out.println("<tr><th class='left'>"+gName+"</th>");
      if (yms!=null && yms.size()>0) {
        for (String ym : yms) {
          String val = "";
          for (StaticVO v : arr) {
            if (v.Y.equals(ym) && v.GUBUN.equals(gubun)) val = (i<1) ? v.A : v.B;
          }
          out.println("<td class='right'>"+StrUtil.addComma(val)+"</td>");
        }
      }
      out.println("<tr>");
    }
  }
}
%>
</tbody>
</table>

<%@ include file="./Footer.jsp" %>