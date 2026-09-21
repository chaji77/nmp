<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
int intPage =  Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intTotalCnt = 0;
String strWriteDate = StrUtil.nvl(request.getParameter("wd"), "");
String strInvoiceeCorpNum = StrUtil.nvl(request.getParameter("cn"), "");
String strCorpName = StrUtil.nvl(request.getParameter("strCorpNm"), "");

String strEmpId = "0";
ArrayList<InvoiceVO> arr = new InvoiceDAO().T_BILL_STANDBY_PROC(strSenderKey, intPage, strWriteDate.replaceAll("/", ""), strInvoiceeCorpNum.replaceAll("-", ""), strEmpId, strCorpName);

%>
<%@ include file="../Header.jsp" %>
<title>계산서발행신청관리</title>

<!-- for calendar -->
<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<script>
$(function() {
  $( ".datepicker").datepicker({changeYear:true,changeMonth:true,dateFormat:"yy/mm/dd"});
  $("input[type='text']").keydown(function(e) {
      if (e.keyCode == 13) {
        goPage(1);
      }
  });
  $(document).on("change", ".billseq", updateSumAmount);
  updateSumAmount();
});
</script>

<style>
.control_bar {text-align:left;padding:0 0 15px 0;}
</style>
<script>
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
  updateSumAmount();
}

function updateSumAmount() {
  var all = $(".billseq");
  var checked = $(".billseq:checked");
  var useAll = checked.length == 0 || checked.length == all.length;
  var target = useAll ? all : checked;
  var sum = 0;
  target.each(function(index, item) {
    sum += Number($(item).data("amt")) || 0;
  });
  $("#sumAmountLabel").text(useAll ? "합계금액" : "선택항목 합계금액");
  $("#sumAmount").text(sum.toLocaleString());
}

function goPage(page) {
  document.frmSearch.page.value = page;
  document.frmSearch.target = "_self";
  document.frmSearch.submit();
}

function view(seq) {
  window.open('InvoiceView.jsp?seq='+seq,'invoice','width=850,height=600,left=100,top=100,scrollbars=no,resizable=no');
}

function getContract(seq) {
  document.frmSearch.seq.value = seq;
  document.frmSearch.target = "_contract";
  document.frmSearch.action = "../trade/Contract.jsp";
  document.frmSearch.method = "post";
  document.frmSearch.submit();
}
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>계산서발행신청관리</span>
  <span class='more'>
    <a class='btn' href='Invoice.jsp'>수기발행</a>
    <a onclick='document.frmToExcel.submit();' class='btn white' title='excel download'><i class="fa-solid fa-download"></i>엑셀다운로드</a>
  </span>
</div>

  <form name='frmSearch' method='post'>
  <input type='hidden' name='page' value='<%=intPage %>'>
  <input type='hidden' name='senderKey' value='<%=strSenderKey%>'>
<%--   <input type='hidden' name='wd' class='datepicker' value='<%=strWriteDate%>'>
  <input type='hidden' name='cn' value='<%=strInvoiceeCorpNum%>'> --%>
  <input type='hidden' name='seq'>
  <table class="list searchbox mobile_hide">
	<tbody>
	  <tr>
	    <td>
	      <ul>
	        <li>
	          <label>회사명</label>
	          <input type='text' name='strCorpNm' value='<%=strCorpName%>' placeholder="회사명">
	        </li>
	        <li>
	          <label>사업자번호</label>
	          <input type='text' name='cn' value='<%=strInvoiceeCorpNum%>' placeholder="사업자번호">
	        </li>
	      </ul>
	    </td>
	    <td class='fill'></td>
	    <td class='btn' style='text-align:right;'>
	      <a onclick="goPage(1);">
	        <i class="fa fa-search" aria-hidden="true" style="font-size:1.7em;margin-right:10px;"></i>
	      </a>
	    </td>
	  </tr>
	</tbody>
  </table>
  </form>
  
  <div class='control_bar'>
    <a href='javascript:publish();' class='btn'>발행</a>
    <a href='javascript:cancel();' class='btn darkorange'>삭제</a>
    <span style='float:right;font-weight:bold;'><span id='sumAmountLabel'>합계금액</span>: <span id='sumAmount'>0</span>원</span>
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
        <th class='left'>신청자</th>
        <th>매매계약서</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    intTotalCnt = vo.TCNT;
%>
      <tr>
        <td class='left'>
          <input type='checkbox' name='billseq' class='billseq' value='<%=vo.BILL_SEQ %>' data-amt='<%=vo.strTotalAmount %>'>
        </td>
        <td><a href='javascript:view(<%=vo.BILL_SEQ %>);'><b><%=vo.BILL_SENDER_KEY %><%=vo.BILL_SEQ %></b></a></td>
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
        <td class='left'><%=StrUtil.nvl(vo.EMP_NM)             %></td>
        <td class='center'>
          <% if (!vo.CTIDS.equals("0")) { %>
          <a href='javascript:getContract(<%=vo.CTIDS%>);' class='btn'>보기</a>
          <% } %>
        </td>
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
<iframe id='ifmContract'></iframe>
<form name='frmToExcel' method='post' action='TaxRequestListForExcel.jsp' target='FrameForExcel'>
  <input type='hidden' name="strSenderKey" value="<%=strSenderKey %>" />
  <input type='hidden' name="strWriteDate" value="<%=strWriteDate %>" />
  <input type='hidden' name="strInvoiceeCorpNum" value="<%=strInvoiceeCorpNum %>" />
</form>
<iframe name='FrameForExcel' id='FrameForExcel' style="display: none;"></iframe>
<%@ include file="../Footer.jsp" %>