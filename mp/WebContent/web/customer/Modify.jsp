<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CustomerBean bean = new CustomerBean();
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
if (arrPersons==null || arrPersons.size()==0 || arrPersons.get(0).PRS_ID==null) return;
//구매사관리 담당자정보
ArrayList<BusinessPersonVO> arrBusinessPersons = new MgrCustomerBean().M_BUSINESS_PERSON_LIST_PROC(intCpyId);

PersonVO pvo = new PersonVO();
if (arrBusinessPersons != null && arrBusinessPersons.size() > 0) {
    Set<Integer> b = new HashSet<Integer>();
    for (int i = 0; i < arrBusinessPersons.size(); i++) {
        BusinessPersonVO bp = arrBusinessPersons.get(i);
        b.add(bp.PRS_ID);
    }
    for (int i = 0; i < arrPersons.size(); i++) {
        PersonVO p = arrPersons.get(i);
        if (!b.contains(Integer.parseInt(p.PRS_ID)) && !StrUtil.nvl(p.PRS_LOGIN).equals("")) {
            pvo = arrPersons.remove(i);
            break;
        }
    }
} else {
    for (int i = 0; i < arrPersons.size(); i++) {
        PersonVO p = arrPersons.get(i);
        if (p.PRS_LOGIN != null && !p.PRS_LOGIN.trim().isEmpty()) {
            pvo = arrPersons.remove(i);
            break;
        }
    }
}

if (cvo.CPY_FOUNDYEAR.length()==8 && StrUtil.isOnlyNumeric(cvo.CPY_FOUNDYEAR)) cvo.CPY_FOUNDYEAR = FormatUtil.addSeparatorDate(cvo.CPY_FOUNDYEAR, "-");
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>회원정보수정</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
#ul_attached_files>li {width:100%;}
#ul_attached_files>li>input[type='checkbox'] {width:0;height:0;}
#ul_attached_files>li>a {display:inline-block;max-width:calc(100% - 140px);overflow:hidden;white-space:nowrap;text-overflow:ellipsis;vertical-align:middle;}
#ul_attached_files>li>i {display:inline-block;}
</style>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>A"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/uploader.js?<%=DateTimeUtil.getCurrentResourceVersion() %>1"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/web/customer/Modify.js?<%=DateTimeUtil.getCurrentResourceVersion() %>A"></script>
<script>
function fillData() {
  $("input[name='cpy_nm']").val("<%=cvo.CPY_NAME%>");
  $("input[name='cpy_type'][value='<%=cvo.CPY_GUBUN%>']").prop("checked", true);
  $("input[name='cpy_ceo_nm']").val("<%=cvo.CPY_CEO_NAME%>");
  $("input[name='cpy_ceo_hp']").val("<%=cvo.CPY_CEO_HP%>");
  $("input[name='biz_type'][value='<%=cvo.CRG_ID%>']").prop("checked", true);
  <%
  if (cvo.CRG_ID.equals("2")) out.println("cpy_no_open(true);");
  %>
  $("input[name='cpy_no']").val("<%=cvo.CPY_INCORPORATE_NO%>");
  $("input[name='uptae']").val("<%=cvo.BUSINESS_TYPE%>");
  $("input[name='upzong']").val("<%=cvo.INDUSTRY%>");
  $("input[name='basic_zipcode']").val("<%=cvo.CPY_ZIPCODE%>");
  $("input[name='basic_addr']").val("<%=cvo.CPY_ADDR%>");
  $("input[name='basic_addr_b']").val("<%=cvo.CPY_ADDR2%>");
  $("input[name='fax']").val("<%=cvo.CPY_FAX%>"); 
  $("input[name='desc']").val("<%=cvo.CPY_BUSINESS_DESC%>");
  $("input[name='found_ymd']").val("<%=cvo.CPY_FOUNDYEAR%>");
  $("input[name='sale_amt']").val("<%=cvo.SALES_AMT%>");
  
  $("input[name='prs_id']").val("<%=pvo.PRS_ID%>");
  $("#login_id").text("<%=pvo.PRS_LOGIN%>");
  $("input[name='login_nm']").val("<%=pvo.PRS_NAME%>");
  $("input[name='login_tel']").val("<%=pvo.PRS_TEL %>");
  $("input[name='login_cell_tel']").val("<%=pvo.PRS_MOBILE_NO%>");
  $("input[name='sms_yn']").prop("checked", true);
  $("input[name='login_email']").val("<%=pvo.PRS_EMAIL%>");
  $("input[name='tax_nm']").val("<%=cvo.MPTAX_USER_NM%>");
  $("input[name='tax_email']").val("<%=cvo.MPTAX_EMAIL%>");
  $("input[name='login_pstn']").val("<%=pvo.PRS_PSTN%>");
  $("input[name='login_extn']").val("<%=pvo.PRS_EXTN%>");
}

