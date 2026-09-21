package kr.co.soap.kodit.guarantee;

import java.sql.Connection;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

/**
 * 담보보증 DAO
 * 기존 SoapCommonDAO 와 동일한 패턴으로 작성
 */
public class GuaranteeDAO {

    private Logger logger = Logger.getLogger(this.getClass());

    // ─────────────────────────────────────────
    // SeqNO 채번
    // ─────────────────────────────────────────
    protected String getNextSeqNo(String tableName, String keyColumn, String keyValue) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        String seqNo = "001";
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.GET_KODIT_GUARANTEE_SEQNO ?, ?, ?;");
            int i = 0;
            ps.setString(++i, tableName);
            ps.setString(++i, keyColumn);
            ps.setString(++i, keyValue);
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                seqNo = rs.getString("SEQNO");
            }
        } catch (Exception e) {
            logger.error("getNextSeqNo error: " + e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return seqNo;
    }

    // ─────────────────────────────────────────
    // GuaranteeNO 로 ApplicationNO 조회
    // F221 에서 ApplicationNO 없을 때 사용
    // ─────────────────────────────────────────
    protected String findApplNoByGrtNo(String grtNo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        String applNo = "";
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "SELECT TOP 1 APPLNO FROM DBO.INFO_GUARANTEE " +
                "WHERE GRTNO = ? ORDER BY APPLNO DESC;");
            ps.setString(1, StrUtil.getParameter(grtNo, "", 12));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                String v = rs.getString("APPLNO");
                if (v != null) applNo = v.trim();
            }
            logger.info("findApplNoByGrtNo: " + grtNo + " -> " + applNo);
        } catch (Exception e) {
            logger.error("findApplNoByGrtNo error: " + e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return applNo;
    }

    // ─────────────────────────────────────────
    // C221 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlC221(GuaranteeVO.C221VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_C221_ADD_PROC " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.ApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.SellerID, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.SellerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.RegistrationDate, "", 8));
            ps.setBigDecimal(++i, vo.ApplicationAMT);
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpirationText, "", 40));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlC221 error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // D211 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlD211(GuaranteeVO.D211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_D211_ADD_PROC " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.ApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.ApprovalDate, "", 8));
            ps.setBigDecimal(++i, vo.ApprovalAMT);
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlD211 error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // E211 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlE211(GuaranteeVO.E211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_E211_ADD_PROC " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.ApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeCode, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.IssueDate, "", 8));
            ps.setBigDecimal(++i, vo.GuaranteeAMT);
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpirationDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.Creditor, "", 40));
            ps.setInt(   ++i, vo.ConditionCount);
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlE211 error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // E211_CONDITION INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlE211Condition(String applNo, String seqNo,
            int condSeqNo, String condition) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_E211_CONDITION_ADD_PROC ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(seqNo, "", 3));
            ps.setInt(   ++i, condSeqNo);
            ps.setString(++i, StrUtil.getParameter(condition, "", 62));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlE211Condition error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // INFO_GUARANTEE_CONDITION 조건행 생성 (F221 조건변경 수신 시)
    //  - SEQNO 채번 / 기간시작(직전만기+1) / 금액승계 / 중복방지는 프로시저가 처리
    //  - 반환: 1=등록, 0=이미존재(생략), -1=오류
    // ─────────────────────────────────────────
    protected int addGuaranteeCondition(String applNo, String endYmd, String amt) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = -1;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.INS_GUARANTEE_CONDITION_PROC ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(endYmd, "", 8));
            ps.setString(++i, StrUtil.getParameter(amt,    "", 20));
            ps.setString(++i, "F221");
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("addGuaranteeCondition error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // F221 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlF221(GuaranteeVO.F221VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_F221_ADD_PROC " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.ApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.CustomerNO, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CGuaranteeNO, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.BankText, "", 50));
            ps.setString(++i, StrUtil.getParameter(vo.CompanyNameText, "", 60));
            ps.setString(++i, StrUtil.getParameter(vo.CEONameText, "", 60));
            ps.setString(++i, StrUtil.getParameter(vo.Address, "", 500));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpirationDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeAMTText, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.CissueDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.ChiefName, "", 30));
            ps.setString(++i, StrUtil.getParameter(vo.KCGFBranch, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.TELNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.TeamCode, "", 1));
            ps.setString(++i, StrUtil.getParameter(vo.TeamMember, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.BranchAddress, "", 500));
            ps.setString(++i, StrUtil.getParameter(vo.IssueInformation, "", 250));
            ps.setInt(   ++i, vo.CCount);
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlF221 error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // F221_CONDITION INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlF221Condition(String applNo, String seqNo,
            int condSeqNo, String cArticle, String before, String after) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_F221_CONDITION_ADD_PROC ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(seqNo, "", 3));
            ps.setInt(   ++i, condSeqNo);
            ps.setString(++i, StrUtil.getParameter(cArticle, "", 20));
            ps.setString(++i, StrUtil.getParameter(before, "", 100));
            ps.setString(++i, StrUtil.getParameter(after, "", 100));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlF221Condition error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // H211 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlH211(GuaranteeVO.H211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_XML_H211_ADD_PROC " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.ApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BuyerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.SellerID, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.SellerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.LoanDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.LoanExpirationDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setBigDecimal(++i, vo.GuaranteeAMT);
            ps.setBigDecimal(++i, vo.ClearAMT);
            ps.setString(++i, StrUtil.getParameter(vo.ClearCode, "", 2));
            ps.setBigDecimal(++i, vo.GuaranteeBalance);
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("receiveXmlH211 error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // INFO_GUARANTEE UPDATE
    // ─────────────────────────────────────────
    protected int updateInfoGuarantee(String applNo, String transNo,
            String status, String grtNo, java.math.BigDecimal kcgfAmt,
            String issueYmd, String chgExpireYmd, String clearYmd) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            String ymdhms = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.UPDATE_INFO_GUARANTEE_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(transNo, "", 4));
            ps.setString(++i, StrUtil.getParameter(status, "", 3));
            ps.setString(++i, StrUtil.getParameter(grtNo, "", 12));
            ps.setBigDecimal(++i, kcgfAmt != null ? kcgfAmt : java.math.BigDecimal.ZERO);
            ps.setString(++i, StrUtil.getParameter(issueYmd, "", 8));
            ps.setString(++i, StrUtil.getParameter(chgExpireYmd, "", 8));
            ps.setString(++i, StrUtil.getParameter(clearYmd, "", 8));
            ps.setString(++i, ymdhms);
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("updateInfoGuarantee error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // INFO_GUARANTEE_STATUS INSERT
    // ─────────────────────────────────────────
    protected int addInfoGuaranteeStatus(String applNo, String transNo,
            java.math.BigDecimal amt, String description) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            String ymdhms = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.RECEIVE_INFO_GUARANTEE_STATUS_ADD_PROC ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(transNo, "", 4));
            ps.setBigDecimal(++i, amt != null ? amt : java.math.BigDecimal.ZERO);
            ps.setString(++i, StrUtil.getParameter(description, "", 100));
            ps.setString(++i, ymdhms);
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error("addInfoGuaranteeStatus error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // 유틸 메서드
    // ─────────────────────────────────────────
    private int parseInt(String val) {
        try { return Integer.parseInt(val.trim()); }
        catch (Exception e) { return 0; }
    }
}
