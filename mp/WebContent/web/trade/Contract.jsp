<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.common.MobileUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.CtItemVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.AbnormalConfiguration" %>
<%@ page import="kr.co.mp.trade.AbnormalTransactionCheck" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
Logger logger = Logger.getLogger("Contract.jsp");
String strReturnForError = "<script>alert('열람권한이 없습니다.');location.href = '"+request.getContextPath()+"';</script>";
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCtId = 0;
try {
  intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
} catch (Exception e) {
  logger.debug("No Logging CpyId : " + StrUtil.nvl(request.getParameter("seq")));
  logger.debug(e.toString());
}
if (intCtId==0) {
  out.print(strReturnForError);
  return;
}

String MOBILE_YN          = StrUtil.nvl((String)pageContext.getAttribute("MOBILE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (MOBILE_YN.equals("Y") && MobileUtil.isMobile(request)) SIGN_EXCLUDE_YN = "Y"; // MOBILE APPROVAL IS REGISTERED, AND IF IT IS A MOBILE ENVIRONMENT, THE SIGNATURE IS EXCLUDED.

TradeBean bean = new TradeBean();
CtHeaderVO vo = bean.CT_HEADER_DETAIL_PROC(intCtId);
ArrayList<CtItemVO> arr = bean.CT_ITEM_LIST_PROC(intCtId);

if (vo==null || StrUtil.nvl(vo.CTID).equals("") || StrUtil.nvl(vo.CTID).equals("0") || arr==null || arr.size()==0) { // No data.
  logger.debug("No Data");
  out.print(strReturnForError);
  return;
}
if (!vo.CPYBUYER.equals(strCpyId) && !vo.CPYSELLER.equals(strCpyId)) { // Only both parties to the contract can view it. This option only applies to user pages.
  System.out.println("no-my-data");
  out.print(strReturnForError);
  return;
}

String strRemoteIP = LoginUtil.getClientIpAddr(request);
String strCpyBizNo = "";
if (vo.STATUS.equals("025")) { // 확인결제인 경우 구매사가 전송주체
  strCpyBizNo = vo.BUYER_BIZ_NO;
  vo.BUYER_IP = strRemoteIP;
} else {
  strCpyBizNo = (vo.CTTYPE.equals("B")) ? vo.SELLER_BIZ_NO : vo.BUYER_BIZ_NO;
  if (vo.CTTYPE.equals("B")) vo.SELLER_IP = strRemoteIP;
  else vo.BUYER_IP = strRemoteIP;
}
boolean isApprover = false; // 승인대상자인지

if (vo.STATUS.equals("020")) {
  if (vo.CTTYPE.equals("B") && vo.CPYSELLER.equals(strCpyId)) isApprover = true;
  if (vo.CTTYPE.equals("S") && vo.CPYBUYER.equals(strCpyId)) isApprover = true;
}



/********** CHECH ABNORMAL TRANSACTION ************/
String strAbnormalCode    = "";
String strAbnormalMessage = "";
if (isApprover) {
  AbnormalTransactionCheck abnormal = new AbnormalTransactionCheck();
  boolean start = abnormal.initialize(Integer.parseInt(strCpyId), vo, arr);
  if (start && !abnormal.initLimit().equals("0000")) {
    strAbnormalMessage = abnormal.getFailMsgInitLimit();
  }
  if (start && strAbnormalMessage.equals("")) {
    String msg = StrUtil.nvl(abnormal.execute("CHECK_STEP_RECEIVED"));
    if (!msg.equals("00000")) {
      strAbnormalCode    = msg;
      strAbnormalMessage = abnormal.getErrorMsgAndSave(msg);
    }
  }
}
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>매매계약서</title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script>
const intMessageShowTime = 2000;
/* close bPopup window */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
function openTaxBill(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/common/Tax.jsp?seq='+seq});
}
/* cancel */
function cancel() {
  showCustomConfirm("계약을 취소하시겠습니까?<br/>취소된 매매계약서는 복원되지 않습니다.", function() {
  $.post("ContractCancelProc.jsp",$("form[name='frmEnt']").serialize(),function(data){
   if (data==0) {
     showAlert("취소할 수 없습니다.<br/>취소는 승인전까지 가능합니다.<br/>진행상태가 변경되었을 수 있으니 다시 확인하십시오.", function(){
       window.location.reload();
     });
   } else {
     showSpinner("취소처리중입니다.");
     $.post(strContextPath + "/common/kakaotalk/Send.jsp", {'tcd':'M007', 'ctid':'<%=StrUtil.nvl(request.getParameter("seq"))%>'}, function(data){
       location.href = strContextPath + "/web/trade/";
       console.log("KAKAO RESPONSE =", data);
     });
   }
  });
  }, function(){});
}
function approval() {
  <% 
  if (SIGN_EXCLUDE_YN.equals("Y")) out.println("goSubmit();");
  else out.println("loadCert();");
  %>
}
/* call signature window */
function loadCert() {
  if (document.frmEnt.ctid.value.length > 0 && document.frmEnt.token.value.length > 0) { // FAILED DURING TRANSMISSION, RETRANSMISSION ATTEMPTED
    send();
    return;
  }
  $("#element_to_pop_up").empty();
  var url = strContextPath + '/static/programs/cert/?ssn='+$("#bizno").val();
  /* $("#signdata").val(""); */
  if (!$("#signdata").val()) {
    $("#signdata").val("");
  }
  $('#element_to_pop_up').append("<iframe id='ifrm_cert'></iframe>");
  $('#ifrm_cert').attr('src', url);
  $('#element_to_pop_up').bPopup();
  document.getElementById("ifrm_cert").contentWindow.postMessage("CALL", "*");
}
/* callback from signature window */
window.addEventListener("message", function(e) {
  hideLoading();
  $("#sgn_id").val("");
  $("#signdata").val("");
  if (e.data=="CLOSE") { // click cancel button
    closePopup();
    return;
  } else if (e.data=="CLOSE_FAIL_SSN") { // mismatch biz no.
    closePopup();
    toast("사업자번호가 불일치합니다.", intMessageShowTime);
    return;
  }
  if (e.data.length>30) { // success
    $("#sgn_id").val("0000");
    var k = (e.data.split("$data")[0]).replace("$dn=", ""); // extract header values
    $("#signdata").val(k);
    closePopup();
    goSubmit();
  }
  return;
});
//////////////////////////SUBMIT //////////////////////////
function check() {
  <% if (!strAbnormalMessage.equals("")) { %>
  showAlert("<%=strAbnormalMessage%>");
  return false;
  <% } %>
  return true;
}
function goSubmit() {
  if (check()) {
    $.ajax({
      url:"ContractConfirmProc.jsp", 
      type: 'post',
      data:$("form[name='frmEnt']").serialize(), 
      async: true,
      success: function(data) {
        console.log("From ContractConfirmProc : " + data);
        hideSpinner();
        var json = JSON.parse(data);
        if (json.step!="send") {
          showAlert(json.msg, function(){
            if (json.step=="session") {
              location.href = "<%=request.getContextPath()%>/web/Login.jsp";
            } else if (json.step=="confirm") {
              document.frmEnt.action = "ContractsReceived.jsp";
              document.frmEnt.method = "post";
              document.frmEnt.submit();
            }
          });
          $("div.result-message").addClass("error-message");
        } else {
          document.frmEnt.token.value = json.msg;
          send();
        }
      },
      error: function(request, status, error) {
        hideSpinner();
        showAlert("통신에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
        console.log(request.status + " : " + request.responseText + " : " + error);
      }, 
      beforeSend: function() {
        showSpinner("결제 승인 중입니다.");
      },
      complete: function() {
        if (window.sendInProgress) {
          console.log("goSubmit()의 complete: send() 실행 중이므로 hideSpinner() 실행 안 함");
          return;
        }
        hideSpinner();
      }
    });
  }
}
function send() {
  window.sendInProgress = true;
  $.ajax({
    url:strContextPath + "/web/transaction/B311.jsp", 
    type: 'post',
    data:$("form[name='frmEnt']").serialize(), 
    async: true,
    success: function(data) {
      // console.log(data);
      var json = JSON.parse(data);
      if (json.is) {
        showAlert("전송되었습니다.", function() {
          document.frmEnt.action = "ContractsReceived.jsp";
          document.frmEnt.method = "post";
          document.frmEnt.submit();
        });
      } else {
    	  //showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
   	  	showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg, function() {
            document.frmEnt.action = "ContractsReceived.jsp";
            document.frmEnt.method = "post";
            document.frmEnt.submit();
        });
      }
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
      window.sendInProgress = false;
    }
  });
}
$(document).ready(function() {
<% if (vo.STATUS.equals("040") || vo.STATUS.equals("050")) { %>
  $("#banking-url").show();  
  $("ul.bank-list").load("<%=request.getContextPath()%>/static/BankUrl.htm");
<% } %>
<% if (!strAbnormalMessage.equals("")) { %>
  showAlert("<%=strAbnormalMessage%>", function() {
   if ("KD001" == "<%=strAbnormalCode%>") {
     document.frmEnt.action = "GenuineTradeConfirm.jsp";
     document.frmEnt.submit();
   }
  });
<% } %>
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>매매계약서</span>
  <span class='more'>
    <a href='javascript:self.print();' class='btn lurian'>인쇄</a>
    <a href='<%=request.getContextPath() %>/web/trade/index.jsp' class='btn'>현황판</a>
  </span>
</div>

<form name='frmEnt' method='post'>
<input type='hidden' name='seq' value='<%=intCtId%>'>
<input type='hidden' name='intBuyerCpyId' value='<%=vo.CPYBUYER%>'>
<!-- TOKEN FOR SEND -->
<input type='hidden' name='ctid' value='<%=IntegerCryptoUtil.crypt(intCtId) %>'>
<input type='hidden' name='status' value='<%=vo.STATUS %>'>
<input type='hidden' name='token'>

<!-- ELECTRONIC SIGNATURE REQUIRED -->
<input type="hidden" id='bizno' name='bizno' value='<%=strCpyBizNo%>'>
<input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
<input type='hidden' id='signdata' name='signdata'><!-- 결과값 : 서명값 -->
</form>
<div id='element_to_pop_up'></div>

<h3>결제정보</h3>

<ul class='detail'>
  <li class='th'>계약번호</li>
  <li class='td'><%=StrUtil.nvl(vo.CTNO) %></li>
  <li class='th'>결제금액</li>
  <li class='td'><strong style='color:red;'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></strong>원</li>
  <li class='th'>구매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.BUYER_NM) %> (<%=FormatUtil.addDashBizNo(vo.BUYER_BIZ_NO) %>, <%=vo.BUYER_CEO_NM %>)</li>
  <li class='th'>판매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.SELLER_NM) %> (<%=FormatUtil.addDashBizNo(vo.SELLER_BIZ_NO) %>, <%=vo.SELLER_CEO_NM %>)</li>
  <li class='th'>만기(대출상환)일</li>
  <li class='td'>
    <% 
    if (StrUtil.nvl(vo.MTYDATE).equals("")) out.print("구매사 지정");
    else out.print(FormatUtil.addSeparatorDate(StrUtil.nvl(vo.MTYDATE)) + " [" + (DateTimeUtil.diff(FormatUtil.addSeparatorDate(StrUtil.nvl(vo.TRADEDATE, DateTimeUtil.getCurrentDate(""))), FormatUtil.addSeparatorDate(StrUtil.nvl(vo.MTYDATE)), "/")+1) + "일]");
    %>
  </li>
  <li class='th'>결제은행/수단</li>
  <li class='td'>
    <%
    if (StrUtil.nvl(vo.BNK_NAME).equals("")) out.print("구매사 지정");
    else out.print(StrUtil.nvl(vo.BNK_NAME) + " " + StrUtil.nvl(vo.PAY_SDESC));
    %>
  </li>
  <li class='th'>MP수수료부담</li>
  <li class='td'><%=(vo.MPPAYCPY.equals("1"))?"판매기업":"구매기업"%> [ <font color='red'><strong><%=StrUtil.addComma(StrUtil.extractInteger(vo.MPFEE_TOTALAMT)) %></strong></font>원 ]</li>
  <li class='th'>진행상태</li>
  <li class='td'>
    <strong style='color:blue;'><%=StrUtil.nvl(vo.CODE_NM) %></strong>
    <% if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) { %>
    &nbsp;(<%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.SETTLEDATE)) %>)
    <% } %>
  </li>
