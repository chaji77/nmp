<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

int intTargetCpyId            = 0;
int intPage                   = 1;
int intRowCnt                 = 20;
String strTargetCpyId         = StrUtil.nvl(request.getParameter("seller_id"), "0");
String strStartYmd            = StrUtil.nvl(request.getParameter("bill_start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 365, "-"));
String strEndYmd              = StrUtil.nvl(request.getParameter("bill_end_ymd"), DateTimeUtil.getCurrentDate("-"));
String strBuyerRelatedBizNos  = StrUtil.nvl(request.getParameter("buyer_related_companies_biz_no"));
String strSellerRelatedBizNos = StrUtil.nvl(request.getParameter("seller_related_companies_biz_no"));
int intTotalCnt               = 0;

if (StrUtil.isOnlyNumeric(strTargetCpyId)) intTargetCpyId = Integer.parseInt(strTargetCpyId);

String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) intPage = Integer.parseInt(strPage);

ArrayList<TaxVO> arr = new TaxBean().CT_BILL_FOR_TRADE_LIST_PROC(intPage, intRowCnt, intCpyId, intTargetCpyId, strStartYmd, strEndYmd);

%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>거래세금계산서</title>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래세금계산서</span>
  <span class='more'>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="8" />
</jsp:include>

<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "InvoicesPerCustomer.jsp";
  document.frmSearch.submit();
}
function openTaxBill(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/common/Tax.jsp?seq='+seq});
}
function dropBill(seq) {
  showCustomConfirm("선택한 세금계산서를 정말 삭제하시겠습니까?", function() {
    $.post("<%=request.getContextPath()%>/mgr/trade/InvoiceDropProc.jsp", {'seq':seq}, function(rtn) {
      if (rtn=="Y") goPage(1);
      else showAlert("이미 매매계약에 사용된 세금계산서는 삭제할 수 없습니다.", function() {});
    });
  }, function() {});
}
</script>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=intPage%>'>
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>검색기간</label>
             <input type='date' name='bill_start_ymd' style='width:auto;' value='<%=strStartYmd%>'> ~ 
             <input type='date' name='bill_end_ymd' style='width:auto;' value='<%=strEndYmd%>'> 
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:goPage(1);'></td>
  </tr>
</tbody>
</table>
</form>

<!-- 세금계산서 목록 -->
<table class='detail'>
  <thead>
    <tr class='mobile_hide'>
      <th class='left'>승인번호</th>
      <th class='center'>작성일</th>
      <th class='right'>경과일</th>
      <th class='left'>공급받는자</th>
      <th class='left'>공급자</th>
      <th class='right'>발행금액</th>
      <th class='right'>결제완료</th>
      <th>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i<arr.size();) {
    TaxVO t = arr.remove(0);
    intTotalCnt = t.TOTAL_CNT;
    BigDecimal fsum = new BigDecimal(0);
    BigDecimal fa = (StrUtil.isOnlyNumeric(t.PAY_SUM_AMOUNT)) ? new BigDecimal(t.PAY_SUM_AMOUNT) : new BigDecimal(0);
    BigDecimal fv = (StrUtil.isOnlyNumeric(t.PAY_SUM_TAX)) ? new BigDecimal(t.PAY_SUM_TAX) : new BigDecimal(0);
    fsum = fa.add(fv);
    long lngElapsedDate = (DateTimeUtil.diff(FormatUtil.addSeparatorDate(t.BILL_DT), DateTimeUtil.getCurrentDate("/"), "/")+1); // 경과일 : 작성일포함
    BigDecimal settled = (StrUtil.isOnlyNumeric(t.SETTLED_AMOUNT)) ? new BigDecimal(t.SETTLED_AMOUNT) : new BigDecimal(0);
    BigDecimal max_limit = fsum.subtract(settled);
%>
    <tr>
      <td>
        <a onclick='openTaxBill(<%=t.SBILL_SEQ%>)'><%=t.APP_NO %></a>
        <!-- 모바일에서는 다른 컬럼을 감추고 아래를 보여준다 -->
        <span class='mobile_show'><br/>작성일 : <%=FormatUtil.addSeparatorDate(t.BILL_DT) %> (<%=lngElapsedDate %>일 경과)</span>
        <span class='mobile_show'><br/>공급자 : <%=StrUtil.cutString(t.SCOMP_NAME, 17, "..") %></span>
        <span class='mobile_show'><br/>발행액 : <strong><%=StrUtil.addCommaAfterRound(fsum.toPlainString()) %>원</strong> (결제완료 <strong><font color='darkred'><%=StrUtil.addCommaAfterRound(t.SETTLED_AMOUNT) %></font></strong>원)</span>
      </td>
      <td class='center mobile_hide'><%=FormatUtil.addSeparatorDate(t.BILL_DT) %></td>
      <td class='right mobile_hide'><%=lngElapsedDate %>일</td>
      <td class='mobile_hide'><span class='ellipse_column'><%=t.RCOMP_NAME %></span></td>
      <td class='mobile_hide'><span class='ellipse_column'><%=t.SCOMP_NAME %></span></td>
      <td class='right mobile_hide'><strong><%=StrUtil.addCommaAfterRound(fsum.toPlainString()) %></strong></td>
      <td class='right mobile_hide'><font color='darkred'><%=StrUtil.addCommaAfterRound(t.SETTLED_AMOUNT) %></font>
      <td class='center'>
        <a onclick="dropBill('<%=IntegerCryptoUtil.crypt(t.SBILL_SEQ) %>');" class='btn darkred'>삭제</a>
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
  getPaging('goPage','<%=intPage%>', '<%=intTotalCnt%>', '<%=intRowCnt%>', 5, '');
  </script>
</div>


<iframe id='ifmContract'></iframe>
<%@ include file="../Footer.jsp" %>
