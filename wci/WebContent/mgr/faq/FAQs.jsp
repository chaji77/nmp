<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.c.faq.FAQBean" %>
<%@ page import="kr.co.mp.c.faq.FAQVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

FAQVO pvo = new FAQVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
String strCAT_ID = StrUtil.nvl(request.getParameter("category"), "0");
if (StrUtil.isOnlyNumeric(strCAT_ID)) pvo.CAT_ID = Integer.parseInt(strCAT_ID);
else pvo.CAT_ID = 1;
String strSearchWord = StrUtil.xss(request.getParameter("searchWord"));

FAQBean bean = new FAQBean();
ArrayList<FAQVO> arrCategories = bean.C_FAQ_CAT_LIST_PROC();
ArrayList<FAQVO> arr = bean.C_FAQ_LIST_PROC(pvo, strSearchWord);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>FAQ관리</title>
<style>
ul.faq-category {display:flex;flex-flow:row wrap;justify-content:center;margin-bottom:40px;}
ul.faq-category li {font-weight:bold;padding:16px;border:1px solid #ddd;border-left:0;text-align:center;background-color:#dfeeff;color:#888;transition:background-color .2s ease-in-out;}
ul.faq-category li:last-child {border:0;border-bottom:1px solid #ddd;background-color:#fff;flex-grow:1;}
ul.faq-category li:first-child {border-left:1px solid #ddd;}
ul.faq-category li.category {cursor:pointer;}
ul.faq-category li.selected {font-size:1.1em;border-bottom:1px solid transparent;background-color:#fff;color:#000;}
ul.faq-category li.category:hover {color:#000;}
</style>
<script>
function goPage(p) {
	document.frmSearch.page.value = p;
	document.frmSearch.action = "FAQs.jsp";
	document.frmSearch.target = "_top";
	document.frmSearch.submit();
}
function search() {
	document.frmSearch.category.value = 0;
	goPage(1);
}
function changeTab(t) {
	document.frmSearch.category.value = t;
	goPage(1);
}
function edit(obj) {
	var id = $(obj).parent().parent().attr("id");
	document.frmSearch.id.value = id;
	document.frmSearch.action = "FAQReg.jsp";
	document.frmSearch.target = "_top";
	document.frmSearch.submit();
}
function drop(obj) {
	var id = $(obj).parent().parent().attr("id");
	document.frmSearch.id.value = id;
	showCustomConfirm("정말 삭제하시겠습니까?", function() {
	  $.post("./FAQDropProc.jsp", $("form[name='frmSearch']").serialize(), function(data) {
	    if (data=="0") {
	      $("#target-list>tbody>tr").each(function(index, item) {
	        if ($(item).attr("id")==id) {
	      	  $(item).next(".answer").remove();
	      	  $(item).remove();
	        }
	      });
	    }
	  });
	}, function() {});
}
function showAnswer(obj) {
	var currentAnswer = $(obj).closest("tr").next(".answer");
    var isVisible = currentAnswer.is(":visible");
    $(".answer").hide();
    if (!isVisible) {
    	currentAnswer.slideDown();
    }
}
$(document).ready(function(){
	$("a.magnify").on("click", function() {
	  	if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
	  	else $("table.searchbox").slideDown();
	});
	$("input[name='searchWord']").keydown(function(key) {
	    if (key.keyCode == 13) search();
	  });
	$("input[name='searchWord']").focus();
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>FAQ관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a href='FAQReg.jsp' class='btn'>신규등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='id' value=''>
<input type='hidden' name='category' value='<%=pvo.CAT_ID%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
     <ul>
        <li>
          <label>검색어</label>
          <input type='search' name='searchWord' value='<%=strSearchWord %>' placeholder='검색어'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:search();'></td>
  </tr>
</tbody>
</table>
</form>

<ul class='faq-category'>
<%
if (arrCategories!=null && arrCategories.size()>0) {
  for (FAQVO v : arrCategories) {
    String strSelected = (v.CAT_ID==pvo.CAT_ID)?"selected":"";
    out.print("<li onclick='changeTab("+v.CAT_ID+");' class='category "+strSelected+"'>"+v.CAT_NM+"</li>");
  }
  String strSelected = (0==pvo.CAT_ID)?"selected":"";
  out.print("<li onclick='changeTab(0);' class='category "+strSelected+"'>전체</li>");
}
%>
  <li></li>
</ul>

<table id='target-list' class='list detail clickable-tr'>
  <colgroup>
    <col width='60%' />
    <col width='10%' />
    <col width='10%' />
    <col width='*'   />
  </colgroup>
  <thead>
   <tr>
     <th class='left'>제목</th>
     <th class='center mobile_hide'>등록자</th>
     <th class='center'>관리</th>
   </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
	for (int i = 0; i < arr.size();) {
		FAQVO v = arr.remove(i);
		intTotalCnt = v.TOTAL_CNT;
		String strId = IntegerCryptoUtil.crypt(v.SEQ);
%>
   <tr id=<%=strId %>>
     <td onClick='showAnswer(this);'>Q. <%=v.TITLE %></td>
     <td class='center mobile_hide'><%=v.USER_NM %></td>
     <td class='center'><a onclick='edit(this);' class='btn lurian'>수정</a> <a onclick='drop(this);' class='btn darkred'>삭제</a></td>
   </tr>
   <tr class='faq answer'>
     <td colspan="3">A. <%=v.CONTENTS %></td>
   </tr>
<%
	}
}
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>