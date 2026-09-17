<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

QnaVO pvo = new QnaVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
String searchStatus = StrUtil.nvl(request.getParameter("searchStatus"), "");
pvo.ANS_YN = searchStatus;

ArrayList<QnaVO> arr = new QnaBean().C_QNA_LIST_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->

<script>
$(document).ready(function() {
  const selectElement = $('#ansyn');
  if (!selectElement) {
    return;
  }
  selectElement.on('change', function () {
    updateSearchCondition(this.value);
  });
  
  $('#target-list').on('click', function (event) {
    const target = event.target;
    const tr = target.closest('tr');
    const mid = tr?.getAttribute('data-mid'); 

    if (target.classList.contains('btn') && target.textContent.trim() === "답변") {
      navigateToEdit(mid, "answer"); 
    } else if (target.classList.contains('lurian')) {
      navigateToEdit(mid, "edit");  
    }
    
    if (target.classList.contains('darkred')) {
      return;
    }
  });
});

function updateSearchCondition(status) {
  const form = document.forms['frmSearch'];
  form.searchStatus.value = status;
  form.page.value = 1; 
  form.submit();
}
	
function goPage(p) {
  const form = document.forms['frmSearch'];
  form.page.value = p;
  form.action = "Qnas.jsp";
  form.target = "_top";
  form.submit();
}

function navigateToEdit(mid, mode) {
  const form = document.forms['frmSearch']; 
  
  form.mid.value = mid; 
  form.mode.value = mode; 
  form.action = "QnaReg.jsp"; 
  form.target = "_top"; 
  form.submit(); 
}

function drop(element) {
  event.stopPropagation();
  const mid = element.getAttribute('data-mid');
  showCustomConfirm("정말 삭제하시겠습니까?", function () {
	  location.href = "QnaDropProc.jsp?id=" + mid;
  });
}


function goDetail(mid) {
  location.href = "Qna.jsp?id=" + mid;
}

function search() {
  goPage(1);
}
</script>

<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>1:1 문의</span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='mid'  value=''>
<input type='hidden' name='mode' value=''> 
<input type='hidden' name='searchStatus' value='<%= pvo.ANS_YN %>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <div>
            <label>처리여부</label>
            <select id="ansyn" name="ansyn">
              <option value="" <%= "".equals(pvo.ANS_YN) ? "selected" : "" %>>전체</option>
              <option value="N" <%= "N".equals(pvo.ANS_YN) ? "selected" : "" %>>미처리</option>
              <option value="Y" <%= "Y".equals(pvo.ANS_YN) ? "selected" : "" %>>처리</option>
            </select>
          </div>
        </li>
      </ul>
    </td>
   </tr>
</tbody>
</table>
</form>

<table id='target-list' class='list detail clickable-tr'>
  <colgroup>
    <col width='10%' />
    <col width='50%' />
    <col width='10%' />
    <col width='10%' />
    <col width='10%' class='mobile_hide' />
    <col width='*' />
  </colgroup>
  <thead>
    <tr>
      <th class='left'>번호</th>
      <th class='left'>제목</th>
      <th class='left'>회사명</th>
      <th class='left'>작성자</th>
      <th class='left'>작성일</th>
      <th class='left mobile_hide'>처리여부</th>
      <th class='left'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr != null && arr.size() > 0) {
	for (QnaVO v : arr) {
      intTotalCnt = v.TOTAL_CNT;
      String answerStatus = "Y".equals(v.ANS_YN) ? "처리완료" : "미처리";
%>
    <tr data-mid="<%= v.SEQ %>" onclick='goDetail("<%= IntegerCryptoUtil.crypt(v.SEQ) %>");'>
      <td class='left'><%= v.SEQ %></td>
      <td><%= StrUtil.nvl(v.Q_TITLE) %></td>
      <td class='left'><%= StrUtil.nvl(v.CPY_NAME) %></td>
      <td class='left'><%= StrUtil.nvl(v.REG_NM) %></td>
      <td class='left'><%= StrUtil.nvl(v.REG_DT) %></td>
      <td class='mobile_hide'><%= answerStatus %></td>
      <td class='left'>
        <% if (!StrUtil.nvl(v.ANS_YN).equals("Y")) { %>
            <a class='btn'>답변</a>
        <% } else { %>
            <a class='btn lurian'>수정</a>
        <% } %>
        <a data-mid="<%= v.SEQ %>" class='btn darkred' onclick='drop(this)'>삭제</a>
      </td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='7' class='noentry'>조회된 문의가 없습니다.</td></tr>");
%>
  </tbody>
</table>
<div id="paging">
  <script>
  getPaging('goPage', '<%= pvo.PAGE %>', '<%= intTotalCnt %>', '<%= pvo.ROW_CNT %>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>
