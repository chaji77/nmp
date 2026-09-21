<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.trade.UnusualListVO" %>
<%@ page import="kr.co.mp.trade.UnusualTransactionVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

int intCpyId       = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id"), "0"));
String strCpyNm    = StrUtil.nvl(request.getParameter("cpy_nm"), "");

int intPage        = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intPageSize    = 20;
String strReleased = StrUtil.nvl(request.getParameter("withReleasedYN"), "N");
String guar_gubun  = StrUtil.nvl(request.getParameter("guar_gubun"), "");
int intTotalCnt    = 0;

TradeBean bean = new TradeBean();
ArrayList<UnusualListVO> arr = null;
ArrayList<UnusualTransactionVO> arrUnusuals = null;
try {
  arr = bean.UNUSUAL_TRANSACTION_LIST_PROC(intPage, intPageSize, strReleased, guar_gubun);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
  arr = null;
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>이상거래관리</title>
<style>
span.w {padding:2px 5px;border:1px solid #ddd;color:#888;}
table.detail td {line-height:1.7em;vertical-align:top;}
table.detail td a.underline {border-bottom:1px solid #00f;color:#00f;}
table.detail td a.btn {padding:2px 6px;}
table.detail td p {display:block;width:100%;}
table.detail .unusual {display:none;}
table.detail .unusual p {line-height:1.7em;}
table.detail td span {padding:2px 5px;}
span.not-solve {background-color:red;color:white;}
span.not-solve:hover {background-color:hotpink;}
.commands {max-width:200px;white-space:wrap;}
.commands a {white-space:nowrap;margin-bottom:10px;}
</style>

<script>
function searchCompany() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'/wci/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch.cpy_id.value = $(obj).attr("cid");
  document.frmSearch.cpy_nm.value = $(obj).text();
  closePopup();
}
function goDetail(ctid) {
  document.frmSearch.seq.value = ctid;
  document.frmSearch.action = "Contract.jsp";
  document.frmSearch.submit();
}
function goPage(p) {
  document.frmSearch.page.value = p;
  var koditChecked = document.getElementsByName('kodit')[0].checked ? 'KODIT' : '';
  var kiboChecked = document.getElementsByName('kibo')[0].checked ? 'KIBO' : '';
  document.frmSearch.guar_gubun.value = koditChecked || kiboChecked;
  document.frmSearch.action = "UnusualContracts.jsp";
  document.frmSearch.submit();
}
function calc(ctid) {
  $.post("<%=request.getContextPath()%>/mgr/mpfee/CalcCommissionFixed.jsp", {'ctid':ctid}, function(data) {
    showAlert(data);
  });
}
function openUnusal(obj) {
  var is = ($(obj).closest("tr").next("tr").children("td")).is(":visible");
  if (!is) ($(obj).closest("tr").next("tr").children("td")).show();
  else ($(obj).closest("tr").next("tr").children("td")).hide();
}
function openReleasePage(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'UnusualReg.jsp?seq='+seq});
}
function openChangeStatusWindow(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'StatusChange.jsp?seq='+seq});
}
function changeStatus() {
  $.post("StatusChangeProc.jsp", $("form[name='frmStatusChange']").serialize(), function(data) {
    window.location.reload();
  });
}
function checkAbnormal(strMpFeeCpyId, intCtId) {
  showSpinner("불러오고있습니다.");
  $("#ifmContract").attr("src", "ContractReg.jsp?cpy_id="+strMpFeeCpyId+"&seq="+intCtId);
}
function showTransactionResult(intCtId) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/mgr/trade/TransactionResult.jsp?seq='+intCtId});
}
function cancelTransaction(encid) {
  $.ajax({
    url:strContextPath + "/web/transaction/B315.jsp", 
    type: 'post',
    data:{'ctid':encid}, 
    async: true,
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        showAlert(json.msg, function() {
          window.location.reload();
        });
      } else showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendTransaction(encid, token) {
  $.ajax({
    url:strContextPath + "/web/transaction/B311.jsp", 
    type: 'post',
    data:{'ctid':encid,'token':token}, 
    async: true,
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        showAlert(json.msg, function() {
          window.location.reload();
        });
      } else showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function openTaxBill(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/common/Tax.jsp?seq='+seq});
}
function sendA211(ctid) {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A211.jsp", 
    type: 'post',
    data:{"ctid":ctid}, 
    async: true,
    success: function(data) {
      showAlert(data);
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendA411(ctid) {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A411.jsp", 
    type: 'post',
    data:{"ctid":ctid, "strSellerClearYn":"Y"},
    async: true,
    success: function(data) {
      if (data=="Y") showAlert("판매사사전검증차단해제등록되었습니다.");
      else showAlert("판매사사전검증차단중입니다.");
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
  $('#ifmContract').on( 'load', function() {
    setTimeout(function() {
      $("#ifmContract").get(0).contentWindow.checkAbnormal();
    }, 500);
  });
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>이상거래관리</span>
  <span class='more'>
    
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=intPage%>'>
<input type='hidden' name='cpy_id' value=''>
<input type='hidden' name='seq' value='0'>
<input type='hidden' name='guar_gubun' value=''>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='withReleasedYN' value='Y' <%=((strReleased.equals("Y"))?"checked":"") %>>해제건 포함</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='kodit' value='KODIT' <%=((guar_gubun.equals("KODIT"))?"checked":"") %>>신보</li>
 		<li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='kibo' value='KIBO' <%=((guar_gubun.equals("KIBO"))?"checked":"") %>>기보</li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>계약일</th>
      <th class='left'>만기일</th>
      <th class='left'>계약아이디/계약번호</th>
      <th class='left'>결제수단/세금계산서</th>
      <th class='left'>구매기업/판매기업</th>
      <th class='right'>결제금액/수수료</th>
      <th class='left'>진행상태</th>
      <th class='left'>이상거래</th>
      <th class='left'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (UnusualListVO vo : arr) {
    String strUnusual   = "";
    String strMpFeeAmt  = "<i class='fa-solid fa-calculator' onclick='calc("+vo.CTID+");' style='cursor:pointer;'></i>";
    if (!StrUtil.nvl(vo.MPFEE_TOTALAMT).equals("")) strMpFeeAmt = StrUtil.addComma(vo.MPFEE_TOTALAMT) + " " + strMpFeeAmt;
    strUnusual += "<a onclick='openReleasePage("+vo.SEQ+");' class='btn'>관리</a> ";
    strUnusual += (vo.USE_YN.equals("N")) ? "<font color='red'>[진행]</font> " : "[해제] ";
    strUnusual += StrUtil.nvl(vo.CONTENT).replaceAll("<br/>", ". ");
    if (vo.USE_YN.equals("N") && vo.SECTION.equals("KD009")) {
      strUnusual += " <a onclick='sendA211("+vo.CTID+");' class='btn'>사전검증조회</a> <a onclick='sendA411("+vo.CTID+");' class='btn'>사전검증해제등록</a>";
    }
    strUnusual += "<br/>";
%>
    <tr>
      <td class='left'><%=FormatUtil.addSeparatorDate(vo.CONTRACTDATE) %></td>
      <td class='left'><%=FormatUtil.addSeparatorDate(vo.MTYDATE) %></td>
      <td class='left'><a onclick='goDetail(<%=vo.CTID%>);' class='underline'><strong><%=vo.CTID%></strong></a><br/><%=vo.CTNO %></td>
      <td class='left' style='max-width:200px;white-space:wrap;'><%=vo.BNK_NAME %> <%=vo.PAY_SDESC %><br/><a onclick='openTaxBill(<%=vo.SBILL_SEQ%>);' class='underline'><%=vo.TAXAPPROVALNO %></a></td>
      <td class='left'>
        <%=vo.BUYER_NM %><%=(vo.CTTYPE.equals("B"))?" <span class='w'>작성</span>":"" %><%=(StrUtil.nvl(vo.MPPAYCPY).equals("2"))?" <span class='w'>부담</span>":"" %><br/>
        <%=vo.SELLER_NM %><%=(vo.CTTYPE.equals("S"))?" <span class='w'>작성</span>":"" %><%=(StrUtil.nvl(vo.MPPAYCPY).equals("1"))?" <span class='w'>부담</span>":"" %>
      </td>
      <td class='right'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></td>
      <td class='left'>
        <% if (vo.STATUS.equals("030") || vo.STATUS.equals("040") || vo.STATUS.equals("050") || vo.STATUS.equals("060") || vo.STATUS.equals("070") || vo.STATUS.equals("080") || vo.STATUS.equals("090")) { %>
        <a onclick='showTransactionResult(<%=vo.CTID%>);' class='underline'><%=vo.CODE_NM %></a>
        <% } else { %>
        <%=vo.CODE_NM %>
        <% } %>
        <% 
        if (vo.STATUS.equals("040") || (vo.STATUS.equals("050") && vo.BNK_CD.equals("TB"))) {
          out.println("<a onclick='cancelTransaction(\""+IntegerCryptoUtil.crypt(vo.CTID)+"\");' class='btn darkred'>전송취소</a>");
        }
        %>
        <% 
        if (vo.STATUS.equals("030") || vo.STATUS.equals("707")) {
          out.println("<a onclick='sendTransaction(\""+IntegerCryptoUtil.crypt(vo.CTID)+"\", \""+CryptoDESUtil.encrypt(vo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "")+"\");' class='btn lurian'>재전송</a>");
        }
        %>
      </td>
      <td style='white-space:wrap;'><%=strUnusual %></td>
      <td class='left commands' style='white-space:nowrap;'>
         <% if (!"060,070".contains(vo.STATUS)) { %>
         <a onclick='openChangeStatusWindow(<%=vo.CTID%>);' class='btn lurian'>상태변경</a>
         <a onclick='checkAbnormal("<%=IntegerCryptoUtil.crypt(vo.CPYBUYER) %>", <%=vo.CTID%>);' class='btn white'>이상거래검증</a>
         <% } %>
      </td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='12' class='noentry'>검색조건에 맞는 계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=intPage%>', '<%=intTotalCnt%>', '<%=intPageSize%>', 5, '');
  </script>
</div>


<iframe id='ifmContract'></iframe>
<%@ include file="../Footer.jsp" %>