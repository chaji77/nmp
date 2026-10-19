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

ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().M_CYCLN_GUARANTEE_LIST_PROC(pvo); // GUARANTEES
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
<title>싸이클론 유효보증서관리</title>
<style>
span.red {color:#FF5733;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "CyclnGuarantees.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function detail(obj) {
  location.href = "CyclnGuarantee.jsp?cpy_id="+$(obj).parent().parent().attr("cid");
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
/* CL120 한도조회. 전문을 등록한 뒤 응답이 올 때까지 2초마다 다시 읽는다. 3분이 지나면 그만둔다.
   취소하면 기다리기만 멈춘다. 이미 등록한 전문은 통신서버가 그대로 보낸다. */
var cl120Run = 0; // 취소하거나 다시 누르면 올라가서 이전 조회의 응답을 버린다
function cl120(obj) {
  var cid = $(obj).parent().parent().attr("cid");
  var url = "<%=request.getContextPath()%>/mgr/customer/CyclnLimitProc.jsp";
  var run = ++cl120Run;
  var fail = function() { if (run!=cl120Run) return; hideSpinner(); showAlert("한도조회에 실패했습니다. 잠시 후 다시 시도하십시오."); };
  showSpinner("은행 응답을 기다리고 있습니다.<br/><br/><a onclick='cl120Cancel();' class='btn'>취소</a>");
  $.post(url, {'cpy_id':cid}, function(data) {
    if (run!=cl120Run) return;
    var sent = JSON.parse($.trim(data));
    if (sent.result!="sent") { hideSpinner(); showAlert(sent.msg); return; }
    var tries = 0;
    (function poll() {
      $.post(url, {'cpy_id':cid, 'tmsg_seq':sent.tmsg_seq, 'req_ymd':sent.req_ymd}, function(d) {
        if (run!=cl120Run) return;
        var json = JSON.parse($.trim(d));
        if (json.result=="wait" && ++tries<90) { setTimeout(poll, 2000); return; }
        hideSpinner();
        showAlert(json.result=="wait" ? "은행 응답이 지연되고 있습니다. 잠시 후 다시 조회하십시오." : json.msg, null, json.result=="ok" ? "cycln-limit-message" : ""); // 결과표는 기본 300px 에 안 들어가 전용 팝업을 쓴다
      }).fail(fail);
    })();
  }).fail(fail);
}
function cl120Cancel() {
  cl120Run++;
  hideSpinner();
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
            <option value='KIBO' <%=(pvo.GUAR_GUBUN.equals("KIBO"))?" selected":"" %>>기보</option>
            <option value='ETC' <%=(pvo.GUAR_GUBUN.equals("ETC"))?" selected":"" %>>비보증</option>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='CyclnGuarantees.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
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
        <a onclick='cl120(this)' class='btn'>한도조회</a><div class='mobile_show'><br><br></div>
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