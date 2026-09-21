package kr.co.soap.kodit.loan.emtnet;

import java.util.List;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.B211ItemVO;
import kr.co.soap.controll.B211VO;
import kr.co.soap.controll.B212VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.kodit.loan.Kodit_B211;

/**
 * 매매계약서 발송(B211) 구상 클래스.
 *  - (OrderNO, SeqNO) 로 XML_B211 + XML_B211_ITEM 읽어 전문 구성
 *  - 송신 후 결과를 DAO 로 적재(XML_B211 Res* + SEND_STATUS)
 *
 * Sender 는 신보 송신기관 코드(EMTNET) 고정. Receiver 0760000 고정.
 */
public class EmtNetB211 extends Kodit_B211 {

    private static final String SENDER_EMTNET = "EMTNET";   // TODO: 항상 EMTNET 확인
    private static final String RECEIVER_KODIT = "0760000";

    private final String orderNO;
    private final String seqNO;

    private final B211Dao dao;

    public EmtNetB211(String orderNO, String seqNO) {
        super();
        this.orderNO = orderNO;
        this.seqNO   = StrUtil.isEmpty(seqNO) ? "001" : seqNO;
        this.dao     = new B211Dao();
    }

    @Override
    protected CommonElement makeB211VO() throws Exception {
        CommonElement ce = new CommonElement();
        ce.setResponseCode("0000");

        if (StrUtil.isEmpty(this.orderNO)) {
            return err(ce, "0080", "주문번호가 없습니다.");
        }

        B211VO header = dao.getB211(this.orderNO, this.seqNO);
        if (header == null) {
            return err(ce, "0080", "매매계약 정보를 읽을 수 없습니다.");
        }
        // 재전송 가드: 전송대기('0' 또는 NULL)만 허용 (SEND_STATUS 는 DAO 가 userField 에 임시보관)
        String sendStatus = StrUtil.nvl(header.getCommonElement().getUserField());
        if (!("0".equals(sendStatus) || "".equals(sendStatus))) {
            return err(ce, "0085", "전송대기 상태가 아닙니다. (상태:" + sendStatus + ")");
        }

        List<B211ItemVO> items = dao.getB211Items(this.orderNO, this.seqNO);
        if (items == null || items.isEmpty()) {
            return err(ce, "0081", "주문상세 정보를 읽을 수 없습니다.");
        }

        // 송신 시각/관리번호 세팅
        CommonElement hce = header.getCommonElement();
        hce.setUserField(null);                       // 임시보관 해제
        hce.setSender(SENDER_EMTNET);
        hce.setTransactionSEQNO(SequenceGenerator.getInstance().getTransSeqNO());
        hce.setReceiver(RECEIVER_KODIT);
        hce.setTransactionDate(DateTimeUtil.getCurrentDate(""));
        hce.setTransactionTime(DateTimeUtil.getCurrentDateTime().substring(8, 14));

        // OrderCount 는 실제 아이템 수로 보정
        header.setOrderCount(String.valueOf(items.size()));
        if (StrUtil.isEmpty(header.getSettlementScheduleCount())) {
            header.setSettlementScheduleCount("1");
        }

        super.b211VO   = header;
        super.itemList = items;
        return ce;
    }

    @Override
    protected void persistResult(B211VO header, List<B211ItemVO> items, B212VO res) throws Exception {
        CommonElement rc = res.getCommonElement();
        String code = StrUtil.nvl(rc.getResponseCode(), "");
        boolean commError = code.isEmpty() || "0099".equals(code) || "4444".equals(code);

        String sendStatus;     // 1=성공, 9=실패, 0=대기(통신오류 재시도)
        String resCode, resMsg, resDate, resTime;
        String resSeqNo;

        if ("0000".equals(code)) {
            sendStatus = "1";
            resCode = "0000"; resMsg = "";
            resSeqNo = StrUtil.nvl(rc.getTransactionSEQNO());
            resDate  = StrUtil.nvl(rc.getTransactionDate());
            resTime  = StrUtil.nvl(rc.getTransactionTime());
        } else if (!commError) {
            sendStatus = "9";
            resCode = code; resMsg = cut(rc.getResponseMessage(), 1000);
            resSeqNo = StrUtil.nvl(rc.getTransactionSEQNO());
            resDate  = StrUtil.nvl(rc.getTransactionDate());
            resTime  = StrUtil.nvl(rc.getTransactionTime());
        } else {
            sendStatus = "0";
            resCode = ""; resMsg = ""; resSeqNo = ""; resDate = ""; resTime = "";
        }

        CommonElement hce = header.getCommonElement();
        Integer txSeq = parseIntOrNull(hce.getTransactionSEQNO());

        dao.saveB211Result(
            this.orderNO, this.seqNO,
            hce.getSender(), (txSeq == null ? 0 : txSeq.intValue()),
            hce.getReceiver(), hce.getTransactionDate(), hce.getTransactionTime(),
            resSeqNo, resDate, resTime, resCode, resMsg, sendStatus);
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
        ce.setResponseCode(code);
        ce.setResponseMessage(msg);
        return ce;
    }
}
