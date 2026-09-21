package kr.co.soap.kodit.loan.emtnet;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.soap.controll.K231VO;

/**
 * K231 전용 DAO. GET_K231_PROC / GET_K231_PENDING_PROC / SAVE_K231_RESULT_PROC
 */
public class K231Dao {

    public static class Pending {
        public String orderNO;
        public String seqNO;
    }

    /** 송신용 K231 헤더 조회 (SEND_STATUS 는 commonElement.userField 에 임시보관) */
    public K231VO getK231(String orderNO, String seqNO) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        K231VO vo = null;
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_K231_PROC ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(orderNO), "", 20));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(seqNO),   "", 3));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                vo = new K231VO();
                vo.setBuyerID(rs.getString("BuyerID"));
                vo.setBuyerBusinessNO(rs.getString("BuyerBusinessNO"));
                vo.setSellerID(rs.getString("SellerID"));
                vo.setSellerBusinessNO(rs.getString("SellerBusinessNO"));
                vo.setOrderNO(rs.getString("OrderNO"));
                vo.setScheduleSEQNO(numStr(rs, "ScheduleSEQNO"));
                vo.setPaymentDueAMT(numStr(rs, "PaymentDueAMT"));
                vo.setPaymentAMT(numStr(rs, "PaymentAMT"));
                vo.setUnclearAMT(numStr(rs, "UnclearAMT"));
                vo.setPaymentDueDate(rs.getString("PaymentDueDate"));
                vo.setPaymentDate(rs.getString("PaymentDate"));
                vo.getCommonElement().setUserField(rs.getString("SEND_STATUS"));
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "GET_K231_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return vo;
    }

    public List<Pending> getK231Pending(int topN) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        List<Pending> list = new ArrayList<Pending>();
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_K231_PENDING_PROC ?;");
            ps.setInt(1, topN);
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            while (rs != null && rs.next()) {
                Pending p = new Pending();
                p.orderNO = rs.getString("OrderNO");
                p.seqNO   = rs.getString("SeqNO");
                list.add(p);
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "GET_K231_PENDING_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return list;
    }

    public int saveK231Result(
            String orderNO, String seqNO,
            String sender, int transSeqNo, String receiver, String transDate, String transTime,
            String resTransSeqNo, String resTransDate, String resTransTime,
            String resResponseCode, String resResponseMsg, String clearSeqNo, String sendStatus) {

        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.SAVE_K231_RESULT_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(orderNO),  "", 20));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(seqNO),    "", 3));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sender),   "", 7));
            ps.setInt   (++i, transSeqNo);
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(receiver), "", 7));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(transDate),"", 8));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(transTime),"", 6));
            ps.setString(++i, StrUtil.nvl(resTransSeqNo, ""));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resTransDate),"", 8));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resTransTime),"", 6));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resResponseCode),"", 4));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(resResponseMsg),"", 1000));
            ps.setString(++i, StrUtil.nvl(clearSeqNo, ""));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sendStatus),"", 1));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) result = rs.getInt("RESULT");
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "SAVE_K231_RESULT_PROC");
            logger.error(e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    private String numStr(ResultSet rs, String col) {
        try {
            String v = rs.getString(col);
            if (v == null) return "";
            v = v.trim();
            int dot = v.indexOf('.');
            if (dot >= 0) {
                String frac = v.substring(dot + 1).replaceAll("0+$", "");
                v = frac.isEmpty() ? v.substring(0, dot) : (v.substring(0, dot) + "." + frac);
            }
            return v;
        } catch (Exception e) { return ""; }
    }
}
