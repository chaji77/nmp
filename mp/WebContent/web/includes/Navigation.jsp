<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%
boolean isLogined = false;

// if (!((String)pageContext.getAttribute("VALID_IP_YN")).equals("N") && !((String)pageContext.getAttribute("CPY_ID")).equals("0")) isLogined = true;
if (!((String)pageContext.getAttribute("CPY_ID")).equals("0")) isLogined = true;
int intReceivedContractsCountForNavigation = ((int)pageContext.getAttribute("SENT_CONTRACT"))+((int)pageContext.getAttribute("RECEIVED_CONTRACT"))+((int)pageContext.getAttribute("SETTLE_STANDBY"));
;
%>
<script>
$(document).ready(function() {
  $("#navigation>li").on("mouseover", function() {
    $("#navigation-items-block").show();
  });
  $("#navigation-items-block").on("mouseleave", function() {
    $("#navigation-items-block").hide();
  });
  $("img.burger").on("click", function() {
    var isVisible = $("div.navigation-mobile-header").is(':visible'); 
    $("div.navigation-mobile-header").remove();
    $("div.navigation-mobile-body").remove();
    if (!isVisible) {
      $("body").append("<div class='navigation-mobile-header'><ul></ul></div>");
      $("div.navigation-mobile-header>ul").html($("#navigation").html());
      $("div.navigation-mobile-header>ul>li>a").attr("href", "#");
      $("div.navigation-mobile-header>ul>li").on("click", function() {
        var nav_id = $(this).attr("class").replace("navigation-li-col ", "");
        $("div.navigation-mobile-body").remove();
        $("body").append("<div class='navigation-mobile-body'><ul></ul></div>");
        $("div.navigation-mobile-body>ul").html($("#navigation-items>li>ul."+nav_id).html());
        $("div.navigation-mobile-body").show();
      });
      $("div.navigation-mobile-header").show();
    }
  });
});
$(window).on('resize', function(){
  $("div.navigation-mobile-header").remove();
  $("div.navigation-mobile-body").remove();
});
</script>
</head>
<body>
  <header>
    <div class='wrapper'>
      <img class='burger' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAAAXNSR0IArs4c6QAAAYNJREFUeF7t2VGKwzAUxdB4/4t26QYK/ghyH2e+BxRLuS3F6/GXGlgpHfwRIH4JBBAgNhDjLUCA2ECMtwABYgMx3gIEiA3EeAsQIDYQ4y1AgNhAjLcAAWIDMd4CBIgNxHgLECA2EOMtQIDYQIy3gH8LsPfe8TNfjV9rHb3UR//8PbkAv/sLEO9DAAFiAzHeAgSIDcR4C5geID7fOPzx74BxBuIDCSBAbCDGW4AAsYEYbwECxAZivAUIEBuI8RYgQGwgxh8vwJWkK8n4nRVAgKsNxA/nQkaA2ECMtwABYgMx/vUFxOcbhz/+ITbOQHwgAQSIDcR4CxAgNhDjLUCA2ECMtwABYgMx3gIEiA3E+OMFuBN2JRm/swIIcLWB+OFevw/wHeAjKH7HBRDgagPxw73+HRCfbxz++IfYOAPxgQQQIDYQ4y1AgNhAjLcAAWIDMd4CBIgNxHgLECA2EOMtQIDYQIy3AAFiAzHeAgSIDcR4CxAgNhDjLUCA2ECMtwABYgMx/gNZbGBhNKJf3wAAAABJRU5ErkJggg=='>
      <a href='<%=request.getContextPath()%>/index.jsp'><img class='logo' src='//image.mp1.co.kr<%=request.getContextPath() %>/bi.png'></a>
      <ul id='navigation'>
        <li class='navigation-li-col nav-001'><a href='<%=request.getContextPath()%>/web/trade/index.jsp'>B2B전자결제</a></li>
        <li class='navigation-li-col nav-002'><a href='<%=request.getContextPath()%>/web/collateral/kodit/'>B2B담보보증</a></li>
        <li class='navigation-li-col nav-003'><a href='<%=request.getContextPath()%>/web/customer/index.jsp'>이용안내</a></li>
        <li class='navigation-li-col nav-004'><a href='<%=request.getContextPath()%>/web/customer/index.jsp'>고객센터</a></li>
		<li class='navigation-li-col nav-005'><a href='<%=request.getContextPath()%>/web/customer/support/mro.jsp'>기업지원서비스</a></li>
      </ul>
      <aside>
        <% if (isLogined) { %>
        <font color='#000' class='mobile_hide is-logined-flag' style='font-weight:bold;'><i class="fa-solid fa-lock"></i> ${CPY_NM}</font>&nbsp;
          <% if (intReceivedContractsCountForNavigation>0) { %>
        <a class='received_contract' href='<%=request.getContextPath()%>/web/trade/index.jsp' title='B2B전자결제현황'><%=intReceivedContractsCountForNavigation %></a>
          <% } %>
        <a href='<%=request.getContextPath() %>/web/customer/MyPage.jsp' class='btn'>마이페이지</a>
        <a href='<%=request.getContextPath() %>/web/Logout.jsp' class='btn'>로그아웃</a>
        <% } else { %>
        <a href='<%=request.getContextPath() %>/web/Login.jsp' class='btn'>로그인</a>
        <a href='<%=request.getContextPath() %>/web/customer/Registration.jsp' class='btn'>회원가입</a>
        <% } %>
      </aside>
    </div>
  </header>
  <div id='navigation-items-block' style='display:none;z-index:2;margin-top: -1px;padding-bottom:30px;border-bottom: 1px solid #ddd;'>
    <div class='wrapper'>
      <ul id='navigation-items'>
        <li class='navigation-li-col'>
          <ul class='nav-001'><!-- B2B전자결제 -->
            <li><a href='<%=request.getContextPath()%>/web/trade/ContractReg.jsp'>매매계약서 작성</a></li>
            <li><a href='<%=request.getContextPath()%>/web/trade/ContractsSent.jsp'>보낸계약서</a></li>
            <li><a href='<%=request.getContextPath()%>/web/trade/ContractsReceived.jsp'>받은계약서</a></li>
            <li><a href='<%=request.getContextPath()%>/web/trade/ContractsMaturityComing.jsp'>만기 미도래 계약서</a></li>
            <% if (!"2".equals((String)pageContext.getAttribute("CPY_GUBUN"))) { %>
            <li><a href='<%=request.getContextPath()%>/web/trade/Invoices.jsp'>거래세금계산서관리</a></li>
            <% } %>
            <li><a href='<%=request.getContextPath()%>/web/trade/MyCompanies.jsp'>거래처관리</a></li>
            <li><a href='<%=request.getContextPath()%>/web/trade/MPInvoices.jsp'>MP세금계산서</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/regreq/index.jsp'>판매기업 등록요청</a></li>
          </ul>
        </li>
        <li class='navigation-li-col'>
          <ul class='nav-002'><!-- B2B담보보증 -->
            <li><a href='<%=request.getContextPath()%>/web/collateral/kodit/'>신용보증기금</a></li>
            <li><a href='<%=request.getContextPath()%>/web/collateral/kibo/'>기술보증기금</a></li>
          </ul>
        </li>
        <li class='navigation-li-col'>
          <ul class='nav-003'><!-- 이용안내 -->
            <li><a href='<%=request.getContextPath()%>/web/customer/guide/Service.jsp'>서비스 소개</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/guide/BankWorkTime.jsp'>은행B2B결제시간</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/download/Downloads.jsp'>프로그램 다운로드</a>
          </ul>
        </li>
        <li class='navigation-li-col'>
          <ul class='nav-004'><!-- 고객센터 -->
            <li><a href='<%=request.getContextPath()%>/web/customer/notice/Notices.jsp'>공지사항</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/guide/Sales.jsp'>영업담당자</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/faq/'>FAQ</a></li>
            <li><a href='<%=request.getContextPath()%>/web/customer/qna/'>1:1 문의</a></li>
          </ul>
        </li>
		 <li class='navigation-li-col'>
          <ul class='nav-005'><!-- 기업지원서비스 -->
            <li><a href='<%=request.getContextPath()%>/web/customer/support/mro.jsp'>회원사전용MRO쇼핑몰</a></li> 
			<li><a href='<%=request.getContextPath()%>/web/customer/support/course_list.jsp'>공개교육</a></li> 
          </ul>
        </li>
      </ul>
    </div>
  </div>
  <main>
    <div class='wrapper'>
