<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.soap.controll.A211VO" %>
<%@ page import="kr.co.soap.controll.A212VO" %>
<%@ page import="kr.co.soap.controll.A411VO" %>
<%@ page import="kr.co.soap.kodit.loan.Kodit_A211" %>
<%@ page import="kr.co.soap.kodit.loan.Kodit_A411" %>
<%@ page import="kr.co.soap.controll.CommonElement" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.trade.TradeEntitiesVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger(this.getClass());

int intSellerCpyId      = 0;
String strCtId          = StrUtil.nvl(request.getParameter("ctid"));
String strSellerClearYn = StrUtil.nvl(request.getParameter("strSellerClearYn"));
int intResult           = 0;
A211VO a211vo           = new A211VO();

if (!strCtId.equals("")) {
  int intCtId = Integer.parseInt(strCtId);
  TradeEntitiesVO vo = new TradeBean().CT_HEADER_ENTITIES_PROC(Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"))));
  intSellerCpyId = vo.SELLER_CPY_ID;
  if (StrUtil.nvl(vo.BUYER_ID).length()!=13) vo.BUYER_ID = "0000000000000";
  if (StrUtil.nvl(vo.SELLER_ID).length()!=13) vo.SELLER_ID = "0000000000000";
  a211vo.setBuyerID(StrUtil.nvl(vo.BUYER_ID));
  a211vo.setBuyerBusinessNO(StrUtil.nvl(vo.BUYER_BIZ_NO));
  a211vo.setSellerID(StrUtil.nvl(vo.SELLER_ID));
  a211vo.setSellerBusinessNO(StrUtil.nvl(vo.SELLER_BIZ_NO));
} else {
  intSellerCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("seller_cpy_id")));
  String strBuyerId  = StrUtil.nvl(request.getParameter("strBuyerId"));
  String strSellerId = StrUtil.nvl(request.getParameter("strSellerId"));
  if (strBuyerId.length()!=13) strBuyerId = "0000000000000";
  if (strSellerId.length()!=13) strSellerId = "0000000000000";
  a211vo.setBuyerID(strBuyerId);
  a211vo.setBuyerBusinessNO(StrUtil.nvl(request.getParameter("strBuyerBizNo")));
  a211vo.setSellerID(strSellerId);
  a211vo.setSellerBusinessNO(StrUtil.nvl(request.getParameter("strSellerBizNo")));
}

A411VO requestVO = new A411VO();
requestVO.setSellerID(StrUtil.nvl(a211vo.getSellerID()));
requestVO.setSellerBusinessNO(StrUtil.nvl(a211vo.getSellerBusinessNO()));
requestVO.setSellerShutoffYN("Y");
requestVO.setSellerClearYN(strSellerClearYn);

Kodit_A211 a211 = new Kodit_A211();
A212VO a212VO = a211.executeA211(a211vo);

logger.debug("A211 RESULT ABOUT " + intSellerCpyId);
logger.debug("외감기업여부         : " + a212VO.getExternalAuditYN());
logger.debug("판매기업보증이용여부 : " + a212VO.getSellerGuaranteeUseYN());
logger.debug("판매기업KED정보보유  : " + a212VO.getSellerKEDinfoYN());
logger.debug("판매기업사전차단여부 : " + a212VO.getSellerShutoffYN());
logger.debug("판매기업차단해제여부 : " + a212VO.getSellerClearYN());

String strYn = "N";
if (StrUtil.nvl(a212VO.getExternalAuditYN(), "N").equals("Y")) strYn = "Y";
if (StrUtil.nvl(a212VO.getSellerGuaranteeUseYN(), "N").equals("Y")) strYn = "Y";
if (StrUtil.nvl(a212VO.getSellerKEDinfoYN(), "N").equals("Y")) strYn = "Y";
if (StrUtil.nvl(a212VO.getSellerClearYN(), "N").equals("Y")) strYn = "Y";

if (strYn.equals("N")) { // 사전차단이 되어 있지 않다면 A411전문전송
  Kodit_A411 a411 = new Kodit_A411();
  CommonElement commonElement = a411.executeA411(requestVO);
  if (commonElement.getResponseCode().equals("0000")) {
    strYn = "Y";
    new CustomerBean().COMPANY_MOD_SELLER_CLEAR_YN_PROC(intSellerCpyId, "Y");
  } else strYn = "N";
}
out.print(strYn);
%>
