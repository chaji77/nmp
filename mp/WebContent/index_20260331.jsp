<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
// 로그인이 필요하면 true로 변경하세요.
// @require LoginCheck.jsp
// pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="./web/includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intTotalCustomerCount = CustomerBean.COMPANY_CNT_PROC();
%>
<%@ include file="./web/includes/Header.jsp" %>
<title><%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %></title>

<meta name="description" content="기업 간 거래(B2B)를 위한 <%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>. 안전하고 효율적인 B2B 거래를 위한 금융 솔루션이 디지털 트랜스포메이션을 돕습니다.">
<meta name="robots" content="index, follow">
<meta property="og:title" content="<%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>">
<meta property="og:description" content="기업 간 거래(B2B)를 위한 <%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>. 안전하고 효율적인 B2B 거래를 위한 금융 솔루션이 디지털 트랜스포메이션을 돕습니다.">
<meta property="og:url" content="https://www.mp1.co.kr<%=request.getContextPath() %>/">
<meta property="og:type" content="website">
<meta property="og:image" content="https://image.mp1.co.kr<%=request.getContextPath() %>/bi_launcher.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="<%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>">
<meta name="twitter:description" content="기업 간 거래(B2B)를 위한 <%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>. 안전하고 효율적인 B2B 거래를 위한 금융 솔루션이 디지털 트랜스포메이션을 돕습니다.">
<meta name="twitter:image" content="https://image.mp1.co.kr<%=request.getContextPath() %>/bi_launcher.png">

<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<!-- in-page styles -->
<style>
body {overflow-x: hidden;}
header {z-index:4;position:fixed;top:0;width:100%;background-color:rgba(255, 255, 255, 0);border-bottom:0;}
header:hover {background-color:white;}
#navigation-items-block {position:fixed;margin-top:57px !important;background-color:rgba(255, 255, 255, 0.95);}
main {clear:both;min-height:0;}

div.banner {
  position:absolute;top:0;left:-10px;width:calc(100% - 20px);padding:20px;padding-top:80px;
  color:#000;line-height:1.4em;font-size:1.2em;border:0;
  background-size:cover;background-repeat:no-repeat;background-position:center top;
}
div.banner>div.wrapper>h1 {font-size:1.8em;line-height:1.3em;letter-spacing:-1px;margin-top:80px;margin-bottom:80px;}
div.banner>div.wrapper>h2 {font-size:1.3em;margin:40px 0;line-height:2em;}
div.banner>div.wrapper>p {margin-bottom:10px;text-align:justify;}
div.banner span.member-cnt {font-size:3.3em;vertical-align:top;}

