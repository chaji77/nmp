<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="com.baroservice.ws.ArrayOfString" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = StrUtil.nvl(request.getParameter("seq"), "0");

if (!StrUtil.isOnlyNumeric(strBillSeq)) return;

int intBillSeq = Integer.parseInt(strBillSeq);
InvoiceVO vo = InvoiceDAO.BILL_DETAIL_PROC(intBillSeq);
%>
<!DOCTYPE HTML>
<html>
<head>
  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
  <title>세금계산서</title>
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/style.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
  <script src="<%=request.getContextPath() %>/static/js/jquery-3.7.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/javascript"></script>
  <script src="<%=request.getContextPath() %>/static/js/common.js?<%=DateTimeUtil.getCurrentResourceVersion()%>" type='text/javascript'></script>

  <style>
  body {padding:20px;}
  th, td {border:1px solid #aaa;}
  </style>
  <script>
  function getXmlLink() {
    $.ajax({
      url:"InvoiceLink.jsp", 
      type: 'post',
      data:{"seq":"<%=strBillSeq%>"}, 
      async: true,
      success: function(data) {
        hideSpinner();
        location.href = data;
      },
      error: function(request, status, error) {
        hideSpinner();
        showAlert("통신에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
        console.log(request.status + " : " + request.responseText + " : " + error);
      }, 
      beforeSend: function() {
        showSpinner("페이지를 찾고 있습니다.");
      },
      complete: function() {
        if (window.sendInProgress) {
          return;
        }
        hideSpinner();
      }
    });
  }
  
  
  </script>
</head>
<body>

    <div style='text-align:right;margin-bottom:10px;'>
      <a href='javascript:getXmlLink();' class='btn hide_print'>XML 내려받기</a>
      <a href='javascript:self.print();' class='btn hide_print'>인쇄</a>
    </div>

    <table class="table-invoice">
      <colgroup>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
      </colgroup>
      <thead>
      <tr>
        <th colspan="17" rowspan="2"><span class="f24"><%=InvoiceUtil.getInvoiceType(vo) %></span></th>
        <th colspan="4" rowspan="2">공 급 자<br/>(보 관 용)</th>
        <th colspan="4">책번호 : </th>
        <td colspan="4"></td>
        <th colspan="1">권</th>
        <td colspan="3"></td>
        <th colspan="1">호</th>
      </tr>
      <tr>
        <th colspan="4">일련번호 : </th>
        <td colspan="9"><%=vo.strSerialNum %></td>
      </tr>
      </thead>
      <tbody>
      <tr>
        <th colspan="1" rowspan="6">공<br/>급<br/>자</th>
        <th colspan="3">등록번호</th>
        <td colspan="8"><%=InvoiceUtil.getBizNo(vo.INVOICER_CORP_NUM)%></td>
        <th colspan="3">종사업장</th>
        <td colspan="2"></td>
        <th colspan="1" rowspan="6">공<br/>급<br/>받<br/>는<br/>자</th>
        <th colspan="3">등록번호</th>
        <td colspan="8"><%=InvoiceUtil.getBizNo(vo.strToBizNo)%></td>
        <th colspan="3">종사업장</th>
        <td colspan="2"><%=InvoiceUtil.getBizNo(vo.strToTaxRegId)%></td>
      </tr>
      <tr>
        <th colspan="3">상호</th>
        <td colspan="8"><%=vo.INVOICER_CORP_NAME%></td>
        <th colspan="1">성명</th>
        <td colspan="4"><%=vo.INVOICER_CEO_NAME%></td>
        <th colspan="3">상호</th>
        <td colspan="8"><%=vo.strToCorpNm %></td>
        <th colspan="1">성명</th>
        <td colspan="4"><%=vo.strToCeo %></td>
      </tr>
      <tr>
        <th colspan="3">사업장<br/>주소</th>
        <td colspan="13"><%=vo.INVOICER_ADDR%></td>
        <th colspan="3">사업장<br/>주소</th>
        <td colspan="13"><%=vo.strToAddr%></td>
      </tr>
      <tr>
        <th colspan="3">업태</th>
        <td colspan="6"><%=vo.INVOICER_BIZ_TYPE%></td>
        <th colspan="1">종목</th>
        <td colspan="6"><%=vo.INVOICER_BIZ_CLASS%></td>
        <th colspan="3">업태</th>
        <td colspan="6"><%=vo.strToBizType%></td>
        <th colspan="1">종목</th>
        <td colspan="6"><%=vo.strToBizClass%></td>
      </tr>
      <tr>
        <th colspan="3">담당자</th>
        <td colspan="6"><%=vo.INVOICER_CONTACT_NAME%></td>
        <th colspan="2">연락처</th>
        <td colspan="5"><%=vo.INVOICER_TEL%></td>
        <th colspan="3">담당자</th>
        <td colspan="6"><%=vo.strToManager%></td>
        <th colspan="2">연락처</th>
        <td colspan="5"><%=vo.strToTel%></td>
      </tr>
      <tr>
        <th colspan="3">이메일</th>
        <td colspan="13"><%=vo.INVOICER_EMAIL %></td>
        <th colspan="3">이메일</th>
        <td colspan="13"><%=vo.strToEmail%></td>
      </tr>
      </tbody>

      <tbody>
      <tr>
        <th colspan="4">작성일자</th>
        <th colspan="17">공급가액</th>
        <th colspan="13">세액</th>
      </tr>
      <tr>
        <td colspan="4" class="center"><%=FormatUtil.addSeparatorDate(vo.strWriteDate) %></td>
        <td colspan="17" class="right"><%=StrUtil.addComma(vo.strAmountTotal)     %></td>
        <td colspan="13" class="right"><%=StrUtil.addComma(vo.strTaxTotal)        %></td>
      </tr>
      <%
      if (vo.strRemark!=null && vo.strRemark.length()>0) {
      %>
      <tr>
        <th colspan='4'>비고</th>
        <td colspan='30'><%=StrUtil.nvl(vo.strRemark) %></td>
      </tr>
      <%
      }
      %>
      </tbody>
      <tbody class="invoice-items">
      <tr>
        <th colspan="1">월</th>
        <th colspan="1">일</th>
        <th colspan="13">품목</th>
        <th colspan="5">규격</th>
        <th colspan="3">수량</th>
        <th colspan="3">단가</th>
        <th colspan="4">공급가액</th>
        <th colspan="4">세액</th>
      </tr>
<%
int intItemCnt = 0;
if (vo.arrTradeItem!=null && vo.arrTradeItem.size()>0) {
  intItemCnt = vo.arrTradeItem.size();
  for (InvoiceVO.TradeItem t : vo.arrTradeItem) {
    String wd = t.strPurchaseExpiry;
    String m = "";
    String d = "";
    if (wd.length()==8) {
      m = Integer.toString(Integer.parseInt("1" + wd.substring(4, 6))-100);
      d = Integer.toString(Integer.parseInt("1" + wd.substring(6))-100);
    }
    System.out.println(m);
    System.out.println(d);
%>
      <tr>
        <td colspan="1" class="right"><%=m %></td>
        <td colspan="1" class="right"><%=d %></td>
        <td colspan="13"><%=t.strName %></td>
        <td colspan="5"><%=t.strInformation %></td>
        <td colspan="3" class="right"><%=StrUtil.addComma(t.strChargeableUnit) %></td>
        <td colspan="3" class="right"><%=StrUtil.addComma(t.strUnitPrice)      %></td>
        <td colspan="4" class="right"><%=StrUtil.addComma(t.strAmount)         %></td>
        <td colspan="4" class="right"><%=StrUtil.addComma(t.strTax)            %></td>
      </tr>
<%
  }
}
if (intItemCnt<3) {
  for (int i=intItemCnt; i<3; i++) {
%>
      <tr>
        <td colspan="1">&nbsp;</td>
        <td colspan="1">&nbsp;</td>
        <td colspan="13">&nbsp;</td>
        <td colspan="5">&nbsp;</td>
        <td colspan="3">&nbsp;</td>
        <td colspan="3">&nbsp;</td>
        <td colspan="4">&nbsp;</td>
        <td colspan="4">&nbsp;</td>
      </tr>
<%
  }
}
%>
      </tbody>
      <tbody>
      <tr>
        <th colspan="7">합계금액</th>
        <th colspan="4">현금</th>
        <th colspan="4">수표</th>
        <th colspan="4">어음</th>
        <th colspan="4">외상미수금</th>
        <td colspan="11" rowspan="2" class=" right">이 금액을 [<span style='color:darkred;font-weight:bold;'><%=InvoiceUtil.getPurposeType(vo) %></span>] 함.</td>
      </tr>
      <tr>
        <td colspan="7" class="right"><%=StrUtil.addComma(vo.strTotalAmount) %></td>
        <td colspan="4" class="right"><%=StrUtil.addComma(vo.strCash) %></td>
        <td colspan="4" class="right"></td>
        <td colspan="4" class="right"></td>
        <td colspan="4" class="right"></td>
      </tr>
      </tbody>
    </table>

</body>
</html>