function maxLengthCheck(object){
  if (object.value.length > object.maxLength) {
    object.value = object.value.slice(0, object.maxLength);
  }
}

</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원정보수정</span>
  <span class='more'>
  </span>
</div>

<form name='frmEnt' autocomplete="off">
<input type='hidden' name='prs_id'>
<input type='file' name='file_bizdoc' value='' onChange='uploadOneFile(event);' style='width:0;height:0;margin:0;padding:0;border:0;'>
<input type='hidden' name='checkDuplicated' value='Y'>
<h3 style='margin-top:0;'>기본 정보</h3>
<ul class='form'>
  <li>
    <label>사업자등록번호</label>
    <input type='text' name='bizno' value='<%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %>' readOnly>
  </li>
  <li>
    <label>회사명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_nm' value='' maxlength='30' placeholder='사업자등록증상의 회사명' required>
  </li>
  <li class='not-has-input'>
    <label>회사구분 <i class="fa-solid fa-asterisk"></i></label>
    <input type='radio' name='cpy_type' value='1'> 구매사
    <input type='radio' name='cpy_type' value='2'> 판매사
    <input type='radio' name='cpy_type' value='3'> 구매&amp;판매사
  </li>
  <li></li>
  <li>
    <label>대표자명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_ceo_nm' value='' maxlength='30' placeholder='사업자등록증상의 대표자명' required>
  </li>
  <li>
    <label>대표자 휴대폰번호</label>
    <input type='text' name='cpy_ceo_hp' value='' maxlength='13' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='01012345678'>
  </li>
  <li class='not-has-input'>
    <label>기업형태 <i class="fa-solid fa-asterisk"></i></label>
    <input type='radio' name='biz_type' value='1' onclick='cpy_no_open(false);'> 법인사업자
    <input type='radio' name='biz_type' value='2' onclick='cpy_no_open(true);'> 개인사업자
  </li>
  <li>
    <label>법인등록번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_no' value='' maxlength='14' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='법인등록번호'>
  </li>
  <li>
    <label>업태 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='uptae' value='' maxlength='100' placeholder='사업자등록증상의 업태' required>
  </li>
  <li>
    <label>종목 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='upzong' value='' maxlength='100' placeholder='사업자등록증상의 종목' required>
  </li>
  <li class='wide'>
    <label>주소 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='basic_zipcode' style='width:120px;' readonly onclick='searchAddr("basic");'> <a onclick='searchAddr("basic");' class='btn'>검색</a><br/>
    <input type='text' name='basic_addr' value='' maxlength='200' placeholder='사업자등록증상의 주소' required class='space-label-1' style='margin-top:3px;' readonly onclick='searchAddr("basic");'><br/>
    <input type='text' name='basic_addr_b' value='' maxlength='200' placeholder='상세주소' required class='space-label-1' style='margin-top:3px;'>
  </li>
  <li class='not-has-input'>
    <label>파일첨부</label>
    <a onclick='uploadBizDoc();' class='btn lurian'>사업자등록증 업로드</a><br/>
    <ul id='ul_attached_files' style='width:100%;padding-left:136px;margin-top:14px;margin-bottom:0;'>
      <% if (cvo.BIZ_DOC_FILE_URL!=null && cvo.BIZ_DOC_FILE_URL.length()>10) { %>
      <li>
        <input type="checkbox" name="file" id="file" value="<%=cvo.BIZ_DOC_FILE_URL %>____________________1">
        <a href="<%=cvo.BIZ_DOC_FILE_URL %>" target="_new"><%=cvo.BIZ_DOC_FILE_URL.substring((cvo.BIZ_DOC_FILE_URL.lastIndexOf("/")+1)) %></a>
        <i class="fa-solid fa-trash" onclick="dropUploadedFile(this);" style="cursor:pointer;" aria-hidden="true"></i>
      </li>
      <% } %>
    </ul>
  </li>
  <li>
    <label>팩스번호</label>
    <input type='text' name='fax' value='' maxlength='13' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='팩스번호'>
  </li>
  <li class='wide'>
    <label>기업설명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='desc' value='' maxlength='200' placeholder='간단한 기업설명 (100자 이내)' required>
  </li>
  <li>
    <label>설립일 <i class="fa-solid fa-asterisk"></i></label>
    <input type='date' name='found_ymd' value='' maxlength='10' style='width:140px;' placeholder='설립일' required>
  </li>
  <li>
    <label>전년도매출액 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='sale_amt' value='0' maxlength='9' pattern="[0-9]+" onkeypress='return checkNumber(event)' oninput='maxLengthCheck(this);' style='width:140px;' placeholder='전년도매출액 (백만원)' required> 백만원 <a onclick='toggleHint();' class='circle'>?</a>
    <div class='hint'>신설기업인 경우 매출액 0백만원 입력 (회원가입 후 최초 도래하는 결산 월 경과시 매출액을 반드시 등록해 주십시오)</div>
  </li>
  <li class='wide space-label' style='font-size:0.9em;color:#888;text-align:justify;'><i class="fa-solid fa-thumbtack" style='vertical-align:middle;'></i> 설립일과 전년도 매출액은 보증기금 이상 거래 모니터링의 근거자료로 활용됩니다.</li>
