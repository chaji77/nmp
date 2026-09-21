<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
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
QnaVO vo = new QnaVO();

String strId = StrUtil.nvl(request.getParameter("mid"), "0");
if (IntegerCryptoUtil.isEncrypted(strId)) vo.SEQ = Integer.parseInt(IntegerCryptoUtil.crypt(strId));
else vo.SEQ = 0;

if (vo.SEQ > 0) vo = bean.C_QNA_DETAIL_PROC(vo.SEQ);
%>

<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>1:1문의</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<script type="text/javascript">
$(document).ready(function(){
});

function goSubmit() {
  if (check()==true) {
    document.frmEnt.action  = "QnARegProc.jsp";
    document.frmEnt.method  = "post";
    document.frmEnt.submit();
  }
}

function check() {
  var is = validate("input[name='title']", "length", [2,50], "제목을 입력하세요.");
  if (is) is = validate("textarea[name='contents']", "length", [2,1000], "내용을 입력하세요.");
  return is;
}
</script>

<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1문의</span>
  <span class='more'>
  </span>
</div>

<form name='frmEnt' id='frmEnt' autocomplete="off">
<input type='hidden' name='mid' value='<%= vo.SEQ %>'>
<ul class='form'>
  <li class='wide' style='padding-bottom:10px;border-bottom:1px solid #ddd;'>
    <label class='emphasis'>제　　목</label>
    <input type='text' name='title' maxlength='50' value='<%=StrUtil.nvl(vo.Q_TITLE) %>'>
  </li>
  <li class='wide' style='padding-bottom:10px;border-bottom:1px solid #ddd;'>
    <label class='emphasis'>문의코드</label>
    <select name='code' maxlength='50' <%= (vo.SEQ > 0) ? "disabled" : "" %>>
      <%
      for (Map.Entry<String, String> entry : QnaVO.getQTypeMap().entrySet()) {
      %>
            <option value='<%= entry.getKey() %>' <%= entry.getKey().equals(vo.Q_CODE) ? "selected" : "" %>><%= entry.getValue() %></option>
      <%
      }
      %>
    </select>
    <% if (vo.SEQ > 0) { %>
    <input type='hidden' name='code' value='<%=StrUtil.nvl(vo.Q_CODE) %>'>
    <% } %>
  </li>
  <li class='wide'>
    <label class='emphasis' style='vertical-align:top;'>문의내용</label>
    <textarea name="contents" style="height:200px;width:calc(100% - 166px);"><%=StrUtil.nvl(vo.Q_CONTENTS).replaceAll("<br>", "") %></textarea>
  </li>
</ul>
</form>

<div class='btns'>
  <a onclick='goSubmit();'><%=(vo.SEQ > 0)?"수정":"등록" %></a>
  <a onclick='history.go(-1);' class='cancel'>취소</a>
</div>

<%@ include file="../../includes/Footer.jsp" %>

