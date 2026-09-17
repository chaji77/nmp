<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
if (strUserSeq.equals("0")) {
  response.sendRedirect("index.jsp");
  return;
}
String strCpyId = (String)session.getAttribute("SESS_BILL_CPY_ID");
int    intPage  = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intTotalCnt = 0;
ArrayList<InvoiceVO> arr = InvoiceDAO.BILL_STANDBY_PROC(intPage, Integer.parseInt(strCpyId));
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<style>
div.control_bar {margin-bottom:10px;}

</style>
<title>발행신청관리-처음빌</title>
<script>
function goPage(page) {
  document.frmSearch.page.value = page;
  document.frmSearch.target = "_self";
  document.frmSearch.submit();
}
function view(seq) {
  window.open('InvoiceView.jsp?seq='+seq,'invoice','width=1280,height=600,left=50,top=50,scrollbars=no,resizable=no');
}
function getCountChecked() {
  var cnt = $(".billseq:checked").length;
  if (cnt == 0) {
    toast("선택된 항목이 없습니다.");
    return false;
  } else return true;
}

function cancel() {
  if (getCountChecked()) {
    showCustomConfirm("정말 삭제하시겠습니까?", function() {
        showLoading();
        document.frmEnt.target = "work";
        document.frmEnt.action = "TaxCancelProc.jsp";
        document.frmEnt.method = "post";
        document.frmEnt.submit();
    }, function() {});
  }
}

function publish() {
  if (getCountChecked()) {
    showCustomConfirm("발행을 시작합니다.", function() {
        showSpinner("발행하고 있습니다.");
        document.frmEnt.target = "work";
        document.frmEnt.action = "TaxPublishProc.jsp";
        document.frmEnt.method = "post";
        document.frmEnt.submit();
    }, function() {});
  }
}

function toggleCheckAll() {
  var isChecked = false;
  if ($("#checkall").is(":checked")) isChecked = true;
  $(".billseq").each(function(index, item) {
    this.checked = isChecked;
  });
}
</script>
<!-- // page head block -->
<%@ include file="Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>발행신청관리</span>
  <span class='more'>
  </span>
</div>

  <form name='frmSearch' method='post'>
  <input type='hidden' name='page' value='<%=intPage %>'>
  </form>

  <div class='control_bar'>
    <a href='javascript:publish();' class='btn'>발행</a>
    <a href='javascript:cancel();' class='btn darkorange'>삭제</a>
  </div>

  <form name='frmEnt'>
  <table class='list'>
    <thead>
      <tr>
        <th class='left'><input type='checkbox' id='checkall' onClick="toggleCheckAll();"></th>
        <th class='left'>발행번호</th>
        <th class='left'>진행상태</th>
        <th>작성일</th>
        <th class='left'>계산서종류</th>
        <th>과세구분</th>
        <th>청구/영수</th>
        <th class='left'>공급받는자</th>
        <th>사업자번호</th>
        <th class='right'>공급가액</th>
        <th class='right'>세액</th>
        <th class='right'>합계금액</th>
        <th class='left'>비고</th>
        <th class='left'>명령</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    intTotalCnt = vo.TCNT;
    boolean isCapablePublish = (Integer.parseInt(vo.strWriteDate) > Integer.parseInt(DateTimeUtil.getCurrentDate(""))) ? false : true;
%>
      <tr>
        <td class='left'>
          <% if (isCapablePublish) { %>
          <input type='checkbox' name='billseq' class='billseq' value='<%=vo.BILL_SEQ %>'>
          <% } %>
        </td>
        <td><a href='javascript:view(<%=vo.BILL_SEQ %>);'><b><%=vo.strSerialNum %></b></a></td>
        <td><%=InvoiceUtil.getStatus(vo) %></td>
        <td class='center'><%=FormatUtil.addSeparatorDate(vo.strWriteDate) %></td>
        <td><%=InvoiceUtil.getInvoiceType(vo) %></td>
        <td class='center'><%=InvoiceUtil.getChargeType(vo) %></td>
        <td class='center'><%=InvoiceUtil.getPurposeType(vo) %></td>
        <!-- td><%=InvoiceUtil.getTaxType(vo)  %></td -->
        <td><%=vo.strToCorpNm        %></td>
        <td class='center'><%=InvoiceUtil.getBizNo(vo.strToBizNo)         %></td>
        <td class='right'><%=StrUtil.addComma(vo.strAmountTotal) %></td>
        <td class='right'><%=StrUtil.addComma(vo.strTaxTotal)    %></td>
        <td class='right'><%=StrUtil.addComma(vo.strTotalAmount) %></td>
        <td class='left'><%=StrUtil.nvl(vo.strRemark)            %></td>
        <td><a href='InvoiceWrite.jsp?seq=<%=vo.BILL_SEQ %>' class='btn'>수정</a></td>
      </tr>
<%
  }
} else {
%>
      <tr>
        <td colspan='14' class='noentry'></td>
      </tr>
<%
}
%>
    </tbody>
  </table>
  </form>

  <div id="paging">
    <script>
    getPaging('goPage',<%=intPage%>,<%=intTotalCnt%>,20,10,'');
    </script>
  </div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
    
<%@ include file="../web/includes/Footer.jsp" %>