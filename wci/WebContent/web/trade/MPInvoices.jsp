<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ page import="com.baroservice.ws.ArrayOfString" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
int intPage =  Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intTotalCnt = 0;
String strWriteDate = StrUtil.nvl(request.getParameter("wd"), "");
String strInvoiceeCorpNum = StrUtil.nvl(request.getParameter("cn"), "");
int intStatus = 1;

InvoiceDAO dao = new InvoiceDAO();
String strEmpId = "0";
ArrayList<InvoiceVO> arr = dao.T_BILL_LIST_BY_CPY_ID_PROC(strSenderKey, intPage, intCpyId);
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>MP세금계산서</title>

<!-- for calendar -->
<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<script>
$(function() {
  $( ".datepicker").datepicker({changeYear:true,changeMonth:true,dateFormat:"yy/mm/dd"});
  $("input[type='text']").keydown(function(e) {
      if (e.keyCode == 13) {
        goPage(1);
      }
  });
});

function goPage(page) {
  document.frmSearch.page.value = page;
  document.frmSearch.target = "_self";
  document.frmSearch.submit();
}

function view(seq) {
  window.open('MPInvoiceView.jsp?'+seq,'invoice','width=850,height=600,left=100,top=100,scrollbars=no,resizable=no');
}

</script>

<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>MP세금계산서</span>
  <span class='more'>
  </span>
</div>

  <form name='frmSearch' method='post'>
  <input type='hidden' name='page' value='<%=intPage %>'>
  <input type='hidden' name='senderKey' value='<%=strSenderKey%>'>
  <input type='hidden' name='seq'>
  <!-- 
  <table class="list searchbox mobile_hide">
    <tbody>
      <tr>
        <td>
          <ul>
            <li>
              <label>작성일</label>
              <input type='text' name='wd' class='datepicker' value='<%=strWriteDate%>'>
            </li>
          </ul>
        </td>

        <td class='fill'></td>
        <td class='btn'><a onclick="goPage(1);"><i class="fa fa-search" aria-hidden="true"></i></a></td>
      </tr>
    </tbody>
  </table>
  -->
  </form>

  <table class='list clickable-tr'>
    <thead>
      <tr>
        <th class='left'>승인번호</th>
        <th class='left'>진행상태</th>
        <th>작성일</th>
        <th class='left'>공급자 (사업자번호)</th>
        <th class='left'>공급받는자 (사업자번호)</th>
        <th class='right'>공급가액</th>
        <th class='right'>세액</th>
        <th class='right'>합계금액</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    intTotalCnt = vo.TCNT;
%>
      <tr onclick='view("<%=IntegerCryptoUtil.crypt(vo.BILL_SEQ) %>");'>
        <td><%=vo.INVOICE_KEY %></td>
        <td><%=InvoiceUtil.getStatus(vo) %></td>
        <td class='center'><%=FormatUtil.addSeparatorDate(vo.strWriteDate) %></td>
        <td>
             <%=vo.INVOICER_CORP_NAME %>
            (<%=ConfigurationMgr.getInstance().getString("OWNER_BIZ_NO") %>)
        </td>
        <td>
             <%=vo.strToCorpNm %>
            (<%=InvoiceUtil.getBizNo(vo.strToBizNo) %>)
        </td>
        <td class='right'><%=StrUtil.addComma(vo.strAmountTotal) %></td>
        <td class='right'><%=StrUtil.addComma(vo.strTaxTotal)    %></td>
        <td class='right'><strong><%=StrUtil.addComma(vo.strTotalAmount) %></strong></td>
      </tr>
<%
  }
} else {
%>
      <tr>
        <td colspan='15' class='noentry'></td>
      </tr>
<%
}
%>
    </tbody>
  </table>

  <div id="paging">
    <script>
    getPaging('goPage',<%=intPage%>,<%=intTotalCnt%>,20,10,'');
    </script>
  </div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
<%@ include file="../includes/Footer.jsp" %>