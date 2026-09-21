<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intActiveId = Integer.parseInt(StrUtil.nvl(request.getParameter("aid"), "0"));
if (intActiveId==0) return;

boolean isEditMode = request.getParameter("cid")!=null;
int intCommentId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
int intLeadCols = Integer.parseInt(StrUtil.nvl(request.getParameter("leadcols"), "3"));
String strDesc = StrUtil.nvl(request.getParameter("desc")).replaceAll("(?i)<br\\s*/?>", "\n").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
String strActionTag = (!isEditMode) ? "등록":"수정";
%>
<script>
function writeComment() {
  var strDesc = $.trim($("#comment_desc").val());
  if (strDesc === "") { showAlert("내용을 입력하세요."); return; }
  $.post(strContextPath + "/mgr/memo/<%=isEditMode ? "CommentModProc.jsp" : "CommentRegProc.jsp"%>", {
    aid: <%=intActiveId%>,
    cid: <%=intCommentId%>,
    comment_desc: strDesc
  }, function(data) {
    if (data!="0") {
      toast("<%=strActionTag%>하였습니다.", 1000, function() {
        closePopup();
        <% if (isEditMode) { %>
        loadComments(<%=intActiveId%>, <%=intLeadCols%>);
        <% } else { %>
        window.location.reload();
        <% } %>
      });
    } else {
      showAlert("<%=strActionTag%>하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
</script>
<h3>댓글 <%=strActionTag %></h3>
<textarea id='comment_desc' style='height:150px;width:calc(100% - 22px);'><%=strDesc %></textarea>
<div class='btns'><a onclick='writeComment();'><%=strActionTag %></a></div>

<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
