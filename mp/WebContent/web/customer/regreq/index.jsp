<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.regreq.RegReqVO" %>
<%@ page import="kr.co.mp.c.regreq.RegReqBean" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));

RegReqVO pvo = new RegReqVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT    = 20;
pvo.BUY_CPY_ID = intCpyId;
pvo.START_DATE = StrUtil.nvl(request.getParameter("startDate"));
pvo.END_DATE   = StrUtil.nvl(request.getParameter("endDate"));
pvo.SEARCH_NM  = StrUtil.nvl(request.getParameter("searchNm"));
String strReqStatus = StrUtil.nvl(request.getParameter("reqStatus"), "0");
pvo.REQ_STATUS = (StrUtil.isOnlyNumeric(strReqStatus)) ? Integer.parseInt(strReqStatus) : 0;

ArrayList<RegReqVO> arr = new RegReqBean().COMPANY_REG_REQ_LIST_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>판매기업 등록요청</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<script src="<%=request.getContextPath()%>/static/js/pop.js" type="text/javascript"></script>
<style>
#element_to_pop_up {
  background-color:white;
  border-radius:15px;
  color:#000;
  display:none;
  padding:20px;
  padding-bottom:60px;
  min-width:300px;
  min-height:180px;
  width:auto;
  height:auto;
}
.bpopup-close-btn {clear:both;position:absolute;left:calc(50% - 10px);margin-top:15px;cursor:pointer;font-size:2em;}
</style>
<script>
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "index.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function doSearch() {
  goPage(1);
}
function regNew() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:'RegReqReg.jsp'});
}
function modifyReq(obj) {
  const tr = $(obj).closest('tr');
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl: 'RegReqReg.jsp?' + $.param(tr.data())});
}
function dropReq(obj) {
  const seq = $(obj).closest('tr').data('seq');
  showCustomConfirm("정말 삭제하시겠습니까?", function () {
    $.post("RegReqModProc.jsp", {seq: seq, mode: 'drop'}, function(data) {
      if (data > 0) location.reload();
      else toast("삭제하지 못했습니다. 잠시 후 다시 시도하십시오.");
    });
  });
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
  $(".searchbox input[name='searchNm']").keydown(function(key) {
    if (key.keyCode == 13) doSearch();
  });
  $("select[name='reqStatus']").on("change", function() {
    doSearch();
  });
});
</script>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div id='element_to_pop_up'></div>

<div class='page-title-block'>
  <span class='title'>판매기업 등록요청</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a class='btn' onclick='regNew();'>등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>등록일</label>
          <input type='date' name='startDate' value='<%=pvo.START_DATE%>'> ~
          <input type='date' name='endDate'   value='<%=pvo.END_DATE%>'>
        </li>
        <li>
          <label>상태</label>
          <select name='reqStatus'>
            <option value='0' <%= pvo.REQ_STATUS==0 ? "selected" : "" %>>전체</option>
<%
for (Map.Entry<Integer, String> entry : RegReqVO.getReqStatusMap().entrySet()) {
%>
            <option value='<%=entry.getKey()%>' <%= pvo.REQ_STATUS==entry.getKey() ? "selected" : "" %>><%=entry.getValue()%></option>
<%
}
%>
          </select>
        </li>
        <li>
          <label>상호명</label>
          <input type='text' name='searchNm' value='<%=pvo.SEARCH_NM%>' placeholder='판매기업명'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:doSearch();'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='index.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<table id='target-list' class='list detail'>
  <thead>
    <tr>
      <th class='left'>등록일</th>
      <th class='left'>판매기업명</th>
      <th class='left'>연락처</th>
      <th class='left'>담당자</th>
      <th class='left mobile_hide'>팩스/이메일</th>
      <th class='left'>사업자번호</th>
      <th class='left mobile_hide'>거래예정일</th>
      <th class='left mobile_hide'>수수료부담</th>
      <th class='left mobile_hide'>비고</th>
      <th class='left'>상태</th>
      <th class='left'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr != null && arr.size() > 0) {
  for (RegReqVO v : arr) {
    intTotalCnt = v.TOTAL_CNT;
%>
    <tr
        data-seq='<%=IntegerCryptoUtil.crypt(v.SEQ)%>'
        data-sell-cpy-name='<%=StrUtil.input(v.SELL_CPY_NAME)%>'
        data-sell-phone='<%=StrUtil.input(v.SELL_PHONE)%>'
        data-sell-prs-name='<%=StrUtil.input(v.SELL_PRS_NAME)%>'
        data-sell-fax='<%=StrUtil.input(v.SELL_FAX)%>'
        data-sell-email='<%=StrUtil.input(v.SELL_EMAIL)%>'
        data-biz-no='<%=StrUtil.input(v.SELL_CPY_BUSINESS_NO)%>'
        data-trade-date='<%=v.TRADE_DATE.length()>=10 ? v.TRADE_DATE.substring(0,10) : v.TRADE_DATE%>'
        data-fee-pay='<%=v.FEE_PAY%>'
        data-memo='<%=StrUtil.input(v.MEMO)%>'>
      <td class='left'><%=v.REG_DATE.length()>=16 ? v.REG_DATE.substring(0,16) : v.REG_DATE%></td>
      <td class='left'><%=StrUtil.nvl(v.SELL_CPY_NAME)%></td>
      <td class='left'><%=StrUtil.isEmpty(v.SELL_PHONE) ? "" : FormatUtil.addDashPhoneNumber(v.SELL_PHONE)%></td>
      <td class='left'><%=StrUtil.nvl(v.SELL_PRS_NAME)%></td>
      <td class='mobile_hide'><%=StrUtil.isEmpty(v.SELL_FAX) ? "" : FormatUtil.addDashPhoneNumber(v.SELL_FAX)%><%=(!StrUtil.isEmpty(v.SELL_FAX) && !StrUtil.isEmpty(v.SELL_EMAIL)) ? "<br>" : ""%><%=StrUtil.nvl(v.SELL_EMAIL)%></td>
      <td class='left'><%=FormatUtil.addDashBizNo(v.SELL_CPY_BUSINESS_NO)%></td>
      <td class='mobile_hide'><%=v.TRADE_DATE.length()>=10 ? v.TRADE_DATE.substring(0,10) : v.TRADE_DATE%></td>
      <td class='mobile_hide'><%=RegReqVO.getFeePayLabel(v.FEE_PAY)%></td>
      <td class='mobile_hide'><%=StrUtil.nvl(v.MEMO)%></td>
      <td class='left'><%=RegReqVO.getReqStatusLabel(v.REQ_STATUS)%></td>
      <td class='left'>
        <a class='btn' onclick='modifyReq(this);'>수정</a>
        <a class='btn darkred' onclick='dropReq(this);'>삭제</a>
      </td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='11' class='noentry'>등록하신 판매기업 등록요청이 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage', '<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../../includes/Footer.jsp" %>
