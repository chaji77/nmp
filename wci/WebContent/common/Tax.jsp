<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxItemVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%!
String getGubun(String cd) {
  cd = StrUtil.nvl(cd);
  if (cd.equals("01")) return "세금계산서";
  if (cd.equals("02")) return "수정세금계산서";
  if (cd.equals("03")) return "계산서";
  return "수정계산서";
}
String getClass(String cd) {
  cd = StrUtil.nvl(cd);
  if (cd.equals("01")) return "일반";
  if (cd.equals("02")) return "영세율";
  if (cd.equals("03")) return "위수탁";
  if (cd.equals("04")) return "수입";
  if (cd.equals("05")) return "영세율위수탁";
  if (cd.equals("06")) return "수입납부 유예";
  return "";
}
%>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = StrUtil.nvl(request.getParameter("seq"));
// System.out.println(strBillSeq);
TaxBean bean = new TaxBean();
TaxVO t = new TaxVO();
BigDecimal fsum   = new BigDecimal(0);
BigDecimal fa_sum = new BigDecimal(0);
BigDecimal fv_sum = new BigDecimal(0);
StringBuffer sbItems = new StringBuffer();
ArrayList<TaxItemVO> arr= new ArrayList<>();
if (StrUtil.isOnlyNumeric(strBillSeq)) {
  t = bean.CT_BILL_MASTER_DETAIL_PROC(strBillSeq);
  arr = bean.CT_BILL_ITEM_DETAIL_PROC(strBillSeq);
  BigDecimal fa = (StrUtil.isOnlyNumeric(t.PAY_SUM_AMOUNT)) ? new BigDecimal(t.PAY_SUM_AMOUNT) : new BigDecimal(0);
  BigDecimal fv = (StrUtil.isOnlyNumeric(t.PAY_SUM_TAX)) ? new BigDecimal(t.PAY_SUM_TAX) : new BigDecimal(0);
  fsum = fa.add(fv);
  if (arr!=null && arr.size()>0) {
    for (TaxItemVO ivo : arr) {
      BigDecimal ia = (StrUtil.isOnlyNumeric(ivo.ITEM_AMOUNT)) ? new BigDecimal(ivo.ITEM_AMOUNT) : new BigDecimal(0);
      BigDecimal iv = (StrUtil.isOnlyNumeric(ivo.ITEM_TAX)) ? new BigDecimal(ivo.ITEM_TAX) : new BigDecimal(0);
      fa_sum = fa_sum.add(ia);
      fv_sum = fv_sum.add(iv);
      BigDecimal isum = ia.add(iv);
      sbItems.append("<tr>");
      sbItems.append("<td>"+StrUtil.input(ivo.ITEM_NAME)+"</td>");
      sbItems.append("<td class='right mobile_hide'>"+StrUtil.addComma(ivo.ITEM_CNT)+"</td>");
      sbItems.append("<td class='left mobile_hide'>"+StrUtil.input(ivo.ITEM_UNIT)+"</td>");
      sbItems.append("<td class='right'>"+StrUtil.addComma(ivo.ITEM_AMOUNT)+"</td>");
      sbItems.append("<td class='right mobile_hide'>"+StrUtil.addComma(ivo.ITEM_TAX)+"</td>");
      sbItems.append("<td class='right'>"+StrUtil.addCommaAfterRound(isum.toPlainString())+"</td>");
      sbItems.append("</tr>");
    }
  }
}

%>
<style>
#element_to_pop_up {background-color:white;padding:20px !important;}
div.tax {min-width: 700px;}
@media only screen and (max-width:767px) {
  div.tax {min-width: calc(100% - 40px);}
}
</style>

<div class='tax'>

  <!-- close -->
  

  <ul class='detail'>

    <li class='th'>일련번호</li>
    <li class='td'><%=StrUtil.nvl(t.BILL_NO) %></li>
    <li class='th'>승인번호</li>
    <li class='td'><%=StrUtil.nvl(t.APP_NO) %></li>

    <li class='th'>작성일</li>
    <li class='td'><%=FormatUtil.addSeparatorDate(StrUtil.nvl(t.BILL_DT)) %></li>
    <li class='th'>합계금액</li>
    <li class='td'><%=StrUtil.addCommaAfterRound(fsum.toPlainString()) %></li>

    <li class='th'>공급가</li>
    <li class='td'><%=StrUtil.addCommaAfterRound(fa_sum.toPlainString())%></li>
    <li class='th'>부가세</li>
    <li class='td'><%=StrUtil.addCommaAfterRound(fv_sum.toPlainString())%></li>

    <li class='th'>계산서분류</li>
    <li class='td'><%=getGubun(t.BILL_TYPE) %></li>
    <li class='th'>계산서종류</li>
    <li class='td'><%=getClass(t.PAY_TAX_RATE) %></li>

    <li class='th'>공급자</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_VENDERNO) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_VENDERNO) %></li>
  
    <li class='th'>공급자 회사명</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_NAME) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자 회사명</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_NAME) %></li>
  
    <li class='th'>공급자 대표</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_CEO) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자 대표</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_CEO) %></li>
  
    <li class='th'>공급자 주소</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_ADDRESS) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자 주소</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_ADDRESS) %></li>

    <li class='th'>공급자 업태</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_TYPE) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자 업태</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_TYPE) %></li>

    <li class='th'>공급자 종목</li>
    <li class='td'><%=StrUtil.nvl(t.SCOMP_CLASS) %></li>
    <li class='th' style='background-color:#fee;'>공급받는자 종목</li>
    <li class='td'><%=StrUtil.nvl(t.RCOMP_CLASS) %></li>

  </ul>
  
  <p>&nbsp;</p>
  
  <table id='items' class='detail'>
    <colgroup>
      <col width='*'/>
      <col width='80' class='mobile_hide'/>
      <col width='80' class='mobile_hide'/>
      <col width='90'/>
      <col width='90' class='mobile_hide'/>
      <col width='100'/>
    </colgroup>
    <thead>
      <tr>
        <th class='left'>품목</th>
        <th class='right mobile_hide'>수량</th>
        <th class='left mobile_hide'>단위</th>
        <th class='right'>공급가</th>
        <th class='right mobile_hide'>세액</th>
        <th class='right'>총액</th>
      </tr>
    </thead>
    <tbody>
      <%=sbItems.toString() %>
    </tbody>
  </table>
  
  <h3 style='margin:0;margin-top:20px;padding:0;width:100%;text-align:center;'><a onclick='closePopup();'><i class="fa-solid fa-xmark" style='font-size:1.6em;'></i></a></h3>
</div>

  