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
WebPageCtrlUtil.setHistoryBack(request, session);
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
QnaVO pvo = new QnaVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
pvo.CPY_ID  = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
pvo.ANS_YN  = "";

ArrayList<QnaVO> arr = new QnaBean().C_QNA_LIST_PROC(pvo);
int intTotalCnt = 0;
%>

<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>1:1문의</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<style>
.answer {margin-left:10px;color:darkorange;}
.answer i {vertical-align:middle;}
</style>
<script type="text/javascript">
$(document).ready(function(){
});

function goPage(p) {
  const form = document.forms['frmSearch'];
  form.page.value = p;
  form.action = "QnAs.jsp";
  form.target = "_top";
  form.submit();
}
function goDetail(mid) {
  const form = document.forms['frmSearch'];
  form.mid.value = mid;
  form.action = "QnA.jsp";
  form.target = "_top";
  form.submit();
}
</script>

<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1문의</span>
  <span class='more'>
    <a href='QnAReg.jsp' class='btn'>등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='mid' value=''>
</form>

<table id='target-list' class='list detail clickable-tr'>
  <thead>
    <tr>
      <th class='left'>작성일</th>
      <th class='left' style='width:80%;'>제목</th>
      <th class='left'>진행상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr != null && arr.size() > 0) {
  for (QnaVO v : arr) {
      intTotalCnt = v.TOTAL_CNT;
      String strAnswer = (StrUtil.nvl(v.ANS_YN).equals("Y")) ? "<strong>답변완료</strong>" : "<font color='#aaa'>관리자확인중</font>";
%>
    <tr onclick='goDetail("<%= IntegerCryptoUtil.crypt(v.SEQ) %>");'>
      <td><%= ((StrUtil.nvl(v.REG_DT)).split(" ")[0]).replaceAll("-", strDateSeparator) %></td>
      <td><%= StrUtil.nvl(v.Q_TITLE) %></td>
      <td><%=strAnswer %></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='3' class='noentry'>등록하신 문의가 없습니다.<br/><br/>문의 내용은 타인에게 내용이 공개되지 않으며,<br/>문자나 이메일로 답변완료 여부를 알릴 수 있으니 참고바랍니다.<br/><br/><a href='QnAReg.jsp' class='btn'>등록</a></td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage', '<%= pvo.PAGE %>', '<%= intTotalCnt %>', '<%= pvo.ROW_CNT %>', 5, '');
  </script>
</div>

<%@ include file="../../includes/Footer.jsp" %>

