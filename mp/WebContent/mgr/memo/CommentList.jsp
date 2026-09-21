<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.mgr.memo.CommentVO" %>
<%@ page import="kr.co.mp.mgr.memo.CommentBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intActiveId = Integer.parseInt(StrUtil.nvl(request.getParameter("aid"), "0"));
if (intActiveId==0) return;
int intLeadCols = Integer.parseInt(StrUtil.nvl(request.getParameter("leadcols"), "3"));

String strManagerId = (String) pageContext.getAttribute("SESS_LOGIN_ID");
ArrayList<CommentVO> arr = new CommentBean().ACTIVE_COMMENT_LIST_PROC(intActiveId);
%>
<%
if (arr!=null && arr.size()>0) {
  for (CommentVO c : arr) {
    String strDesc = HtmlWhiteListUtil.filter(c.COMMENT_DESC).replaceAll("&quot;", "");
    String strDescAttr = StrUtil.nvl(c.COMMENT_DESC).replaceAll("&", "&amp;").replaceAll("\"", "&quot;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
%>
    <tr class='comment-row-<%=intActiveId %>'>
<%
    for (int k=0; k<intLeadCols; k++) {
      if (k==intLeadCols-1) {
%>
      <td class='mobile_hide right' style='color:#000;'>↳</td>
<%
      } else {
%>
      <td class='mobile_hide'></td>
<%
      }
    }
%>
      <td style='white-space:wrap;'><%=strDesc %></td>
      <td class='mobile_hide'><%=c.USER_NM %></td>
      <td class='center mobile_hide'><%=c.WRITE_DATE.substring(0, 16) %></td>
      <td class='left'>
      <% if (strManagerId.equals(c.WRITE_ID)) { %>
        <a data-desc="<%=strDescAttr %>" onclick='editComment(<%=c.COMMENT_ID %>, <%=intActiveId %>, this, <%=intLeadCols %>);' class='btn lurian'>수정</a>
        <a onclick='dropComment(<%=c.COMMENT_ID %>, <%=intActiveId %>);' class='btn darkred'>삭제</a>
      <% } %>
      </td>
    </tr>
<%
  }
} else {
%>
    <tr class='comment-row-<%=intActiveId %>'><td colspan='<%=intLeadCols+4 %>' class='noentry'>등록된 댓글이 없습니다.</td></tr>
<%
}
%>
