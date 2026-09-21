package kr.co.soap.kibo.guarantee;

import java.sql.Connection;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

/**
 * 기보(KIBO) 담보보증 DAO
 * 신보 GuaranteeDAO 와 동일한 패턴
 * 대상 테이블: KIBO_GUARANTEE, KIBO_GUARANTEE_STATUS, KIBO_XML_* 시리즈
 */
public class KiboGuaranteeDAO {

    private Logger logger = Logger.getLogger(this.getClass());

    // ─────────────────────────────────────────
    // SeqNO 채번
    // 신보와 동일한 프로시저 사용 (테이블명만 KIBO_ prefix)
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
    // GuaranteeNO 로 EApplicationNO 조회
    // F211에서 EApplicationNO 없을 때 사용
    // ─────────────────────────────────────────
    protected String findApplNoByGrtNo(String grtNo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        String applNo = "";
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "SELECT TOP 1 APPLNO FROM DBO.KIBO_GUARANTEE " +
                "WHERE GRTNO = ? ORDER BY APPLNO DESC;");
            ps.setString(1, StrUtil.getParameter(grtNo, "", 12));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                String v = rs.getString("APPLNO");
                if (v != null) applNo = v.trim();
            }
            logger.info("findApplNoByGrtNo(KIBO): " + grtNo + " -> " + applNo);
        } catch (Exception e) {
            logger.error("findApplNoByGrtNo error: " + e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return applNo;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_C221 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlC221(KiboGuaranteeVO.C221VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_C221 (" +
                "  EApplicationNO, SeqNO, TransactionSEQNO, TransactionNO," +
                "  Sender, Receiver, TransactionDate, TransactionTime," +
                "  TransactionID, CodeType, TransactionLength," +
                "  ResponseCode, ResponseMessage, UserField," +
                "  ResSender, ResReceiver, ResTransactionSEQNO, ResTransactionNO," +
                "  ResTransactionDate, ResTransactionTime, ResTransactionID," +
                "  GuaranteeNO, ResCodeType, ResTransactionLength," +
                "  ResResponseCode, ResResponseMessage," +
                "  CancelDate, CancelReason, ResUserField," +
                "  ID, BusinessNO, CustomerNO, RegisterationDate," +
                "  GuaranteeCode, CurrencyCode, ApplicationAMT, GuaranteeRate," +
                "  GuaranteeExpirationText, GuaranteeType, LoanPurpose, GuaranteeWay," +
                "  FavoriteDate, ApplicantName, ApplicantTelno, ApplicantEmail," +
                "  SellerID, SellerBusinessNO, REG_DATE" +
                ") VALUES (" +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,GETDATE()" +
                ");");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.EApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionID, "", 9));
            ps.setString(++i, StrUtil.getParameter(vo.CodeType, "", 1));
            ps.setInt(   ++i, parseInt(vo.TransactionLength));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, "");  // ResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, "");  // ResSender
            ps.setString(++i, "");  // ResReceiver
            ps.setInt(   ++i, 0);   // ResTransactionSEQNO
            ps.setString(++i, "");  // ResTransactionNO
            ps.setString(++i, "");  // ResTransactionDate
            ps.setString(++i, "");  // ResTransactionTime
            ps.setString(++i, "");  // ResTransactionID
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, "");  // ResCodeType
            ps.setInt(   ++i, 0);   // ResTransactionLength
            ps.setString(++i, "");  // ResResponseCode
            ps.setString(++i, "");  // ResResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            ps.setString(++i, "");  // ResUserField
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.CustomerNO, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.RegistrationDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeCode, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.CurrencyCode, "", 3));
            ps.setBigDecimal(++i, vo.ApplicationAMT);
            ps.setBigDecimal(++i, vo.GuaranteeRate);
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpirationText, "", 40));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.LoanPurpose, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeWay, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.FavoriteDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.ApplicantName, "", 16));
            ps.setString(++i, StrUtil.getParameter(vo.ApplicantTelno, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.ApplicantEmail, "", 30));
            ps.setString(++i, StrUtil.getParameter(vo.SellerID, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.SellerBusinessNO, "", 10));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlC221(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_D211 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlD211(KiboGuaranteeVO.D211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_D211 (" +
                "  EApplicationNO, SeqNO, TransactionSEQNO, ApprovalDate," +
                "  TransactionNO, Sender, ApprovalAMT, Receiver," +
                "  TransactionDate, UserField, TransactionTime," +
                "  ID, TransactionID, BusinessNO, CodeType, TransactionLength," +
                "  ResponseCode, ResponseMessage, CancelReason," +
                "  ResSender, ResReceiver, GuaranteeNO," +
                "  ResTransactionSEQNO, ResTransactionNO, CancelDate," +
                "  ResTransactionDate, ResTransactionTime, ResTransactionID," +
                "  ResCodeType, ResTransactionLength, ResResponseCode, ResResponseMessage, ResUserField," +
                "  CustomerNO, CurrencyCode, REG_DATE" +
                ") VALUES (" +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,GETDATE()" +
                ");");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.EApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.ApprovalDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setBigDecimal(++i, vo.ApprovalAMT);
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionID, "", 9));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.CodeType, "", 1));
            ps.setInt(   ++i, parseInt(vo.TransactionLength));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, "");  // ResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            ps.setString(++i, "");  // ResSender
            ps.setString(++i, "");  // ResReceiver
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setInt(   ++i, 0);   // ResTransactionSEQNO
            ps.setString(++i, "");  // ResTransactionNO
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, "");  // ResTransactionDate
            ps.setString(++i, "");  // ResTransactionTime
            ps.setString(++i, "");  // ResTransactionID
            ps.setString(++i, "");  // ResCodeType
            ps.setInt(   ++i, 0);   // ResTransactionLength
            ps.setString(++i, "");  // ResResponseCode
            ps.setString(++i, "");  // ResResponseMessage
            ps.setString(++i, "");  // ResUserField
            ps.setString(++i, StrUtil.getParameter(vo.CustomerNO, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CurrencyCode, "", 3));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlD211(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_E211 INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlE211(KiboGuaranteeVO.E211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_E211 (" +
                "  EApplicationNO, SeqNO, TransactionID, CodeType, TransactionLength," +
                "  Sender, TransactionSEQNO, Receiver, TransactionNO," +
                "  TransactionDate, TransactionTime, ResponseCode, ResponseMessage, UserField," +
                "  ResTransactionID, ResCodeType, ResTransactionLength," +
                "  ResSender, ResTransactionSEQNO, ResReceiver, ResTransactionNO," +
                "  ResTransactionDate, ResTransactionTime, ResResponseCode, ResResponseMessage, ResUserField," +
                "  GuaranteeKind, ID, BusinessNO, CustomerNO, GuaranteeNO," +
                "  IssueDate, GuaranteeAMTText, GUARANTEEAMTEXT," +
                "  GuaranteeExpirationDate, GuaranteeType, Creditor," +
                "  ConditionCount, GuaranteeMaxAMTText, REG_DATE" +
                ") VALUES (" +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,GETDATE()" +
                ");");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.EApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionID, "", 9));
            ps.setString(++i, StrUtil.getParameter(vo.CodeType, "", 1));
            ps.setInt(   ++i, parseInt(vo.TransactionLength));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, "");  // ResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, "");  // ResTransactionID
            ps.setString(++i, "");  // ResCodeType
            ps.setInt(   ++i, 0);   // ResTransactionLength
            ps.setString(++i, "");  // ResSender
            ps.setInt(   ++i, 0);   // ResTransactionSEQNO
            ps.setString(++i, "");  // ResReceiver
            ps.setString(++i, "");  // ResTransactionNO
            ps.setString(++i, "");  // ResTransactionDate
            ps.setString(++i, "");  // ResTransactionTime
            ps.setString(++i, "");  // ResResponseCode
            ps.setString(++i, "");  // ResResponseMessage
            ps.setString(++i, "");  // ResUserField
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeKind, "", 50));
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.CustomerNO, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.IssueDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeAMTText, "", 50));
            ps.setBigDecimal(++i, vo.GuaranteeAMT);
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpirationDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setString(++i, StrUtil.getParameter(vo.Creditor, "", 40));
            ps.setInt(   ++i, vo.ConditionCount);
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeMaxAMTText, "", 20));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlE211(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_E211_CONDITION INSERT
    // ─────────────────────────────────────────
    protected int receiveXmlE211Condition(String applNo, String seqNo,
            int condSeqNo, String condition) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_E211_CONDITION " +
                "(EApplicationNO, SeqNO, ConditionSEQNO, Condition) " +
                "VALUES (?, ?, ?, ?);");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(seqNo, "", 3));
            ps.setInt(   ++i, condSeqNo);
            ps.setString(++i, StrUtil.getParameter(condition, "", 62));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlE211Condition(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_F211 INSERT
    // 신보와 달리 PK = CApplicationNO + SeqNO
    // ─────────────────────────────────────────
    protected int receiveXmlF211(KiboGuaranteeVO.F211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_F211 (" +
                "  CApplicationNO, SeqNO, TransactionID, CodeType, TransactionLength," +
                "  Sender, TransactionSEQNO, Receiver, TransactionNO," +
                "  TransactionDate, TransactionTime, ResponseCode, ResponseMessage, UserField," +
                "  ResTransactionID, ResTransactionLength, ResCodeType," +
                "  ResSender, ResTransactionSEQNO, ResReceiver, ResTransactionNO," +
                "  ResTransactionDate, ResTransactionTime, ResResponseCode, ResResponseMessage, ResUserField," +
                "  ID, BusinessNO, CustomerNO, EApplicationNO, CGuaranteeNO, GuaranteeNO," +
                "  ChiefName, FundBranchName, TELNO, TeamCode, TeamMember," +
                "  BranchAddress, GuaranteeCaution1, GuaranteeCaution2, Ccount, REG_DATE" +
                ") VALUES (" +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?,?,GETDATE()" +
                ");");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.CApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionID, "", 9));
            ps.setString(++i, StrUtil.getParameter(vo.CodeType, "", 1));
            ps.setInt(   ++i, parseInt(vo.TransactionLength));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, "");  // ResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, "");  // ResTransactionID
            ps.setInt(   ++i, 0);   // ResTransactionLength
            ps.setString(++i, "");  // ResCodeType
            ps.setString(++i, "");  // ResSender
            ps.setInt(   ++i, 0);   // ResTransactionSEQNO
            ps.setString(++i, "");  // ResReceiver
            ps.setString(++i, "");  // ResTransactionNO
            ps.setString(++i, "");  // ResTransactionDate
            ps.setString(++i, "");  // ResTransactionTime
            ps.setString(++i, "");  // ResResponseCode
            ps.setString(++i, "");  // ResResponseMessage
            ps.setString(++i, "");  // ResUserField
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.CustomerNO, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.EApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.CGuaranteeNO, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.ChiefName, "", 30));
            ps.setString(++i, StrUtil.getParameter(vo.FundBranchName, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.TELNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.TeamCode, "", 1));
            ps.setString(++i, StrUtil.getParameter(vo.TeamMember, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.BranchAddress, "", 250));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeCaution1, "", 50));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeCaution2, "", 200));
            ps.setInt(   ++i, vo.Ccount);
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlF211(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_F211_CONDITION INSERT
    // 신보와 달리 PK = CApplicationNO + SEQNO + ConditionSEQNO
    // ChgYN 필드 추가
    // ─────────────────────────────────────────
    protected int receiveXmlF211Condition(String cApplNo, String seqNo,
            int condSeqNo, String cArticle, String before, String after, String chgYN) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_F211_CONDITION " +
                "(CApplicationNO, SEQNO, ConditionSEQNO, CArticle, Before, After, ChgYN) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?);");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(cApplNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(seqNo, "", 3));
            ps.setInt(   ++i, condSeqNo);
            ps.setString(++i, StrUtil.getParameter(cArticle, "", 20));
            ps.setString(++i, StrUtil.getParameter(before, "", 42));
            ps.setString(++i, StrUtil.getParameter(after, "", 42));
            ps.setString(++i, StrUtil.getParameter(chgYN, "", 10));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlF211Condition(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_XML_H211 INSERT
    // 신보와 달리: GuaranteeExpiration(만기일), JobDate(처리일), ClearCode 없음
    // ─────────────────────────────────────────
    protected int receiveXmlH211(KiboGuaranteeVO.H211VO vo) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_XML_H211 (" +
                "  EApplicationNO, SeqNO, TransactionID, CodeType, TransactionLength," +
                "  Sender, TransactionSEQNO, Receiver, TransactionNO," +
                "  TransactionDate, TransactionTime, ResponseCode, ResponseMessage, UserField," +
                "  ResTransactionID, ResCodeType, ResTransactionLength," +
                "  ResSender, ResTransactionSEQNO, ResReceiver, ResTransactionNO," +
                "  ResTransactionDate, ResTransactionTime, ResResponseCode, ResResponseMessage, ResUserField," +
                "  ID, BusinessNO, SellerID, SellerBusinessNO, GuaranteeNO," +
                "  LoanDate, GuaranteeExpiration, GuaranteeType," +
                "  GuaranteeAMT, JobDate, ClearAMT, GuaranteeBalance," +
                "  CancelDate, CancelReason, REG_DATE" +
                ") VALUES (" +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?," +
                "  ?,?,?,?,?,?,?,?,?,?,?,GETDATE()" +
                ");");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(vo.EApplicationNO, "", 20));
            ps.setString(++i, StrUtil.getParameter(vo.SeqNO, "", 3));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionID, "", 9));
            ps.setString(++i, StrUtil.getParameter(vo.CodeType, "", 1));
            ps.setInt(   ++i, parseInt(vo.TransactionLength));
            ps.setString(++i, StrUtil.getParameter(vo.Sender, "", 7));
            ps.setInt(   ++i, parseInt(vo.TransactionSEQNO));
            ps.setString(++i, StrUtil.getParameter(vo.Receiver, "", 7));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionNO, "", 4));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.TransactionTime, "", 6));
            ps.setString(++i, StrUtil.getParameter(vo.ResponseCode, "", 4));
            ps.setString(++i, "");  // ResponseMessage
            ps.setString(++i, StrUtil.getParameter(vo.UserField, "", 39));
            ps.setString(++i, "");  // ResTransactionID
            ps.setString(++i, "");  // ResCodeType
            ps.setInt(   ++i, 0);   // ResTransactionLength
            ps.setString(++i, "");  // ResSender
            ps.setInt(   ++i, 0);   // ResTransactionSEQNO
            ps.setString(++i, "");  // ResReceiver
            ps.setString(++i, "");  // ResTransactionNO
            ps.setString(++i, "");  // ResTransactionDate
            ps.setString(++i, "");  // ResTransactionTime
            ps.setString(++i, "");  // ResResponseCode
            ps.setString(++i, "");  // ResResponseMessage
            ps.setString(++i, "");  // ResUserField
            ps.setString(++i, StrUtil.getParameter(vo.ID, "", 24));
            ps.setString(++i, StrUtil.getParameter(vo.BusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.SellerID, "", 13));
            ps.setString(++i, StrUtil.getParameter(vo.SellerBusinessNO, "", 10));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeNO, "", 12));
            ps.setString(++i, StrUtil.getParameter(vo.LoanDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeExpiration, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.GuaranteeType, "", 2));
            ps.setBigDecimal(++i, vo.GuaranteeAMT);
            ps.setString(++i, StrUtil.getParameter(vo.JobDate, "", 8));
            ps.setBigDecimal(++i, vo.ClearAMT);
            ps.setBigDecimal(++i, vo.GuaranteeBalance);
            ps.setString(++i, StrUtil.getParameter(vo.CancelDate, "", 8));
            ps.setString(++i, StrUtil.getParameter(vo.CancelReason, "", 100));
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("receiveXmlH211(KIBO) error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_GUARANTEE UPDATE
    // 신보 updateInfoGuarantee 와 동일한 패턴
    // ─────────────────────────────────────────
    protected int updateKiboGuarantee(String applNo, String transNo,
            String status, String grtNo, java.math.BigDecimal kcgfAmt,
            String issueYmd, String chgExpireYmd, String clearYmd) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            String ymdhms = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());

            // 빈 값은 업데이트 제외
            StringBuilder sql = new StringBuilder(
                "UPDATE DBO.KIBO_GUARANTEE SET STATUS_YMDHMS = ?");

            if (status != null && !status.isEmpty())
                sql.append(", STATUS = ?");
            if (grtNo != null && !grtNo.isEmpty())
                sql.append(", GRTNO = ?");
            if (kcgfAmt != null && kcgfAmt.compareTo(java.math.BigDecimal.ZERO) > 0)
                sql.append(", KCGF_AMT = ?");
            if (issueYmd != null && !issueYmd.isEmpty())
                sql.append(", ISSUEYMD = ?, FIRST_EXPIREYMD = ?");
            if (chgExpireYmd != null && !chgExpireYmd.isEmpty())
                sql.append(", CHG_EXPIREYMD = ?");
            if (clearYmd != null && !clearYmd.isEmpty())
                sql.append(", CLEARYMD = ?");

            sql.append(" WHERE APPLNO = ?");

            ps = new WrapPreparedStatementUtil(conn, sql.toString());
            int i = 0;
            ps.setString(++i, ymdhms);
            if (status != null && !status.isEmpty())
                ps.setString(++i, status);
            if (grtNo != null && !grtNo.isEmpty())
                ps.setString(++i, StrUtil.getParameter(grtNo, "", 12));
            if (kcgfAmt != null && kcgfAmt.compareTo(java.math.BigDecimal.ZERO) > 0)
                ps.setBigDecimal(++i, kcgfAmt);
            if (issueYmd != null && !issueYmd.isEmpty()) {
                ps.setString(++i, StrUtil.getParameter(issueYmd, "", 8));
                ps.setString(++i, StrUtil.getParameter(issueYmd, "", 8));
            }
            if (chgExpireYmd != null && !chgExpireYmd.isEmpty())
                ps.setString(++i, StrUtil.getParameter(chgExpireYmd, "", 8));
            if (clearYmd != null && !clearYmd.isEmpty())
                ps.setString(++i, StrUtil.getParameter(clearYmd, "", 8));
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));

            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
            logger.info("updateKiboGuarantee: " + applNo + " -> " + transNo +
                        " status=" + status + " result=" + result);
        } catch (Exception e) {
            logger.error("updateKiboGuarantee error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // KIBO_GUARANTEE_STATUS INSERT
    // ─────────────────────────────────────────
    protected int addKiboGuaranteeStatus(String applNo, String transNo,
            java.math.BigDecimal amt, String description) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        int result = 0;
        try {
            String ymdhms = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());

            // SEQNO 채번
            String seqNo = getNextSeqNo("KIBO_GUARANTEE_STATUS", "APPLNO", applNo);

            ps = new WrapPreparedStatementUtil(conn,
                "INSERT INTO DBO.KIBO_GUARANTEE_STATUS " +
                "(APPLNO, SEQNO, TRANSNO, AMT, RESPONSE, RESPMSG, CREUSER, CREMSG, CRETIME, OKYESNO) " +
                "VALUES (?, ?, ?, ?, '0000', '', 'system', ?, ?, 'Y');");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(applNo, "", 20));
            ps.setString(++i, StrUtil.getParameter(seqNo, "", 3));
            ps.setString(++i, StrUtil.getParameter(transNo, "", 4));
            ps.setBigDecimal(++i, amt != null ? amt : java.math.BigDecimal.ZERO);
            ps.setString(++i, StrUtil.getParameter(description, "", 100));
            ps.setString(++i, ymdhms);
            logger.debug(ps.getQueryString());
            result = ps.executeUpdate();
        } catch (Exception e) {
            logger.error("addKiboGuaranteeStatus error: " + e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    // ─────────────────────────────────────────
    // 유틸
    // ─────────────────────────────────────────
    private int parseInt(String val) {
        try { return Integer.parseInt(val != null ? val.trim() : "0"); }
        catch (Exception e) { return 0; }
    }
}
