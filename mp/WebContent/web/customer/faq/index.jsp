	<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.faq.FAQBean" %>
<%@ page import="kr.co.mp.c.faq.FAQVO" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
FAQVO pvo = new FAQVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
String strCatId = StrUtil.nvl(request.getParameter("cat"), "0");
if (StrUtil.isOnlyNumeric(strCatId)) pvo.CAT_ID = Integer.parseInt(strCatId);
else pvo.CAT_ID  = 0;
String strSearchWord = StrUtil.xss(request.getParameter("searchWord"));

FAQBean bean = new FAQBean();
ArrayList<FAQVO> arrCategories = bean.C_FAQ_CAT_LIST_PROC();
ArrayList<FAQVO> arr = bean.C_FAQ_LIST_PROC(pvo, strSearchWord);
int intTotalCnt = 0;
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>FAQ</title>
<style>
div.searchbox {text-align:center;background-color:transparent;margin-bottom:20px;}
div.searchbox input {width:170px;border-radius:20px 0 0 20px;padding:20px;border:3px solid #555;border-right:0;background-color:transparent;vertical-align:top;}
div.searchbox i.fa {font-size:2em;vertical-align:top;cursor:pointer;color:#555;padding:7px;border-radius:0 20px 20px 0;border:3px solid #555;border-left:0;}
ul.faq-category {display:flex;flex-flow:row wrap;justify-content:center;margin-bottom:40px;}
ul.faq-category li {padding:16px;border:1px solid #888;border-left:0;text-align:center;background-color:#dfeeff;color:#888;transition:background-color .2s ease-in-out;}
ul.faq-category li:first-child, ul.faq-category li:last-child {border:0;border-bottom:1px solid #888;background-color:#fff;flex-grow:1;}
ul.faq-category li:first-child {border-right:1px solid #888;}
ul.faq-category li.category {cursor:pointer;}
ul.faq-category li.selected {font-size:1.1em;padding-left:25px;padding-right:25px;border-bottom:1px solid transparent;background-color:#fff;color:#000;font-weight:bold;}
ul.faq-category li.category:hover {padding-left:25px;padding-right:25px;color:#000;font-weight:bold;}
ul.faq-list li {line-height:2em;padding:10px 0;border-bottom:1px dotted #ddd;}
.bullet {color:white;padding:5px 10px;background-color:#246CEB;border-radius:20px;margin-right: 5px;}
.question {font-size:1.1em;}
.answer {display:none;margin:10px 0;padding:10px;text-align:justify;}
.answer p {line-height:1.6em;}
.cat {color:#246ceb;padding:0 10px;}
@media only screen and (max-width:767px) {
ul.faq-category {display:none;}
}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "index.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function search() {
  document.frmSearch.cat.value  = 0;
  goPage(1);
}
function goCategory(catid) {
  document.frmSearch.cat.value  = catid;
  goPage(1);
}
function showAnswer(obj) {
    var currentAnswer = $(obj).closest("li").next(".answer");
    var isVisible = currentAnswer.is(":visible");
    $(".answer").hide();
    if (!isVisible) {
        currentAnswer.slideDown();
    }
}
$(document).ready(function(){
  $("input[name='searchWord']").keydown(function(key) {
    if (key.keyCode == 13) search();
  });
  $("input[name='searchWord']").focus();
});
</script>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>FAQ</span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cat' value='<%=pvo.CAT_ID%>'>
<div class='searchbox'>
  <input type='search' name='searchWord' value='<%=strSearchWord %>' maxlength='10' placeholder='검색어'><i class="fa fa-search" aria-hidden="true" onclick='javascript:search();'></i>
</div>
</form>

<ul class='faq-category'>
  <li></li>
<%
if (arrCategories!=null && arrCategories.size()>0) {
  for (FAQVO v : arrCategories) {
    String strSelected = (v.CAT_ID==pvo.CAT_ID)?"selected":"";
    out.print("<li onclick='goCategory("+v.CAT_ID+");' class='category "+strSelected+"'>"+v.CAT_NM+"</li>");
  }
  String strSelected = (0==pvo.CAT_ID)?"selected":"";
  out.print("<li onclick='goCategory(0);' class='category "+strSelected+"'>전체</li>");
}
%>
  <li></li>
</ul>

<ul class='faq-list'>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
    FAQVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
%>
  <li class='question'><a onclick='showAnswer(this);'><span class='bullet'>Q</span><span class='cat'>[ <%=v.CAT_NM %> ]</span><%=v.TITLE %></a></li>
   <li class='answer'><%=v.CONTENTS %></li>
<%
  }
}
%>
</ul>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<h2 style='margin-top:100px;margin-bottom:30px;'>문제를 해결하지 못했나요?</h2>
<p style='margin-bottom:5px;'><a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><i class="fa-solid fa-square-phone"></i> 전화상담 <strong><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></strong></a></p>

<p>&nbsp;</p>
<p>&nbsp;</p>



<%@ include file="../../includes/Footer.jsp" %>