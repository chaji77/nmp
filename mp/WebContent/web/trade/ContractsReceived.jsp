<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;
String strPrsId       = (String)pageContext.getAttribute("PRS_ID");

String strPageTitle   = "받은 계약서";
String strPageCode    = "R";
String strDetailPage  = "Contract.jsp";

String strPage        = StrUtil.nvl(request.getParameter("page"), "1");
String strStatus      = StrUtil.nvl(request.getParameter("status"), "000");
String strStartYmd    = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd      = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
String strTargetCpyId = StrUtil.nvl(request.getParameter("tc"), "0");
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>
<script>
function toggleAllCheckContracts() {
  var isChecked = $("input[name='AllCheckContracts']").is(":checked");
  $('#contract_list').find('input[name="seq"]').prop("checked", isChecked);
}
function cancelSelected() {
  var seqs = $('#contract_list').find('input[name="seq"]:checked').map(function() {
    return $(this).val();
  }).get();
  if (seqs.length == 0) {
    toast("선택된 매매계약서가 없습니다.");
    return;
  }
  showCustomConfirm("선택한 " + seqs.length + "건을 취소하시겠습니까?", function() {
    var done = 0;
    $.each(seqs, function(idx, seq) {
      $.post("ContractCancelProc.jsp", { seq: seq }, function() {
        done++;
        if (done === seqs.length) {
          showAlert("취소되었습니다.", function() { location.reload(true); });
        }
      });
    });
  }, function() {});
}
</script>


<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <a onclick='document.frmToExcel.submit();' class='btn white' title='excel download'><i class="fa-solid fa-download"></i>엑셀다운로드</a>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<jsp:include page="Contracts.jsp">
  <jsp:param name="cpy_id" value="<%=strCpyId %>" />
  <jsp:param name="prs_id" value="<%=strPrsId %>" />
  <jsp:param name="page_code" value="<%=strPageCode %>" />
  <jsp:param name="page" value="<%=strPage %>" />
  <jsp:param name="status" value="<%=strStatus %>" />
  <jsp:param name="start_ymd" value="<%=strStartYmd %>" />
  <jsp:param name="end_ymd" value="<%=strEndYmd %>" />
  <jsp:param name="tc" value="<%=strTargetCpyId %>" />
  <jsp:param name="detail_page" value="<%=strDetailPage %>" />
</jsp:include>

<!-- for excel download -->
<form name='frmToExcel' method='post' action='ContractsForExcel.jsp' target='FrameForExcel'>
  <input type='hidden' name="cpy_id" value="<%=strCpyId %>" />
  <input type='hidden' name="prs_id" value="<%=strPrsId %>" />
  <input type='hidden' name="page_code" value="<%=strPageCode %>" />
  <input type='hidden' name="page" value="<%=strPage %>" />
  <input type='hidden' name="status" value="<%=strStatus %>" />
  <input type='hidden' name="start_ymd" value="<%=strStartYmd %>" />
  <input type='hidden' name="end_ymd" value="<%=strEndYmd %>" />
  <input type='hidden' name="tc" value="<%=strTargetCpyId %>" />
  <input type='hidden' name="detail_page" value="<%=strDetailPage %>" />
</form>
<iframe name='FrameForExcel' id='FrameForExcel' style="display: none;"></iframe>
<!-- // for excel download -->

<%@ include file="../includes/Footer.jsp" %>
