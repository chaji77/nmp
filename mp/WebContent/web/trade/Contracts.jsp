<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.trade.UnusualTransactionVO" %>
<%
request.setCharacterEncoding("utf-8");

int intCpyId       = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id")));
int intPrsId       = Integer.parseInt(StrUtil.nvl(request.getParameter("prs_id")));
String strPageCode = StrUtil.nvl(request.getParameter("page_code"));
String strDetail   = StrUtil.nvl(request.getParameter("detail_page"), "Contract.jsp");
String strTempYn   = StrUtil.nvl(request.getParameter("tmpyn"), "N");

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, intPrsId); // 내거래처

CtHeaderVO pvo     = new CtHeaderVO();
pvo.PAGE           = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT        = 20;
pvo.STATUS         = StrUtil.nvl(request.getParameter("status"), "");
pvo.CTNO           = StrUtil.nvl(request.getParameter("ctno"), "");
pvo.SBDATE         = StrUtil.nvl(request.getParameter("sbdate"), "R");
String strStartYmd = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
int intTargetCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("tc"), "0"));
int intTotalCnt    = 0;

//MATURITY COMING
String strMaturityYN = StrUtil.nvl(request.getParameter("maturity_yn"), "N");

TradeBean bean = new TradeBean();
ArrayList<CtHeaderVO> arr;
ArrayList<UnusualTransactionVO> arrUnusuals = null;
try {
  if (!strMaturityYN.equals("Y")) arr = bean.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, intTargetCpyId, strPageCode, intPrsId);
  else arr = bean.CT_HEADER_COMING_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;

  String strCtIds = "";
  for (CtHeaderVO v : arr) {
    strCtIds += ","+v.CTID;
  }
  if (strCtIds.length()>1) {
    strCtIds = strCtIds.substring(1);
    arrUnusuals = bean.UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(strCtIds, "N");
  }

} catch (Exception e) {
  arr = null;
}

String strCurrentPage = (request.getRequestURL()).toString();
System.out.println(strCurrentPage);
// CONFIRM_SETTLE_YN
boolean hasConfirmSettleYn = false;
if (strCurrentPage.contains("ContractsSent.jsp") && arr!=null && arr.size()>0) {
  for (CtHeaderVO v : arr) {
    if (v.STATUS.equals("025")) {
      hasConfirmSettleYn = true;
      break;
    }
  }
}
// RECEIVED LIST : ALLOW SELECT-CANCEL FOR PENDING(020) ROWS ONLY
boolean isReceivedCancelable = strPageCode.equals("R");
// COLUM COUNT
int intColumnCnt   = 10; // (strTempYn.equals("Y") || hasConfirmSettleYn) ? 10 : 9;
long lngTotalSettleAmt = 0;
if (arr!=null) {
  for (CtHeaderVO v : arr) {
    lngTotalSettleAmt += Long.parseLong(StrUtil.nvl(v.TOTALCONTRACTAMT, "0"));
  }
}
String strTotalSettleAmt = String.valueOf(lngTotalSettleAmt);
%>

