<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.soap.controll.K232VO" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
if ("OPTIONS".equalsIgnoreCase(request.getMethod())) { response.setStatus(200); return; }
response.setContentType("application/json; charset=UTF-8");

String orderNo = StrUtil.nvl(request.getParameter("orderNo"), "");
String seqNo   = StrUtil.nvl(request.getParameter("seqNo"),   "001");

Logger logger = Logger.getLogger(this.getClass());
try {
    if (StrUtil.isEmpty(orderNo)) {
        out.print("{\"result\":\"F\",\"message\":\"주문번호(orderNo)가 없습니다.\"}");
        return;
    }
    EmtNetSenderVO vo = new EmtNetSenderVO();
    vo.xmlGubn   = "K231";
    vo.orderNo   = orderNo;
    vo.k231SeqNo = seqNo;

    Object resObj = EmtNetService.execute(vo);
    K232VO tranVo = (K232VO) resObj;
    String code = StrUtil.nvl(tranVo.getCommonElement().getResponseCode(), "9999");
    String msg  = StrUtil.nvl(tranVo.getCommonElement().getResponseMessage(), "");
    String clr  = StrUtil.nvl(tranVo.getClearSEQNO(), "");

    if ("0000".equals(code)) {
        out.print("{\"result\":\"S\",\"orderNo\":\"" + orderNo + "\",\"clearSeqNo\":\"" + clr + "\",\"message\":\"결제 접수 완료\"}");
    } else {
        String em = msg.replaceAll("\"", "'");
        out.print("{\"result\":\"F\",\"orderNo\":\"" + orderNo + "\",\"message\":\"[" + code + "] " + em + "\"}");
    }
} catch (Exception e) {
    out.print("{\"result\":\"F\",\"message\":\"신보와의 통신이 원활하지 않습니다.\"}");
    logger.error("K231 통신 오류", e);
}
%>
