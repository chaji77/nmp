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
String strFromNotificationYN = StrUtil.nvl(request.getParameter("notification"),"N");
LocalDateTime now = LocalDateTime.now();
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
String formattedDate = (strCheckOutYn.equals("Y")) ? now.format(formatter) : "";

ArrayList<NotificationVO> arr = NotificationDAO.NOTIFICATE_PROC(strRegId, formattedDate);
String strContextPath = ConfigurationMgr.getInstance().getString("CONTEXT_PATH");
if (strFromNotificationYN.equals("Y") && (arr==null || arr.size()==0)) {
  out.print("");
} else {
%>
<div>
  <input type='hidden' name='notification_cnt' value='<%=arr.size()%>'>
  <div>
    <i class="fa-solid fa-bell manager-nav-btn"></i> <strong>알림</strong>
    <span class='more'><a onclick='hideNotificationForNavigation();' class='btn white'>닫기</a><a onclick='checkoutForNavigation();' class='btn white'>체크아웃</a></span>
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
</div>
<%
}
%>