</ul>

<h3>첨부세금계산서 정보</h3>

<ul class='detail'>
  <li class='th'>세금계산서 승인번호</li>
  <li class='td'>
    <%
    if (StrUtil.nvl(vo.TAXAPPROVALNO).equals("")) out.print("");
    else out.print("<a onclick='openTaxBill("+StrUtil.nvl(vo.SBILL_SEQ)+")' style='color:blue;'>" + StrUtil.nvl(vo.TAXAPPROVALNO) + "</a>");
    %>
  </li>
  <li class='th'>사업자구분</li>
  <li class='td'><%=StrUtil.nvl(vo.TAXTYPE_NM) %></li>
  <li class='th'>작성일</li>
  <li class='td'><%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.BILL_DT)) %></li>
  <li class='th'>발행금액</li>
  <li class='td'><%=StrUtil.addComma(vo.BILL_SUM) %>원</li>
</ul>

<h3>품목정보</h3>

<!-- items table -->
<table id='items' class='detail'>
  <colgroup>
    <col width='*'/>
    <col width='80' class='mobile_hide'/>
    <col width='80' class='mobile_hide'/>
    <col width='90'/>
    <col width='90' class='mobile_hide'/>
    <col width='100'/>
  </colgroup>
  <thead>
    <tr>
      <th class='left'>품목</th>
      <th class='right mobile_hide'>수량</th>
      <th class='left mobile_hide'>단위</th>
      <th class='right'>공급가</th>
      <th class='right mobile_hide'>세액</th>
      <th class='right'>총액</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CtItemVO ivo : arr) {
%>
    <tr>
      <td style='white-space:wrap;'><%=StrUtil.nvl(ivo.ITEMNAME) %></td>
      <td class='right mobile_hide'><%=StrUtil.addComma(ivo.QTY) %></td>
      <td class=' mobile_hide'><%=StrUtil.nvl(ivo.UNIT) %></td>
      <td class='right'><%=StrUtil.addComma(ivo.SUPPLYAMT) %></td>
      <td class='right mobile_hide'><%=StrUtil.addComma(ivo.TAXAMT) %></td>
      <td class='right'><%=StrUtil.addComma(ivo.TOTALAMT) %></td>
    </tr>
<%
  }
}
%>    
  </tbody>
