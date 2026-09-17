<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
if (strUserSeq.equals("0")) {
  response.sendRedirect("index.jsp");
  return;
}
String strCpyId       = (String)session.getAttribute("SESS_BILL_CPY_ID");
int    intPage        = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
String strStartDate   = StrUtil.nvl(request.getParameter("sd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 365, "-"));
String strEndDate     = StrUtil.nvl(request.getParameter("ed"), DateTimeUtil.getCurrentDate("-"));
String strCompanyName = StrUtil.nvl(request.getParameter("cn"));
int intTotalCnt = 0;
ArrayList<InvoiceVO> arr        = InvoiceDAO.BILL_LIST_BY_CPY_ID_PROC(intPage, Integer.parseInt(strCpyId), strStartDate.replaceAll("-", ""), strEndDate.replaceAll("-", ""), strCompanyName);
ArrayList<InvoiceVO> arrStandBy = InvoiceDAO.BILL_STANDBY_PROC(intPage, Integer.parseInt(strCpyId));
int intStandBy = (arrStandBy!=null) ? arrStandBy.size() : 0;
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>발행목록-처음빌</title>
<script>
function goPage(page) {
  document.frmSearch.page.value = page;
  document.frmSearch.target = "_self";
  document.frmSearch.submit();
}
function view(seq) {
	window.open('InvoiceView.jsp?seq='+seq,'invoice','width=1280,height=600,left=50,top=50,scrollbars=no,resizable=no');
}
function showErrMsg(ecode) {
  toast("오류내용을 조회하고 있습니다.", 50000);
  $.ajax({
    type:"POST",
    url:"GetErrString.jsp",
    data:{"e":ecode},
    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    success:function(r) {
      r = $.trim(r);
      removePopupMessage();
      alert(r);
    },
    error:function(a,b,c){
      toast("오류가 발생했습니다. 잠시 후 다시 시도하십시오. 문제가 지속되면 관리자에게 문의바랍니다.")
    }
  });
}
</script>
<!-- // page head block -->
<%@ include file="Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>발행목록</span>
  <span class='more'>
  </span>
</div>

  <form name='frmSearch' method='post' autocomplete="off">
  <input type='hidden' name='page' value='<%=intPage %>'>
  <table class='searchbox mobile_hide'>
    <tbody>
      <tr>
        <td>
          <ul>
            <li>
              <label>검색기간</label>
              <input type='date' name='sd' value='<%=strStartDate %>' style='width:auto;'>
              <input type='date' name='ed' value='<%=strEndDate %>' style='width:auto;'>
            </li>
            <li>
              <label>공급받는자</label>
              <input type='search' name='cn' value='<%=strCompanyName%>' placeholder='공급받는자'>
            </li>
          </ul>
        </td>
        <td class='fill'></td>
        <td class='btn' style='text-align:right;'>
          <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
          <a href='Invoices.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
        </td>
      </tr>
    </tbody>
  </table>
  </form>

  <form name='frmEnt'>
  <table class='list'>
    <thead>
      <tr>
        <th class='left'>발행번호</th>
        <th class='left'>진행상태</th>
        <th class='left'>승인번호</th>
        <th>작성일</th>
        <th class='left'>계산서종류</th>
        <th>과세구분</th>
        <th>청구/영수</th>
        <th class='left'>공급받는자</th>
        <th>사업자번호</th>
        <th class='right'>공급가액</th>
        <th class='right'>세액</th>
        <th class='right'>합계금액</th>
        <th class='left'>비고</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    intTotalCnt = vo.TCNT;
%>
      <tr>
        <td><a href='javascript:view(<%=vo.BILL_SEQ %>);'><b><%=vo.strSerialNum %></b></a></td>
        <td><%=InvoiceUtil.getStatus(vo) %>
           <%
           if (vo.BILL_STATUS<0) {
             out.print("<a href='javascript:showErrMsg("+Integer.toString(vo.BILL_STATUS)+");' class='btn darkred' style='border-radius:30px;'>?</a> ");
           }
           %>
        </td>


        <td><%=vo.INVOICE_KEY %></td>
        <td class='center'><%=FormatUtil.addSeparatorDate(vo.strWriteDate) %></td>
        <td><%=InvoiceUtil.getInvoiceType(vo) %></td>
        <td class='center'><%=InvoiceUtil.getChargeType(vo) %></td>
        <td class='center'><%=InvoiceUtil.getPurposeType(vo) %></td>
        <!-- td><%=InvoiceUtil.getTaxType(vo)  %></td -->
        <td><%=vo.strToCorpNm        %></td>
        <td class='center'><%=InvoiceUtil.getBizNo(vo.strToBizNo)         %></td>
        <td class='right'><%=StrUtil.addComma(vo.strAmountTotal) %></td>
        <td class='right'><%=StrUtil.addComma(vo.strTaxTotal)    %></td>
        <td class='right'><%=StrUtil.addComma(vo.strTotalAmount) %></td>
        <td class='left'><%=StrUtil.nvl(vo.strRemark)             %></td>
      </tr>
<%
  }
} else {
%>
      <tr>
        <td colspan='14' class='noentry'></td>
      </tr>
<%
}
%>
    </tbody>
  </table>
  </form>

  <div id="paging">
    <script>
    getPaging('goPage',<%=intPage%>,<%=intTotalCnt%>,20,10,'');
    </script>
  </div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
    
<%@ include file="../web/includes/Footer.jsp" %>