div.banner-btns {z-index:3;position:absolute;font-size:30px;top:580px;color:#555;display:flex;flex-flow:row wrap;justify-content:center;width:100%;}
div.banner-btns i {cursor:pointer;margin:5px;}

ul.direct-links {clear:both;display:flex;flex-flow:row wrap;justify-content:center;min-height:180px;}
ul.direct-links>li {position:relative;width:96px;margin:10px 0px 30px 0px;text-align:center;transition:font-size .3s ease-in-out, margin-top .3s ease-in-out, color .3s ease-in-out;}
ul.direct-links>li:hover {margin-top:-10px;}
ul.direct-links>li>a {color:darkgreen;}
ul.direct-links>li>a:hover {color:#072;cursor:pointer;}
ul.direct-links>li i {font-size:4em;margin-top:0px;line-height:1.6em;}
ul.direct-links>li i:hover {font-size:4.2em;margin-bottom:20px;color:white;background-color:#072;padding:0 20px;border-radius:10px;}

span.contract-cnt {position:absolute;top:20px;right:0;color:white;background-color:#FF5733;border-radius:50px;padding:10px 15px;font-weight:bold;animation:blink 3s infinite;}
span.due-date {background-color:#33aa57;color:white;padding:3px 5px;border-radius:3px;}

ul.customer-service-block {clear:both;position:relative;display:flex;flex-flow:row wrap;color:#000;}
ul.customer-service-block>li {min-width:300px;min-height:260px;padding-left:20px;padding-right:20px;padding-top:40px;border-top:1px solid #ddd;}
ul.customer-service-block>li:first-child {padding-left:0;border-right:1px solid #ddd;}
ul.customer-service-block>li:nth-child(even) {max-width: 300px;border-right:1px solid #ddd;}
ul.customer-service-block>li:last-child {flex-grow: 1;padding-right:0;background-color:rgb(255,255,255,0.3);}
ul.customer-service-block>li:last-child span.more {margin-right:30px;}
ul.customer-service-block div.title {width:100%;font-size:1.6em;font-weight:bold;vertical-align:top;border-bottom:1px solid transparent;height: 40px;}
ul.customer-service-block div.title.call {font-size:3em;padding-top:2px;padding-bottom:0px;border-bottom:0;}
ul.customer-service-block div.title.call a {color:#FF5733;}
ul.customer-service-block>li>ul>li {padding:3px 0;overflow:hidden;white-space:nowrap;text-overflow:elipsis;word-break:break-all;}
.notice-list {max-width:450px;}

ul.bank-list {display:flex;flex-flow:row wrap;}
ul.bank-list li {width: 33%;}
ul.bank-list img {width:25px;vertical-align:middle;}

div#load-url-via-popup {display:none;position:fixed;z-index:5;top:20px;left:20px;padding:10px;background-color:#fff;border-radius:10px;border:3px solid #bbb;}
div#load-url-via-popup div.body {max-height:500px;overflow:auto;}

a.add-more {border-radius:20px;padding:5px 8px;transition:padding .5s, border-radius 1s;}
a.add-more:hover {background-color:black;border-radius:0px;border:1px solid black;padding:15px;}
a.add-more:hover::after {content:' MORE';}

div.footer-nav {margin-top:0;}
div.footer-nav, div.footer-nav a {color:white;}
div.footer-nav a:hover {color:darkorange;}
footer {opacity: 0.8;}
#LoginBox {padding:10px 0;}

#video {
  position:fixed;top:0px;left:0px;
  min-width:110%;min-height:100%;width:auto;
  z-index:-10;overflow:hidden;
}
#main2 {clear:both;margin-top:720px;}

@media only screen and (min-width:768px) and (max-width:1100px) {
  div.banner {height:560px;background-position:center;}
  ul.direct-links>li {margin:10px 5px 30px 5px;}
  .tablet-hide {display:none;}
}
@media only screen and (max-width:767px) {
  header>div>aside {margin-right:10px;}
  div.banner {height:560px;}
  div.banner>div.wrapper>h1 {font-size:1.3em;margin-top:40px;margin-bottom:40px;}
  div.banner>div.wrapper>h2 {font-size:1.1em;margin:20px 0;}
  div.banner>div.wrapper>p {font-size:0.825em;line-height:1.6em;}
  div.banner span.member-cnt {font-size:2em;}
  div.banner-btns {top:520px;}
  ul.direct-links {min-height:0;}
  ul.direct-links>li {margin:5px;width:76px;font-size:0.9em;}
  ul.direct-links>li i {font-size:3em;}
  span.due-date {padding:2px 5px;}
  ul.customer-service-block {padding-top:40px;background-image:none;}
  ul.customer-service-block>li {width:100%;padding:0;padding-top:40px;}
  ul.customer-service-block>li:first-child {border-right:0;}
  ul.customer-service-block>li:nth-child(even) {border-right:0;max-width:100%;}
  ul.customer-service-block>li:last-child {border-bottom:0;}
  li.customer-service-block-li-separator {border-right:0;min-width:100% !important;}
  div.footer-nav, div.footer-nav a {color:black;}
  .notice-list {max-width:350px;}
  .mobile_hide {display:none !important;}
  #main2 {background-color:#fff;margin-top: 600px;padding-top: 20px;}
  #video {left:-320px;height:100%;}
}
</style>
<script>
var timer_banner;
var turn_time = 7000;
var dot_focused_color = '#FF5733';
function showBannerButton() {
  for (var i=0; i<$("div.banner").length; i++) {
    $("div.banner-btns").append('<i class="fa-solid fa-circle-dot" idx="'+i+'"></i> ');
  }
  $("div.banner-btns i").eq(0).css("color", dot_focused_color);
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
  var banner_current_idx = 0;
  $("div.banner").each(function(idx,item){
    if ($(this).is(":visible")) banner_current_idx = idx;
  });
  if (banner_current_idx == banner_tgt_idx) {}
  else {
    clearTimeout(timer_banner);
    $("div.banner:visible").css("z-index", "2");
    $("div.banner").eq(banner_tgt_idx).css("z-index", "1");
    $("div.banner:visible").hide('slide', {direction: "left"}, 600);
    $("div.banner").eq(banner_tgt_idx).show('slide', {direction: "right"}, 500);
    $("div.banner-btns i").css("color", "#555");
    $("div.banner-btns i").eq(banner_tgt_idx).css("color", dot_focused_color);
    timer_banner = setTimeout(rotate_banner, turn_time);
  }
}
function loadPopImage(url) {
  console.log(url);
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
function loadLoginBox() {
  if ($("#LoginBox").html().length == 0) {
    $("#LoginBox").load("./web/LoginBox.jsp");
    $("#LoginBox").css("border-top", "1px solid #ddd");
  } else {
    $("#LoginBox").html("");
    $("#LoginBox").css("border-top", "0");
  }
}
function callbackAfterLogin(ref) {
  toast("로그인되었습니다.", 1000, function(){
    location.href = ref;
  });
}
$(document).ready(function() {
  $("ul.bank-list").load("<%=request.getContextPath()%>/static/BankUrl.htm?202505");
  showBannerButton();
  timer_banner = setTimeout(rotate_banner, 5000);
  $("div.banner-btns i").on("click", function() {
    show_banner($(this).attr("idx"));
  });
  if ($("span.contract-cnt").text()=="0") $("span.contract-cnt").hide();
  if ($(".is-logined-flag").length>0) $(".login-btn").hide(); 
});
$(document).on('visibilitychange', function() {
  if (document.visibilityState === 'hidden') {
    clearTimeout(timer_banner);
  } else {
    timer_banner = setTimeout(rotate_banner, 5000);
  }
});
window.addEventListener('scroll', function() {
  var scrollPosition = window.scrollY || window.pageYOffset;
  if (scrollPosition > 50) {
    $("header").css("background-color", "white");
    $("#video").css("filter", "blur(10px)");
  } else {
    $("header").css("background-color", "rgba(255, 255, 255, 0)");
    $("#video").css("filter", "blur(0px)");
  }
});
</script>
<%@ include file="./web/includes/Navigation.jsp" %>

    </div>
  </main>

  <video id="video" preload="auto" autoplay="true" loop="loop" muted="muted" volume="0">
    <source src="//image.mp1.co.kr/mp/banner/clover2.mp4">
  </video>

  <div class='banner'>
    <div class='wrapper'>
       <h1 style='line-height:2.6em;'><%=ConfigurationMgr.getInstance().getString("OWNER_BRAND_NM") %>은<br/><span class='member-cnt'><%=StrUtil.addComma(intTotalCustomerCount) %></span> 회원사와 함께합니다.</h1>
    </div>
  </div>

  <div class='banner' style='display:none;'>
    <div class='wrapper'>
      <jsp:include page="./ValidInvoiceDate.jsp">
        <jsp:param name="from" value="home" />
      </jsp:include>
    </div>
  </div>

  <div class='banner' style='display:none;'>
    <div class='wrapper'>
      <h1>B2B대출거래진정성강화를 위한 제도개선 안내 (KODIT 신용보증기금)</h1>
      <p><i class="fa-solid fa-asterisk"></i> 면세 포함 의무발행대상 여부와 관계없이 <strong>국세청(홈텍스)을 통한 전자세금계산서 첨부 의무화</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> B2B대출 부정 사용 예방을 위한 <strong>이상거래 모니터링 강화</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> 경상적 매출이 발생하는 정상적 사업장 여부를 확인하는 <strong>판매기업 사전검증 도입</strong></p>
      <p><i class="fa-solid fa-asterisk"></i> B2B대출거래 기본요건 관리강화를 위하여 매매계약체결 시 <strong>사업자용 공동인증서 서명 필수</strong></p>
      <p>&nbsp;</p>
      
      <p><a href="javascript:loadPopImage('//image.mp1.co.kr/images/popup_master/notice_151217.jpg');" class='btn lurian' title='자세히 보기'>자세히 보기</a></p>
      
    </div>
  </div>
  <div class='banner-btns'></div>

  <main id='main2'>
    <div class='wrapper'>

      <ul class='direct-links'>
        <li class='login-btn'><a onclick='loadLoginBox();'><i class="fa-solid fa-unlock"></i><br/>로그인</a></li>
        <li><a href='<%=request.getContextPath()%>/web/trade/ContractReg.jsp'><i class="fa-solid fa-file-signature"></i><br/>매매계약서<br/>작성</a></li>
        <li><a href='<%=request.getContextPath()%>/web/trade/ContractsReceived.jsp'><span class='contract-cnt'>${RECEIVED_CONTRACT}</span><i class="fa-solid fa-receipt"></i><br/>받은 계약서</a></li>
        <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/guide/BankWorkTime.jsp'><i class="fa-solid fa-clock"></i><br/>인터넷 뱅킹<br/>시간 확인</a></li>
        <li><a href='<%=request.getContextPath()%>/web/customer/'><i class="fa-solid fa-person-circle-question"></i><br/>도움이 필요<br/>하세요?</a></li>
        <!-- li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/download/Downloads.jsp'><i class="fa-solid fa-cloud-arrow-down"></i><br/>필수프로그램<br/>다운로드</a></li -->
        <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/download/Sign.jsp'><i class="fa-solid fa-address-card"></i><br/>인증서<br/>테스트</a></li>
        <li class='mobile_hide'><a href="<%=ConfigurationMgr.getInstance().getString("REMOTE_SUPPORT_URL") %>" target="_blank"><i class="fa-solid fa-desktop"></i><br/>원격지원</a></li>
      </ul>
      
      <div id='LoginBox'></div>
    
      <ul class='customer-service-block'>
        <li class='customer-service-block-li-separator'>
          <div class='title' style='margin-bottom:13px;'>고객센터</div>
          <div class='title call'><a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></a></div>
          <div><span style='background-color:#aaa;padding:2px 5px;border-radius:5px;color:white;font-size:0.9em;'>FAX</span> <%=ConfigurationMgr.getInstance().getString("OWNER_FAX") %></div>
      
          <div style='margin-top:30px;margin-bottom:15px;font-size:1.3em;font-weight:bold;'>운영시간</div>
          <ul>
            <li><%=ConfigurationMgr.getInstance().getString("OWNER_WORKING_TIME") %></li>
            <li><%=ConfigurationMgr.getInstance().getString("OWNER_BREAK_TIME") %></li>
          </ul>
        </li>
        <li class='customer-service-block tablet-hide'>
          <div class='title'>인터넷뱅킹 바로가기</div>
          <ul class='bank-list'></ul>
        </li>
        <li>
          <div class='title' style='width:100%;'>공지사항
            <span class='more mobile_hide' style='font-size:0.6em;'><a href='<%=request.getContextPath()%>/web/customer/notice/Notices.jsp' class='btn white add-more'><i class="fa-solid fa-plus"></i></a></span>
          </div>
          <ul class='notice-list'>
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
