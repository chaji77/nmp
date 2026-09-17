<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CustomerBean bean = new CustomerBean();
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
if (arrPersons==null || arrPersons.size()==0 || arrPersons.get(0).PRS_ID==null) return;
PersonVO pvo = arrPersons.get(0);

ArrayList<RelationCompanyVO> arrRelationCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intCpyId, "N");

if (cvo.CPY_FOUNDYEAR.length()==8 && StrUtil.isOnlyNumeric(cvo.CPY_FOUNDYEAR)) cvo.CPY_FOUNDYEAR = FormatUtil.addSeparatorDate(cvo.CPY_FOUNDYEAR, ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"));
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>보증신청</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
input[type='text'] {width:30%;margin-right:10px;}
label {vertical-align:top;padding-top: 10px;}
textarea {width: calc(100% - 175px);}
</style>
<script>
function loadCompanySearchPage() {
  let pop = window.open("../CompanySearch.jsp", "_search_company_", 'width=900,height=900,scrollbars=yes,resizable=no');
}
$(document).ready(function(){

});
function getFormattedDate() {
  let today = new Date();
  let year = today.getFullYear();
  let month = String(today.getMonth() + 1).padStart(2, "0");
  let day = String(today.getDate()).padStart(2, "0");
  return `${year}년 ${month}월 ${day}일`;
}


function goSubmit() {
  var is = validate("input[name='sell_cpy_id']", "length", [1,11], "거래처를 입력하세요.");
  if (is) is = validate("input[name='txt_mp_appamt']", "length", [1, 15], "신청금액을 입력하세요");
  if (is) is = validate("input[name='txt_appl_expireymd']", "length", [1, 40], "보증기한을 입력하세요");
  if (!is) return false;
  
  var cpy_name = $("#seller_cpy_nm").val();
  var mp_appamt = $("#txt_mp_appamt").val();
  var app_exprire = $("#txt_appl_expireymd").val();
  var descipt = $("#area_description").val();

  var msg = "------------------------------------<br/>";
      msg = msg + "신청일자 : " + getFormattedDate() + "<br/>";
      msg = msg + "신청기업 : <%=cvo.CPY_NAME%><br/>";
      msg = msg + "거래기업 : " + cpy_name + "<br/>";
      msg = msg + "신청금액 : " + mp_appamt + "원<br/>";
      msg = msg + "보증기한 : " + app_exprire + "<br/>";
      msg = msg + "비    고 : " + descipt + "<br/>";
      msg = msg + "------------------------------------<br/>";
      msg = msg + "담보보증신청하시겠습니까?";

  showCustomConfirm(msg, function() {
    $.post("https://w4.mp1.co.kr/guarantee_sys/yesb2b/secu_grt/kodit/grt_req_write_cross_act.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      var json = JSON.parse(data);
      showAlert(json.msg, function(){
        if (json.cd=="0000") location.href = "index.jsp";
      });
    });
  }, function() {});
}

</script>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>
<%@ include file="tab.jsp" %>

<div class='page-title-block'>
  <span class='title'>보증신청</span>
  <span class='more'>
    
  </span>
</div>

<h3>신청회사(구매기업)</h3>

<form name='frmEnt' method='post'>
<input type='hidden' name='applNO'>
<input type='hidden' name='prsid' value="<%=(String)pageContext.getAttribute("USER_LOGIN")%>">
<input type='hidden' name='sell_cpy_id'   id='seller_cpy_id'>
<input type='hidden' name='sell_cpy_name' id='seller_cpy_nm'>
<input type='hidden' name='cpy_ceo_name'  id='seller_ceo'   >
<input type='hidden' name='cpy_biz_no'    id='seller_bizno' >
<input type='hidden' name='adr_desc'      id='seller_addr'  >
<input type='hidden' name='cudType'       value='C'>
<ul class='detail'>
  <li class='th'>회사명</li>
  <li class='td'><%=cvo.CPY_NAME%></li>
  <li class='th'>대표자명</li>
  <li class='td'><%=cvo.CPY_CEO_NAME%></li>
  <li class='th'>사업자등록번호</li>
  <li class='td'><%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %></li>
  <li class='th'>주소</li>
  <li class='td'><%=cvo.CPY_ADDR%> <%=cvo.CPY_ADDR2%></li>
</ul>

<h3>거래처(판매기업)</h3>

<ul class='detail'>
  <li class='th'>회사명</li>
  <li class='td'><span class='seller_cpy_nm'>거래처를 조회하십시오.</span>&nbsp;&nbsp;<a onclick='loadCompanySearchPage();' class='btn'>조회</a></li>
  <li class='th'>대표자명</li>
  <li class='td seller_ceo'></li>
  <li class='th'>사업자등록번호</li>
  <li class='td seller_bizno'></li>
  <li class='th'>주소</li>
  <li class='td seller_addr'></li>
</ul>

<h3>신청내용</h3>

<ul class='form'>
  <li>
    <label>신청금액</label>
    <input type='text' name='txt_mp_appamt' id='txt_mp_appamt' maxlength="15">원
  </li>
  <li>
    <label>보증기한</label>
    <input type='text' name='txt_appl_expireymd' id='txt_appl_expireymd' value='발급후 1년' maxlength="40">*한글로 입력해주세요
  </li>
  <li>
    <label>비고</label>
    <textarea name='area_description' id='area_description'></textarea>
  </li>
</ul>
</form>


<div style='text-align:center;padding:20px 0;'>
신청일자 <%=DateTimeUtil.getCurrentDate(".") %><br/>
위와같이 담보보증을 신청합니다.
</div>

<div class='btns'>
  <a onclick='goSubmit();'>담보보증신청</a>
  <a class='cancel' href='index.jsp'>취소</a>
</div>

<%@ include file="../../includes/Footer.jsp" %>