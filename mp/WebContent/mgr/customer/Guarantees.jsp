<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.common.BankVO" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getOnlyDate(String ymdhis) {
  if (StrUtil.nvl(ymdhis).length()>10) return ymdhis.substring(0, 10);
  return ymdhis;
}
%>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = "-";
String strToday = DateTimeUtil.getCurrentDate(strDateSeparator);
ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("GUARANTEE_MASTER_INFO.GUAR_STATUS");

PayMethodVO pvo = new PayMethodVO();
pvo.CPY_ID      = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.BNK_CD      = StrUtil.nvl(request.getParameter("bnk_cd"));
pvo.PAY_ID      = StrUtil.nvl(request.getParameter("pay_id"), "0");
pvo.GUAR_GUBUN  = StrUtil.nvl(request.getParameter("gubun"));
pvo.PAGE        = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT     = 20;
String strCpyNm = StrUtil.nvl(request.getParameter("cpy_nm"));

ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().M_GUARANTEE_LIST_PROC(pvo); // GUARANTEES
ArrayList<BankVO> banks = CodeBean.BANK_LIST_PROC(); // BANKS
ArrayList<CodeVO> status = CodeBean.C_CODE_PROC("GUARANTEE_MASTER_INFO.GUAR_STATUS"); // STATUS

int  intTotalCnt          = 0;
long lngTotalGuaranteeAmt = 0L;

if (arrPayMethods!=null && arrPayMethods.size()>0) {
  intTotalCnt = ((PayMethodVO)arrPayMethods.get(0)).TOTAL_CNT;
  lngTotalGuaranteeAmt = ((PayMethodVO)arrPayMethods.get(0)).SUM_AMT;
}

%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>유효보증서관리</title>
<style>
span.red {color:#FF5733;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "Guarantees.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function detail(obj) {
  location.href = "Guarantee.jsp?cpy_id="+$(obj).parent().parent().attr("cid");
}
function extend(obj, seq) {
  var cid = $(obj).parent().parent().attr("cid");
  var pid = $(obj).parent().parent().attr("payid");
  showCustomConfirm("연장하시겠습니까?", function() {
  $.post("<%=request.getContextPath()%>/mgr/customer/GuaranteeExtendOrDropProc.jsp", {'cid':cid, 'payId':pid, 'seq': seq, 'action':'extend'}, function(data){
	if (data==0) showAlert("연장된 보증서가 있습니다.");
	else window.location.reload();
  })
  }, function(){});
}
function drop(obj, seq) {
  var cid = $(obj).parent().parent().attr("cid");
  var pid = $(obj).parent().parent().attr("payid");
  showCustomConfirm("삭제하시겠습니까?", function() {
  $.post("<%=request.getContextPath()%>/mgr/customer/GuaranteeExtendOrDropProc.jsp", {'cid':cid, 'payId':pid, 'seq': seq, 'action':'drop'}, function(data){
    if (data==0) window.location.reload();
      else showAlert("삭제할 수 없습니다.");
  })
  }, function(){});
}
function modify(obj, seq) {
  var cid = $(obj).parent().parent().attr("cid");
  var pid = $(obj).parent().parent().attr("payid");
  location.href = "GuaranteeReg.jsp?cpy_id="+cid+"&payId="+pid+"&seq="+seq;
}
function a311(obj) {
  var cid = $(obj).parent().parent().attr("cid");
  var s = $(obj).parent().parent().attr("payid");
  if (s.indexOf("xx")>-1) {
    var bp = s.split("xx");
    $.ajax({
      url:strContextPath + "/web/transaction/A311.jsp", 
      type: 'post',
      data:{'cpy_id':cid,'bank_cd':bp[0],'pay_cd':bp[1]}, 
      async: true,
      success: function(data) {
        var json = JSON.parse($.trim(data));
        intLimitSum = json.limit;
        json.msg = "<h4 style='margin-top:0;padding-top:0;'>"+$("select[name='bnk_pay_id'] option:selected").text()+" 한도조회결과</h4>" + json.msg;
        showAlert(json.msg);
      },
      beforeSend: function() {
        showSpinner("응답을 기다리고 있습니다.");
      },
      complete: function() {
        hideSpinner();
      }
    });
  }
}
function searchCompany() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch.cid.value = $(obj).attr("cid");
  document.frmSearch.cpy_nm.value = $(obj).text();
  closePopup();
}
function showExtendForms() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/GuaranteeExtendAllForPopup.jsp'});
}
function extendAll() {
  var date = $("form[name='frmExtendAll'] input[name=val_date]").val();
  if (date == "") toast("날짜를 지정해주세요.");
  else {
	closePopup();
	$.post("<%=request.getContextPath()%>/mgr/customer/GuaranteesExtendAllProc.jsp", {'date': date}, function(data) {
	  if(data<0) showAlert("일괄연장에 실패하였습니다.");
	  else showAlert(data + "건 연장되었습니다.");
	});
  }
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
  <span class='title'>유효보증서관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cid' value='<%=pvo.CPY_ID%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>회원사</label>
          <input type='search' name='cpy_nm' readOnly placeholder='회원사' onclick='searchCompany();' onchange='goPage(1);' value='<%=strCpyNm%>'>
        </li>
        <li>
          <label>보증기관</label>
          <select name='gubun' onchange='goPage(1);'>
            <option value=''></option>
            <option value='KODIT' <%=(pvo.GUAR_GUBUN.equals("KODIT"))?" selected":"" %>>신보</option>
            <option value='KIBO' <%=(pvo.GUAR_GUBUN.equals("KIBO"))?" selected":"" %>>기보</option>
            <option value='KOREG' <%=(pvo.GUAR_GUBUN.equals("KOREG"))?" selected":"" %>>재단</option>
            <option value='ETC' <%=(pvo.GUAR_GUBUN.equals("ETC"))?" selected":"" %>>기타</option>
          </select>
        </li>
        <li>
          <label>은행</label>
          <select name='bnk_cd' onchange='goPage(1);'>
            <option value=''></option>
            <%
            if (banks!=null && banks.size()>0) {
              for (BankVO b : banks) {
                out.println("<option value='"+b.BNK_CD+"'"+((b.BNK_CD.equals(pvo.BNK_CD))?" selected":"")+">"+b.BNK_NAME+"</option>");
              }
            }
            %>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='Guarantees.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>


<div style='padding:10px 0 20px 0;'>
  <a onclick='showExtendForms();' class='btn darkred'>근도래만기일괄연장</a>
  <span class='more' style='font-size:1.2em;font-weight:bold;'>유효보증총액 : <%=StrUtil.addComma(lngTotalGuaranteeAmt) %>원</span>
</div>

<table class='detail'>
  <thead>
    <tr>
      <th class='left mobile_hide'>회사명</th>
      <th class='left mobile_hide'>사업자번호</th>
      <th class='left mobile_hide'>구분</th>
      <th class='left mobile_hide'>은행</th>
      <th class='left'><span class='mobile_hide'>결제수단</span><span class='mobile_show'>내용</span></th>
      <th class='mobile_hide'>보증기간</th>
      <th class='mobile_hide'>유효만기일</th>
      <th class='right mobile_hide'>보증액</th>
      <th class='right mobile_hide'>변동액</th>
      <th class='left mobile_hide'>메모</th>
      <!-- <th class='left mobile_hide'>등록</th>
      <th class='left mobile_hide'>수정</th> -->
      <th class='left' style='width:10%;'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arrPayMethods!=null && arrPayMethods.size()>0) {
  String strPayCode = "";
  for (PayMethodVO t : arrPayMethods) {
    strPayCode = t.BNK_CD+"xx"+t.PAY_ID;
    String strCodeName = t.GUAR_STATUS;
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO c : arrCodes) {
        if (c.CODE_CD.trim().equals(t.GUAR_STATUS.trim())) strCodeName = c.CODE_NM;
      }
    }
    String strFrom    = t.GUAR_CRA_DATE.substring(0, 10);
    String strTo      = t.GUAR_EXP_DATE.substring(0, 10);
    Long diffDay    = DateTimeUtil.diff("", t.GUAR_VAL_DATE.substring(0, 10), "-");
