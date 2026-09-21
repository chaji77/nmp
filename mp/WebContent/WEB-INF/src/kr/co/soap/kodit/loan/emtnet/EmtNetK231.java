package kr.co.soap.kodit.loan.emtnet;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.K231VO;
import kr.co.soap.controll.K232VO;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.kodit.loan.Kodit_K231;

/**
 * 결제전문(K231) 구상 클래스.
 *  - (OrderNO, SeqNO) 로 XML_K231 읽어 전문 구성 -> 송신 -> 결과(ClearSEQNO 포함) 적재
 */
public class EmtNetK231 extends Kodit_K231 {

    private static final String SENDER_EMTNET  = "EMTNET";
    private static final String RECEIVER_KODIT = "0760000";

    private final String orderNO;
    private final String seqNO;
    private final K231Dao dao;

    public EmtNetK231(String orderNO, String seqNO) {
        super();
        this.orderNO = orderNO;
        this.seqNO   = StrUtil.isEmpty(seqNO) ? "001" : seqNO;
        this.dao     = new K231Dao();
    }

    @Override
    protected CommonElement makeK231VO() throws Exception {
        CommonElement ce = new CommonElement();
        ce.setResponseCode("0000");

        if (StrUtil.isEmpty(this.orderNO)) return err(ce, "0080", "주문번호가 없습니다.");

        K231VO row = dao.getK231(this.orderNO, this.seqNO);
        if (row == null) return err(ce, "0080", "결제전문 정보를 읽을 수 없습니다.");

        String sendStatus = StrUtil.nvl(row.getCommonElement().getUserField());
        if (!("0".equals(sendStatus) || "".equals(sendStatus)))
            return err(ce, "0085", "발송대기 상태가 아닙니다. (상태:" + sendStatus + ")");

        CommonElement hce = row.getCommonElement();
        hce.setUserField(null);
        hce.setSender(SENDER_EMTNET);
        hce.setTransactionSEQNO(SequenceGenerator.getInstance().getTransSeqNO());
        hce.setReceiver(RECEIVER_KODIT);
        hce.setTransactionDate(DateTimeUtil.getCurrentDate(""));
        hce.setTransactionTime(DateTimeUtil.getCurrentDateTime().substring(8, 14));
        if (StrUtil.isEmpty(row.getScheduleSEQNO())) row.setScheduleSEQNO("1");

        super.k231VO = row;
        return ce;
    }

    @Override
    protected void persistResult(K231VO req, K232VO res) throws Exception {
        CommonElement rc = res.getCommonElement();
        String code = StrUtil.nvl(rc.getResponseCode(), "");
        boolean commError = code.isEmpty() || "0099".equals(code) || "4444".equals(code);

        String sendStatus, resCode, resMsg, resDate, resTime, resSeqNo, clearSeq;
        if ("0000".equals(code)) {
            sendStatus = "1"; resCode = "0000"; resMsg = "";
            resSeqNo = StrUtil.nvl(rc.getTransactionSEQNO());
            resDate  = StrUtil.nvl(rc.getTransactionDate());
            resTime  = StrUtil.nvl(rc.getTransactionTime());
            clearSeq = StrUtil.nvl(res.getClearSEQNO());
        } else if (!commError) {
            sendStatus = "9"; resCode = code; resMsg = cut(rc.getResponseMessage(), 1000);
            resSeqNo = StrUtil.nvl(rc.getTransactionSEQNO());
            resDate  = StrUtil.nvl(rc.getTransactionDate());
            resTime  = StrUtil.nvl(rc.getTransactionTime());
            clearSeq = "";
        } else {
            sendStatus = "0"; resCode = ""; resMsg = ""; resDate = ""; resTime = ""; resSeqNo = ""; clearSeq = "";
        }

        CommonElement hce = req.getCommonElement();
        Integer txSeq = parseIntOrNull(hce.getTransactionSEQNO());

        dao.saveK231Result(
            this.orderNO, this.seqNO,
            hce.getSender(), (txSeq == null ? 0 : txSeq.intValue()),
            hce.getReceiver(), hce.getTransactionDate(), hce.getTransactionTime(),
            resSeqNo, resDate, resTime, resCode, resMsg, clearSeq, sendStatus);
    }

    private static Integer parseIntOrNull(String s) {
        try { return (s == null || s.trim().isEmpty()) ? null : Integer.valueOf(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }
    private static String cut(String s, int n) {
        if (s == null) return null;
        return s.length() <= n ? s : s.substring(0, n);
    }
    private CommonElement err(CommonElement ce, String code, String msg) {
        ce.setResponseCode(code); ce.setResponseMessage(msg); return ce;
    }
}
