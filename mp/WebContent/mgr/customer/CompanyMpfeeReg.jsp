<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.UploadUtil"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoVO" %>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoBean" %>
<%@ page import="kr.co.mp.c.*" %>
<%
    request.setCharacterEncoding("utf-8");

    CompanyMpFeeInfoVO mpvo = new CompanyMpFeeInfoVO();
    String strCid = StrUtil.nvl(request.getParameter("cid"));
    int cid = 0;

    if (!strCid.isEmpty()) {
        cid = Integer.parseInt(strCid);
    }

    CompanyMpFeeInfoBean bean = new CompanyMpFeeInfoBean();
    mpvo = bean.COMPANY_MPFEE_INFO_PROC(cid);

    String strActionName = (mpvo != null && mpvo.BIZNO != null && !mpvo.BIZNO.isEmpty()) ? "수정" : "등록";
    String useYn = StrUtil.nvl(mpvo.USE_YN, "N"); 
    
%>

<style>
    li.bizNo input { width: 200px !important; }
    li.bizNo a.disabled { pointer-events: none; }
    li.etc label { vertical-align: top; }
</style>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>

<script type="text/javascript">
function searchAddr(tgt) {
  new daum.Postcode({
    oncomplete: function(data) {
      var fullRoadAddr = data.roadAddress;
      var extraRoadAddr = '';
      if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)) extraRoadAddr += data.bname;
      if(data.buildingName !== '' && data.apartment === 'Y') extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
      if(extraRoadAddr !== '') extraRoadAddr = ' (' + extraRoadAddr + ')';
      if(fullRoadAddr !== '') fullRoadAddr += extraRoadAddr;
      $("input[name='"+tgt+"_zipcode']").val(data.zonecode);
      $("input[name='"+tgt+"_addr']").val(fullRoadAddr);
      $("input[name='"+tgt+"_addr2']").val("");
      $("input[name='"+tgt+"_addr_b']").focus();
    }
  }).open();
}
function check() {
	document.frmMpfeeReg.bizno.value = document.frmMpfeeReg.bizno.value.replace(/[^0-9]/g, "");
	var is = isValidBusinessNumber(document.frmMpfeeReg.bizno.value); 
    
	if (!is) {
	    toast("올바른 사업자번호가 아닙니다.", 1000, function() {
	    $("input[name='biznm']").val('');
	   });
	 }
     return is;
}

function goCheck() {
 	if (check()) {
 		var mpBizNo = document.frmMpfeeReg.bizno.value;
 		$.post("BizNoCheck.jsp", {cpyId: <%=request.getParameter("cid")%>, bizno: mpBizNo}, function(data) {
 			var biznm = $.trim(data);
 			if (biznm=='이미 등록된 업체입니다.') {
 				toast(biznm, 1000, function() {
 					$("input[name='biznm']").val('');
 				})
 			} else if (biznm!="") $("input[name='biznm']").val(data);
 			else toast("해당 사업자번호의 회원이 존재하지 않습니다.", 1000, function() {
 				$("input[name='biznm']").val('');
 			})
 		});
 	}
}

function fillData() {
$("input[name='bizno']").val("<%=StrUtil.nvl(mpvo.BIZNO)%>"); 
$("input[name='biznm']").val("<%=StrUtil.nvl(mpvo.BIZNM)%>");
$("input[name='ceonm']").val("<%=StrUtil.nvl(mpvo.CEONM)%>");
$("input[name='business_type']").val("<%=StrUtil.nvl(mpvo.BUSINESS_TYPE)%>");
$("input[name='industry']").val("<%=StrUtil.nvl(mpvo.INDUSTRY)%>");
$("input[name='basic_zipcode']").val("<%=StrUtil.nvl(mpvo.ZIPCODE)%>");
$("input[name='basic_addr']").val("<%=StrUtil.nvl(mpvo.ADDR)%>");
$("input[name='basic_addr2']").val("<%=StrUtil.nvl(mpvo.ADDR2)%>");
$("input[name='use_yn'][value='<%=useYn%>']").prop("checked", true); 
}

</script>

<h3>별도발행처 등록/수정</h3>
<form name='frmMpfeeReg'>
   <input type='hidden' name='cid' value='<%=cid%>'>
   <input type='hidden' name='zipcode' value='<%=mpvo.ZIPCODE%>'>
   <ul class='form'>
       <li>
           <label>사업자번호</label>
           <input type='text' name='bizno' value='<%=mpvo.BIZNO != null ? FormatUtil.addDashBizNo(mpvo.BIZNO) : "" %>' maxlength='12' pattern="[0-9]+" placeholder='사업자등록번호' onblur="goCheck();">
       </li>
       <li>
           <label class='not-has-input'>회사명</label>
           <input type='text' name='biznm' value='<%=StrUtil.nvl(mpvo.BIZNM)%>' maxlength='50' placeholder="회사명">
       </li>
       <li>
           <label class='not-has-input'>대표자명</label>
           <input type='text' name='ceonm' value='<%=StrUtil.nvl(mpvo.CEONM)%>' maxlength='20' placeholder="대표자명">
       </li>
       <li>
           <label class='not-has-input'>업태</label>
           <input type='text' name='business_type' value='<%=StrUtil.nvl(mpvo.BUSINESS_TYPE)%>' maxlength='50' placeholder="업태">
       </li>
       <li>
           <label class='not-has-input'>업종</label>
           <input type='text' name='industry' value='<%=StrUtil.nvl(mpvo.INDUSTRY)%>' maxlength='50' placeholder="업종">
       </li>
       <li class='wide'>
           <label>주소</label>
           <input type='text' name='basic_zipcode' style='width:200px;' readonly onclick='searchAddr("basic");' value="<%=StrUtil.nvl(mpvo.ZIPCODE, "")%>"> <a onclick='searchAddr("basic");' class='btn'>검색</a><br/>
           <input type='text' name='basic_addr' value='<%=StrUtil.nvl(mpvo.ADDR)%>' maxlength='200' placeholder='사업자등록증상의 주소'  style='margin-top:3px; margin-left:112px; width: 350px;' readonly onclick='searchAddr("basic");'><br/>
           <input type='text' name='basic_addr2' value='<%=StrUtil.nvl(mpvo.ADDR2)%>' maxlength='200' placeholder='상세주소' style='margin-top:3px; margin-left:112px; width: 350px;'>
       </li>
       <li>
           <label class='not-has-input'>사용여부</label>
           <input type='radio' name='use_yn' value='Y' <%= useYn.equals("Y") ? "checked" : "" %>> 사용
           <input type='radio' name='use_yn' value='N' <%= useYn.equals("N") ? "checked" : "" %>> 미사용
       </li>
       <li style='margin-top:15px;'>
           <label></label>
           <div class='btns'>
               <a href='javascript:editMpfeeInfo();'><%=strActionName%></a>
           </div>
       </li>
   </ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>