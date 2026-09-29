<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
pageContext.setAttribute("GUIDE_TAB", "4");
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>싸이클론 준비서류</title>
<%@ include file="../../includes/Navigation.jsp" %>

  <div class='page-title-block'>
    <span class='title'>싸이클론 이용안내</span>
    <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
  </div>

<%@ include file="cyclnGuideTab.jsp" %>

  <div class='guide-section'>
    <h2><i class="fa-solid fa-caret-right"></i> 싸이클론(Cycle Loan) 약정 시 준비서류</h2>
    <ul>
      <li>사업자등록증 사본</li>
      <li>법인등기부등본 [개인사업자 생략]</li>
      <li>법인인감증명서 [개인사업자 생략]</li>
      <li>재무제표 또는 부가가치세과세증명원 [기 제출기업은 생략]</li>
      <li>도장(법인인 경우 법인인감)</li>
      <li>신분증</li>
    </ul>
  </div>

<%@ include file="../../includes/Footer.jsp" %>
