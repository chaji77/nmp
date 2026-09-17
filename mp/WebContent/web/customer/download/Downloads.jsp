<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>필수 프로그램 다운로드</title>
<link href="<%=request.getContextPath() %>/static/font/fontawesome-free-6.7.2-web/css/brands.css?2025" rel="stylesheet" />
<style>
ul.download-list li {margin-bottom:14px;font-size:1.2em;line-height:1.4em;}
ul.download-list li i {font-size:2em;vertical-align:middle;margin-right:5px;}
</style>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>필수 프로그램 다운로드</span>
</div>

<p>서비스 이용에 꼭 필요한 프로그램을 설치하십시오.</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<ul class='download-list'>
  <li><i class="fa-brands fa-windows"></i> <a href='<%=request.getContextPath() %>/static/programs/SecuKitNXS/Install/SecuKitNXS.exe' target='_new'>전자서명</a> (한국정보인증 제공, 매매계약서의 전자서명에 사용)</li>
  <li><i class="fa-brands fa-windows"></i> <a href='<%=request.getContextPath() %>/static/programs/AldServer_setup.exe' target='_new'>세금계산서 스크래핑</a> (알디스 제공, 세금계산서를 가져오기 위해 사용)</li>
  <li><i class="fa-brands fa-windows"></i> <a href='https://sesw.hometax.go.kr/dn_dir/veraport/magic-pki/NTSMagicLineMBXSetup.exe' target='_new'>국세청 인증</a> (국세청 제공, 국세청 접속에 사용)</li>
</ul>



<%@ include file="../../includes/Footer.jsp" %>