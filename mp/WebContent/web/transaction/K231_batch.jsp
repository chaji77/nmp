<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.soap.controll.K232VO" %>
<%@ page import="kr.co.soap.sender.EmtNetSenderVO" %>
<%@ page import="kr.co.soap.sender.EmtNetService" %>
<%@ page import="kr.co.soap.kodit.loan.emtnet.K231Dao" %>
<%!
    private static final Object BATCH_LOCK = new Object();
%>
<%
response.setContentType("application/json; charset=UTF-8");
Logger logger = Logger.getLogger(this.getClass());

int limit = 100;
try { limit = Integer.parseInt(StrUtil.nvl(request.getParameter("limit"), "100")); } catch (Exception e) {}
if (limit < 1) limit = 1; if (limit > 200) limit = 200;

int total=0, success=0, fail=0;
synchronized (BATCH_LOCK) {
    try {
        K231Dao dao = new K231Dao();
        List<K231Dao.Pending> list = dao.getK231Pending(limit);
        total = list.size();
        for (K231Dao.Pending p : list) {
            String code = "9999";
            try {
                EmtNetSenderVO vo = new EmtNetSenderVO();
                vo.xmlGubn = "K231"; vo.orderNo = p.orderNO; vo.k231SeqNo = p.seqNO;
                K232VO r = (K232VO) EmtNetService.execute(vo);
                code = StrUtil.nvl(r.getCommonElement().getResponseCode(), "9999");
            } catch (Exception ex) { logger.error("K231 batch item 오류 orderNo=" + p.orderNO, ex); }
            if ("0000".equals(code)) success++; else fail++;
        }
    } catch (Exception e) {
        logger.error("K231 batch 오류", e);
        out.print("{\"result\":\"F\",\"message\":\"배치 처리 오류\"}"); return;
    }
}
out.print("{\"result\":\"S\",\"total\":" + total + ",\"success\":" + success + ",\"fail\":" + fail + "}");
%>
