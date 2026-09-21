<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoVO" %>
<%@ page import="kr.co.mp.mgr.sales.SalesMemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

int intTotalCnt = 0;
SalesMemoVO pvo = new SalesMemoVO();
pvo.PAGE    = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT = 20;
pvo.CPY_ID  = intCpyId;

ArrayList<SalesMemoVO> arr = new SalesMemoBean().SALES_MEMO_LIST_PER_CPY_ID_PROC(pvo);

String loggedInManager = (String)session.getAttribute("SESS_LOGIN_ID");

boolean isPopup = "1".equals(request.getParameter("popup"));
%>
<% if (!isPopup) { %>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>영업 메모</title>
<% } %>
<style>
table.detail td {vertical-align:top;}
<% if (isPopup) { %>
#element_to_pop_up table.detail, #element_to_pop_up table.detail th, #element_to_pop_up table.detail td {font-size:15px;}
<% } %>
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "SalesMemosPerCustomer.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
var memoContents = {};
<%
if (arr!=null && arr.size()>0) {
  Gson gson = new Gson();
  for (SalesMemoVO t : arr) {
%>
memoContents[<%=t.MEMO_ID%>] = <%=gson.toJson(t.CONTENTS)%>;
<%
  }
}
%>
function getMemoRegPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'SalesMemoReg.jsp?cid=<%=intCpyId%>'});
}
function editMemo(memoId) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'SalesMemoReg.jsp?cid=<%=intCpyId%>&mid='+memoId});
}
function deleteMemo(memoId) {
  showCustomConfirm("삭제하시겠습니까?", function() {
    $.post("SalesMemoDropProc.jsp", {'mid':memoId}, function(data) {
      if (data>0) {
<% if (isPopup) { %>
        $("#element_to_pop_up").load("<%=request.getContextPath()%>/mgr/sales/SalesMemoPerCustomer.jsp?cpy_id=<%=strCpyId%>&popup=1");
<% } else { %>
        location.reload(true);
<% } %>
      } else {
        toast("삭제하지 못했습니다. 잠시 후 다시 시도하십시오.");
      }
    });
  }, function() {});
}
<% if (isPopup) { %>
function sizeMemoListPopup() {
  $("#element_to_pop_up").css({width:"40vw", "max-height":"80vh", "overflow-y":"auto"});
  $(window).trigger("resize");
}
sizeMemoListPopup();
setTimeout(sizeMemoListPopup, 300);
<% } %>
</script>

<% if (!isPopup) { %>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>
<% } %>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
</form>

<div class='page-title-block memo-page'>
  <span class='title'>영업 메모</span>
<% if (!isPopup) { %>
  <span class='more'>
    <a onclick='getMemoRegPage();' class='btn lurian'>등록</a>
  </span>
<% } %>
</div>

<% if (isPopup) { %>
<ul class='category'>
  <li class='category' onclick="$('#element_to_pop_up').load('<%=request.getContextPath()%>/mgr/sales/SalesInformation.jsp?cpy_id=<%=strCpyId%>&popup=1');">추가정보</li>
  <li class='category selected' style='color:#007bff; background-color:#f8f9fa;'>영업메모</li>
</ul>
<% } else { %>
<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="10" />
</jsp:include>
<% } %>

<% if (isPopup) { %>
<div style='text-align:right;margin-bottom:8px;'>
  <a onclick='getMemoRegPage();' class='btn' style='font-size:15px;'>등록</a>
</div>
<% } %>

<% if (isPopup) { %>
<div style='max-height:45vh;overflow-y:auto;'>
<% } %>
<table class='detail'>
  <thead>
    <tr>
      <th class='left mobile_hide' style='width:10%;<%=isPopup?"position:sticky;top:0;background:#fafafa;":"" %>'>작성자</th>
      <th class='left' style='width:70%;<%=isPopup?"position:sticky;top:0;background:#fafafa;":"" %>'>내용</th>
      <th class='mobile_hide' style='width:10%;<%=isPopup?"position:sticky;top:0;background:#fafafa;":"" %>'>작성일시</th>
      <th class='left' style='width:10%;<%=isPopup?"position:sticky;top:0;background:#fafafa;":"" %>'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (SalesMemoVO t : arr) {
    intTotalCnt = t.TOTAL_CNT;
    String strContents = HtmlWhiteListUtil.filter(t.CONTENTS).replaceAll("&quot;", "");
%>
    <tr id='memo_row_<%=t.MEMO_ID %>'>
      <td class='mobile_hide'><%=t.USER_NM %></td>
      <td style='white-space:wrap;'><div class='mobile_show'><%=t.USER_NM %> (<%=t.WRITE_DATE.substring(0, 16) %>)<br/></div><%=strContents %></td>
      <td class='center mobile_hide'><%=t.WRITE_DATE.substring(0, 16) %></td>
      <td class='center'>
<% if (loggedInManager!=null && loggedInManager.equals(t.WRITE_ID)) { %>
        <a href="javascript:void(0);" onclick="editMemo(<%=t.MEMO_ID%>);" class='btn lurian'>수정</a>
        <a href="javascript:void(0);" onclick="deleteMemo(<%=t.MEMO_ID%>);" class='btn darkred'>삭제</a>
<% } %>
      </td>
    </tr>
<%
  }
}
%>
  </tbody>
</table>
<% if (isPopup) { %>
</div>
<% } %>

<% if (!isPopup) { %>
<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>
<% } %>

<% if (!isPopup) { %>
<%@ include file="../Footer.jsp" %>
<% } else { %>
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
<% } %>
