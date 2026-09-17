<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
String strCpyNm = StrUtil.nvl((String)session.getAttribute("REGISTED_CPY_NM"));
String strFile  = StrUtil.nvl((String)session.getAttribute("REGISTED_FILE"));
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>회원가입완료</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
ul.step {height: 96px;}
ul.step li {display:none;padding:15px;}
h1 {line-height:1.2em;}
p {line-height:1.8em;}
span.title-underline {
  width: 80px;
  height: 5px;
  background-color: rgba(234,179,120,.3);
  display: inline-block;
}
.exp-body {width:60%;margin-left:auto;margin-right:auto;}
#cause-box {display:none;padding: 30px;margin-top:20px;margin-bottom:20px;border:1px solid #eee;line-height:1.6em;text-align:justify;background-color: rgba(234,179,120,.3);}
.ask {text-align:center;font-size:1.6em;}
span.em {font-weight:bold;color:darkorange;}
@media only screen and (max-width:767px) {
  .exp-body {width: 100%;}
}
</style>
<script>
function toggleCauseBox() {
 if ($("#cause-box").is(":visible")) $("#cause-box").hide();
 else $("#cause-box").slideDown();
}
$(document).ready(function(){
  $("ul.step li").each(function(idx, item) {
    $(item).slideDown(200*idx);
  });
  setTimeout(function(){
    $("ul.step li").eq(6).addClass("now");
  }, 1300);
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원가입</span>
  <span class='more'>
  </span>
</div>

<ul class='step'>
  <li><strong>STEP 1</strong><br/><br/>회원가입여부<br/>확인</li><li class='after'></li>
  <li><strong>STEP 2</strong><br/><br/>약관 및 개인정보처리방침 동의</li><li class='after'></li>
  <li><strong>STEP 3</strong><br/><br/>회원정보 입력</li><li class='after'></li>
  <li><strong>STEP 4</strong><br/><br/>회원가입 완료</li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<h1 style='width:100%;text-align:center;'><%=strCpyNm %>님! 회원가입 완료되었습니다.</h1>
<div style='margin-top:10px;text-align:center;'>
  <span class='title-underline'></span>
</div>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='exp-body'>

  <p>관리자의 승인 절차 후 최종 회원가입 승인이 이루어지며, 승인 이후부터 서비스를 이용하실 수 있습니다.</p>
  <% if (strFile.length()<10) { %>
  <p style='color:red;'>사업자등록증을 첨부하지 않으셨습니다. 아래의 팩스번호로 <span style='border-bottom:1px solid #f00;'>사업자등록증 사본</span>을 전송하셔야 승인절차를 진행할 수 있습니다.</p>
  <%
  }
  %>
  <p>&nbsp;</p>
  <p>[안내] B2B대출결제 이용 시 주의사항 안내 &nbsp;&nbsp; <a onclick='toggleCauseBox();' class='btn'>상세보기</a></p>
  <div id='cause-box'>
  B2B대출을 통한 결제를 하시거나 받으실 경우 유의사항을 안내드립니다.<br/><br/>
  B2B 대출제도는 거래시스템의 전자화를 통해 각종 비용을 절감하고, 현금결제를 통한 연쇄도산 방지, 비대면 거래의 대금회수 불확실성을 해소하는 등 구매기업과 판매기업 모두에게 유익한 제도입니다.<br/><br/>
  다만, B2B대출자금은 <span class='em'>페이퍼컴퍼니, 특수관계기업 등을 이용</span>한 허위거래를 기반으로 대출금을 유용하거나 (세금)계산서 취소 등 진정한 상거래가 아닌 <span class='em'>자금융통목적의 거래에 사용된 경우</span> 결제 받은 기업은 대금을 즉시 해당은행으로 상환해야 하며, 대출결제 실행한 이용기업은 <span class='em'>대출금의 정상적인 운용이 불가</span>해집니다. 또한 사안에 따라 <span class='em'>형사처벌 대상</span>이 될 수 있습니다.<br/><br/>
  최근 일부 기업체에서 제도를 악용하는 사례가 발생함에 따라 선량하게 이용중인 대다수 기업을 위해 B2B대출 건전성 제고 노력을 기울이고 있사오니 많은 협조 부탁드립니다.<br/>
  </div>
  <p>기타 문의사항은 아래의 고객센터로 문의바랍니다.</p>

</div>

<p>&nbsp;</p>
<p>&nbsp;</p>


<p class='ask'>
  <%=((strFile.length()<10)? "팩스 <span style='color:darkred;font-weight:bold;'>" + ConfigurationMgr.getInstance().getString("OWNER_FAX") + "</span>" : "") %><br/>
  고객센터 <a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL")%>' style='color:darkblue;font-weight:bold;'><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></a></p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='btns'>
  <a href='<%=request.getContextPath()%>'>홈</a>
  <a href='<%=request.getContextPath()%>/web/Login.jsp' class='lurian'>로그인</a>
</div>


<%@ include file="../includes/Footer.jsp" %>