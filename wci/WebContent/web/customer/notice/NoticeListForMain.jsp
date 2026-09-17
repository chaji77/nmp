<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%
request.setCharacterEncoding("utf-8");

NoticeVO pvo = new NoticeVO();
pvo.PAGE = 1;
pvo.ROW_CNT = 5;
String strIncludeDroppedArticle = "N";
ArrayList<NoticeVO> arr = new NoticeBean().C_NOTICE_LIST_PROC(pvo, strIncludeDroppedArticle);
%>
<%
if (arr!=null && arr.size()>0) {
  for (int i=0; i< arr.size();) {
    NoticeVO v = arr.remove(i);
    out.println("            <li><i class='fa-regular fa-message'></i> &nbsp; <a href='"+request.getContextPath()+"/web/customer/notice/Notice.jsp?nid="+IntegerCryptoUtil.crypt(v.SEQ)+"'>"+StrUtil.nvl(v.TITLE)+"</a></li>");
  }
} else out.println("<li>등록된 게시글이 없습니다.</li>");
%>
