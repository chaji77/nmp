<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
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
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCtId = 0;
try {
  intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
} catch (Exception e) {
  // System.out.println("Error@Contract.jsp : " + StrUtil.nvl(request.getParameter("seq")));
}
if (intCtId==0) {
  return;
}

TradeBean bean = new TradeBean();
CtHeaderVO vo = bean.CT_HEADER_DETAIL_PROC(intCtId);

String strCpyBizNo = (String)pageContext.getAttribute("CPY_BIZ_NO");
String strGubun    = "B";
if (vo.SELLER_BIZ_NO.equals(strCpyBizNo)) strGubun = "S";
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>B2B대출 진성거래 확약서</title>
<style>
#element_to_pop_up {
    background-color:transparent;
    border-radius:15px;
    color:#000;
    display:none;
    padding:0px;
    padding-right:10px;
    min-width:400px;
    min-height: 180px;
    width:auto;
    height:auto;
}
.b-close{
    cursor:pointer;
    position:absolute;
    right:10px;
    top:5px;
}
#ifrm_cert {width:500px;height:650px;border:0;}
#result-msg i {font-size:8em;margin-bottom:20px;}
</style>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script>
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
}
/* call signature window */
function loadCert() {
  $("#element_to_pop_up").empty();
  var url = strContextPath + '/static/programs/cert/?ssn='+$("#bizno").val();
  $("#signdata").val("");
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
    showAlert("사업자번호가 불일치합니다.");
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
function goSubmit() {
  $.post("GenuineTradeConfirmProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
    if (data==0) showAlert("처리하지 못했습니다. 고객센터에 문의하십시오.");
    else {
      location.href='index.jsp';
    }
  });
}
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>B2B대출 진성거래 확약서</span>
  <span class='more'>

  </span>
</div>

<form name='frmEnt' method='post'>
<input type='hidden' name='ctid' value='<%=intCtId%>'>
<input type='hidden' name='gubun' value='<%=strGubun%>'>
<input type="hidden" id='bizno' name='bizno' value='<%=strCpyBizNo%>'>
<input type='hidden' id='sgn_id' name='sgn_id'>
<input type='hidden' id='signdata' name='signdata'>
</form>
<div id='element_to_pop_up'></div>

<h3></h3>

<ul class='detail'>
  <li class='th'>구매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.BUYER_NM) %> (<%=FormatUtil.addDashBizNo(vo.BUYER_BIZ_NO) %>, <%=vo.BUYER_CEO_NM %>)</li>
  <li class='th'>판매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.SELLER_NM) %> (<%=FormatUtil.addDashBizNo(vo.SELLER_BIZ_NO) %>, <%=vo.SELLER_CEO_NM %>)</li>

  <li class='th'>계약번호</li>
  <li class='td'><%=StrUtil.nvl(vo.CTNO) %></li>
  <li class='th'>결제금액</li>
  <li class='td'><strong style='color:red;'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></strong>원</li>

  <li class='th'>세금계산서 승인번호</li>
  <li class='td'><%=StrUtil.nvl(vo.TAXAPPROVALNO) %></li>
  <li class='th mobile_hide'>&nbsp;</li>
  <li class='td mobile_hide'>&nbsp;</li>
</ul>

<p>&nbsp;</p>
<p>상기 매매계약 내용은 진성거래에 의한 내역임을 확인합니다.</p>
<p>만약 경상적인 진성거래가 아닌 허위·융통거래로 판명될 경우 기 대출금은 즉시 상환하셔야 하며, 미상환 시 민·형사상 책임질 것을 확약합니다.</p>
<p>&nbsp;</p>

<div class='btns'><a onclick='loadCert();'>전자서명</a></div>

<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %>