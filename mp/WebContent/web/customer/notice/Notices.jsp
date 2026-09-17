<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeAttachVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%
// 로그인이 필요하면 true로 변경하세요.
// @require LoginCheck.jsp
// pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
NoticeVO pvo = new NoticeVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
String strIncludeDroppedArticle = "N";
ArrayList<NoticeVO> arr = new NoticeBean().C_NOTICE_LIST_PROC(pvo, strIncludeDroppedArticle);
int intTotalCnt = 0;
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>공지사항</title>

<script>
function goDetail(r) {
  location.href = "Notice.jsp?nid=" + r + "&page=<%=strPage%>";
}
function goPage(p) {
  location.href = "Notices.jsp?page="+p;
}
</script>

<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>공지사항</span>
</div>

<table id='target-list' class='list clickable-tr has-cap'>
  <colgroup>
    <col width='*' />
    <col width='100' class='mobile_hide' />
  </colgroup>
  <thead>
    <tr>
      <th class='left'>제목</th>
      <th class='left mobile_hide'>등록일</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i< arr.size();) {
    NoticeVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
%>
    <tr onclick='goDetail("<%=IntegerCryptoUtil.crypt(v.SEQ)%>");'>
      <td><%=StrUtil.nvl(v.TITLE) %></td>
      <td class='mobile_hide'><%=StrUtil.nvl(v.REG_DT).substring(0, 10).replaceAll("-", strDateSeparator) %></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='2' class='noentry'>등록된 게시글이 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../../includes/Footer.jsp" %>
