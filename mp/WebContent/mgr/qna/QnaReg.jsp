<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>

<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strActionName = "등록";

QnaBean bean = new QnaBean();
QnaVO vo = new QnaVO();

int mid = Integer.parseInt(request.getParameter("mid"));

if (mid > 0) {
    vo.SEQ = mid;
    vo  = bean.C_QNA_DETAIL_PROC(vo.SEQ);
    if (vo.A_CONTENTS != null && vo.A_CONTENTS.trim().isEmpty()){
    	strActionName = "등록";
    } else {
    	strActionName = "수정";
    }
} else {
	strActionName = "등록";
	vo = new QnaVO();
}

%>

<%@ include file="../Header.jsp" %>

<title>1:1문의</title>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script type="text/javascript">

$(document).ready(function(){
});

function goSubmit() {
  if (check()==true) {
    showLoading();
    var contents = CKEDITOR.instances['contents'].getData().trim();
    document.frmEnt.editor.value = contents; 
    document.frmEnt.action  = "./QnaRegProc.jsp";
    document.frmEnt.method  = "post";
    document.frmEnt.submit();
  }
}

 function check() {
  return true;
 }
</script>

<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1문의 <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<form name='frmEnt' id='frmEnt' autocomplete="off">
<input type='hidden' name='mid' value='<%= vo.SEQ %>'>
<input type='hidden' name='editor' value=''>
<table class="form list detail" summary="Registration Form">
  <colgroup>
  <col width="100px" />
  <col width="70%" />
  <col width="100px" />
  <col width="*" />
  </colgroup>
  <tbody>
    <tr>
      <th>작 &nbsp;성 &nbsp;자</th>
      <td><%= StrUtil.nvl(vo.CPY_NAME) %> <%=StrUtil.nvl(vo.REG_NM) %></td>
      <th>작성일시</th>
      <td colspan='3'><%=StrUtil.nvl(vo.REG_DT) %></td>
    </tr>
    <tr>
      <th>제　　목</th>
      <td><%=StrUtil.nvl(vo.Q_TITLE) %></td>
      <th>답변여부</th>
      <td>
        <select name='answered'>
          <option value='Y' <%=(StrUtil.nvl(vo.ANS_YN).equals("Y"))?"selected":""%>>답변완료</option>
          <option value='N' <%=(StrUtil.nvl(vo.ANS_YN).equals("N"))?"selected":""%>>미처리</option>
        </select>
      </td>
    </tr>
    <tr>
      <th>내　　용</th>
      <td colspan='3'><%=StrUtil.nvl(vo.Q_CONTENTS).replaceAll("\r", "<br/>")%></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>
<div>
  <textarea id="contents" name="contents" style="height:200px;width:calc(100% - 2px);"><%=StrUtil.nvl(vo.A_CONTENTS) %></textarea>
</div>
</form>

<div class='btns'>
  <a onclick='goSubmit();'><%=strActionName %></a>
  <a onclick='history.go(-1);' class='cancel'>취소</a>
</div>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<iframe name="work" id="work" height="0" width="0" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>

<script type="text/javascript" src='<%=request.getContextPath() %>/static/js/CKEditorSetMini.js?<%=DateTimeUtil.getCurrentResourceVersion()%>'></script>
