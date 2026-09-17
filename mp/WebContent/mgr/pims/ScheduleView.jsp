<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleVO" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%
int intPlanId = Integer.parseInt(StrUtil.nvl(request.getParameter("plan_id"), "0"));
ScheduleVO vo = new ScheduleCtrl().P_PLAN_DETAIL_PROC(intPlanId);
if (vo==null) return;
%>
<style>
ul.detail li.th {width:50px;}
ul.detail li.td {width:calc(100% - 92px);}
</style>
<div style='max-width:340px;'>
  <div>
    <span style='width:auto;font-size:1.2em;font-weight:bold;'>일정내용</span>
    <span class='more'>
      <a onclick='editSchedule(<%=intPlanId %>);' class='btn lurian'>수정</a>
      <a onclick='dropSchedule(<%=intPlanId %>);' class='btn darkred'>삭제</a>
    </span>
  </div>
  <p>&nbsp;</p>
  <ul class='detail'>
    <li class='th'>분류</li>
    <li class='td'><%=ScheduleCtrl.getGrpNm(vo.GRP) %></li>
    <li class='th'>일정</li>
    <li class='td'><%=FormatUtil.addSeparatorDate(vo.START_YMD, "/") %> <%=vo.START_HM %> ~ <%=FormatUtil.addSeparatorDate(vo.END_YMD, "/") %> <%=vo.END_HM %></li>
    <li class='th'>작성자</li>
    <li class='td'><%=vo.EMP_NM %></li>
    <li class='th'>제목</li>
    <li class='td'><%=vo.SCH_NM %></li>
  </ul>
  <div style='padding: 10px 0;'><%=vo.CONTENTS %></div>
  
  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
</div>