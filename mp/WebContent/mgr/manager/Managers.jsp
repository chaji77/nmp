<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

ManagerVO pvo = new ManagerVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
pvo.USER_NM = StrUtil.xss(request.getParameter("nm"));
ArrayList<ManagerVO> arr = new ManagerBean().M_MANAGER_LIST_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>관리자관리</title>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "Managers.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function search() {
  goPage(1);
}
function edit(obj) {
  var mid = $(obj).parent().parent().attr("mid");
  document.frmSearch.mid.value = mid;
  document.frmSearch.action = "ManagerReg.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function drop(obj) {
  var mid = $(obj).parent().parent().attr("mid");
  document.frmSearch.mid.value = mid;
  showCustomConfirm("정말 삭제하시겠습니까?", function() {
    $.post("./ManagerDropProc.jsp", $("form[name='frmSearch']").serialize(), function(data) {
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
  <span class='title'>관리자관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a href='ManagerReg.jsp' class='btn'>신규등록</a>
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
          <label>성명</label>
          <input type='text' name='nm' value='<%=pvo.USER_NM %>' placeholder='성명'>
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
    <col width='27%' />
    <col width='27%' />
    <col width='27%' />
    <col width='*' />
  </colgroup>
  <thead>
    <tr>
      <th class='left'>성명</th>
      <th class='left'>아이디</th>
      <th class='left mobile_hide'>등록자</th>
      <th class='center'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i< arr.size();) {
    ManagerVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
    String strManagerId = IntegerCryptoUtil.crypt(v.MAN_ID);
%>
    <tr mid='<%=strManagerId %>'>
      <td><%=StrUtil.nvl(v.USER_NM) %></td>
      <td><%=StrUtil.nvl(v.LOGIN_ID) %></td>
      <td class='mobile_hide'><%=StrUtil.nvl(v.REG_NM) %></td>
      <td class='center'><a onclick='edit(this);' class='btn lurian'>수정</a> <a onclick='drop(this);' class='btn darkred'>삭제</a></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='4' class='noentry'>등록된 관리자가 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>


<%@ include file="../Footer.jsp" %>