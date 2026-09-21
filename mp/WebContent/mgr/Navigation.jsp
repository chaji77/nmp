<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.mp.mgr.dashboard.DashboardVO" %>
<%@ page import="kr.co.mp.mgr.dashboard.DashboardBean" %>
<%
DashboardVO navDashboardVO = new DashboardBean().DASHBOARD_EXIST_CHECK_PROC();
%>
<style>
.nav-dot {display:inline-block;width:4px;height:4px;border-radius:50%;background-color:red;margin-left:4px;vertical-align:top;}
</style>
</head>
<body>
  <header>
    <img class='burger' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAAAXNSR0IArs4c6QAAAYNJREFUeF7t2VGKwzAUxdB4/4t26QYK/ghyH2e+BxRLuS3F6/GXGlgpHfwRIH4JBBAgNhDjLUCA2ECMtwABYgMx3gIEiA3EeAsQIDYQ4y1AgNhAjLcAAWIDMd4CBIgNxHgLECA2EOMtQIDYQIy3gH8LsPfe8TNfjV9rHb3UR//8PbkAv/sLEO9DAAFiAzHeAgSIDcR4C5geID7fOPzx74BxBuIDCSBAbCDGW4AAsYEYbwECxAZivAUIEBuI8RYgQGwgxh8vwJWkK8n4nRVAgKsNxA/nQkaA2ECMtwABYgMx/vUFxOcbhz/+ITbOQHwgAQSIDcR4CxAgNhDjLUCA2ECMtwABYgMx3gIEiA3E+OMFuBN2JRm/swIIcLWB+OFevw/wHeAjKH7HBRDgagPxw73+HRCfbxz++IfYOAPxgQQQIDYQ4y1AgNhAjLcAAWIDMd4CBIgNxHgLECA2EOMtQIDYQIy3AAFiAzHeAgSIDcR4CxAgNhDjLUCA2ECMtwABYgMx/gNZbGBhNKJf3wAAAABJRU5ErkJggg=='>
    <a href='<%=request.getContextPath()%>/mgr/trade/index.jsp'><img class='logo' src='<%=request.getContextPath()%>/static/images/bi.png'></a>
    <ul id='navigation'>
      <li class='navigation-li-col nav-001'><a href='<%=request.getContextPath()%>/mgr/customer/Companies.jsp'>회원관리</a><% if (navDashboardVO.REG_REQ_EXIST) { %><span class='nav-dot'></span><% } %></li>
      <li class='navigation-li-col nav-002'><a href='<%=request.getContextPath()%>/mgr/trade/Contracts.jsp'>거래관리</a></li>
      <li class='navigation-li-col nav-003'><a href='<%=request.getContextPath()%>/mgr/etax/TaxRequestList.jsp'>정산관리</a></li>
      <li class='navigation-li-col nav-004'><a href='<%=request.getContextPath()%>/mgr/notice/Notices.jsp'>사이트관리</a><% if (navDashboardVO.QNA_EXIST) { %><span class='nav-dot'></span><% } %></li>
      <li class='navigation-li-col nav-005'><a href='<%=request.getContextPath()%>/mgr/sales/SalesCompanies.jsp'>영업업체관리</a></li>
    </ul>
    <aside>
      <i class="fa-solid fa-comments manager-nav-btn" onclick="showMyMemoForNaviator();"></i>
      <i class="fa-solid fa-bell manager-nav-btn" onclick='showNotificationForNaviator();'></i><span class='notification_cnt'></span>
      <i class="fa-solid fa-magnifying-glass manager-nav-btn" onclick='toggleSearchCompanyForm();'></i> &nbsp;
      <span class='user-nm'>${SESS_MGR_NM}님 <i class="fa-solid fa-right-from-bracket"></i></span>
    </aside>
  </header>
  <div id='navigation-items-block' style='display:none;z-index:2;border-bottom: 1px solid #eee;'>
    <ul id='navigation-items'>
      <li class='navigation-li-col'>
        <ul class='nav-001'><!-- 회원관리 -->
          <li><a href='<%=request.getContextPath()%>/mgr/customer/Companies.jsp'>회원관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/direct/DirectRelations.jsp'>직발주회원관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/customer/Guarantees.jsp'>유효보증서관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/mpfee/MpFees.jsp'>수수료관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/memo/Memos.jsp'>메모(상담)관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/customer/MessageBlockList.jsp'>문자/메일전송차단관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/customer/CompanyRegReqs.jsp'>판매기업 등록요청</a><% if (navDashboardVO.REG_REQ_EXIST) { %><span class='nav-dot'></span><% } %></li>
        </ul>
      </li>
      <li class='navigation-li-col'>
        <ul class='nav-002'><!-- 거래관리 -->
          <li><a href='<%=request.getContextPath()%>/mgr/trade/Contracts.jsp'>거래관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/trade/UnusualContracts.jsp'>이상거래관리</a></li>
        </ul>
      </li>
      <li class='navigation-li-col'>
        <ul class='nav-003'><!-- 정산관리 -->
          <li><a href='<%=request.getContextPath()%>/mgr/etax/TaxList.jsp'>세금계산서관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/etax/TaxRequestList.jsp'>계산서발행신청관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/etax/MonthlyTargets.jsp'>월합세금계산서발행</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/Static.jsp'>월별통계</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/DailyRevenue.jsp'>일별수수료</a></li>
        </ul>
      </li>
      <li class='navigation-li-col'>
        <ul class='nav-004'><!-- 사이트관리 -->
          <li><a href='<%=request.getContextPath()%>/mgr/notice/Notices.jsp'>공지관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/faq/FAQs.jsp'>FAQ관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/qna/Qnas.jsp'>1:1문의</a><% if (navDashboardVO.QNA_EXIST) { %><span class='nav-dot'></span><% } %></li>
          <li><a href='<%=request.getContextPath()%>/mgr/salesrep/Salesreps.jsp'>영업담당자관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/holiday/Holidays.jsp'>휴일관리</a></li>
          <li><a href='<%=request.getContextPath()%>/mgr/manager/Managers.jsp'>관리자관리</a></li>
        </ul>
      </li>
      <li class='navigation-li-col'>
        <ul class='nav-005'><!-- 영업업체관리 -->
          <li><a href='<%=request.getContextPath()%>/mgr/sales/SalesCompanies.jsp'>업체관리</a></li>
        </ul>
      </li>
    </ul>
  </div>
  <form name='frmSearchCompany' method='post' action='<%=request.getContextPath()%>/mgr/customer/Companies.jsp' autocomplete="off">
  <div id='SearchCompanyForm'>
  <div>회원검색</div>
  <input type='search' name='bizno' maxlength='12' pattern="[0-9]+" placeholder='사업자번호'><br/>
  <input type='search' name='nm' maxlength='20' value='' placeholder='회사명'>
  <div onclick='document.frmSearchCompany.submit();'>검색</div>
  </div>  
  </form>

<div id='notification-block' style='display:none;'></div>

  <main>
