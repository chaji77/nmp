<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
QnaBean bean = new QnaBean();
QnaVO   vo   = new QnaVO();
vo.SEQ = 0;

String strId = StrUtil.nvl(request.getParameter("mid"), "0");
if (IntegerCryptoUtil.isEncrypted(strId)) {
  int intseq = Integer.parseInt(IntegerCryptoUtil.crypt(strId));
  vo  = bean.C_QNA_DETAIL_PROC(intseq);
} else {
  response.sendRedirect("index.jsp"); 
  return; 
}

int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
if (intCpyId != vo.CPY_ID) {
  out.println("<script>alert('자신의 문의만 열람할 수 있습니다.');location.href='index.jsp';</script>");
  return;
}

String qTypeLabel = QnaVO.getQCodeLabel(vo.Q_CODE);

%>

<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>1:1문의</title>
<style>
</style>
<script type="text/javascript">
$(document).ready(function(){
});
function drop() {
  showCustomConfirm("정말 삭제하시겠습니까?", function () {
    location.href = "QnADropProc.jsp?mid=<%=strId%>";
  });
}
<% if (!StrUtil.nvl(vo.ANS_YN).equals("Y")) { %>
function modify() {
  location.href = "QnAReg.jsp?mid=<%=strId%>";
}
<% } %>
</script>

<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1문의</span>
  <span class='more'>
    <a onclick='drop();' class='btn darkred'>삭제</a>
    <% if (!StrUtil.nvl(vo.ANS_YN).equals("Y")) { %>
    <a onclick='modify();' class='btn lurian'>수정</a>
    <% } %>
    <a onclick='goHistoryBack();' class='btn'>목록</a>
  </span>
</div>

<ul class='detail'>
  <li class='th'>제　　목</li>
  <li class='td'><%=StrUtil.input(vo.Q_TITLE) %></li>
  <li class='th'>작성일시</li>
  <li class='td'><%=StrUtil.input(vo.REG_DT) %></li>
  <li class='th'>회 &nbsp;사 &nbsp;명</li>
  <li class='td'><%=StrUtil.input(vo.CPY_NAME) %></li>
  <li class='th'>작 &nbsp;성 &nbsp;자</li>
  <li class='td'><%=StrUtil.input(vo.REG_NM) %></li>
  <li class='th'>유　　형</li>
  <li class='td wide'><%=  qTypeLabel %></li>
  <li class='th'>문의내용</li>
  <li class='td wide'><%=StrUtil.nvl(vo.Q_CONTENTS) %></li>
  <% if ("Y".equals(vo.ANS_YN)){ %>
  <li class='th'>응답내용</li>
  <li class='td wide'><%=StrUtil.nvl(vo.A_CONTENTS).replaceAll("&quot;", "'") %></li>
  <% } %>
</ul>



<%=WebPageCtrlUtil.getHistoryBack(session) %>
<%@ include file="../../includes/Footer.jsp" %>

