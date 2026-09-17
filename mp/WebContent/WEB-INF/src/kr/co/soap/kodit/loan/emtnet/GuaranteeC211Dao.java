package kr.co.soap.kodit.loan.emtnet;

import java.sql.Connection;
import java.sql.ResultSet;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

/**
 * C211 전용 DAO. SoapCommonDAO 와 동일한 커넥션/실행 패턴.
 *  - GET_GUARANTEE_INFO_PROC : 신청 헤더 조회
 *  - SAVE_C211_RESULT_PROC   : 송신 결과 적재(XML_C211 + STATUS + 상태갱신)
 */
public class GuaranteeC211Dao {

    /** GET_GUARANTEE_INFO_PROC 결과 */
    public static class GuaranteeInfo {
        public boolean found = false;
        public int    buyerCpyId;
        public int    sellerCpyId;
        public long   applAmt;
        public String applExpireText;
        public String grtType;
        public String status;
    }

    public GuaranteeInfo getGuaranteeInfo(String applNo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();

        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;

        GuaranteeInfo info = new GuaranteeInfo();
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_GUARANTEE_INFO_PROC ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(applNo), "", 20));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                info.found          = true;
                info.buyerCpyId     = rs.getInt("CPY_BUYER");
                info.sellerCpyId    = rs.getInt("CPY_SELLER");
                info.applAmt        = rs.getLong("MP_APPLAMT");
                info.applExpireText = rs.getString("APPL_EXPIREYMD");
                info.grtType        = rs.getString("GRTTYPE");
                info.status         = rs.getString("STATUS");
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "GET_GUARANTEE_INFO_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return info;
    }

    /**
     * 송신 결과 적재. 응답이 없는 통신오류면 res* 인자를 빈문자("")로 넘긴다(프로시저에서 NULL 처리).
     * @return RESULT (성공 1 / 오류 -1)
     */
    public int saveC211Result(
            String applNo, String creUser, String creTime,
            String sender, int transSeqNo, String receiver, String transDate, String transTime,
            String buyerId, String buyerBizNo, String sellerId, String sellerBizNo,
            String applAmt, String grtExpireText, String grtType,
            String resTransSeqNo, String resTransDate, String resTransTime,
            String resResponseCode, String resResponseMsg, String okYesNo) {

        Connection conn = ConnectionMgr.getInstance().getConnetion();

        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        int intResult = 0;
        try {
            String q = "";
            for (int a = 0; a < 21; a++) q += ", ?";
            q = q.substring(1);
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SAVE_C211_RESULT_PROC " + q + ";");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(applNo),         "",  20));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(creUser),        "",  16));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(creTime),        "",  14));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sender),         "",   7));
            ps.setInt   (++i, transSeqNo);
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(receiver),       "",   7));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(transDate),      "",   8));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(transTime),      "",   6));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(buyerId),        "",  13));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(buyerBizNo),     "",  10));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sellerId),       "",  13));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sellerBizNo),    "",  10));
            ps.setString(++i, StrUtil.nvl(applAmt, "0"));                 // 숫자: 패딩 없이 그대로
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(grtExpireText),  "",  50));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(grtType),        "",   2));
            ps.setString(++i, StrUtil.nvl(resTransSeqNo, ""));           // 숫자(or "")
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resTransDate),   "",   8));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resTransTime),   "",   6));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resResponseCode),"",   4));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resResponseMsg), "",  65));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(okYesNo),        "",   1));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                intResult = rs.getInt("RESULT");
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "SAVE_C211_RESULT_PROC");
            logger.error(e.toString());
            intResult = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return intResult;
    }
}
