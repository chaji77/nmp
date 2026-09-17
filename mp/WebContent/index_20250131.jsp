<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
// 로그인이 필요하면 true로 변경하세요.
// @require LoginCheck.jsp
// pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="./web/includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
%>
<%@ include file="./web/includes/Header.jsp" %>
<title></title>

<!-- in-page styles -->
<style>
ul.banner-block {border-bottom:1px solid #ddd;min-height:360px;}
ul.banner-block>li {float:left;}
ul.banner-block>li:first-child {width:calc(100% - 245px);border-right:1px solid #ddd;padding-left:20px;background-color:#eef;}
ul.banner-block>li:last-child {padding:20px 0 20px 20px;width:200px;}
ul.banner-block>li>div.banner {min-height:340px;line-height:1.4em;font-size:1.1em;height:300px;}
ul.banner-block>li>div.banner>h1 {padding-top:20px;font-size:1.6em;line-height:1.2em;letter-spacing:-1px;margin-top:20px;margin-bottom:30px;}
ul.banner-block>li>div.banner>h2 {font-size:1.3em;margin:40px 0;line-height:2em;}
ul.banner-block>li>div.banner>p {margin-bottom:10px;padding-right:10px;}
ul.banner-block>li>div.banner>p>strong {color:#FF5733;}
ul.banner-block>li>ul {display:flex;flex-flow:row wrap;justify-content:flex-end;}
ul.banner-block>li>ul>li {position:relative;width:76px;margin-top:17px;margin-bottom:17px;text-align:center;transition:color .2s ease-in-out;}
ul.banner-block>li>ul>li>a {color:black;}
ul.banner-block>li>ul>li>a:hover {color:#78B3EA;cursor:pointer;}
ul.banner-block>li>ul>li:nth-child(even) {margin-left:40px;}
ul.banner-block>li>ul>li i {font-size:3em;line-height:1.2em;}

div.banner-btns {position:absolute;font-size:30px;width:auto;margin-top:-60px;margin-left:240px;color:#aaa;}
div.banner-btns i:hover {cursor:pointer;color:#FF5733;}

@keyframes blink {0% {opacity:0;} 10% {opacity:1;} 90% {opacity:1;} 100% {opacity:0;}}
span.contract-cnt {position:absolute;right:0;color:white;background-color:#FF5733;border-radius:50px;padding:10px 15px;font-weight:bold;animation:blink 3s infinite;}
span.due-date {background-color:#FF5733;color:white;padding:10px;border-radius:10px;}

ul.customer-service-block {
  clear:both;position:relative;min-height:180px;
  /* background-image:url('./static/images/notice.png'); */
  background-repeat:no-repeat;
  background-position:right bottom;
  background-size: 160px;
}
ul.customer-service-block>li {float:left;min-height:180px;padding-left:20px;padding-right:20px;padding-top:40px;}
ul.customer-service-block div.title {width:100%;font-size:1.6em;font-weight:bold;vertical-align:top;border-bottom:1px solid #fafafa;height: 40px;margin-bottom:20px;}
ul.customer-service-block div.title.call {font-size:3em;padding-top:2px;padding-bottom:7px;border-bottom:0;}
ul.customer-service-block div.title.call a {color:#FF5733;}
ul.customer-service-block>li>ul>li {padding:3px 0;overflow:hidden;white-space:nowrap;text-overflow:elipsis;word-break:break-all;}
li.customer-service-block-li-separator {border-right:1px solid #ddd;}

div#load-url-via-popup {display:none;position:absolute;z-index:210;top:20px;left:20px;padding:10px;background-color:#fff;border-radius:10px;border:3px solid #bbb;}
div#load-url-via-popup div.body {max-height:500px;overflow:auto;}
	
div.footer-nav {margin-top:0;}

@media only screen and (max-width:767px) {
  ul.banner-block>li>div.banner>h1 {font-size:1.3em;}
  ul.banner-block>li>div.banner>h2 {font-size:1.1em;margin:20px 0;}
  ul.banner-block>li>div.banner>p {font-size:0.9em;text-align:justify;}
  ul.banner-block>li:first-child, ul.banner-block>li:last-child {width:100%;border-right:0;padding-left:0;background-color:#fff !important;}
  ul.banner-block>li:last-child {padding:20px 0;border-top:1px solid #ddd;background-color:#eef !important;}
  ul.banner-block>li>ul {display:flex;flex-flow:row wrap;justify-content:flex-start;}
  ul.banner-block>li>ul>li:nth-child(even), ul.banner-block>li>ul>li:nth-child(odd) {margin-left:10px;}
  ul.banner-block>li>ul>li i {font-size:3em;}
  span.due-date {padding:5px;}
  ul.customer-service-block {border-top:1px solid #ddd;padding-top:40px;background-image:none;}
  ul.customer-service-block>li {width:calc(100% - 20px);padding:0;}
  li.customer-service-block-li-separator {border-right:0;}
}
</style>
<script>
var timer_banner;
var arr_banner_color = ['#eef', '#efe', '#fee', '#eff', '#ffe'];
function showBannerButton() {
  for (var i=0; i<$("div.banner").length; i++) {
    $("div.banner-btns").append('<i class="fa-solid fa-circle-dot" idx="'+i+'"></i> ');
  }
  $("div.banner-btns i").eq(0).css("color", "#FF5733");
}
function rotate_banner() {
  var banner_cnt = $("div.banner").length;
  var banner_idx = 0;
  var banner_tgt_idx = 0;
  $("div.banner").each(function(idx, item) {
    if ($(this).is(":visible")) banner_idx = idx;
  });
  if (banner_idx == banner_cnt-1) banner_tgt_idx = 0;
  else banner_tgt_idx = banner_idx+1;
  show_banner(banner_tgt_idx);
}
function show_banner(banner_tgt_idx) {
  clearTimeout(timer_banner);
  $("div.banner").hide();
  $("div.banner").eq(banner_tgt_idx).fadeIn();
  $("div.banner-btns i").css("color", "#aaa");
  $("div.banner-btns i").eq(banner_tgt_idx).css("color", "#FF5733");
  $("ul.banner-block>li:first-child").css("background-color", arr_banner_color[banner_tgt_idx]);
  timer_banner = setTimeout(rotate_banner, 5000);
}
function loadPop(url) {
  const img = new Image();
  img.src = url;
  img.onload = function() {
    $("#load-url-via-popup div.body").html("<img src='"+url+"'>");
    $("#load-url-via-popup").css("width", (img.width+8)+"px");
    $("#load-url-via-popup").slideDown();
  }
}
function closePopupWindow() {
  $("#load-url-via-popup div.body").html("");
  $("#load-url-via-popup").slideUp();
}
$(document).ready(function() {
  showBannerButton();
  timer_banner = setTimeout(rotate_banner, 5000);
  $("div.banner-btns i").on("click", function() {
    show_banner($(this).attr("idx"));
  });
});
</script>
<%@ include file="./web/includes/Navigation.jsp" %>

<ul class='banner-block'>
  <li>
    <div class='banner'>
      <h1>B2B 구매자금을 신청하시기 전에 (세금)계산서 발급일자를 먼저 확인하세요.</h1>
      <h2><span class='due-date'>2024/11/30</span> 작성한 세금계산서는 <span class='due-date'>2024/12/30</span> 까지 이용가능합니다.</h2>
      <p><i class="fa-solid fa-asterisk"></i> 한국은행에서 규정한 금융기관 기업구매자금대출 취급세칙 제6조 3항에 따라<br/>판매대금추심의뢰서는 세금계산서 등의 발급일로부터 31일 이내에 추심의뢰하거나 전송한 것이어야 합니다.</p>
      <p>&nbsp;</p>
      <!-- p><a href='' class='btn'>자세히 보기</a></p -->
    </div>
    <div class='banner' style='display:none;'>
      <h1>신용보증기금 보증증액 상담 안내</h1>
      <p>2023년도 결산기준 신용보증기금 B2B 구매자금 기 보증 증액 상담을 진행합니다.</p>
      <p><i class="fa-solid fa-asterisk"></i> <strong>대상기업</strong> : 2023년 결산 재무제표가 확정, 신고됨에 따라 추가로 자금수요가 발생한 회원사</p>
      <p><i class="fa-solid fa-asterisk"></i> <strong>구비서류/신청방법</strong> : 사업자등록증, 2023년 재무제표, 부가세 과세표준증명원, 보증 상담 신청서 1부</p>
      <p>당사는 B2B 구매자금 중개역할을 담당하는 Market Place(MP)로서 일체의 보증 및 심사에 관여하지 않으며, 해당 업무는 주무부서인 보증기관의 평가에 의해 결정됨을 알려드립니다.</p>
      <p>&nbsp;</p>
      <p><a href='//image.mp1.co.kr/images/data/kodit_hc_202404.zip' class='btn'>신청서 다운로드</a></p>
    </div>
    <div class='banner' style='display:none;'>
      <h1>B2B대출거래진정성강화를 위한 제도개선 안내 (KODIT 신용보증기금)</h1>
      <p><i class="fa-solid fa-asterisk"></i> 면세 포함 의무발행대상 여부와 관계없이 <strong>국세청(홈텍스)을 통한 전자세금계산서 첨부 의무화</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> B2B대출 부정 사용 예방을 위한 <strong>이상거래 모니터링 강화</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> 경상적 매출이 발생하는 정상적 사업장 여부를 확인하는 <strong>판매기업 사전검증 도입</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> B2B대출거래 기본요건 관리강화를 위하여 매매계약체결 시 <strong>사업자용 공인(범용)전용인증서 서명 필수</strong> 확인</p>
      <p>&nbsp;</p>
      <p><a onclick="loadPop('//image.mp1.co.kr/images/popup_master/notice_151217.jpg');" class='btn'>자세히 보기</a></p>
    </div>
    <div class='banner-btns'></div>
  </li>
  <li>
    <ul>
      <li><a href='<%=request.getContextPath()%>/web/trade/ContractReg.jsp'><i class="fa-solid fa-file-signature"></i><br/>매매계약서 작성</a></li>
      <li><a href='<%=request.getContextPath()%>/web/trade/ContractsReceived.jsp'><span class='contract-cnt'>${RECEIVED_CONTRACT}</span><i class="fa-solid fa-receipt"></i><br/>받은 계약서</a></li>
      <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/download/Sign.jsp'><i class="fa-solid fa-address-card"></i><br/>인증서확인</a></li>
      <li><a href='<%=request.getContextPath()%>/web/customer/guide/Service.jsp'><i class="fa-solid fa-clipboard-question"></i><br/>서비스안내</a></li>
      <li class='mobile_hide'><a href="<%=ConfigurationMgr.getInstance().getString("REMOTE_SUPPORT_URL") %>" target="_blank"><i class="fa-solid fa-desktop"></i><br/>원격지원</a></li>
      <li><a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><i class="fa-solid fa-headset"></i><br/><strong><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></strong></a></li>
    </ul>
  </li>
</ul>

<ul class='customer-service-block'>
  <li class='customer-service-block-li-separator'>
    <div class='title call'><a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></a></div>
    <div><span style='background-color:black;padding:5px 8px;border-radius:5px;color:white;'><i class="fa-solid fa-fax"></i> fax</span> <%=ConfigurationMgr.getInstance().getString("OWNER_FAX") %></div>
  </li>
  <li class='customer-service-block-li-separator'>
    <div class='title'>고객센터 운영시간</div>
    <ul>
      <li><%=ConfigurationMgr.getInstance().getString("OWNER_WORKING_TIME") %></li>
      <li><%=ConfigurationMgr.getInstance().getString("OWNER_BREAK_TIME") %></li>
    </ul>
  </li>
  <li>
    <div class='title'><a href='<%=request.getContextPath()%>/web/customer/notice/Notices.jsp'>공지사항</a></div>
    <ul style='max-width:300px;'>
    <%@ include file="./web/customer/notice/NoticeListForMain.jsp" %>
    </ul>
  </li>
</ul>

<div id='load-url-via-popup'>
  <div style='width:100%;height: 34px;'><span class='more close' onclick='closePopupWindow();'></span></div>
  <div class='body'></div>
</div>

<%@ include file="./web/customer/notice/PopupNotice.jsp" %>
<%@ include file="./web/includes/Footer.jsp" %>
