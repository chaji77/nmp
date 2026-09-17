<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.mp.c.LoginVO" %>
<%@ page import="kr.co.mp.c.LoginBean" %>
<%@ page import="kr.co.mp.trade.TradeStatusVO"%>
<%@ page import="kr.co.mp.trade.TradeStatusBean"%>
<%
/*
1.로그인정보의 관리
  로그인한 사용자의 정보는 암호화된 JSON파일의 쿠키로 관리한다.
  로그인하지 않은 경우, pageContext.getAttribute("CPY_ID")를 복호화한 값은 "0"이다.
  쿠키는 복사하여 다른 PC에서 사용할 수 있다. 이를 방지하기 위해 쿠키에 저장된 사용자의 IP와 현재의 IP를 비교한다.
  VO의 VALID_IP_YN가 "N"인 경우, 사용자의 아이피가 변경된 것이다.
2.로그인이 필요한 페이지인 경우
  이 페이지를 불러오기 전에 pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);를 선언한다.
3.로그인이 필요없는 페이지의 경우
  이 페이지를 불러오기 전에 pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);를 선언하거나 생략한다.
*/
LoginVO lvo_for_login_check = LoginBean.getToken(request);
try {
  boolean isNeedLogin = false; // 로그인정보가 필요한 페이지인가? 
  if (pageContext.getAttribute("SESS_NEED_LOGIN_PAGE")!=null) isNeedLogin = (boolean) pageContext.getAttribute("SESS_NEED_LOGIN_PAGE");
  if (isNeedLogin) {
    if (lvo_for_login_check==null || lvo_for_login_check.CPY_ID.equals("0")) {
      boolean login_check_hasParams = false;
      Enumeration<String> login_check_enumeration = request.getParameterNames();
      while (login_check_enumeration.hasMoreElements()) {
        login_check_hasParams =true;
      }
      if (!login_check_hasParams) {
        String strLoginCheckRef = request.getRequestURI() + ((request.getQueryString()!=null)?"?"+request.getQueryString():"");
        session.setAttribute("LOGIN_AFTER", strLoginCheckRef);
        // System.out.println("LOGIN_AFTER : " + strLoginCheckRef);
      }
      out.println("<script>");
      out.println("if(opener==null || typeof(opener)==='undefined') {top.location.href = '"+ request.getContextPath() + "/web/Login.jsp';}");
      out.println("else {opener.location.href = '"+ request.getContextPath() + "/web/Login.jsp';self.close();}");
      out.println("</script>");
      if (true) return;
    }
  }
} catch(Exception e) {}

/* logined user information */
if (lvo_for_login_check==null) lvo_for_login_check = new LoginVO();
pageContext.setAttribute("VALID_IP_YN",       StrUtil.nvl(lvo_for_login_check.VALID_IP_YN));
pageContext.setAttribute("CPY_GUBUN",         StrUtil.nvl(lvo_for_login_check.CPY_GUBUN));
pageContext.setAttribute("CPY_ID",            StrUtil.nvl(lvo_for_login_check.CPY_ID));
pageContext.setAttribute("CPY_BIZ_NO",        StrUtil.nvl(lvo_for_login_check.CPY_BIZ_NO));
pageContext.setAttribute("CPY_NM",            StrUtil.nvl(lvo_for_login_check.CPY_NM));
pageContext.setAttribute("PRS_ID",            StrUtil.nvl(lvo_for_login_check.PRS_ID));
pageContext.setAttribute("USER_LOGIN",        StrUtil.nvl(lvo_for_login_check.USER_LOGIN));
pageContext.setAttribute("CU_USE_YN",         StrUtil.nvl(lvo_for_login_check.CU_USE_YN));
pageContext.setAttribute("CONFIRM_SETTLE_YN", StrUtil.nvl(lvo_for_login_check.CONFIRM_SETTLE_YN));
pageContext.setAttribute("REVERSE_YN",        StrUtil.nvl(lvo_for_login_check.REVERSE_YN));
pageContext.setAttribute("MOBILE_YN",         StrUtil.nvl(lvo_for_login_check.MOBILE_YN));
pageContext.setAttribute("SIGN_EXCLUDE_YN",   StrUtil.nvl(lvo_for_login_check.SIGN_EXCLUDE_YN));
pageContext.setAttribute("CRG_ID",            StrUtil.nvl(lvo_for_login_check.CRG_ID));
pageContext.setAttribute("PAPER_BILL_YN",     StrUtil.nvl(lvo_for_login_check.PAPER_BILL_YN));

/* trade statuses */
int intTradeStatusBuyerSent      = 0;
int intTradeStatusBuyerReceived  = 0;
int intTradeStatusSellerSent     = 0;
int intTradeStatusSellerReceived = 0;
int intTradeStatusSettleStandby  = 0;
int intTradeStatusYetMaturity    = 0;
if (lvo_for_login_check!=null && !StrUtil.nvl(lvo_for_login_check.CPY_ID).equals("") && !StrUtil.nvl(lvo_for_login_check.CPY_ID).equals("0") && StrUtil.isOnlyNumeric(lvo_for_login_check.CPY_ID)) {
  ArrayList<TradeStatusVO> arrTradeStatuses = TradeStatusBean.CT_HEADER_STATUS_PER_CPY_ID_PROC(Integer.parseInt(lvo_for_login_check.CPY_ID));
  if (arrTradeStatuses!=null && arrTradeStatuses.size()>0) {
    for (TradeStatusVO tsv : arrTradeStatuses) {
      if (tsv.WAIT_TYPE.equals("BUYER_SENT"))      intTradeStatusBuyerSent      = tsv.WAIT_COUNT;
      if (tsv.WAIT_TYPE.equals("BUYER_RECEIVED"))  intTradeStatusBuyerReceived  = tsv.WAIT_COUNT;
      if (tsv.WAIT_TYPE.equals("SELLER_SENT"))     intTradeStatusSellerSent     = tsv.WAIT_COUNT;
      if (tsv.WAIT_TYPE.equals("SELLER_RECEIVED")) intTradeStatusSellerReceived = tsv.WAIT_COUNT;
      if (tsv.WAIT_TYPE.equals("SETTLE_STANDBY"))  intTradeStatusSettleStandby  = tsv.WAIT_COUNT;
      if (tsv.WAIT_TYPE.equals("YET_MATURITY"))    intTradeStatusYetMaturity    = tsv.WAIT_COUNT;
    }
  }
}

pageContext.setAttribute("BUYER_SENT",        intTradeStatusBuyerSent);
pageContext.setAttribute("BUYER_RECEIVED",    intTradeStatusBuyerReceived);
pageContext.setAttribute("SELLER_SENT",       intTradeStatusSellerSent);
pageContext.setAttribute("SELLER_RECEIVED",   intTradeStatusSellerReceived);
pageContext.setAttribute("SENT_CONTRACT",     intTradeStatusBuyerSent + intTradeStatusSellerSent); // 보낸계약건수
pageContext.setAttribute("RECEIVED_CONTRACT", intTradeStatusBuyerReceived + intTradeStatusSellerReceived); // 받은계약건수
pageContext.setAttribute("SETTLE_STANDBY",    intTradeStatusSettleStandby); // 결제대기건수
pageContext.setAttribute("YET_MATURITY",      intTradeStatusYetMaturity); // 만기미도래건수
%>