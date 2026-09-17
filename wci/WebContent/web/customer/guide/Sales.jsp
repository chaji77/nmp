<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepVO" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
SalesrepVO pvo = new SalesrepVO();
pvo.PAGE = 1;
pvo.ROW_CNT = 100;
ArrayList<SalesrepVO> arr = new SalesrepBean().M_SALESREP_LIST_PROC(pvo);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>영업담당자</title>
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>영업담당자</span>
</div>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>담당자</th>
      <th class='left'>연락처</th>
      <th class='left mobile_hide'>웹 팩스(팩스)</th>
      <th class='left'>이메일</th>
    </tr>
  </thead>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i< arr.size();) {
	SalesrepVO v = arr.remove(i); 
%>
  <tbody>
    <tr>
      <td><%=StrUtil.nvl(v.NM) %></td>
      <td class='left'><a href='tel:<%= StrUtil.nvl(v.PHONE_NO) %>'><%= StrUtil.nvl(v.PHONE_NO) %></a></td>
      <td class='left mobile_hide'><%= StrUtil.nvl(v.FAX_NO) %></td>
      <td class='left'><a href='mailto:<%= StrUtil.nvl(v.EMAIL)%>'><%= StrUtil.nvl(v.EMAIL) %></a></td>
    </tr>
  </tbody>
<%
  }
} else out.println("<tr><td colspan='5' class='noentry'>등록된 영업담당자가 없습니다.</td></tr>");
%>
</table>


<%@ include file="../../includes/Footer.jsp" %>