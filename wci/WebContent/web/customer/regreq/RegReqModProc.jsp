<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.regreq.RegReqVO" %>
<%@ page import="kr.co.mp.c.regreq.RegReqBean" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));

String strSeqEnc = StrUtil.nvl(request.getParameter("seq"));
if (!IntegerCryptoUtil.isEncrypted(strSeqEnc)) {
  out.println(0);
  return;
}
int intSeq = Integer.parseInt(IntegerCryptoUtil.crypt(strSeqEnc));

RegReqBean bean = new RegReqBean();

// 본인 소유 요청인지 확인 (SEQ 단건조회 프로시저가 없어 자기 목록에서 검색해서 대조)
RegReqVO svo = new RegReqVO();
svo.PAGE       = 1;
svo.ROW_CNT    = 100000;
svo.BUY_CPY_ID = intCpyId;
ArrayList<RegReqVO> arr = bean.COMPANY_REG_REQ_LIST_PROC(svo);
RegReqVO owned = null;
if (arr != null) {
  for (RegReqVO v : arr) {
    if (v.SEQ == intSeq) { owned = v; break; }
  }
}
if (owned == null) {
  out.println(0);
  return;
}

if ("drop".equals(request.getParameter("mode"))) {
  out.println(bean.COMPANY_REG_REQ_DROP_PROC(intSeq));
  return;
}

RegReqVO vo = new RegReqVO();
vo.SEQ                  = intSeq;
vo.SELL_CPY_NAME        = StrUtil.nvl(request.getParameter("sellCpyName"));
vo.SELL_PHONE           = StrUtil.nvl(request.getParameter("sellPhone"));
vo.SELL_PRS_NAME        = StrUtil.nvl(request.getParameter("sellPrsName"));
vo.SELL_FAX             = StrUtil.nvl(request.getParameter("sellFax"));
vo.SELL_EMAIL           = StrUtil.nvl(request.getParameter("sellEmail"));
vo.SELL_CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("sellCpyBusinessNo")).replaceAll("-", "");
vo.TRADE_DATE           = StrUtil.nvl(request.getParameter("tradeDate"));
String strFeePay        = StrUtil.nvl(request.getParameter("feePay"));
vo.FEE_PAY              = (!strFeePay.isEmpty() && StrUtil.isOnlyNumeric(strFeePay)) ? Integer.parseInt(strFeePay) : 0;
vo.MEMO                 = StrUtil.nvl(request.getParameter("memo"));
vo.REQ_STATUS           = owned.REQ_STATUS; // 상태는 관리자 전용 항목이라 고객 수정시 그대로 보존

out.println(bean.COMPANY_REG_REQ_MOD_PROC(vo));
%>