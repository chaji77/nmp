<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

CustomerBean bean = new CustomerBean();
// 회원사정보
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
// 회원사추가정보(기업신용등급, 업종상세, 인증현황, 전년도매출액 등)
CompanyVO moreInfoVo = bean.COMPANY_MOREINFO_PROC(intCpyId);
cvo.CPY_CREDIT_GRADE  = moreInfoVo.CPY_CREDIT_GRADE;
cvo.CPY_INDUSTRY_CODE = moreInfoVo.CPY_INDUSTRY_CODE;
cvo.INDUSTRY_DETAIL   = moreInfoVo.INDUSTRY_DETAIL;
cvo.EXPORT_YN         = moreInfoVo.EXPORT_YN;
cvo.PATENT_YN         = moreInfoVo.PATENT_YN;
cvo.MAINBIZ_YN        = moreInfoVo.MAINBIZ_YN;
cvo.INNOBIZ_YN        = moreInfoVo.INNOBIZ_YN;
cvo.LAB_YN            = moreInfoVo.LAB_YN;
cvo.SALES_YEAR        = moreInfoVo.SALES_YEAR;
cvo.SALES_AMOUNT      = moreInfoVo.SALES_AMOUNT;
cvo.CPY_SCALE         = moreInfoVo.CPY_SCALE;
cvo.EMPLOYEE_COUNT    = moreInfoVo.EMPLOYEE_COUNT;
// 담당자정보
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
if (arrPersons==null || arrPersons.size()==0 || arrPersons.get(0).PRS_ID==null) return;
// 구매사관리 담당자정보
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
if (cvo.CPY_FOUNDYEAR.length()==8 && StrUtil.isOnlyNumeric(cvo.CPY_FOUNDYEAR)) cvo.CPY_FOUNDYEAR = FormatUtil.addSeparatorDate(cvo.CPY_FOUNDYEAR, ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"));

boolean isPopup = "1".equals(request.getParameter("popup"));
%>
<% if (!isPopup) { %>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>회원정보</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>
<% } %>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js"></script>

<style>
#moreinfo-section, #moreinfo-section ~ * {font-size:<%=isPopup?"15px":"13px"%>;}
#moreinfo-section ~ * select, #moreinfo-section ~ * input[type='text'] {font-size:<%=isPopup?"15px":"13px"%>;}
ul.detail li {line-height:1.2;}
li.emp {background-color:#fee !important;}
li.td.emp {color:red;font-weight:bold;}
li.detail-group {width:100%;background-color:#f0f0f0;font-size:<%=isPopup?"17px":"15px"%>;font-weight:bold;}
.view-moreinfo.chip {display:inline-block;padding:3px 8px;margin-right:6px;border:1px solid #bbb;border-radius:3px;font-size:0.9em;}
.edit-moreinfo {display:inline-block;vertical-align:middle;margin-right:14px;margin-bottom:6px;}
.edit-moreinfo select {margin-left:4px;}
</style>
<script>
function goEditPage() {
  location.href = "<%=request.getContextPath()%>/mgr/customer/CompanyModify.jsp?<%=strCpyId%>";
}
function toggleMoreInfoEdit() {
  $(".view-moreinfo").hide();
  $(".edit-moreinfo").show();
  $("#btnMoreInfoEdit").hide();
  $("#btnSaveMoreInfo, #btnCancelMoreInfo").show();
}
function cancelMoreInfoEdit() {
  $(".view-moreinfo").show();
  $(".edit-moreinfo").hide();
  $("#btnMoreInfoEdit").show();
  $("#btnSaveMoreInfo, #btnCancelMoreInfo").hide();
}
function miField(sel) {
  // 팝업 모드일 땐 뒷페이지(SalesCompanies.jsp 등)에 같은 name의 필드가 있을 수 있어
  // #element_to_pop_up 안으로 범위를 좁혀서 찾는다.
  return <%=isPopup%> ? $("#element_to_pop_up " + sel) : $(sel);
}
function saveMoreInfo() {
  showCustomConfirm("변경사항을 저장하시겠습니까?", function() {
    $.post("<%=request.getContextPath()%>/mgr/sales/CompanyMoreInfoModProc.jsp", {
      cpy_id: <%=intCpyId%>,
      industry_code: miField("input[name='industry_code']").val().toUpperCase(),
      industry_detail: miField("input[name='industry_detail']").val(),
      credit_grade: miField("input[name='credit_grade']").val(),
      export_yn: miField("select[name='export_yn']").val(),
      patent_yn: miField("select[name='patent_yn']").val(),
      mainbiz_yn: miField("select[name='mainbiz_yn']").val(),
      innobiz_yn: miField("select[name='innobiz_yn']").val(),
      lab_yn: miField("select[name='lab_yn']").val(),
      sales_year: miField("input[name='sales_year']").val(),
      sales_amount: miField("input[name='sales_amount']").val().replace(/,/g, ""),
      cpy_scale: miField("select[name='cpy_scale']").val(),
      employee_count: miField("input[name='employee_count']").val()
    }, function(data) {
      if (data>0) {
<% if (isPopup) { %>
        toast("성공했습니다.", 2000, function() {
          $("#element_to_pop_up").load("<%=request.getContextPath()%>/mgr/sales/SalesInformation.jsp?cpy_id=<%=strCpyId%>&popup=1");
        });
<% } else { %>
        location.reload(true);
<% } %>
      } else {
        toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
      }
    });
  }, function() {});
}
<% if (isPopup) { %>
function sizeMoreInfoPopup() {
  $("#element_to_pop_up").css({width:"40vw", "max-height":"80vh", "overflow-y":"auto"});
  $(window).trigger("resize");
}
sizeMoreInfoPopup();
setTimeout(sizeMoreInfoPopup, 300);
<% } %>
</script>
<% if (!isPopup) { %>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원정보</span>
  <span class='more'>
    <a onclick='goEditPage()' class='btn lurian'>수정</a>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="9" />
</jsp:include>

<input type='hidden' name='prs_passwd' value='<%=CryptoDESUtil.decrypt(pvo.PRS_PASSWD) %>'>
<% } %>

<% if (isPopup) { %>
<div class='page-title-block'>
  <span class='title'>영업 정보</span>
</div>
<ul class='category'>
  <li class='category selected' style='color:#007bff; background-color:#f8f9fa;'>추가정보</li>
  <li class='category' onclick="$('#element_to_pop_up').load('<%=request.getContextPath()%>/mgr/sales/SalesMemoPerCustomer.jsp?cpy_id=<%=strCpyId%>&popup=1');">영업메모</li>
</ul>
<% } %>

<div class='page-title-block' id='moreinfo-section'>
  <span class='subtitle'>
  <% if (isPopup) { %>
    <b style="text-decoration: underline;cursor:pointer; color:#007bff;" onclick="location.href='<%=request.getContextPath()%>/mgr/sales/SalesInformation.jsp?cpy_id=<%=strCpyId%>';"><%=cvo.CPY_NAME%></b>
  <% } else { %>
    <b style="text-decoration: underline;"><%=cvo.CPY_NAME%></b>
  <% } %>
   기본정보</span>
  <span class='more'>
    <a id='btnMoreInfoEdit' onclick='toggleMoreInfoEdit();' class='btn lurian'>수정</a>
    <a id='btnSaveMoreInfo' onclick='saveMoreInfo();' class='btn lurian' style='display:none;'>변경사항 저장</a>
    <a id='btnCancelMoreInfo' onclick='cancelMoreInfoEdit();' class='btn' style='display:none;'>취소</a>
  </span>
</div>

<ul class='detail'>
  <li class='detail-group'>사업자정보</li>
  <li class='th'>사업자등록번호</li>
  <li class='td'><%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %></li>
  <%-- <li class='th'>회사명</li>
  <li class='td'><%=cvo.CPY_NAME%></li> --%>
  <li class='th'>법인등록번호</li>
  <li class='td'><%=cvo.CPY_INCORPORATE_NO%></li>
  <li class='th'>회사구분</li>
  <li class='td'><%
  if (cvo.CPY_GUBUN.equals("1")) out.print("구매사");
  else if (cvo.CPY_GUBUN.equals("2")) out.print("판매사");
  else out.print("구매&amp;판매사");
  %></li>
  <li class='th'>대표자명</li>
  <li class='td'><%=cvo.CPY_CEO_NAME%></li>
  <li class='th'>기업형태</li>
  <li class='td'><%
  if (cvo.CRG_ID.equals("1")) out.print("법인사업자");
  else out.print("개인사업자");
  %></li>
  <li class='th'>기업구분</li>
  <li class='td'>
    <span class='view-moreinfo'><%
    if (cvo.CPY_SCALE.equals("1")) out.print("일반");
    else if (cvo.CPY_SCALE.equals("2")) out.print("외감");
    else if (cvo.CPY_SCALE.equals("3")) out.print("중견");
    else out.print("-");
    %></span>
    <select name='cpy_scale' class='edit-moreinfo' style='display:none;'>
      <option value=''  <%=(!cvo.CPY_SCALE.equals("1") && !cvo.CPY_SCALE.equals("2") && !cvo.CPY_SCALE.equals("3"))?"selected":"" %>>-</option>
      <option value='1' <%=(cvo.CPY_SCALE.equals("1"))?"selected":"" %>>일반</option>
      <option value='2' <%=(cvo.CPY_SCALE.equals("2"))?"selected":"" %>>외감</option>
      <option value='3' <%=(cvo.CPY_SCALE.equals("3"))?"selected":"" %>>중견</option>
    </select>
  </li>
  <li class='th'>종업원수</li>
  <li class='td'>
    <span class='view-moreinfo'><%=(cvo.EMPLOYEE_COUNT==null||cvo.EMPLOYEE_COUNT.isEmpty())?"-":cvo.EMPLOYEE_COUNT+"명"%></span>
    <input type='text' name='employee_count' class='edit-moreinfo' value='<%=StrUtil.nvl(cvo.EMPLOYEE_COUNT) %>' maxlength='1000000' pattern="[0-9]+" onkeypress='return checkNumber(event)' style='display:none;' placeholder='종업원수'>
  </li>
  <li class='th'></li>
  <li class='td'></li>
  

  <li class='detail-group'>업종/영업정보</li>
  <li class='th'>업태</li>
  <li class='td'><%=cvo.BUSINESS_TYPE%></li>
  <li class='th'>종목</li>
  <li class='td'><%=cvo.INDUSTRY%></li>
  <li class='th'>업종코드</li>
  <li class='td'>
    <span class='view-moreinfo'><%=cvo.CPY_INDUSTRY_CODE %></span>
    <input type='text' name='industry_code' class='edit-moreinfo' value='<%=cvo.CPY_INDUSTRY_CODE %>' maxlength='8' style='display:none;' placeholder='업종코드'>
  </li>
  <li class='th'>업종상세</li>
  <li class='td'>
    <span class='view-moreinfo'><%=cvo.INDUSTRY_DETAIL %></span>
    <input type='text' name='industry_detail' class='edit-moreinfo' value='<%=cvo.INDUSTRY_DETAIL %>' maxlength='50' style='display:none;' placeholder='업종상세'>
  </li>
  <li class='th'>매출액 (백만원)</li>
  <li class='td'>
    <span class='view-moreinfo'><%=cvo.SALES_AMOUNT.isEmpty()?"":cvo.SALES_YEAR+"년 / "+StrUtil.addComma(cvo.SALES_AMOUNT)%></span>
    <input type='text' name='sales_year' class='edit-moreinfo' value='<%=cvo.SALES_YEAR %>' maxlength='4' pattern="[0-9]+" onkeypress='return checkNumber(event)' style='display:none;width:60px;' placeholder='YYYY'>
    <span class='edit-moreinfo' style='display:none;'>년</span>
    <input type='text' name='sales_amount' class='edit-moreinfo' value='<%=StrUtil.addComma(cvo.SALES_AMOUNT) %>' maxlength='9' pattern="[0-9]+" onkeypress='return checkNumber(event)' style='display:none;width:120px;' placeholder='매출액'>
  </li>
  <li class='th'>기업신용등급</li>
  <li class='td'>
    <span class='view-moreinfo'><%=cvo.CPY_CREDIT_GRADE %></span>
    <input type='text' name='credit_grade' class='edit-moreinfo' value='<%=cvo.CPY_CREDIT_GRADE %>' maxlength='5' style='display:none;width:80px;' placeholder='AAA, AA, A...'>
  </li>

  <% if (!isPopup) { %>
  <li class='detail-group'>주소/기타</li>
  <li class='th'>주소</li>
  <li class='td'>[<%=cvo.CPY_ZIPCODE%>] <%=cvo.CPY_ADDR%> <%=cvo.CPY_ADDR2%></li>
  <li class='th'>팩스</li>
  <li class='td'><%=cvo.CPY_FAX%></li>
  <li class='th'>첨부파일</li>
  <li class='td'>
  <% if (cvo.BIZ_DOC_FILE_URL!=null && cvo.BIZ_DOC_FILE_URL.length()>10) { %>
      <a href="<%=cvo.BIZ_DOC_FILE_URL %>" target="_new"><%=cvo.BIZ_DOC_FILE_URL.substring((cvo.BIZ_DOC_FILE_URL.lastIndexOf("/")+1)) %></a>
  <% } %>
  </li>
  <li class='th'>설립일</li>
  <li class='td'><%=cvo.CPY_FOUNDYEAR%></li>

  <li class='detail-group'>담당자정보</li>
  <li class='th'>로그인계정</li>
  <li class='td'><%=pvo.PRS_LOGIN%></li>
  <li class='th'>최근로그인</li>
  <li class='td'><%=cvo.LAST_LOGIN_DT %></li>
  <li class='th'>기업설명</li>
  <li class='td'><%=StrUtil.nvl(cvo.CPY_BUSINESS_DESC) %></li>
  <li class='th'>일반전화번호</li>
  <li class='td'><a href='tel:<%=pvo.PRS_TEL %>'><%=pvo.PRS_TEL %></a></li>
  <% } %>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>부가정보</span>
</div>

<ul class='detail'>
  <li class='td' style='width:100%;'>
    <strong style='margin-right:14px;'>인증현황</strong>
    <span class='view-moreinfo chip'>수출 <%=(cvo.EXPORT_YN.equals("Y"))?"O":(cvo.EXPORT_YN.equals("N")?"X":"-") %></span>
    <span class='edit-moreinfo' style='display:none;margin-right:12px;'>수출
      <select name='export_yn'>
        <option value=''  <%=(!cvo.EXPORT_YN.equals("Y") && !cvo.EXPORT_YN.equals("N"))?"selected":"" %>>-</option>
        <option value='Y' <%=(cvo.EXPORT_YN.equals("Y"))?"selected":"" %>>O</option>
        <option value='N' <%=(cvo.EXPORT_YN.equals("N"))?"selected":"" %>>X</option>
      </select>
    </span>
    <span class='view-moreinfo chip'>특허 <%=(cvo.PATENT_YN.equals("Y"))?"O":(cvo.PATENT_YN.equals("N")?"X":"-") %></span>
    <span class='edit-moreinfo' style='display:none;margin-right:12px;'>특허
      <select name='patent_yn'>
        <option value=''  <%=(!cvo.PATENT_YN.equals("Y") && !cvo.PATENT_YN.equals("N"))?"selected":"" %>>-</option>
        <option value='Y' <%=(cvo.PATENT_YN.equals("Y"))?"selected":"" %>>O</option>
        <option value='N' <%=(cvo.PATENT_YN.equals("N"))?"selected":"" %>>X</option>
      </select>
    </span>
    <span class='view-moreinfo chip'>메인비즈 <%=(cvo.MAINBIZ_YN.equals("Y"))?"O":(cvo.MAINBIZ_YN.equals("N")?"X":"-") %></span>
    <span class='edit-moreinfo' style='display:none;margin-right:12px;'>메인비즈
      <select name='mainbiz_yn'>
        <option value=''  <%=(!cvo.MAINBIZ_YN.equals("Y") && !cvo.MAINBIZ_YN.equals("N"))?"selected":"" %>>-</option>
        <option value='Y' <%=(cvo.MAINBIZ_YN.equals("Y"))?"selected":"" %>>O</option>
        <option value='N' <%=(cvo.MAINBIZ_YN.equals("N"))?"selected":"" %>>X</option>
      </select>
    </span>
    <span class='view-moreinfo chip'>이노비즈 <%=(cvo.INNOBIZ_YN.equals("Y"))?"O":(cvo.INNOBIZ_YN.equals("N")?"X":"-") %></span>
    <span class='edit-moreinfo' style='display:none;margin-right:12px;'>이노비즈
      <select name='innobiz_yn'>
        <option value=''  <%=(!cvo.INNOBIZ_YN.equals("Y") && !cvo.INNOBIZ_YN.equals("N"))?"selected":"" %>>-</option>
        <option value='Y' <%=(cvo.INNOBIZ_YN.equals("Y"))?"selected":"" %>>O</option>
        <option value='N' <%=(cvo.INNOBIZ_YN.equals("N"))?"selected":"" %>>X</option>
      </select>
    </span>
    <span class='view-moreinfo chip'>연구소 <%=(cvo.LAB_YN.equals("Y"))?"O":(cvo.LAB_YN.equals("N")?"X":"-") %></span>
    <span class='edit-moreinfo' style='display:none;margin-right:12px;'>연구소
      <select name='lab_yn'>
        <option value=''  <%=(!cvo.LAB_YN.equals("Y") && !cvo.LAB_YN.equals("N"))?"selected":"" %>>-</option>
        <option value='Y' <%=(cvo.LAB_YN.equals("Y"))?"selected":"" %>>O</option>
        <option value='N' <%=(cvo.LAB_YN.equals("N"))?"selected":"" %>>X</option>
      </select>
    </span>
  </li>
</ul>

<% if (!isPopup) { %>
<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>
<% } else { %>
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
<% } %>