%>
    <tr cid='<%=IntegerCryptoUtil.crypt(t.CPY_ID) %>' payid='<%=strPayCode%>'>
      <td class='mobile_hide'><%=t.CPY_NAME %></td>
      <td class='mobile_hide'><%=FormatUtil.addDashBizNo(t.CPY_BUSINESS_NO) %></td>
      <td class='mobile_hide'><%=strCodeName %></td>
      <td class='mobile_hide'><%=t.BNK_NAME %></td>
      <td style='white-space:wrap;'>
        <div class='mobile_show'><%=t.CPY_NAME %><br/><%=FormatUtil.addDashBizNo(t.CPY_BUSINESS_NO) %></div>
        <div class='mobile_show'><%=t.BNK_NAME %><br/></div>
        <%=t.PAY_SDESC %>
        <div class='mobile_show'>
          <br/>유효만기일 : <%=t.GUAR_VAL_DATE.substring(0, 10)  %>
          <br/>보증액 : <%=StrUtil.addCommaAfterRound(t.GUAR_TOTAL_AMT) %>원
          <br/><br/><span style='border-top:1px solid #ddd;padding-top:10px;'><%=t.MEMO %></span>
        </div>
      </td>
      <td class='center mobile_hide'><%=strFrom  %> ~ <%=strTo  %></td>
      <td class='center mobile_hide'><%=t.GUAR_VAL_DATE.substring(0, 10)  %> <span class='<%=diffDay<8?"red":"" %>'>(<%=diffDay %>일 전)</span></td>
      <td class='right mobile_hide'><%=StrUtil.addCommaAfterRound(t.GUAR_TOTAL_AMT) %></td>
      <td class='right mobile_hide'><%=StrUtil.addCommaAfterRound(t.CHANGE_AMT) %></td>
      <td class='mobile_hide' style='white-space:wrap;'><%=t.MEMO %></td>
      <%-- <td class='mobile_hide'><%=t.WRITE_ID %> (<%=getOnlyDate(t.WRITE_DATE) %>)</td>
      <td class='mobile_hide'><%=(t.MODIFY_ID + " (" + getOnlyDate(t.MODIFY_DATE) +")").replace(" ()", "") %></td> --%>
      <td class='left'>
        <a onclick='detail(this)' class='btn'>상세</a><div class='mobile_show'><br><br></div>
        <a onclick='a311(this)' class='btn'>한도조회</a><div class='mobile_show'><br><br></div>
        <a onclick='modify(this, <%=t.CPY_GUAR_SEQ %>);' class='btn lurian'>수정</a><div class='mobile_show'><br><br></div>
        <a onclick='extend(this, <%=t.CPY_GUAR_SEQ %>)' class='btn'>연장</a>
        <a onclick='drop(this, <%=t.CPY_GUAR_SEQ %>)' class='btn darkred mobile_hide'>삭제</a>
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

<script>

</script>

<%@ include file="../Footer.jsp" %>