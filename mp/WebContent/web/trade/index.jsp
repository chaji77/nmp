<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<!-- 내보증서 -->
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<!-- 거래내역 -->
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int    intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;
String strPrsId       = (String)pageContext.getAttribute("PRS_ID");

ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().CT_MY_PAYMETHOD_PROC(intCpyId); // 내보증서

CtHeaderVO pvo     = new CtHeaderVO();
String strPageCode = "A";
pvo.PAGE           = 1;
pvo.ROW_CNT        = 200;
pvo.STATUS         = "000";
String strStartYmd = DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-");
String strEndYmd   = DateTimeUtil.getCurrentDate("-");
int intTargetCpyId = 0;
int intTotalCnt    = 0;
/*
TradeBean bean = new TradeBean();
ArrayList<CtHeaderVO> arr;
try {
  arr = bean.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, intTargetCpyId, strPageCode);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
  arr = null;
}
*/
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>B2B전자결제 거래현황</title>

<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />

<style>
ul.status-bar {display:flex;flex-flow:row wrap;justify-content:center;border-radius:5px;background-color:#246CEB;padding:20px 0;color:#8adcf5;}
ul.status-bar li {line-height:1.4em;text-align:center;width:120px;padding:10px;margin:3px;border-right:1px solid #357dfc;}
ul.status-bar li:last-child {border:0;}
ul.status-bar li i.fa-solid {font-size:4em;}
ul.status-bar li span.cnt {color:white;border-radius:50px;padding:10px 15px;font-weight:bold;background-color:#024ac9;}
ul.status-bar li span.cnt.blink {background-color:#ff0;color:#000;animation:blink 2s infinite;}
ul.status-bar a {color:#8adcf5;}
ul.status-bar a:hover {color:#fff;}
ul.guarantee-list {border-top:1px solid #ddd;border-bottom:1px solid #ddd;margin-bottom:10px;padding:20px 20px 10px 20px;display:flex;flex-flow:row wrap;}
ul.guarantee-list li {margin-bottom: 10px;width:calc(50% - 20px);}
ul.guarantee-list li i {background-color:#246CEB;color:white;border-radius:20px;padding: 8px 10px;}
div.ref {color:#aaa;text-align:center;}
h2 {font-size:1.2em;margin-top:50px;margin-bottom:10px;}
@media only screen and (max-width:767px) {
  ul.status-bar {padding:0;background-color:transparent;}
  ul.status-bar li, ul.status-bar li:last-child {background-color:#246CEB;border:1px solid #ddd;padding: 20px;}
  ul.guarantee-list li {width:calc(100% - 20px);}
}
</style>
<script>
function goDetail(r) {
  location.href = "Contract.jsp?seq="+r;
}
$(document).ready(function() {
  $("ul.status-bar li span.cnt").each(function(idx, item) {
    if ($(item).text()!="0") $(item).addClass("blink"); 
  });
  $(".status-bar").delay(500).slideDown();
  $.post("ContractsTempCnt.jsp", {'cpy_id':'<%=strCpyId%>'}, function(data){
    if (data!=0) $("#temp_contact_cnt").text(data);
    else $("#temp_contact_cnt").remove();
  });
  $("table.searchbox, ul.exp").hide();
});

</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>B2B전자결제</span>
  <span class='more'>
  </span>
</div>

<h2>DASHBOARD</h2>
<ul class='status-bar' style='display:none;'>
  <li><a href='<%=request.getContextPath()%>/web/trade/ContractsSent.jsp'><i class="fa-solid fa-paper-plane"></i><br/><br/>계약승인요청<br/>(보낸계약서)<br/><br/><span class='cnt'>${SENT_CONTRACT}</span></a></li>
  <li><a href='<%=request.getContextPath()%>/web/trade/ContractsReceived.jsp'><i class="fa-solid fa-receipt"></i><br/><br/>계약승인대기<br/>(받은계약서)<br/><br/><span class='cnt'>${RECEIVED_CONTRACT}</span></a></li>
  <li><i class="fa-solid fa-won-sign"></i><br/><br/>인터넷뱅킹대기<br/><br/><br/><span class='cnt'>${SETTLE_STANDBY}</span></li>
  <li><a href='<%=request.getContextPath()%>/web/trade/ContractsMaturityComing.jsp'><i class="fa-solid fa-clock"></i><br/><br/>만기 미도래<br/><br/><br/><span class='cnt'>${YET_MATURITY}</span></a></li>
</ul>

<!-- 약정정보 -->
<%
if (arrPayMethods!=null && arrPayMethods.size()>0) {
%>
<h2>등록된 결제수단</h2>
<ul class='guarantee-list'>
<%
  for (PayMethodVO v : arrPayMethods) {
    out.println("<li><i class='fa-regular fa-file'></i> "+v.BNK_NAME+" "+v.PAY_SDESC+"</li>");
  }
%>
</ul>
<div class='ref'>신규 또는 변경사항은 고객센터(<a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></a>)로 문의하십시오.</div>
<%
}
%>

<h2>
  진행중 매매계약
  <span class='more' style='font-size:0.8em;font-weight:normal;'><a href='ContractsTemp.jsp' class='btn'>임시보관함<span id='temp_contact_cnt'></span></a></span>
</h2>

<jsp:include page="Contracts.jsp">
  <jsp:param name="cpy_id" value="<%=strCpyId %>" />
  <jsp:param name="prs_id" value="<%=strPrsId %>" />
  <jsp:param name="page_code" value="<%=strPageCode %>" />
  <jsp:param name="page" value="<%=pvo.PAGE %>" />
  <jsp:param name="status" value="<%=pvo.STATUS %>" />
  <jsp:param name="start_ymd" value="<%=strStartYmd %>" />
  <jsp:param name="end_ymd" value="<%=strEndYmd %>" />
  <jsp:param name="tc" value="<%=intTargetCpyId %>" />
  <jsp:param name="detail_page" value="Contract.jsp" />
</jsp:include>

<%@ include file="../includes/Footer.jsp" %>