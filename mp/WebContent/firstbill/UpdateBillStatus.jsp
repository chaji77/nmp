<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.baroservice.api.BarobillApiProfile"%>
<%@ page import="com.baroservice.api.BarobillApiService"%>
<%@ page import="com.baroservice.ws.ArrayOfString"%>
<%@ page import="com.baroservice.ws.ArrayOfTaxInvoiceStateEX"%>
<%@ page import="com.baroservice.ws.TaxInvoiceStateEX"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil"%>
<%@ page import="kr.co.mp.firstbill.*" %>
<%!
ArrayList<String[]> getStatus(BarobillApiService barobillApiService, String strKey, String strBizNo, ArrayOfString mgtKeyList) {
    ArrayList<String[]> arr = new ArrayList<>();
    try {
        ArrayOfTaxInvoiceStateEX taxInvoiceStates = barobillApiService.taxInvoice.getTaxInvoiceStatesEX(strKey, strBizNo, mgtKeyList);
        if (taxInvoiceStates==null) return arr;
        for (TaxInvoiceStateEX r : taxInvoiceStates.getTaxInvoiceStateEX()) {
            String[] s = new String[3];
            int intStatus = r.getBarobillState();
            if (intStatus<0) {
                s[0] = Integer.toString(intStatus); // fail
                s[1] = "";
                s[2] = "";
            }
            else {
                int intResult = r.getNTSSendState();
                s[0] = Integer.toString(intResult);
                s[1] = r.getMgtKey();
                s[2] = r.getInvoiceKey();
            }
            arr.add(s);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return arr;
}
%>
<h3>국세청전송결과수신</h3>
<ul>
<%
BarobillApiProfile mode = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? BarobillApiProfile.TESTBED : BarobillApiProfile.RELEASE;
String key = ConfigurationMgr.getInstance().getString("ETAX_KEY");
BarobillApiService barobillApiService = new BarobillApiService(mode);
ArrayList<String> arrBizNo = new ArrayList<>();
ArrayList<InvoiceVO> arr = InvoiceDAO.BILL_STATUS_PROC();
if (arr!=null && arr.size()>0) {
  for (InvoiceVO vo : arr) {
    arrBizNo.add(vo.INVOICER_CORP_NUM);
  }
  Set<String> s = new LinkedHashSet<>(arrBizNo);
  arrBizNo.clear();
  arrBizNo.addAll(s);
  
  for (String sn : arrBizNo) {
    ArrayOfString mgtKeyList = new ArrayOfString();
    for (InvoiceVO v : arr) {
      if (sn.equals(v.INVOICER_CORP_NUM)) {
        mgtKeyList.getString().add(v.strSerialNum);
      }
    }
    if (mgtKeyList.getString().size()>0) {
      ArrayList<String[]> status = getStatus(barobillApiService, key, sn, mgtKeyList);
      if (status!=null && status.size()>0) {
        for (String[] st : status) {
          InvoiceDAO.BILL_UPDATE_STATUS_AND_AUTH_PROC(StrUtil.nvl(st[1]), Integer.parseInt(st[0]), StrUtil.nvl(st[2]));
          out.print("<li>" + st[0] + "::::" + st[1] + "::::" + st[2] + "</li>");
        }
      }
    }
  }
}


%>
</ul>
<h3>신규수신</h3>
<%
String strDate = StrUtil.nvl(request.getParameter("ymd"), DateTimeUtil.getCurrentDate(""));
int intCnt = InvoiceDAO.BAT_LOAD_BILL_PROC(strDate);
%>
<ul>
  <li><%=intCnt %></li>
</ul>