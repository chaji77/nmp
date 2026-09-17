package rcftp;

import java.sql.Connection;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.stream.Collectors;

import org.apache.log4j.Logger;

import kr.co.funology.maven.fw.mgr.ConfigurationMgr;
import kr.co.funology.maven.fw.mgr.ConnectionMgr;
import kr.co.funology.maven.fw.util.StrUtil;
import kr.co.funology.maven.fw.util.WrapPreparedStatementUtil;

public class ContractReceiver extends Receiver {


    public ContractReceiver(String strFilePath) {
        super("B", strFilePath);
    }

    public boolean insert(List<VO> batch) {
        if (batch == null || batch.isEmpty()) return true;

        String strSenderCode = batch.get(0).SELLER_CODE;
        String strSql = "INSERT INTO "+ConfigurationMgr.getInstance().getString("DB_NM")+".DBO.B2B_TRANS_ORDER_" + strSenderCode +
                " (SENDER, TRANSACTIONSEQNO, RECEIVER, TRANSACTIONNO, ORDERNO, SEQNO, TRADEDATE, " +
                "SELLERID, SELLERBUSINESSNO, BUYERID, BUYERBUSINESSNO, TOTALCONTRACTAMT, PAYMENTDUEDATE, " +
                "ITEM, SIZE, QUANTITY, QUANTITYUNIT, UNITPRICE, SUPPLYAMT, TAXAMT, TOTALAMT) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger("CodeDAO");
        Set<String> failedOrderNos = new ConcurrentSkipListSet<>();

        try {
            ps = new WrapPreparedStatementUtil(conn, strSql);
            for (VO vo : batch) {
                try {
                    int i = 0;
                    ps.setString(++i, vo.SELLER_CODE);
                    ps.setString(++i, vo.TRANSACTION_SEQ_NO);
                    ps.setString(++i, ConfigurationMgr.getInstance().getString("RECEIVER"));
                    ps.setString(++i, vo.ORDER_TYPE_CD);
                    ps.setString(++i, vo.ORDER_NO);
                    ps.setInt(++i, vo.ORDER_SEQ_NO);
                    ps.setString(++i, vo.CONTRACT_DATE);
                    ps.setString(++i, vo.SELLER_ID);
                    ps.setString(++i, vo.SELLER_BUSINESS_NO);
                    ps.setString(++i, vo.BUYER_ID);
                    ps.setString(++i, vo.BUYER_BUSINESS_NO);
                    ps.setBigDecimal(++i, vo.TOTAL_CONTRACT_AMT);
                    ps.setString(++i, vo.PAYMENT_DUE_DATE);
                    ps.setString(++i, StrUtil.cutString(vo.ITEM, 50, ""));
                    ps.setString(++i, vo.SIZE);
                    ps.setBigDecimal(++i, vo.QUANTITY);
                    ps.setString(++i, StrUtil.cutString(vo.QUANTITY_UNIT, 10, ""));
                    ps.setBigDecimal(++i, vo.UNIT_PRICE);
                    ps.setBigDecimal(++i, vo.SUPPLY_AMT);
                    ps.setBigDecimal(++i, vo.TAX_AMT);
                    ps.setBigDecimal(++i, vo.TOTAL_AMT);
                    logger.debug(ps.getQueryString());
                    ps.addBatch();
                } catch (Exception e) {
                    logger.error("DB 삽입 오류: " + vo);
                    failedOrderNos.add(vo.ORDER_NO);
                }
            }
            ps.executeBatch();
            return failedOrderNos.isEmpty();
        } catch (Exception e) {
            logger.error(ps != null ? ps.getQueryString() : "");
            logger.error(e.toString());
            failedOrderNos.addAll(batch.stream().map(vo -> vo.ORDER_NO).collect(Collectors.toSet()));
            return false;
        } finally {
            ConnectionMgr.getInstance().closeConnection(conn, ps, null);
        }
    }
}
