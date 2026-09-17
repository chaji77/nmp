<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
// 이 페이지는 로그인 페이지와 메인 페이지에서 호출될 수 있도록 구현됨
request.setCharacterEncoding("utf-8");
String csrf_token = UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrf_token);
String ref = StrUtil.nvl((String)session.getAttribute("LOGIN_AFTER"), request.getContextPath() + "/index.jsp");
if (ref.contains("Proc.jsp")  || ref.contains("Complete.jsp")) ref = request.getContextPath() + "/index.jsp";
session.removeAttribute("LOGIN_AFTER");
LoginBean.removeToken(request, response);
%>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/web/Login.css?<%=DateTimeUtil.getCurrentResourceVersion() %>1">

<script type="text/javascript">
var strReffer = "<%=ref%>";
</script>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/web/Login.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>

<ul class='flex-layer'>
  <li>
    <form name='frmEnt' autocomplete='off'>
    <input type="hidden" name="csrf_token" value="<%=csrf_token %>" />
    <ul class='form-box login-box'>
      <li><h3>일반 로그인</h3></li>
      <li><label>아이디</label><input type='text' name='login_id' value='' maxlength='16' placeholder='아이디'></li>
      <li><label>비밀번호</label><input type='password' name='login_pw' value='' maxlength='16' placeholder='비밀번호'></li>
      <li class='btn-block'><label></label><a onclick='logon();' class='btn lurian'>로그인</a></li>
    </ul>
    </form>
  </li>
  <li class='mobile_hide'>
    <form name='frmEntForCert' autocomplete='off'>
    <input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
    <input type='hidden' id='signdata' name='signdata'><!-- 결과값 -->
    <ul class='form-box cert-box'>
      <li><h3>공동인증서 로그인</h3></li>
      <li><label>사업자번호</label><input type='text' name='<%=csrf_token %>' id='SSN' value='' maxlength='12' placeholder='사업자번호(숫자만 입력)'></li>
      <li></li>
      <li class='btn-block'><label></label><a onclick='loadCert();' class='btn lurian'>로그인</a></li>
    </ul>
    </form>
    <div id="element_to_pop_up"></div><!-- 전자서명호출팝업창 -->
  </li>
</ul>

<div style='text-align:center;margin-top:20px;margin-bottom:60px;'>
  <a href='<%=request.getContextPath() %>/web/customer/Registration.jsp'>회원가입</a> &nbsp;|&nbsp; <a onclick='forgotAccount();'>아이디/비밀번호 찾기</a>
</div>
