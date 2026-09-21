package kr.co.soap.kibo.loan.emtnet;

import org.w3c.dom.Document;

import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.K311VO;
import kr.co.soap.kibo.loan.Kibo_K3XX;

/**
 * 기보 B413 (대출보증 - 이상거래 해제 통지) 수신 처리
 *
 * [변경 이유]
 *  기존에는 EmtNetRcvBM 에서 생성자만 호출하고 executeK3XX() 파이프라인을
 *  타지 않아, RECEIVE_XML_K311 INSERT(saveToDB) 가 실행되지 않았다.
 *  그 결과 updateDBWithResponse() 의 UPDATE 도 ORDERNO/SEQNO 가 없어
 *  0건 갱신으로 조용히 지나갔고, 수신 이력이 전혀 남지 않았다.
 *
 * [변경 내용]
 *  executeB413() 이 executeK3XX() 를 호출하도록 배선.
 *  → K311/K315/K321 과 동일한 처리 흐름을 탄다.
 *  → RECEIVE_XML_K311 에 B413 행이 INSERT 되고,
 *    SEND_XML_B311_LIST_BY_CTID_PROC 가 전문번호 필터 없이 UNION 하므로
 *    거래관리 > 진행상태 팝업에 자동으로 표시된다.
 *
 * [B413 IndivPart 필드]
 *  BuyerBusinessNO, SellerBusinessNO, TradeDate, OrderNO, ContractDate,
 *  BuyerRecordNO, SellerRecordNO, InquireDate, InquireDateSeqNo,
 *  NotifyConfirmSTCD
 */
public class EmtNetB413 extends Kibo_K3XX {

    public EmtNetB413(Document doc) {
        super(doc);
    }

    /**
     * B413 처리 진입점
     * EmtNetRcvBM 에서 호출한다.
     */
    public void executeB413() throws Exception {

        System.out.println("################ B413 START ################");

        executeK3XX();      // 공통 파이프라인 (VO세팅 → 채번 → Body → saveToDB)

        // ── 응답코드 보정
        //  executeK3XX() 는 내부 예외 발생 시 ResponseCode 를 9901 로 바꾼다.
        //  B413 은 기보가 보내는 '통지' 전문이고 우리 쪽은 수신기록이 목적이므로,
        //  DB 저장이 실패하더라도 기보에는 정상(0000)으로 응답해야 한다.
        //  (저장 실패 시 재전송을 유발하거나 기보 측 오류로 잡히는 것을 방지)
        String code = getResCommonElement().getResponseCode();
        if (!"0000".equals(code)) {
            System.out.println("[B413] 수신기록 실패(code=" + code + ") → 응답은 0000 으로 반환");
            getResCommonElement().setResponseCode("0000");
            getResCommonElement().setResponseMessage("");
        }

        System.out.println("################ B413 END ################");
    }

    /**
     * B413 개별부(IndivPart) → K311VO 매핑
     *
     * RECEIVE_XML_K311_ADD_PROC 는 K311 기준으로 금액 파라미터를 요구하지만
     * B413 에는 금액 항목이 없다. VO 기본값(0/null)으로 들어가며,
     * 여기서는 B413 에 실제 존재하는 값만 채운다.
     */
    @Override
    protected void getK3XXBodyElement() {

        Document doc = getDoc();
        K311VO vo = getKiboXmlK311();
        if (doc == null || vo == null) return;

        // B413 에 존재하는 공통 항목
        vo.setTradedate(nvlTrim(XMLUtil.getNodeValue(doc, "TradeDate")));
        vo.setContractdate(nvlTrim(XMLUtil.getNodeValue(doc, "ContractDate")));

        /*
         * [금액 컬럼 처리]
         * SETTLEMANTDUEAMT / SETTLEAMT / PAYMENTAMT / REFUNDAMT /
         * BUYERFEE / SELLERFEE 는 K311(결제전문) 전용이라 B413 에는 없다.
         *
         * K311VO 의 해당 필드가 int 이면 기본값 0 으로 들어가므로 아래 코드는 불필요.
         * String 타입이라면 null 인 채로 SoapCommonBean 에서 숫자 변환 시
         * 예외가 날 수 있으므로, 그 경우 아래 주석을 해제할 것.
         *
         *   vo.setSettlemantdueamt(0);
         *   vo.setSettleamt(0);
         *   vo.setPaymentamt(0);
         *   vo.setRefundamt(0);
         *   vo.setBuyerfee(0);
         *   vo.setSellerfee(0);
         *   vo.setSettlementduedate("");
         */

        // ── 컬럼 길이 방어 (RESPONSEMESSAGE/USERFIELD 는 VARCHAR(39))
        //    B413 원문의 ResponseMessage 는 공백 패딩 65자로 수신되므로
        //    trim 하지 않으면 INSERT 시 truncation 오류가 발생한다.
        vo.setResponsemessage(cut(nvlTrim(vo.getResponsemessage()), 39));
        vo.setUserfield(cut(nvlTrim(vo.getUserfield()), 39));

        /*
         * [참고] B413 고유 필드는 K311VO 에 대응 컬럼이 없어 저장하지 않는다.
         *   BuyerBusinessNO / SellerBusinessNO / BuyerRecordNO / SellerRecordNO
         *   InquireDate / InquireDateSeqNo / NotifyConfirmSTCD
         *
         * 지원팀 요구사항(수신 시점 확인)은 전송일/전송시간으로 충족된다.
         * 통지확인상태코드(NotifyConfirmSTCD)까지 화면에 노출해야 한다면
         * 아래처럼 USERFIELD 에 담아 팝업 '내용' 칼럼에 표시할 수 있다.
         *
         *   String stcd = nvlTrim(XMLUtil.getNodeValue(doc, "NotifyConfirmSTCD"));
         *   vo.setUserfield(cut("해제통지 STCD=" + stcd, 39));
         */

        System.out.println("[B413] ORDERNO=" + vo.getOrderno()
                + ", TRADEDATE=" + vo.getTradedate()
                + ", CONTRACTDATE=" + vo.getContractdate());
    }

    /**
     * Kibo_K3XX 추상 메소드.
     * B413 은 수신 이력 기록이 목적이므로 별도 업무 처리는 없다.
     * (실제 이상거래 해제 처리는 기보에서 수행되어 통지만 오는 구조)
     */
    @Override
    protected void processByK3XX() throws Exception {
        System.out.println("processByK3XX - B413 (수신기록 전용, 업무처리 없음)");
    }

    // ── util
    private String nvlTrim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private String cut(String s, int max) {
        if (s == null) return "";
        return (s.length() > max) ? s.substring(0, max) : s;
    }
}
