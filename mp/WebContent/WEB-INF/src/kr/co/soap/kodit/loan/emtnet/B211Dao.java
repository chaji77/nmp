package kr.co.soap.kodit.loan.emtnet;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.soap.controll.B211ItemVO;
import kr.co.soap.controll.B211VO;

/**
 * B211 전용 DAO. SoapCommonDAO 와 동일한 커넥션/실행 패턴.
 *   GET_B211_PROC / GET_B211_ITEM_PROC / GET_B211_PENDING_PROC / SAVE_B211_RESULT_PROC
 */
public class B211Dao {

    /** 전송대기 키 (자동전송/리스트용) */
    public static class Pending {
        public String orderNO;
        public String seqNO;
    }

    /** 헤더 조회 (송신용). 못 찾으면 null. */
    public B211VO getB211(String orderNO, String seqNO) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        B211VO vo = null;
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_B211_PROC ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(orderNO), "", 20));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(seqNO),   "", 3));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                vo = new B211VO();
                vo.setApplicationNO(rs.getString("ApplicationNO"));
                vo.setGuaranteeNO(rs.getString("GuaranteeNO"));
                vo.setTradeDate(rs.getString("TradeDate"));
                vo.setOrderNO(rs.getString("OrderNO"));
                vo.setContractDate(rs.getString("ContractDate"));
                vo.setBuyerID(rs.getString("BuyerID"));
                vo.setBuyerBusinessNO(rs.getString("BuyerBusinessNO"));
                vo.setSellerID(rs.getString("SellerID"));
                vo.setSellerBusinessNO(rs.getString("SellerBusinessNO"));
                vo.setTotalContractAMT(numStr(rs, "TotalContractAMT"));
                vo.setSettlementScheduleCount(numStr(rs, "SettlementScheduleCount"));
                vo.setScheduleSEQNO(numStr(rs, "ScheduleSEQNO"));
                vo.setSettlementType(rs.getString("SettlementType"));
                vo.setSettlementDueAMT(numStr(rs, "SettlementDueAMT"));
                vo.setDeliveryDueDate(rs.getString("DeliveryDueDate"));
                vo.setPaymentDueDate(rs.getString("PaymentDueDate"));
                vo.setOrderCount(numStr(rs, "OrderCount"));
                // SEND_STATUS 는 검증용으로 commonElement.userField 에 임시 보관
                vo.getCommonElement().setUserField(rs.getString("SEND_STATUS"));
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "GET_B211_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return vo;
    }

    /** 주문상세 조회 */
    public List<B211ItemVO> getB211Items(String orderNO, String seqNO) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        List<B211ItemVO> list = new ArrayList<B211ItemVO>();
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_B211_ITEM_PROC ?, ?;");
            int i = 0;
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(orderNO), "", 20));
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(seqNO),   "", 3));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            while (rs != null && rs.next()) {
                B211ItemVO it = new B211ItemVO();
                it.setOrderSEQNO(numStr(rs, "OrderSEQNO"));
                it.setItem(rs.getString("Item"));
                it.setSize(rs.getString("Size"));
                it.setQuantity(numStr(rs, "Quantity"));
                it.setQuantityUnit(rs.getString("QuantityUnit"));
                it.setUnitPrice(numStr(rs, "UnitPrice"));
                it.setSupplyAMT(numStr(rs, "SupplyAMT"));
                it.setTaxAMT(numStr(rs, "TaxAMT"));
                it.setTotalAMT(numStr(rs, "TotalAMT"));
                list.add(it);
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "GET_B211_ITEM_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return list;
    }

    /** 전송대기 목록 TOP N */
    public List<Pending> getB211Pending(int topN) {
        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        List<Pending> list = new ArrayList<Pending>();
        try {
            ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_B211_PENDING_PROC ?;");
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
            logger.error(ps != null ? ps.getQueryString() : "GET_B211_PENDING_PROC");
            logger.error(e.toString());
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return list;
    }

    /** 송신 결과 적재 */
    public int saveB211Result(
            String orderNO, String seqNO,
            String sender, int transSeqNo, String receiver, String transDate, String transTime,
            String resTransSeqNo, String resTransDate, String resTransTime,
            String resResponseCode, String resResponseMsg, String sendStatus) {

        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        ResultSet rs = null;
        int result = 0;
        try {
            ps = new WrapPreparedStatementUtil(conn,
                "EXEC DBO.SAVE_B211_RESULT_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
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
            ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(sendStatus),"", 1));
            logger.debug(ps.getQueryString());
            rs = ps.executeQuery();
            if (rs != null && rs.next()) {
                result = rs.getInt("RESULT");
            }
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "SAVE_B211_RESULT_PROC");
            logger.error(e.toString());
            result = -1;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
        }
        return result;
    }

    /**
     * numeric/decimal 컬럼을 전송용 문자열로 정규화.
     *  - 끝자리 0 제거: "28160000.00"->"28160000"(금액 정수화), "1.00"->"1"
     *  - 의미있는 소수는 보존: "1.50"->"1.5", "1.05"->"1.05" (수량 등)
     */
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
