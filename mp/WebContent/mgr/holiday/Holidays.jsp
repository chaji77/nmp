<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayVO" %>
<%@ page import="kr.co.mp.mgr.holiday.HolidayBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

HolidayVO pvo = new HolidayVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;

String defaultYear = DateTimeUtil.getCurrentDate("").substring(0, 4);
String selectedYear = StrUtil.nvl(request.getParameter("year"), defaultYear);
if (!StrUtil.isOnlyNumeric(selectedYear) || selectedYear.length() != 4) selectedYear = defaultYear;

int datesExist = new HolidayBean().M_HOLIDAY_DATES_EXIST_CHECK_PROC(selectedYear);
ArrayList<HolidayVO> arr = new HolidayBean().M_HOLIDAY_LIST_PROC(pvo, selectedYear);

String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>휴일관리</title>

<script type="text/javascript">
function goPage(p) {
	var selectedYear = $('#selectedYear').text();
	location.href = "Holidays.jsp?year="+selectedYear+"&page="+p;
}
	
function changeYear(diff) {
	var currentYear = parseInt($('#selectedYear').text());
	var changedYear = currentYear + diff;
	location.href = "Holidays.jsp?year=" + changedYear;
}

function generateYearlyDates() {
	var selectedYear = $('#selectedYear').text();
	$.post("./HolidaysYearlyRegProc.jsp", { year: selectedYear }, function(data) {
		if (data.success != "-1") {
			location.href='Holidays.jsp?year=' + data.year;
		} else {
			toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
		}
	});
}

function edit(obj) {
	var id = $(obj).parent().parent().attr("id");
	document.frmSearch.id.value = id;
	document.frmSearch.action = "HolidayReg.jsp";
	document.frmSearch.target = "_top";
	document.frmSearch.submit();
}
function drop(obj) {
	  var id = $(obj).parent().parent().attr("id");
	  document.frmSearch.id.value = id;
	  showCustomConfirm("정말 삭제하시겠습니까?", function() {
	    $.post("./HolidayDropProc.jsp", $("form[name='frmSearch']").serialize(), function(data) {
	      if (data=="0") {
	        $("#target-list>tbody>tr").each(function(index, item) {
	          if ($(item).attr("id")==id) $(item).remove();
	        });
	      }
	    });
	  }, function() {});
}
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>휴일관리</span>
  <span class='more'>
<% if (datesExist == 0) { %>
  <a href='HolidayReg.jsp?year=<%=selectedYear %>' class='btn'>휴일등록</a>
<% } else { %>
  <a onclick='generateYearlyDates()' class='btn'>영업일 생성</a>
<% } %>    
  </span>
</div>

<div style='display: flex; justify-content: center;font-size:1.6em;letter-spacing:-2px;padding-bottom:30px;'>
  <a onclick='changeYear(-1)'><i class="fa-solid fa-chevron-left"></i></a>
  <span id="selectedYear" style='margin-left:25px;'><%=selectedYear %></span>
  <span style='margin-right:25px;'> 년</span>
  <a onclick='changeYear(+1)'><i class="fa-solid fa-chevron-right"></i></a>
</div>

<table id='target-list' class='list detail'>
  <colgroup>
    <col width='27%' >
    <col width='27%' />
    <col width='27%' >
    <col width='*' />
  </colgroup>
  <thead>
    <tr>
      <th class='center'>일자</th>
      <th class='center'>휴일명</th>
      <th class='center'>관리</th>
    </tr>
  </thead>  
  <tbody>
<%
if (arr!=null && arr.size()>0) {
	for(int i=0; i< arr.size();) {
		HolidayVO v = arr.remove(i);
		intTotalCnt = v.TOTAL_CNT;

		String strHolidayDate = FormatUtil.addSeparatorDate(v.DATE);
%>
    <tr id='<%=v.DATE %>'>
      <td class='center'> <%=StrUtil.nvl(strHolidayDate) %> (<%=DateTimeUtil.getWeekKorean(strHolidayDate, strDateSeparator) %>)</td>
      <td class='center'><%=StrUtil.nvl(v.DATE_NAME) %></td>
      <td class='center'><a onclick='edit(this);' class='btn lurian'>수정</a> <a onclick='drop(this);' class='btn darkred'>삭제</a></td>
    </tr>
<%
	}	
} else if (datesExist > 0) out.println("<tr><td colspan='4' class='noentry'>해당 연도의 영업일이 생성되지 않았습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='id'  value=''>
</form>

<%@ include file="../Footer.jsp" %>