</table>

<p>&nbsp;</p>

<div class='btns'>
<% 
if (isApprover) { 
  out.println("<a onclick='approval();'>결제승인</a>");
  out.println("<a onclick='cancel();' class='cancel'>계약취소</a>");
} else {
  if (vo.STATUS.equals("010")) {
    if (StrUtil.nvl(vo.CTTYPE).equals("B")) out.println("<a href='ContractReg.jsp?seq="+vo.CTID+"'>수정</a>");
    else out.println("<a href='ContractRegForSeller.jsp?seq="+vo.CTID+"'>수정</a>");
  } else if (vo.STATUS.equals("020")) out.println("<a onclick='cancel();' class='cancel'>계약취소</a>");
  // else if (vo.STATUS.equals("025") || vo.STATUS.equals("707")) out.println("<a onclick='" + ((SIGN_EXCLUDE_YN.equals("Y"))?"goSubmit":"loadCert") + "();'>전송</a>");
  else if (vo.STATUS.equals("025")) out.println("<a onclick='" + ((SIGN_EXCLUDE_YN.equals("Y"))?"goSubmit":"loadCert") + "();'>전송</a>");
}
%>
</div>

<p>&nbsp;</p>

<style>
ul.bank-list {display:flex;flex-flow:row wrap;border:1px solid #ddd;padding:10px;}
ul.bank-list li {width:100px;padding:3px;}
</style>
<div id='banking-url' style='display:none;'>
  <h3>인터넷뱅킹 바로가기</h3>
  <ul class='bank-list'></ul>
</div>



<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../includes/Footer.jsp" %>