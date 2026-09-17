<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.MastOffCommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getCompanyName(String id, String strComNm, String strBizNo) {
  if (id.equals("0")) return "모든기업";
  return strComNm + "(" + strBizNo + ")";
}
String getPayGubunName(String strPayGubun) {
  if (strPayGubun.equals("10")) return "구매자금/카드(론)";
  if (strPayGubun.equals("20")) return "종통대";
  return "글로벌구매카드";
}
String getCommMethodName(String strCommMethod, ArrayList<CodeVO> arrCodes) {
  if (arrCodes!=null && arrCodes.size()>0) {
    for (CodeVO c : arrCodes) {
       if (c.CODE_CD.equals(strCommMethod)) return c.CODE_NM;
    }
  }
  return "";
}
%>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = StrUtil.nvl(request.getParameter("cpy_id"), "0");
strCpyId = (StrUtil.isOnlyNumeric(strCpyId)) ? strCpyId : "0";
int intCpyId     = Integer.parseInt(strCpyId);
int intTotalCnt  = 0;
String strCpyNm  = StrUtil.nvl(request.getParameter("cpy_nm"));


CommissionVO pvo = new CommissionVO();
pvo.PAGE         = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT      = 20;
pvo.PAY_GUBUN    = StrUtil.nvl(request.getParameter("pay_gubun"), "00");
pvo.COMM_METHOD  = StrUtil.nvl(request.getParameter("pay_method"), "000");
pvo.MAX_YN       = StrUtil.nvl(request.getParameter("max_yn"), "X");
pvo.SBDATE       = StrUtil.nvl(request.getParameter("sbdate"), "");
pvo.START_DT     = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
pvo.END_DT       = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("INFO_COMMISSION.COMM_METHOD");

