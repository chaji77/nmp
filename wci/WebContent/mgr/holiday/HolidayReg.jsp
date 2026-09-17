<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>

<%@ include file="../Header.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strId = request.getParameter("id");
strId = strId!=null ? strId : null;

String year = StrUtil.nvl(request.getParameter("year"));
String strStartYmd   = FormatUtil.addSeparatorDate(year+"0101");

String strActionName = "등록";
HolidayVO vo = new HolidayVO();
if (strId!=null) {
  vo = new HolidayBean().M_HOLIDAY_DETAIL_PROC(strId);
  strStartYmd = FormatUtil.addSeparatorDate(vo.DATE);
  strActionName = "수정";
}
%>

<!-- page head block -->
<title>휴일 등록</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<script type="text/javascript">
function check() {
	var is = validate("input[name='date']", "length", [10,10], "날짜를 확인하세요.");
	if (is) is = validate("input[name='date_name']", "length", [2, 10], "휴일명을 확인하세요.");
	return is;
}
function goSubmit() {
	if (check()) {
	showCustomConfirm("<%=strActionName%>하시겠습니까?", function() {
	    $.post("HolidayRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
	      console.log(data);
	      if (data==1) {
	        goHistoryBack();
	      } else if (data==0){
	        toast("해당 연도의 영업일을 먼저 등록해주세요.");
	      } else if (data==-1){
	        toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
	      }
	    });
	  })
	}
}

$(document).ready(function(){

});
</script>
<!-- page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>휴일 <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<h3>&nbsp;</h3>

<form name='frmEnt' method='post' autocomplete="off">
<input type='hidden' name='id' value='<%=StrUtil.nvl(strId)%>'>
<ul class='form'>
  <li>
    <label for='date' class='emphasis'>날짜</label>
    <input type='date' name='date' value='<%=strStartYmd.replaceAll(strDateSeparator, "-") %>' style='width:100px;'>
  </li>
  <li>
    <label for='date_name' class='emphasis'>휴일명</label>
    <input type='text' name='date_name' value='<%=StrUtil.xss(vo.DATE_NAME) %>' maxlength='11' placeholder="대체 휴일">
  </li>
</ul>
</form>

<div class='btns'>
  <a onclick='goSubmit();'><%=strActionName%></a>
  <a onclick='history.go(-1);' class='cancel'>취소</a>
</div>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>
