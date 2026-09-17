<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.common.BankVO" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

ArrayList<BankVO> banks = CodeBean.BANK_LIST_PROC();
ArrayList<CodeVO> status = CodeBean.C_CODE_PROC("GUARANTEE_MASTER_INFO.GUAR_STATUS");

int intSeq = 0;
String  strDefaultPayment = "";
boolean isEditMode = false;
PayMethodVO t = null;
if (request.getParameter("payId")!=null) {
  PayMethodVO pvo  = new PayMethodVO();
  String[] payId   = (StrUtil.nvl(request.getParameter("payId"))).split("xx");
  pvo.BNK_CD       = payId[0];
  pvo.PAY_ID       = payId[1];
  pvo.CPY_ID       = intCpyId;
  pvo.CPY_GUAR_SEQ = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
  intSeq           = pvo.CPY_GUAR_SEQ;
  GuaranteeBean b  = new GuaranteeBean();
  t = b.GUARANTEE_MASTER_INFO_DETAIL_PROC(pvo);
  if (t!=null) {
    ArrayList<PayMethodVO> arr = new GuaranteeBean().BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC(t.GUAR_GUBUN, t.BNK_CD);
    if (arr!=null && arr.size()>0) {
      for (PayMethodVO v : arr) {
        strDefaultPayment += "<option value='"+v.PAY_ID+"'"+((v.PAY_ID.equals(t.PAY_ID))?" selected":"")+">"+v.PAY_SDESC+"</option>";
      }
    }
  }
  isEditMode = (t!=null);
}
System.out.println(strDefaultPayment);
String strActionTag = (!isEditMode) ? "등록":"수정";
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>보증서<%=strActionTag %></title>
<link rel="stylesheet" type="text/css" href="/mp/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
li.branch input.disabled, li.branch a.disabled {pointer-events:none;}
</style>
<script>
function search() {
  closePopup();
  var gubun = $("select[name='guar_gubun']").val();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/GuaranteeLocationsForPopup.jsp?guar='+gubun});
}
function numberToKorean(num) {
  if (typeof num !== 'number' || isNaN(num)) throw new Error('유효한 숫자를 입력해주세요.');
  const units = ['', '만', '억', '조', '경'];
  const digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
  const positions = ['', '십', '백', '천'];
  if (num === 0) return '영';
  let result = '';
  let unitIndex = 0;
  while (num > 0) {
    let part = num % 10000; // 4자리씩 나눔
    num = Math.floor(num / 10000);
    if (part > 0) {
      let partStr = '';
      let positionIndex = 0;
      while (part > 0) {
        let digit = part % 10;
        if (digit > 0) partStr = digits[digit] + positions[positionIndex] + partStr;
        part = Math.floor(part / 10);
        positionIndex++;
      }
      result = partStr + units[unitIndex] + result;
    }
    unitIndex++;
  }
  return result;
}
function printKorean() {
  $(".guar_amt").text(numberToKorean(1*document.frmEnt.amt.value)+"원");
}
function getPayment() {
console.log("hello");
<% if (!isEditMode) { %>
  $("select[name='pay_id']").html("");
  $.post("PaymentMethodsByBank.jsp", $("form[name='frmEnt']").serialize(), function(data) {
    $("select[name='pay_id']").html(data);
  });
<% } %>
}
function changeExpDate() {
  let date = new Date($("input[name='cra_date']").val());
  date.setFullYear(date.getFullYear() + 1);
  date.setDate(date.getDate() - 1);
  let edate = date.toISOString().split('T')[0];
  $("input[name='exp_date']").val(edate);
  $("input[name='val_date']").val(edate);
}
function regist() {
  var form = $("form[name='frmEnt']");
  var reportValidity = form[0].reportValidity();
  if(reportValidity){
    $("select[name='guar_gubun'], select[name='bnk_cd'], select[name='pay_id']").prop("disabled", false);
    console.log($("select[name='pay_id']").val());
    $.post("GuaranteeRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      if (data==0) showAlert("중복되어 있습니다.");
      else location.href = "Guarantee.jsp?cpy_id=<%=strCpyId%>";
    });
  }
}
function choiceBranch(obj) {
  document.frmEnt.guar_loc.value = $(obj).attr("gid");
  document.frmEnt.branch.value = $(obj).text();
  closePopup();
}
function fill() {
<% if (isEditMode) { %>
  $("select[name='guar_gubun']").val("<%=t.GUAR_GUBUN%>");
  $("input[name='branch']").val("<%=t.GUAR_LOC_DESC%>");
  $("select[name='bnk_cd']").val("<%=t.BNK_CD%>");
  $("select[name='pay_id']").val("<%=t.PAY_ID%>");
  $("select[name='guar_status']").val("<%=t.GUAR_STATUS %>");
  $("input[name='cra_date']").val("<%=t.GUAR_CRA_DATE %>");
  $("input[name='exp_date']").val("<%=t.GUAR_EXP_DATE %>");
  $("input[name='val_date']").val("<%=t.GUAR_VAL_DATE %>");
  $("input[name='amt']").val("<%=StrUtil.extractInteger(t.GUAR_TOTAL_AMT) %>");
  $("input[name='memo']").val("<%=t.MEMO %>");
  printKorean();
  $("select[name='guar_gubun'], select[name='bnk_cd'], select[name='pay_id']").prop("disabled", true);
<% } %>
}
$(document).ready(function(){
  <%=(!isEditMode)?"getPayment();":"fill();" %>
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>보증서<%=strActionTag %></span>
  <span class='more'>
    <a onclick='history.go(-1);' class='btn'>돌아가기</a>
  </span>
</div>

<jsp:include page="./CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="2" />
</jsp:include>

<form name='frmEnt' autocomplete="off">
<input type='hidden' name='cid' value='<%=strCpyId%>'>
<input type='hidden' name='seq' value='<%=intSeq%>'>
<input type='hidden' name='guar_loc'>
<ul class='form'>
  <li>
    <label class='emphasis'>보증기관</label>
    <select name='guar_gubun'>
      <option value='KODIT'>신보</option>
      <option value='KIBO'>기보</option>
      <option value='KOREG'>재단</option>
      <option value='ETC'>기타</option>
    </select>
  </li>
  <li class='branch'>
    <label>지점명</label>
    <input name='branch' style='width:calc(100% - 198px);' class='<%=isEditMode?"disabled":"" %>' onclick='search()' readonly><a class='btn <%=isEditMode?"disabled":"" %>' href="javascript:search();">검색</a>
  </li>
  <li>
    <label class='emphasis'>은행</label>
    <select name='bnk_cd' onchange='getPayment();'>
    <%
    if (banks!=null && banks.size()>0) {
      for (BankVO vo : banks) out.println("<option value='"+vo.BNK_CD+"'>"+vo.BNK_NAME+"</option>");
    }
    %>
    </select>
  </li>
  <li>
    <label class='emphasis'>결제수단</label>
    <select name='pay_id'>
    <%=strDefaultPayment %>
    </select>
  </li>
  <li>
    <label class='emphasis'> 보증상태</label>
    <select name='guar_status'>
    <%
    if (status!=null && status.size()>0) {
      for (CodeVO vo : status) out.println("<option value='"+vo.CODE_CD.trim()+"'>"+vo.CODE_NM+"</option>");
    }
    %>
    </select>
  </li>
  <li>
    <label class='emphasis'>보증시작일</label>
    <input type='date' name='cra_date' style='width:100px;' onchange="changeExpDate();" required>
  </li>
  <li>
    <label class='emphasis'>보증마감일</label>
    <input type='date' name='exp_date' style='width:100px;' required>
  </li>
  <li>
    <label class='emphasis'>유효만기일</label>
    <input type='date' name='val_date' style='width:100px;' required>
  </li>
  <li>
    <label class='emphasis'>보증액</label>
    <input type='number' name='amt' required style='width:100px;' onchange='printKorean();'>
    <span class='guar_amt'></span>
  </li>
  <li>
    <label style='vertical-align:top;'>메모</label>
    <input name='memo' maxlength='150'>
  </li>
  <li>
    <label></label>
    
  </li>
</ul>
</form>

<div class='btns'>
  <a onclick='regist();'><%=strActionTag %></a>
</div>

<%@ include file="../Footer.jsp" %>