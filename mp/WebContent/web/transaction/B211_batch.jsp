<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.soap.controll.B212VO" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.B211Dao" %>
<%!
    // 한 번에 도는 작업이 겹치지 않도록 간단한 동기화 (스케줄러 중복 호출 방지)
    private static final Object BATCH_LOCK = new Object();
%>
<%
response.setContentType("application/json; charset=UTF-8");
Logger logger = Logger.getLogger(this.getClass());

int limit = 100;
try { limit = Integer.parseInt(StrUtil.nvl(request.getParameter("limit"), "100")); } catch (Exception e) {}
if (limit < 1)   limit = 1;
if (limit > 200) limit = 200;

int total = 0, success = 0, fail = 0;
StringBuilder sb = new StringBuilder();

synchronized (BATCH_LOCK) {
    try {
        B211Dao dao = new B211Dao();
        List<B211Dao.Pending> list = dao.getB211Pending(limit);
        total = list.size();

        for (B211Dao.Pending p : list) {
            String code = "9999";
            try {
                EmtNetSenderVO vo = new EmtNetSenderVO();
                vo.xmlGubn   = "B211";
                vo.orderNo   = p.orderNO;
                vo.b211SeqNo = p.seqNO;
                Object resObj = EmtNetService.execute(vo);
                B212VO tranVo = (B212VO) resObj;
                code = StrUtil.nvl(tranVo.getCommonElement().getResponseCode(), "9999");
            } catch (Exception ex) {
                logger.error("B211 batch item 오류 orderNo=" + p.orderNO, ex);
            }
            if ("0000".equals(code)) success++; else fail++;
        }
    } catch (Exception e) {
        logger.error("B211 batch 오류", e);
        out.print("{\"result\":\"F\",\"message\":\"배치 처리 오류\"}");
        return;
    }
}

out.print("{\"result\":\"S\",\"total\":" + total + ",\"success\":" + success + ",\"fail\":" + fail + "}");
System.out.println("=== B211 batch 완료 total=" + total + " success=" + success + " fail=" + fail);
%>