</ul>

<h3>실무담당자 정보</h3>
<ul class='form'>
  <li class='not-has-input'>
    <label>로그인아이디</label>
    <span id='login_id'></span>
  </li>
  <li class='mobile_hide'>
    <span style='margin-left:10px;color:#aaa;'><i class="fa-solid fa-circle-exclamation" style='color:hotpink;'></i> 비밀번호 수정은 <a href='Managers.jsp'>계정관리</a>에서 가능합니다.</span> 
  </li>
  <li>
    <label>담당자명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='login_nm' value='' maxlength='20' placeholder='담당자명' required>
  </li>
  <li>
    <label>일반전화</label>
    <input type='tel' name='login_tel' value='' maxlength='24' placeholder='일반전화' required>
  </li>
  <li>
    <label>휴대전화번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='tel' name='login_cell_tel' value='' maxlength='13' placeholder='휴대전화번호' required style='margin-bottom:5px;'><br/>
    <input type='checkbox' name='sms_yn' value='1' checked class='space-label' style='vertical-align:middle;'>거래진행 안내 문자(SMS) 수신
  </li>
  <li>
    <label>메일주소</label>
    <input type='email' name='login_email' value='' maxlength='40' placeholder='메일주소' pattern='[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$'>
  </li>
  <li>
    <label>담당자 직위</label>
    <input type='text' name='login_pstn' value='' maxlength='50' placeholder='담당자 직위'>
  </li>
  <li>
    <label>내선번호</label>
    <input type='text' name='login_extn' value='' maxlength='4' placeholder='내선번호'>
  </li>
</ul>

<ul class='form'>
  <li><h3>MP수수료 세금계산서 정보</h3></li>
  <li class='block-title-aside'><input type='checkbox' onclick='copyToInvoicer(this);'> 실무담당자 정보와 동일</li>
  <li>
    <label>수신담당자</label>
    <input type='text' name='tax_nm' value='' maxlength='20' placeholder='담당자명'>
  </li>
  <li>
    <label>수신메일 <i class="fa-solid fa-asterisk"></i></label>
    <input type='email' name='tax_email' value='' maxlength='30' placeholder='수신메일' pattern='[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' required>
  </li>
</ul>

</form>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='btns'>
  <a onclick='goSubmit();'>수정</a>
  <a href='MyPage.jsp' class='cancel'>취소</a>
</div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %>