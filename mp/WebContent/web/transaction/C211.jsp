<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.soap.controll.C212VO" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%
request.setCharacterEncoding("utf-8");
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

// CORS preflight(OPTIONS)는 본처리 없이 200으로 통과
if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
    response.setStatus(200);
    return;
}

response.setContentType("application/json; charset=UTF-8");

String applNo  = StrUtil.nvl(request.getParameter("applNo"),  "");
String creUser = StrUtil.nvl(request.getParameter("creUser"), "");  // 작업자 ID (팝업에서 전달)

System.out.println("=== C211 요청 === applNo=" + applNo + " creUser=" + creUser);

Logger logger = Logger.getLogger(this.getClass());
try {
    if (StrUtil.isEmpty(applNo)) {
        out.print("{\"result\":\"F\",\"message\":\"신청번호(applNo)가 없습니다.\"}");
        return;
    }

    EmtNetSenderVO vo = new EmtNetSenderVO();
    vo.xmlGubn = "C211";
    vo.applNo  = applNo;
    vo.creUser = creUser;

    // 송신 + 결과 적재(XML_C211 / INFO_GUARANTEE_STATUS / 상태갱신)는 내부에서 처리됨
    Object resObj = EmtNetService.execute(vo);
    C212VO tranVo = (C212VO) resObj;

    String code = StrUtil.nvl(tranVo.getCommonElement().getResponseCode(), "9999");
    String msg  = StrUtil.nvl(tranVo.getCommonElement().getResponseMessage(), "");

    System.out.println("=== C211 응답 === code=" + code + " msg=" + msg);

    if ("0000".equals(code)) {
        out.print("{\"result\":\"S\",\"applNo\":\"" + applNo + "\",\"message\":\"신보 접수가 완료되었습니다.\"}");
        logger.debug("C211 성공 applNo=" + applNo);
    } else {
        String em = msg.replaceAll("\"", "'");
        out.print("{\"result\":\"F\",\"applNo\":\"" + applNo + "\",\"message\":\"[" + code + "] " + em + "\"}");
        logger.debug("C211 실패 applNo=" + applNo + " code=" + code);
    }
} catch (Exception e) {
    out.print("{\"result\":\"F\",\"message\":\"신보와의 통신이 원활하지 않습니다.\"}");
    logger.error("C211 통신 오류", e);
}
%>
