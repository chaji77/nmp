<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

int intTotalCnt = 0;
MemoVO pvo  = new MemoVO();
pvo.PAGE    = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT = 20;
pvo.CPY_ID  = intCpyId;

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("ACTIVE_MANAGEMENT.ACTIVE_KIND");
ArrayList<MemoVO> arr = new MemoBean().ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC(pvo);

String loggedInManager = (String)session.getAttribute("SESS_LOGIN_ID");
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>메모(상담)</title>
<style>
table.detail td {vertical-align:top;}
span.to {color:darkgreen;font-weight:bold;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "MemosPerCustomer.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function editMemo(intCpyId, intActiveId) {
  closePopup();
  //$("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/mgr/memo/MemoReg.jsp?cid='+intCpyId+'&aid='+intActiveId});
  var strUrl = strContextPath+'/mgr/memo/MemoReg.jsp?cid='+intCpyId+'&aid='+intActiveId;
  window.open(strUrl, "_memo_", 'width=500,height=900,scrollbars=yes,resizable=no');
}
function dropMemo(aid) {
  showCustomConfirm("삭제하시겠습니까?", function() {
    $.post(strContextPath + "/mgr/memo/MemoDropProc.jsp", {'aid':aid}, function(data) {
      if (data!="0") {
        toast("삭제하였습니다.", 1000, function() {
          window.location.reload();
        });
      } else {
        toast("삭제하지 못했습니다. 잠시 후 다시 시도하십시오.");
      }
    });
  }, function() {});
}

$(document).ready(function(){
<%
if (arr!=null && arr.size()>0) {
  for (MemoVO t : arr) {
    if (t.COMMENT_YN.equals("Y")) {
%>
  loadComments(<%=t.ACTIVE_ID %>, 2);
<%
    }
  }
}
%>
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
</form>

<div class='page-title-block memo-page'>
  <span class='title'>메모(상담)</span>
  <span class='more'>
    <a onclick='getMemoWindow(<%=intCpyId %>);' class='btn'>등록</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="5" />
</jsp:include>


<table class='detail'>
  <thead>
    <tr>
      <th class='left mobile_hide'>분류</th>
      <th class='left mobile_hide'>구분</th>
      <th class='left'>내용</th>
      <th class='left mobile_hide'>작성자</th>
      <th class='mobile_hide'>작성일시</th>
      <th style='width:10%;'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  String strCodeName = "";
  for (MemoVO t : arr) {
    intTotalCnt = t.TOTAL_CNT;
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO c : arrCodes) {
        if (c.CODE_CD.trim().equals(t.ACTIVE_KIND.trim())) strCodeName = c.CODE_NM;
      }
    }
    String strDesc = HtmlWhiteListUtil.filter(t.ACTIVE_DESC).replaceAll("&quot;", "");
    String toUser  = StrUtil.nvl(t.TO_USER_NM, "");
    if (!toUser.equals("")) toUser = "<span class='to'><i class='fa-solid fa-location-dot'></i> "+toUser+"</span> ";
%>
    <tr id='memo_row_<%=t.ACTIVE_ID %>'>
      <td class='mobile_hide'><%=strCodeName %></td>
      <td class='mobile_hide'><%=t.CALL_TYPE.equals("1")?"IN":"OUT" %></td>
      <td style='white-space:wrap;'><div class='mobile_show'><%=strCodeName %><br/><%=t.USER_NM  %> (<%=t.WRITE_DATE.substring(0, 16) %>)<br/></div><%=toUser%><%=strDesc %></td>
      <td class='mobile_hide'><%=t.USER_NM  %></td>
      <td class='center mobile_hide'><%=t.WRITE_DATE.substring(0, 16) %></td>
      <td class='center'>
      <a onclick='addComment(<%=t.ACTIVE_ID %>);' class='btn'>댓글추가</a>
<% if (loggedInManager.equals(t.WRITE_ID)) { %>
      <a onclick='editMemo(<%=intCpyId %>, <%=t.ACTIVE_ID %>)' class='btn lurian'>수정</a> <a onclick='dropMemo(<%=t.ACTIVE_ID %>);' class='btn darkred'>삭제</a>
<% } %>
      </td>
    </tr>
<%
  }
}
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>