CommissionBean bean = new CommissionBean();
ArrayList<CommissionVO> arr  = bean.INFO_COMMISSION_LIST_PROC(intCpyId, pvo);
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>수수료관리</title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
td {line-height:2em;vertical-align:top;}
td.memo {line-height:1.2em;white-space:normal;}
span.role {padding:3px;border:1px solid #ddd;color:#888;}
@media only screen and (max-width:767px) {
  td.memo {line-height:1.5em;min-width:290px;}
  span.role {padding:1px;}
}
</style>

<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "MpFees.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function goSearch() {
  goPage(1);
}
function drop(commid) {
  showCustomConfirm("삭제하시겠습니까?", function(){
    $.post("<%=request.getContextPath()%>/mgr/mpfee/MpFeeDropProc.jsp", {'commid':commid}, function(data){
     if (data==1) window.location.reload();
     else showAlert("삭제할 수 없습니다.");
    });
  }, function(){});
}
function searchCompany() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch.cpy_id.value = $(obj).attr("cid");
  document.frmSearch.cpy_nm.value = $(obj).text();
  closePopup();
}
function renew(commid) {
  showCustomConfirm("같은 조건으로 적용기간을 갱신하시겠습니까?", function(){
    $.post("<%=request.getContextPath()%>/mgr/mpfee/RenewProc.jsp", {'commid':commid}, function(data){
     if (data==1) window.location.reload();
     else showAlert("갱신할 수 없습니다.");
    });
  }, function(){});
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>수수료관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a href='<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp' class='btn'>신규등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cpy_id' value='<%=intCpyId%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>회원사</label>
          <input type='search' name='cpy_nm' readOnly placeholder='회원사' onclick='searchCompany();' onchange='goSearch();' value='<%=strCpyNm%>'>
        </li>
        <li>
          <label>결제구분</label>
          <select name='pay_gubun' onchange='goSearch();'>
            <option value='00'<%=pvo.PAY_GUBUN.equals("00")?" selected":"" %>></option>
            <option value="10"<%=pvo.PAY_GUBUN.equals("10")?" selected":"" %>>구매자금/카드(론)</option>
            <option value="20"<%=pvo.PAY_GUBUN.equals("20")?" selected":"" %>>종통대</option>
            <option value="30"<%=pvo.PAY_GUBUN.equals("30")?" selected":"" %>>글로벌구매카드</option>
          </select>
        </li>
        <li>
          <label>계산방식</label>
          <select name='pay_method' onchange='goSearch();'>
            <option value='000'></option>
            <%
            if (arrCodes!=null && arrCodes.size()>0) {
              for (CodeVO c : arrCodes) {
                out.println("<option value='"+StrUtil.nvl(c.CODE_CD).trim()+"'"+((pvo.COMM_METHOD.equals(StrUtil.nvl(c.CODE_CD).trim()))?" selected":"")+">"+StrUtil.nvl(c.CODE_NM).trim()+"</option>");
              }
            }
            %>
          </select>
        </li>
        <li>
          <input type='checkbox' name='max_yn' value='Y' onclick='goSearch();' style='min-width:auto !important;width:auto !important;' <%=(pvo.MAX_YN.equals("Y"))?"checked":""%>> 연맥스
        </li>
        <li class='search-option-status'>
          <label>검색기준일</label>
          <select name='sbdate' onChange="goPage(1);">
            <option value="" <%=(pvo.SBDATE.equals(""))?"selected":""%>></option>
            <option value="S" <%=(pvo.SBDATE.equals("S"))?"selected":""%>>적용시작일</option>
            <option value="E" <%=(pvo.SBDATE.equals("E"))?"selected":""%>>적용종료일</option>
          </select>
        </li>
        <li>
          <label>검색기간</label>
          <input type='date' name='start_ymd' value='<%=pvo.START_DT %>' style='width:auto;'>
          <input type='date' name='end_ymd' value='<%=pvo.END_DT %>' style='width:auto;'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn'><img class='magnify' onclick='javascript:goSearch();' style='margin-top:7px;'></td>
  </tr>
</tbody>
</table>
</form>

<div style='text-align:right;padding-bottom:10px;'><i class="fa-solid fa-asterisk"></i> 적용기간만기가 30일 이내인 경우, 갱신 버튼이 활성화됩니다.</div>

<table style='border-top:2px solid #ddd;min-width:100%;'>
  <thead class='mobile_hide'>
    <tr>
      <th class='left'>구매사<br/>판매사</th>
      <th class='left'>계산방식<br/>결제구분</th>
      <th class='right'>기준일수<br/>만기계산일</th>
      <th class='right'>기본요율<br>할인율</th>
      <th class='right'>비례요율</th>
      <th class='left'>적용기간</th>
      <th class='right'>청구총액<br/>수금총액</th>
      <th class='left'>등록자<br/>등록일시</th>
      <th class='left'>메모</th>
      <th class='right'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CommissionVO vo : arr) {
    intTotalCnt      = vo.TOTAL_CNT;
    String strMty    = (!vo.MTY_ENDDAYS.equals("0")) ? "<br/>" + vo.MTY_STDAYS + " ~ " + vo.MTY_ENDDAYS : "";
    //String strCustomerId = (vo.PAY_CPY.equals("B")) ? vo.CPY_BUYER : vo.CPY_SELLER;
    String strCustomerId = vo.CPY_BUYER;
%>
    <tr class='mobile_hide'>
      <td>
        <span class='role'>구매</span> <%=getCompanyName(vo.CPY_BUYER, vo.BUYER_NM, vo.BUYER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? " <font color='red'>[부담]</font>" : "" %><br/>
        <span class='role'>판매</span> <%=getCompanyName(vo.CPY_SELLER, vo.SELLER_NM, vo.SELLER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? "" : " <font color='red'>[부담]</font>" %>
      </td>
      <td><strong><%=getCommMethodName(vo.COMM_METHOD, arrCodes) %></strong><%=(vo.MAX_YN.equals("Y"))?" [연맥스] ":"" %><br/><%=getPayGubunName(vo.PAY_GUBUN) %></td>
      <td class='right'><%=vo.STD_DAYS %><%=strMty %></td>
      <td class='right'><%=vo.CPY_COMMISSION_RATE %><br/><%=vo.DISCOUNT_RATE %></td>
      <td class='right'><%=vo.CPY_COMMISSION_RATE1 %><br/><%=vo.CPY_COMMISSION_RATE2 %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.START_DT, ".") %> ~ <%=FormatUtil.addSeparatorDate(vo.END_DT, ".") %></td>
      <td class='right'><%=StrUtil.addComma(StrUtil.extractInteger(vo.RECEIVE_MONEY)) %><br/><%=StrUtil.addComma(StrUtil.extractInteger(vo.END_MONEY)) %><%=(vo.OFFLINE_YN.equals("Y"))?"<br/>오프라인징수":"" %></td>
      <td><%=vo.MODID %><br/><%=FormatUtil.addSeparatorDateTime(vo.MODDATE, ".") %></td>
      <td class='memo'><%=vo.COMM_DESC.replaceAll("\r", "<br/>") %></td>
      <td class='right'>
        <a href='<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp?commid=<%=vo.COMM_ID %>' class='btn lurian'>수정</a>
        <a class='btn darkred' onclick='drop(<%=vo.COMM_ID %>)'>삭제</a>
        <a class='btn' href='MpFeePerCustomer.jsp?cpy_id=<%=IntegerCryptoUtil.crypt(strCustomerId) %>'>상세</a>
        <% if (!vo.START_DT.equals("") && !vo.END_DT.equals("") && DateTimeUtil.diff(null, vo.END_DT, "")<30) { %>
        <a class='btn' onclick='renew(<%=vo.COMM_ID %>)'>갱신</a>
        <% } %>
      </td>
    </tr>
    <tr class='mobile_show'>
      <td class='memo' style='min-width:280px;'>
        <span class='role'>구매</span> <%=getCompanyName(vo.CPY_BUYER, vo.BUYER_NM, vo.BUYER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? " <font color='red'>[부담]</font>" : "" %><br/>
        <span class='role'>판매</span> <%=getCompanyName(vo.CPY_SELLER, vo.SELLER_NM, vo.SELLER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? "" : " <font color='red'>[부담]</font>" %><br/>
        <span class='role'>방식</span> <%=getCommMethodName(vo.COMM_METHOD, arrCodes) %><br/>
        <div style='margin-top:10px;padding-top:10px;border-top:1px solid #ddd;'><%=vo.COMM_DESC.replaceAll("\r", "<br/>") %></div>
      </td>
      <td class='right'>
        <a href='<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp?commid=<%=vo.COMM_ID %>' class='btn lurian'>수정</a>
        <br/><a class='btn darkred' onclick='drop(<%=vo.COMM_ID %>)'>삭제</a>
        <br/><a class='btn' href='MpFeePerCustomer.jsp?cpy_id=<%=IntegerCryptoUtil.crypt(strCustomerId) %>'>상세</a>
        <% if (!vo.START_DT.equals("") && !vo.END_DT.equals("") && DateTimeUtil.diff(null, vo.END_DT, "")<30) { %>
        <br/><a class='btn' onclick='renew(<%=vo.COMM_ID %>)'>갱신</a>
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



