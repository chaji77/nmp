package rcftp;

import java.sql.Connection;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.stream.Collectors;

import org.apache.log4j.Logger;

import kr.co.funology.maven.fw.mgr.ConfigurationMgr;
import kr.co.funology.maven.fw.mgr.ConnectionMgr;
import kr.co.funology.maven.fw.util.WrapPreparedStatementUtil;

public class SettleReceiver extends Receiver {

    public SettleReceiver(String strFilePath) {
        super("S", strFilePath);
    }

    public boolean insert(List<VO> batch) {
        System.out.println("insert settlement data");
        if (batch == null || batch.isEmpty()) return true;

        String strSenderCode = batch.get(0).SELLER_CODE;
        String strSql = "INSERT INTO "+ConfigurationMgr.getInstance().getString("DB_NM")+".DBO.B2B_TRANS_SETTLEMENT_" + strSenderCode + " (SENDER, TRANSACTIONSEQNO, RECEIVER, TRANSACTIONNO, ORDERNO, SEQNO, PAYMENTAMT, PAYMENTDATE) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";

        Connection conn = ConnectionMgr.getInstance().getConnetion();
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger(this.getClass());
        Set<String> failedOrderNos = new ConcurrentSkipListSet<>();

        try {
            ps = new WrapPreparedStatementUtil(conn, strSql);
            for (VO vo : batch) {
                try {
                    int i = 0;
                    ps.setString(     ++i, vo.SELLER_CODE        );
                    ps.setString(     ++i, vo.TRANSACTION_SEQ_NO );
                    ps.setString(++i, ConfigurationMgr.getInstance().getString("RECEIVER"));
                    ps.setString(     ++i, vo.SETTLE_TYPE_CD     );
                    ps.setString(     ++i, vo.ORDER_NO           );
                    ps.setInt(        ++i, vo.SETTLE_SEQ_NO      );
                    ps.setBigDecimal( ++i, vo.PAYMENT_AMT        );
                    ps.setString(     ++i, vo.PAYMENT_DATE       );
                    logger.debug(ps.getQueryString());
                    ps.addBatch();
                } catch (Exception e) {
                    logger.error("DB 삽입 오류: " + vo);
                    failedOrderNos.add(vo.ORDER_NO);
                }
            }
            ps.executeBatch();
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
