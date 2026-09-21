<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");

String strBillSeq = StrUtil.nvl(request.getParameter("seq"), "0");
if (!StrUtil.isOnlyNumeric(strBillSeq) || strBillSeq.equals("0")) return;

InvoiceVO voCheck = new InvoiceDAO().T_BILL_DETAIL_PROC(Integer.parseInt(strBillSeq));
if (voCheck.BILL_STATUS != 0) {
  out.println("error");
  return;
}

InvoiceVO vo = new InvoiceVO();
vo.BILL_SEQ     = strBillSeq;
vo.strWriteDate = StrUtil.nvl(request.getParameter("write_ymd"), "").replaceAll(strDateSeparator, "");

String[] arrItemMonth = request.getParameterValues("item_m");
String[] arrItemDate  = request.getParameterValues("item_d");
String[] arrItemName  = request.getParameterValues("item_item");
String[] arrItemSpec  = request.getParameterValues("item_spec");
String[] arrItemCnt   = request.getParameterValues("item_cnt");
String[] arrItemUnit  = request.getParameterValues("item_unit");
String[] arrItemPrice = request.getParameterValues("item_price");
String[] arrItemTax   = request.getParameterValues("item_tax");

ArrayList<InvoiceVO.TradeItem> arrTradeItem = new ArrayList<>();

if (arrItemMonth != null) {
  for (int i=0; i<arrItemMonth.length; i++) {
    InvoiceVO.TradeItem t = vo.new TradeItem();
    String ym = vo.strWriteDate.substring(0,6);
    t.strPurchaseExpiry = ym + ((StrUtil.nvl(arrItemDate[i], "1").length()==1) ? "0":"") + StrUtil.nvl(arrItemDate[i], "1");
    t.strName = StrUtil.nvl(arrItemName[i], "");
    t.strInformation = StrUtil.nvl(arrItemSpec[i], "");
    t.strChargeableUnit = StrUtil.nvl(arrItemCnt[i], "0").replaceAll(",", "");
    t.strUnitPrice = StrUtil.nvl(arrItemUnit[i], "0").replaceAll(",", "");
    t.strAmount = StrUtil.nvl(arrItemPrice[i], "0").replaceAll(",", "");
    t.strTax = StrUtil.nvl(arrItemTax[i], "0").replaceAll(",", "");
    t.strDescription = "";
    arrTradeItem.add(t);
  }
}
vo.arrTradeItem = arrTradeItem;

try {
  int intResult = new InvoiceDAO().T_BILL_DETAIL_MOD_PROC(vo);
  out.println(intResult > 0 ? "ok" : "error");
} catch (Exception e) {
  System.out.println(e.toString());
  out.println("error");
}
%>
