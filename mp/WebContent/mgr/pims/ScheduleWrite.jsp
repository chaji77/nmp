<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleVO" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String defaultYmd = StrUtil.nvl(request.getParameter("ymd"), DateTimeUtil.getCurrentDate(""));
defaultYmd = defaultYmd.substring(0, 4)+strDateSeparator+defaultYmd.substring(4, 6)+strDateSeparator+defaultYmd.substring(6);

// FOR EDIT
int intPlanId = Integer.parseInt(StrUtil.nvl(request.getParameter("plan_id"), "0"));
ScheduleVO vo = new ScheduleCtrl().P_PLAN_DETAIL_PROC(intPlanId);

String strButtonTitle = (intPlanId>0) ? "수정" : "등록";
%>


<style>
select {height:30px;width:calc(100% - 12px);margin-bottom:2px;}
input {height:28px;margin-bottom:2px;width:calc(100% - 12px);}
textarea {width: 100%;}
</style>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script>
function editEndDate() {
  var symd = $("#startymd").val().replaceAll("<%=strDateSeparator%>", "");
  var eymd = $("#endymd").val().replaceAll("<%=strDateSeparator%>", "");
  if (symd>eymd) $("#endymd").val($("#startymd").val());
}
function editStartDate() {
  var symd = $("#startymd").val().replaceAll("<%=strDateSeparator%>", "");
  var eymd = $("#endymd").val().replaceAll("<%=strDateSeparator%>", "");
  if (symd>eymd) $("#startymd").val($("#endymd").val());
}
function check() {
  if (document.frmScheduleReg.title.value.trim().length<2) {
    toast("제목을 입력하세요.");
    document.frmScheduleReg.title.focus();
    return false;
  }
  if (document.frmScheduleReg.startymd.value.trim().length<2) {
    toast("시작일을 입력하세요.");
    document.frmScheduleReg.startymd.focus();
    return false;
  }
  if (document.frmScheduleReg.endymd.value.trim().length<2) {
    toast("종료일을 입력하세요.");
    document.frmScheduleReg.endymd.focus();
    return false;
  }

  var sd = document.frmScheduleReg.startymd.value.trim().replaceAll("<%=strDateSeparator%>", "");
  var ed = document.frmScheduleReg.endymd.value.trim().replaceAll("<%=strDateSeparator%>", "");

  var sh = "1" + document.frmScheduleReg.start_h.value.trim();
  var eh = "1" + document.frmScheduleReg.end_h.value.trim();

  var sm = "1" + document.frmScheduleReg.start_m.value.trim();
  var em = "1" + document.frmScheduleReg.end_m.value.trim();

  if (sd>ed) {
    toast("종료일이 시작일을 앞설 수 없습니다.");
    return false;
  }

  if (sd==ed && sh > eh) {
    toast("종료시간이 시작시간을 앞설 수 없습니다.");
    return false;
  }

  if (sd==ed && sh == eh && sm > em) {
    toast("종료시간이 시작시간보다 앞설 수 없습니다.");
    return false;
  }
  return true;
}
function writeSchedule() {
  if (check()) {
    document.frmScheduleReg.note.value = CKEDITOR.instances['contents'].getData();
    $.post(strContextPath + "/mgr/pims/ScheduleWriteProc.jsp", $("form[name='frmScheduleReg']").serialize(), function(data) {
      closePopup();
      window.location.reload();
    });
  }
}
function fillData() {
<%
if (intPlanId>0 && vo.GRP!=null) {
%>
  $("input[name='plan_id']").val("<%=intPlanId %>");
  $("select[name='section']").val("<%=vo.GRP%>");

  $("input[name='startymd']").val("<%=FormatUtil.addSeparatorDate(vo.START_YMD, "/")%>");
  $("input[name='start_h']").val("<%=vo.START_HM.substring(0,2) %>");
  $("input[name='start_m']").val("<%=vo.START_HM.substring(3,5) %>");
  
  $("input[name='endymd']").val("<%=FormatUtil.addSeparatorDate(vo.START_YMD, "/")%>");
  $("input[name='end_h']").val("<%=vo.END_HM.substring(0,2) %>");
  $("input[name='end_m']").val("<%=vo.END_HM.substring(3,5) %>");
  
  $("input[name='title']").val("<%=StrUtil.input(vo.SCH_NM) %>");
<%
}
%>
}
$(document).ready(function() {
  $(".datepicker").datepicker({changeYear:true,changeMonth:true,dateFormat:"yy<%=strDateSeparator%>mm<%=strDateSeparator%>dd"});
  fillData();
});
</script>
<h3>일정<%=strButtonTitle %></h3>
<form name='frmScheduleReg' method='post' autocomplete='off'>
<input type='hidden' name='plan_id' value='0'>
<input type='hidden' name='note' value=''>
<ul>
  <li>
    <select name='section' style='width:100%;'>
    <option value='1'>업무</option>
    <option value='2'>회의</option>
    <option value='3'>외근|출장</option>
    <option value='4'>휴가</option>
    </select>
  </li>
  <li>
    <input type='text' id="startymd" name='startymd' class='datepicker' size="10" style="width:80px;" value="<%=defaultYmd%>" onchange='editEndDate();'>
    <select name='start_h' id='start_h' style='width:60px;'>
      <% for(int i=7; i<24; i++ ) { %>
      <option value="<%if(i<10){out.print("0"+i);}else{out.print(i);}%>" <%if(i==9) out.print("selected");%>><%if(i<10){out.print("0"+i);}else{out.print(i);}%></option>
      <% } %>
    </select> <b>:</b>
    <select name='start_m' id='start_m' style='width:60px;'>
      <% for(int i=0; i<60; i=i+5 ) { %>
      <option value="<%if(i<10){out.print("0"+i);}else{out.print(i);}%>" <%if(i==0) out.print("selected");%>><%if(i<10){out.print("0"+i);}else{out.print(i);}%></option>
      <% } %>
    </select>
    <br/>
    <input type='text' id="endymd" name='endymd' class='datepicker' size="10" style="width:80px;" value="<%=defaultYmd%>"  onchange='editStartDate();'>
    <select name='end_h' id='end_h' style='width:60px;'>
      <% for(int i=7; i<25; i++ ) { %>
      <option value="<%if(i<10){out.print("0"+i);}else{out.print(i);}%>" <%if(i==18) out.print("selected");%>><%if(i<10){out.print("0"+i);}else{out.print(i);}%></option>
      <% } %>
    </select> <b>:</b>
    <select name='end_m' id='end_m' style='width:60px;'>
      <% for(int i=0; i<60; i=i+5 ) { %>
      <option value="<%if(i<10){out.print("0"+i);}else{out.print(i);}%>" <%if(i==0) out.print("selected");%>><%if(i<10){out.print("0"+i);}else{out.print(i);}%></option>
      <% } %>
    </select>
  </li>
  <li><input type='text' name='title' maxlength='100' placeholder='제목' required></li>
  <li><textarea id="contents" style="height:300px;width:calc(100% - 2px);"><%=StrUtil.nvl(vo.CONTENTS) %></textarea><li>
</ul>
<div class='btns'><a onclick='writeSchedule();'><%=strButtonTitle %></a></div>
</form>

<script type="text/javascript" src='<%=request.getContextPath() %>/static/js/CKEditorSetMini.js?<%=DateTimeUtil.getCurrentResourceVersion()%>'></script>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>

