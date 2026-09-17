<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil"%>
<%
if (ConfigurationMgr.getInstance().getString("SYSTEM_CONSTRUCTION_YN").equals("Y")) {
  response.sendRedirect(request.getContextPath() + "/error/construct.jsp");
}
%>
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
<link rel="apple-touch-icon" href="//image.mp1.co.kr<%=request.getContextPath() %>/favicon.png" />
<link rel="shortcut icon" href="//image.mp1.co.kr<%=request.getContextPath() %>/favicon.png" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/style.css?<%=DateTimeUtil.getCurrentResourceVersion() %>" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/web.css?<%=DateTimeUtil.getCurrentResourceVersion() %>" />
<script src="<%=request.getContextPath() %>/static/js/jquery-3.7.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion() %>" type="text/javascript"></script>
<script src="<%=request.getContextPath() %>/static/js/common.js?<%=DateTimeUtil.getCurrentResourceVersion() %>" type='text/javascript'></script>
<script src="<%=request.getContextPath() %>/static/js/paging.js?<%=DateTimeUtil.getCurrentResourceVersion() %>" type='text/javascript'></script>
<%
/* fontawesome 외부연결이 끊겼을때 아래 css를 적용 */
%>
<!-- script src="https://kit.fontawesome.com/17faa015a1.js" crossorigin="anonymous"></script -->
<link href="<%=request.getContextPath() %>/static/font/fontawesome-free-6.7.2-web/css/fontawesome.css?2025" rel="stylesheet" />
<link href="<%=request.getContextPath() %>/static/font/fontawesome-free-6.7.2-web/css/solid.css?2025" rel="stylesheet" />

