<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
boolean isLogined = false;

String strSessionUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
String strSessionCorpId  = StrUtil.nvl((String)session.getAttribute("SESS_BILL_CPY_ID"), "0");
String strSessionCorpNm  = StrUtil.nvl((String)session.getAttribute("SESS_BILL_CPY_NM"), "");
String strSessionUserNm  = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_NM"), "");
if (!strSessionUserSeq.equals("0")) isLogined = true;

%>
<style>
img.logo {height: 34px;margin: 0px 10px 0px 0px;}
</style>
</head>
<body>
  <header>
    <div class='wrapper'>
      <img class='logo' src='//image.mp1.co.kr/firstbill/bi_firstbill.png?a'>
      <ul id='navigation'>
        <li class='navigation-li-col nav-001'><a href='Cert.jsp'>인증서관리</a></li>
        <li class='navigation-li-col nav-002'><a href='Standbys.jsp'>발행신청관리</a></li>
        <li class='navigation-li-col nav-001'><a href='Invoices.jsp'>발행목록</a></li>
      </ul>
      <aside>
        <% if (isLogined) { %>
        <font color='#000' class='mobile_hide is-logined-flag' style='font-weight:bold;'><i class="fa-solid fa-lock"></i> <%=strSessionCorpNm %></font>&nbsp;
        <a href='Logout.jsp' class='btn'>로그아웃</a>
        <% } %>
      </aside>
    </div>
  </header>
  <main>
    <div class='wrapper'>