<style>
table.searchbox td {padding:20px;}
.searchbox label {width:60px;}
ul.exp {display:flex;flex-flow:row wrap;justify-content:left;margin:20px 0;padding:10px;border:1px solid #ddd;color:#888;}
ul.exp>li {padding:10px;}
ul.exp>li>ul>li {padding:3px 0;}
ul.exp>li>ul>li>strong {color:#000;}
td.unusual {color:darkred;}
td.unusual a {font-weight:bold;color:red;border-bottom:1px solid #f00;}
@media only screen and (max-width:767px) {
  table.searchbox td {padding:5px;}
}
</style>

<script>
function goDetail(r, status, cttype, seller) {
  if (status=="010" && cttype=="S" && "<%=intCpyId%>"==seller) { // EDIT PAGE FOR SELL CONTRACT
    location.href = "ContractRegForSeller.jsp?seq=" + r;
    return;
  }
  if (status=="020" && cttype=="S" && "<%=intCpyId%>"!=seller) { // CONFIRM PAGE FOR SELL CONTRACT
    location.href = "ContractReg.jsp?seq=" + r;
    return;
  }
  location.href = "<%=strDetail%>?seq="+r;
}
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.submit();
}
function goGenuineTradeConfirm(seq) {
  document.frmSearch.seq.value = seq;
  document.frmSearch.action = "GenuineTradeConfirm.jsp";
  document.frmSearch.submit();
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
  <% if (strTempYn.equals("Y")) { %>
  $(document).on('change', "#contract_list input[name='seq'], input[name='AllCheckContracts']", updateCheckedTotal);
  updateCheckedTotal();
  <% } %>
});
<% if (strTempYn.equals("Y")) { %>
function updateCheckedTotal() {
  var sum = 0;
  $("#contract_list input[name='seq']:checked").each(function() {
    sum += parseInt($(this).data("amt")) || 0;
  });
  $("#totalSettleAmtValue").text(addComma(sum));
}
<% } %>
</script>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='seq' value='0'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>검색기간</label>
          <input type='date' name='start_ymd' value='<%=strStartYmd %>' style='width:85px;'>
          <input type='date' name='end_ymd' value='<%=strEndYmd %>' style='width:85px;'>
        </li>
        <li class='search-for-trade search-option-status'>
          <label>진행상태</label>
          <select name='status' onChange="goPage(1);">
            <option value="000">전체</option>
            <option value="020" <%=(pvo.STATUS.equals("020"))?"selected":""%>>승인대기</option>
            <option value="025" <%=(pvo.STATUS.equals("025"))?"selected":""%>>계약승인(결제대기)</option>
            <option value="040" <%=(pvo.STATUS.equals("040"))?"selected":""%>>계약승인(결제중)</option>
            <option value="060" <%=(pvo.STATUS.equals("060"))?"selected":""%>>결제완료</option>
            <option value="080" <%=(pvo.STATUS.equals("080"))?"selected":""%>>취소</option>
          </select>
        </li>
        <li class='search-for-trade'>
          <label>거래처</label>
          <select name='tc' onChange="goPage(1);">
          <option value="0">전체</option>
          <%
          if (arrMyCompanies!=null && arrMyCompanies.size()>0) {
            for (CompanyVO mcvo : arrMyCompanies) {
              out.println("<option value='"+mcvo.CPY_ID+"'"+((intTargetCpyId==mcvo.CPY_ID)?"selected":"")+">"+mcvo.CPY_NAME+" ("+mcvo.CPY_CEO_NAME+")</option>");
            }
          }
          %>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:goPage(1);'></td>
  </tr>
</tbody>
</table>
</form>

<ul class='exp'>
  <li class='mobile_hide'><i class="fa fa-commenting fa-5x" style="color:#246CEB;"></i></li>
  <li>
    <ul>
      <li><strong>승인대기</strong>는 구매기업이 전송한 매매계약서를 판매기업이 계약 승인하기 전 상태입니다.</li>
      <li><strong>계약승인(결제중)</strong>은 판매기업의 계약 승인 후 구매기업에서 인터넷뱅킹 결제를 진행 중인 상태입니다.</li>
      <li><strong>계약승인(결제대기)</strong>은 확인결제를 신청한 구매사의 매매계약서가 판매기업의 계약 승인으로 회신된 상태입니다. 일괄 전송을 하시려면 <a href='ContractsSent.jsp' style='color:blue'>보낸계약서</a>로 이동하십시오.</li>
    </ul>
  </li>
</ul>

<% if (!strMaturityYN.equals("Y")) { %>
<div style='margin-bottom:15px;text-align:right;'><strong><%=strTempYn.equals("Y")?"선택항목 결제총액":"현재 페이지 결제총액"%> : <font color='red' id='totalSettleAmtValue'><%=StrUtil.addComma(strTotalSettleAmt) %></font>원</strong></div>
<% } %>

<% if (strTempYn.equals("Y") || hasConfirmSettleYn) { %>
<div style='padding:10px 0;'><a href='javascript:sendMulti();' class='btn'>일괄전송</a>&nbsp;<a href='javascript:removeSelected();' class='btn'>삭제</a></div>
<% } else if (isReceivedCancelable) { %>
<div style='padding:10px 0;'><a href='javascript:cancelSelected();' class='btn'>선택취소</a></div>
<% } %>

<%=((strMaturityYN.equals("Y"))?"<div style='margin-bottom:15px;text-align:right;'>기간내 결제총액 : <font color='red'>" + StrUtil.addComma(strTotalSettleAmt) + "</font>원</div>":"")%>


<table class='detail clickable-tr'>
  <thead>
    <tr>
      <th class='left' style='width:10px;'><input type='checkbox' name='AllCheckContracts' value='Y' 
          <%=(!strTempYn.equals("Y") && !hasConfirmSettleYn && !isReceivedCancelable)?"disabled":"onclick='toggleAllCheckContracts();'"%>></th>
      <th class='left mobile_hide'>계약번호</th>
      <th class='left'>계약일<p class='mobile_show'><br/>거래일<br/>결제금액<br/>진행상태</p></th>
      <th class='left mobile_hide'>거래일</th>
      <th class='left mobile_hide'>만기일</th>
      <th class='left'>은행/결제수단<p class='mobile_show'><br/>계약번호<br/>구매기업<br/>판매기업</p></th>
      <th class='left mobile_hide'>구매기업</th>
      <th class='left mobile_hide'>판매기업</th>
      <th class='right mobile_hide'>결제금액</th>
      <th class='center mobile_hide'>진행상태</th>
    </tr>
  </thead>
  <tbody id='contract_list'>
<%
if (arr!=null && arr.size()>0) {
  for (CtHeaderVO vo : arr) {
    String strReplacedStatusName = vo.CODE_NM;
    String strUnusual   = "";
    if (arrUnusuals!=null && arrUnusuals.size()>0) {
        for (UnusualTransactionVO uvo : arrUnusuals) {
          if (uvo.CTID.equals(vo.CTID) && uvo.USE_YN.equals("N")) {
            strUnusual += "<i class='fa-solid fa-circle-exclamation'></i> " + "[<strong>" + StrUtil.nvl(uvo.CONTENT).replaceAll("<br/>", "") + "</strong>] 사유로 거래를 진행할 수 없습니다. ";
            if (uvo.SECTION.equals("KD001")) {
              strUnusual += "계속 진행하시려면 <a onclick='goGenuineTradeConfirm("+vo.CTID+")'>진성거래확약서를 제출</a>하십시오. 이미 제출하셨다면, 거래상대의 진성거래확약서 제출을 기다려 주십시오.<br/>";
            } else strUnusual += "<br/>";
          }
        }
      }
%>
    <tr>
      <% if ((strTempYn.equals("Y") && vo.STATUS.equals("010")) || (hasConfirmSettleYn && vo.STATUS.equals("025")) || (isReceivedCancelable && vo.STATUS.equals("020"))) { %>
      <td class='left'><input type='checkbox' name='seq' value='<%=vo.CTID%>' data-amt='<%=StrUtil.nvl(vo.TOTALCONTRACTAMT,"0")%>'></td>
      <% } else { %>
      <td class='left'></td>
      <% } %>
      <td class='left mobile_hide'   onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=StrUtil.nvl(vo.CTNO) %></td>
      <td class='left'               onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=FormatUtil.addSeparatorDate(vo.CONTRACTDATE) %><p class='mobile_show'><br/><%=FormatUtil.addSeparatorDate(vo.REGDATE) %><br/><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %><br/><%=vo.CODE_NM %></p></td>
      <td class='left mobile_hide'   onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=FormatUtil.addSeparatorDate(vo.REGDATE) %>
      <td class='left mobile_hide'   onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=FormatUtil.addSeparatorDate(vo.MTYDATE) %>
        <% if (!StrUtil.nvl(vo.MTYDATE).equals("") && StrUtil.nvl(vo.MTYDATE).length()==8) { %>
        <span style='color:red;'>[<%=DateTimeUtil.getLeftDateFromToday(vo.MTYDATE) %>일 남음]</span>
        <% } %>
      </td>
      <td class='left'               onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=vo.BNK_NAME %> <%=vo.PAY_SDESC %><p class='mobile_show'><br/><%=StrUtil.nvl(vo.CTNO) %><br/><%=vo.BUYER_NM %><br/><%=vo.SELLER_NM %></p></td>
      <td class='left mobile_hide'   onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=vo.BUYER_NM %></td>
      <td class='left mobile_hide'   onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=vo.SELLER_NM %></td>
      <td class='right mobile_hide'  onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></td>
      <td class='center mobile_hide' onclick='goDetail("<%=vo.CTID%>", "<%=vo.STATUS%>", "<%=vo.CTTYPE%>", "<%=vo.CPYSELLER%>");'><%=strReplacedStatusName %></td>
    </tr>
    <% if (!strUnusual.equals("")) { %>
    <tr><td colspan='<%=intColumnCnt %>' class='unusual'><%=strUnusual %></td></tr>
    <% } %>
<%
  }
} else out.println("<tr><td colspan='"+intColumnCnt+"' class='noentry'>검색조건에 맞는 계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>