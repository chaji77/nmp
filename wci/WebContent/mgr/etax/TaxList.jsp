<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ page import="com.baroservice.ws.ArrayOfString" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
int intPage =  Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intTotalCnt = 0;
String strWriteDate = StrUtil.nvl(request.getParameter("wd"), "");
String strInvoiceeCorpNum = StrUtil.nvl(request.getParameter("cn"), "");
int intStatus = 1;

InvoiceDAO dao = new InvoiceDAO();
String strEmpId = "0";
ArrayList<InvoiceVO> arr = dao.T_BILL_LIST_PROC(strSenderKey, intPage, strWriteDate.replaceAll("/", ""), strInvoiceeCorpNum.replaceAll("-", ""), intStatus, strEmpId);
ArrayList<InvoiceVO> arrStandBy = dao.T_BILL_STATUS_PROC(strSenderKey);
int intStandBy = (arrStandBy!=null) ? arrStandBy.size() : 0;
%>
<%@ include file="../Header.jsp" %>
<title>세금계산서관리</title>

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
});
</script>

<style>
.control_bar {text-align:left;width:calc(100% - 40px);padding:15px 0 10px 0;border-top:1px solid #eee;}
</style>
<script>
function getCountChecked() {
  var cnt = $(".billseq:checked").length;
  if (cnt == 0) {
    toast("선택된 항목이 없습니다.");
    return false;
  } else return true;
}

function toggleCheckAll() {
  var isChecked = false;
  if ($("#checkall").is(":checked")) isChecked = true;
  $(".billseq").each(function(index, item) {
    this.checked = isChecked;
  });
}

function goPage(page) {
  document.frmSearch.page.value = page;
  document.frmSearch.target = "_self";
  document.frmSearch.submit();
}

function view(seq) {
  window.open('InvoiceView.jsp?seq='+seq,'invoice','width=850,height=600,left=100,top=100,scrollbars=no,resizable=no');
}

function showErrMsg(ecode) {
  toast("오류내용을 조회하고 있습니다.", 50000);
  $.ajax({
    type:"POST",
    url:"GetErrString.jsp",
    data:{"e":ecode},
    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    success:function(r) {
      r = $.trim(r);
      removePopupMessage();
      alert(r);
    },
    error:function(a,b,c){
      toast("오류가 발생했습니다. 잠시 후 다시 시도하십시오. 문제가 지속되면 관리자에게 문의바랍니다.")
    }
  });
}

function repub(seq) {
  $.ajax({
    type:"POST",
    url:"TaxReWriteProc.jsp",
    data:{"seq":seq},
    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    success:function(r) {
      r = $.trim(r);
      console.log(r);
      send(r);
    },
    error:function(a,b,c){
      toast("오류가 발생했습니다. 잠시 후 다시 시도하십시오. 문제가 지속되면 관리자에게 문의바랍니다.")
    }
  });
}

function send(seq) {
  showLoading();
  document.frmEnt.billseq.value = seq;
  document.frmEnt.target = "work";
  document.frmEnt.action = "TaxPublishProc.jsp";
  document.frmEnt.method = "post";
  document.frmEnt.submit();
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
  <span class='title'>세금계산서관리</span>
  <span class='more'>
    <a class='btn' href='Invoice.jsp'>수기발행</a>
    <a href='<%=request.getContextPath()%>/mgr/etax/' class='btn'>연동관리</a>
  </span>
</div>

  <form name='frmSearch' method='post'>
  <input type='hidden' name='page' value='<%=intPage %>'>
  <input type='hidden' name='senderKey' value='<%=strSenderKey%>'>
  <input type='hidden' name='seq'>
  <table class="list searchbox mobile_hide">
    <tbody>
      <tr>
        <td>
          <ul>
            <li>
              <label>작성일</label>
              <input type='text' name='wd' class='datepicker' value='<%=strWriteDate%>'>
            </li>
            <li>
               <label>사업자번호</label>
              <input type='text' name='cn' value='<%=strInvoiceeCorpNum%>' placeholder="사업자번호">
            </li>
          </ul>
        </td>
        <td class='fill'></td>
        <td class='btn' style='text-align:right;'><a onclick="goPage(1);"><i class="fa fa-search" aria-hidden="true" style="font-size:1.7em;margin-right:10px;"></i></a></td>
      </tr>
    </tbody>
  </table>
  </form>

  <div style='text-align:right;padding-bottom:10px;'>
  미완료건 : <%=intStandBy %>
  </div>

  <table class='list'>
    <thead>
      <tr>
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
        <th class='center'>매매계약서</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    intTotalCnt = vo.TCNT;
%>
      <tr>
        <td><a href='javascript:view(<%=vo.BILL_SEQ %>);'><b><%=vo.BILL_SENDER_KEY %><%=vo.BILL_SEQ %></b></a></td>
        <td>
           <%=InvoiceUtil.getStatus(vo) %>
           <%
           if (vo.BILL_STATUS<0) {
             out.print("<a href='javascript:showErrMsg("+Integer.toString(vo.BILL_STATUS)+");' class='btn darkred' style='border-radius:30px;'>?</a> ");
             // out.print("<a href='javascript:repub("+vo.BILL_SEQ+");' class='btn'>재발행</a>");
           }
           %>
        </td>
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
        <td colspan='15' class='noentry'></td>
      </tr>
<%
}
%>
    </tbody>
  </table>

  <div id="paging">
    <script>
    getPaging('goPage',<%=intPage%>,<%=intTotalCnt%>,20,10,'');
    </script>
  </div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>