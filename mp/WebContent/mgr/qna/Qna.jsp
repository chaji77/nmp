<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");

QnaBean bean = new QnaBean();
QnaVO   vo   = new QnaVO();
vo.SEQ = 0;

String strId = StrUtil.nvl(request.getParameter("id"), "0");
if (IntegerCryptoUtil.isEncrypted(strId)) {
  int intseq = Integer.parseInt(IntegerCryptoUtil.crypt(strId));
  vo  = bean.C_QNA_DETAIL_PROC(intseq);
} else {
  response.sendRedirect("Qnas.jsp"); 
  return; 
}


%>

<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>1:1문의</title>
<style>
ul.detail a:not(.btn) {text-decoration: underline;color:blue;}
ul.detail li.td.wide {width: calc(100% - 162px);}
</style>
<script type="text/javascript">
function goPage(c) {
  const mid = document.frmEnt.mid.value;
   if (c == 1) {
       document.frmEnt.action = "QnaReg.jsp";
       document.frmEnt.submit();
   } else if (c == 2) {
       showCustomConfirm("정말 삭제하시겠습니까?", function () {
         location.href = "QnaDropProc.jsp?id=" + mid;
  });
   }
}

function goHistoryBack() {
  window.history.back();
}
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1문의</span>
  <span class='more'>
    <a onclick='goHistoryBack();' class='btn'>목록</a>
    <% if (!StrUtil.nvl(vo.ANS_YN).equals("Y")) { %>
       <a onclick='goPage(1);' class='btn lurian'>답변</a>
    <% } else { %>
       <a onclick='goPage(1);' class='btn lurian'>수정</a>
    <% } %>
    <a onclick='goPage(2);' class='btn darkred'>삭제</a>
  </span>
</div>
<form name='frmEnt' method='post'>
<input type='hidden' name='mid' value='<%=vo.SEQ%>'>
<input type='hidden' name='searchStatus' value='<%= vo.ANS_YN %>'> 
</form>

<ul class='detail'>
  <li class='th'>제　　목</li>
  <li class='td'><%=StrUtil.input(vo.Q_TITLE) %></li>
  <li class='th'>작성일시</li>
  <li class='td'><%=StrUtil.input(vo.REG_DT) %></li>
  <li class='th'>회 &nbsp;사 &nbsp;명</li>
  <li class='td'>
    <a href='<%=request.getContextPath()%>/mgr/customer/Company.jsp?cpy_id=<%=IntegerCryptoUtil.crypt(vo.CPY_ID)%>'><%=StrUtil.input(vo.CPY_NAME) %></a>
    <a class='btn white' title='SMS'  onclick='getSMSWindow(<%=vo.CPY_ID%>);'><i class="fa-solid fa-comment-sms"></i><span class='mobile_hide'> 문자</span></a>
    <a class='btn white' title='MAIL' onclick='getMailWindow(<%=vo.CPY_ID%>);'><i class="fa-solid fa-paper-plane"></i><span class='mobile_hide'> 메일</span></a>
  </li>
  <li class='th'>작 &nbsp;성 &nbsp;자</li>
  <li class='td'><%=StrUtil.input(vo.REG_NM) %></li>
  <li class='th'>문의내용</li>
  <li class='td wide'><%=StrUtil.nvl(vo.Q_CONTENTS) %></li>
  <% if ("Y".equals(vo.ANS_YN)){ %>
  <li class='th'>응답내용</li>
  <li class='td wide'><%=StrUtil.nvl(vo.A_CONTENTS).replaceAll("&quot;", "'") %></li>
  <% } %>
</ul>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>

