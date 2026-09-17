<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepVO" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>

<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

SalesrepVO pvo = new SalesrepVO();
String strMid = request.getParameter("mid");
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
pvo.NM = StrUtil.xss(request.getParameter("nm"));
ArrayList<SalesrepVO> arr = new SalesrepBean().M_SALESREP_LIST_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>영업담당자관리</title>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "Salesreps.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function search() {
  goPage(1);
}
function edit(obj) {
  var mid = $(obj).parent().parent().attr("mid");
  document.frmSearch.mid.value = mid;
  document.frmSearch.action = "SalesrepReg.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function drop(obj) {
  var mid = $(obj).parent().parent().attr("mid");
  document.frmSearch.mid.value = mid;
  showCustomConfirm("정말 삭제하시겠습니까?", function() {
    $.post("./SalesrepDropProc.jsp", $("form[name='frmSearch']").serialize(), function(data) {
      console.log(data);
      if (data=="0") {
        $("#target-list>tbody>tr").each(function(index, item) {
          if ($(item).attr("mid")==mid) $(item).remove();
        });
      }
    });
  }, function() {});
}
$(document).ready(function(){
  $("input[name='nm']").keydown(function(key) {
    if (key.keyCode == 13) search();
  });
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
}); 
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>영업담당자관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a href='SalesrepReg.jsp' class='btn'>신규등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='mid'  value=''>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>담당자명</label>
          <input type='text' name='nm' value='<%=pvo.NM %>' placeholder='담당자명'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:search();'></td>
  </tr>
</tbody>
</table>
</form>

<table id='target-list' class='list detail'>
  <colgroup>
    <col width='20%' />
    <col width='20%' />
    <col width='20%' />
    <col width='20%' />
    <col width='*' />
  </colgroup>
  <thead>
    <tr>
      <th class='left'>담당자</th>
      <th class='left'>연락처</th>
      <th class='left mobile_hide'>웹 팩스(팩스)</th>
      <th class='left'>이메일</th>
      <th class='center'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i< arr.size();) {
	SalesrepVO v = arr.remove(i); 
    intTotalCnt = v.TOTAL_CNT;
    String strSalesrepId = IntegerCryptoUtil.crypt(v.SALESREP_ID);
%>
    <tr mid='<%=strSalesrepId %>'>
      <td><%=StrUtil.nvl(v.NM) %></td>
      <td class='left'><a href='tel:<%= StrUtil.nvl(v.PHONE_NO) %>'><%= StrUtil.nvl(v.PHONE_NO) %></a></td>
      <td class='left mobile_hide'><%= StrUtil.nvl(v.FAX_NO) %></td>
      <td class='left'><a href='mailto:<%= StrUtil.nvl(v.EMAIL)%>'><%= StrUtil.nvl(v.EMAIL) %></a></td>
      <td class='center'><a onclick='edit(this);' class='btn lurian'>수정</a> <a onclick='drop(this);' class='btn darkred'>삭제</a></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='5' class='noentry'>등록된 영업담당자가 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>


<%@ include file="../Footer.jsp" %>