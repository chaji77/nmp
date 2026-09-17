<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
TradeBean bean = new TradeBean();
CtHeaderVO vo = bean.CT_HEADER_DETAIL_PROC(intCtId);

%>

<h3>진행상태변경</h3>

<p>&nbsp;</p>

<form name='frmStatusChange'>

<ul class='form'>
  <li style='margin-top:10px;'>
    <label>계약아이디</label>
    <input type='text' name='seq' value='<%=intCtId %>' readOnly>
  </li>
  <li>
    <label>진행상태</label>
    <select name='status'>
      <option value="010">임시보관</option>
      <option value="020">승인대기</option>
      <option value="025">계약승인(은행전송대기)</option>
      <option value="040">계약승인(결제중)</option>
      <option value="050">은행추심완료</option>
      <option value="060">결제완료</option>
      <%
      if ("010,020,025".contains(vo.STATUS)) {
      %>
      <option value="080">취소</option>
      <%
      }
      %>
      <option value="090">삭제</option>
    </select>
  </li>
  <li style='margin-top:20px;'>
    <label></label>
    <a onclick='changeStatus()' class='btn'>저장</a>
  </li>
</ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>