<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

NoticeVO pvo = new NoticeVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
String strIncludeDroppedArticle = "N";
ArrayList<NoticeVO> arr = new NoticeBean().C_NOTICE_LIST_PROC(pvo, strIncludeDroppedArticle);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<script>
function goDetail(r) {
  location.href = "Notice.jsp?id=" + r;
}
function goPage(p) {
  location.href = "Notices.jsp?page="+p;
}
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>공지사항관리</span>
  <span class='more'>
    <a href='NoticeReg.jsp' class='btn'>신규등록</a>
  </span>
</div>

<table id='target-list' class='list detail clickable-tr'>
  <colgroup>
    <col width='10%' class='mobile_hide' />
    <col width='60%' />
    <col width='10%' class='mobile_hide' />
    <col width='*' />
  </colgroup>
  <thead>
    <tr>
      <th class='left mobile_hide'>등록일시</th>
      <th class='left'>제목</th>
      <th class='left mobile_hide'>등록자</th>
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
      <td class='mobile_hide'><%=StrUtil.nvl(v.REG_DT) %></td>
      <td><%=StrUtil.nvl(v.TITLE) %></td>
      <td class='mobile_hide'><%=StrUtil.nvl(v.USER_NM) %></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='4' class='noentry'>등록된 게시글이 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>