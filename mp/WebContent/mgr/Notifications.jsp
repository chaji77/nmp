<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.mp.mgr.NotificationVO" %>
<%@ page import="kr.co.mp.mgr.NotificationDAO" %>
<%@ include file="./ManagerLoginCheck.jsp" %>
<%
String strRegId = (String)pageContext.getAttribute("SESS_LOGIN_ID");
String strCheckOutYn = StrUtil.nvl(request.getParameter("checkout"),"N");
LocalDateTime now = LocalDateTime.now();
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
String formattedDate = (strCheckOutYn.equals("Y")) ? now.format(formatter) : "";

ArrayList<NotificationVO> arr = NotificationDAO.NOTIFICATE_PROC(strRegId, formattedDate);
String strContextPath = ConfigurationMgr.getInstance().getString("CONTEXT_PATH");
%>
<%@ include file="./Header.jsp" %>
<!-- page head block -->
<title>알림</title>
<!-- // page head block -->
<%@ include file="./Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>알림</span>
  <span class='more'>
    <span class='more'><a href='Notifications.jsp?checkout=Y' class='btn white'>체크아웃</a></span>
  </span>
</div>


  <ul>
  <%
  if (arr!=null && arr.size()>0) {
    for (NotificationVO v : arr) {
      v.CONTENTS = v.CONTENTS.replaceAll("__CONTEXT_PATH__", strContextPath);
      v.CONTENTS = v.CONTENTS.replaceAll("__COMPANY_LINK__", "<a href='"+strContextPath+"/mgr/customer/Company.jsp?cpy_id="+v.CPY_ID+"'>");
      out.println("<li style='padding:5px 0px;margin:5px 0px;border-bottom:1px solid #eee;'>["+v.GUBUN+"] "+v.CONTENTS+"<br/>"+v.REG_DT.substring(0, 19)+"</li>");
    }
  }
  %>
  </ul>


<%@ include file="./Footer.jsp" %>