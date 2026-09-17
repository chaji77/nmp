<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.BillReceiverVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String[] getPreviousAndNextMonths() {
    LocalDate today = LocalDate.now();
    YearMonth currentMonth = YearMonth.from(today);
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMM");
    String[] result = new String[4];
    for (int i = 0; i <= 2; i++) {
        result[2 - i] = currentMonth.minusMonths(i).format(formatter);
    }
    result[3] = currentMonth.plusMonths(1).format(formatter);
    return result;
}
String getLastDayOfMonth(String yearMonth) {
  String formattedYearMonth = yearMonth.substring(0, 4) + "-" + yearMonth.substring(4, 6);
  YearMonth yearMonthObj = YearMonth.parse(formattedYearMonth);
  LocalDate lastDay = yearMonthObj.atEndOfMonth();
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
  return lastDay.format(formatter);
}
%>
<%
request.setCharacterEncoding("utf-8");
String strYearMonth = StrUtil.nvl(request.getParameter("ym"), DateTimeUtil.getCurrentDate("").substring(0, 6));
ArrayList<BillReceiverVO> arr = new InvoiceDAO().T_BILL_MONTH_TARGET_LIST_PROC(strYearMonth);
String[] arrMonthCombo = getPreviousAndNextMonths();
%>
<%@ include file="../Header.jsp" %>
<title>월합세금계산서발행</title>

<script>
function goSubmit() {
  document.frmSearch.target = "_self";
  document.frmSearch.action = "MonthlyTargets.jsp";
  document.frmSearch.submit();
}
function goContracts(intCpyId, strCpyName) {
  document.frmSearch.cpy_id.value = intCpyId;
  document.frmSearch.cpy_nm.value = strCpyName;
  document.frmSearch.target = "_new";
  document.frmSearch.action = "../trade/Contracts.jsp";
  document.frmSearch.submit();
}
function pub() {
  $.ajax({
    type:"POST",
    url:"MonthlyPublishProc.jsp",
    data:{"ym":"<%=strYearMonth%>"},
    async: true,
    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    success:function(r) {
      r = $.trim(r);
      showAlert(r + "건이 발행되었습니다.", function() {
        window.location.reload();
      });
    },
    error:function(a,b,c){
      toast("오류가 발생했습니다. 잠시 후 다시 시도하십시오. 문제가 지속되면 관리자에게 문의바랍니다.")
    },
    beforeSend: function() {
      showSpinner("발행신청하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>월합세금계산서발행</span>
  <span class='more'>
    <a class='btn' onclick='pub();'>일괄발행</a>
  </span>
</div>

  <form name='frmSearch' method='post'>
  <input type='hidden' name="cpy_id">
  <input type='hidden' name="cpy_nm">
  <input type='hidden' name="status" value='060'>
  <input type='hidden' name="start_ymd" value='<%=(strYearMonth.substring(0, 4)+"-"+strYearMonth.substring(4, 6)+"-01")%>'>
  <input type='hidden' name="end_ymd" value='<%=getLastDayOfMonth(strYearMonth)%>'>
  <table class="list searchbox mobile_hide">
    <tbody>
      <tr>
        <td>
          <ul>
            <li>
              <label>발행년월</label>
              <select name='ym' onchange='goSubmit();'>
              <%
              for (int i=0; i<arrMonthCombo.length; i++) {
                out.print("<option value='"+arrMonthCombo[i]+"'");
                if (arrMonthCombo[i].equals(strYearMonth)) out.print(" selected");
                out.println(">"+arrMonthCombo[i].substring(0,4)+"/"+arrMonthCombo[i].substring(4,6)+"</option>");
              }
              %>
              </select>
            </li>
          </ul>
        </td>

        <td class='fill'></td>
        <td class='btn' style='text-align:right;'><a onclick="goSubmit();"><i class="fa fa-search" aria-hidden="true" style="font-size:1.7em;margin-right:10px;"></i></a></td>
      </tr>
    </tbody>
  </table>
  </form>

  <table class='list'>
    <thead>
      <tr>
        <th class='left'>발행대상</th>
        <th>사업자번호</th>
        <th class='right'>공급가액</th>
        <th class='right'>세액</th>
        <th class='right'>합계금액</th>
        <th class='left'>매매계약서</th>
      </tr>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (BillReceiverVO r : arr) {
    if (r.CPY_ID>0) {
%>
      <tr onclick='goContracts(<%=r.CPY_ID%>, "<%=r.CPY_NAME%>")'>
        <td><%=r.CPY_NAME %></td>
        <td class='center'><%=r.CPY_BUSINESS_NO %></td>
        <td class='right'><%=StrUtil.addComma(r.MPFEE_SUPPLYAMT) %></td>
        <td class='right'><%=StrUtil.addComma(r.MPFEE_TAXAMT)    %></td>
        <td class='right'><%=StrUtil.addComma(r.MPFEE_TOTALAMT) %></td>
        <td class='left'><%=r.CNT%>건 (<%=StrUtil.nvl(r.CTNO).replaceAll(",", ", ") %>)</td>
      </tr>
<%
    } else {
      if (r.CNT>0) out.println("<tr><td colspan='6' class='noentry'>해당월의 월합세금계산서 "+r.CNT+"건이 발행되었습니다.</td></tr>");
    }
  }
} else {
%>
      <tr>
        <td colspan='6' class='noentry'>발행대상이 없습니다.</td>
      </tr>
<%
}
%>
    </tbody>
  </table>

<%@ include file="../Footer.jsp" %>