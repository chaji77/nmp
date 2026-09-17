package kr.co.soap.kodit.loan.emtnet;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.C211VO;
import kr.co.soap.controll.C212VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.EnumData;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kodit.loan.Kodit_C211;

/**
 * 담보보증 신청(C211) 송신 구상 클래스. (EmtNetA311S 패턴)
 *  - applNo 로 INFO_GUARANTEE 조회(DAO) -> 구매/판매 회사정보(bean) -> 전문 구성
 *  - 송신 후 결과를 DAO 로 적재(XML_C211 + INFO_GUARANTEE_STATUS + 상태갱신)
 *
 * ID 규칙: 법인번호(CPY_INCORPORATE_NO) 사용, 없으면(개인) "0000000000000".
 *          (주민번호 미수집 정책 → 평문 그대로 전송/저장)
 */
public class EmtNetC211 extends Kodit_C211 {

    private static final String RECEIVER_KODIT = "0760000";   // 신보 수신기관(고정)
    private static final String ID_ZERO        = "0000000000000";

    private final String applNo;
    private final String creUser;     // 작업자 ID (CREUSER 적재용)

    // INFO_GUARANTEE 적재값
    private long   applAmt;
    private String applExpireText;    // APPL_EXPIREYMD (예: "발급후 1년")
    private String grtType;           // GRTTYPE (예: "02")

    private SoapCommonVO.CompanyVO cpyBuyer  = null;
    private SoapCommonVO.CompanyVO cpySeller = null;

    private final SoapCommonBean      bean;
    private final GuaranteeC211Dao    dao;
    private GuaranteeC211Dao.GuaranteeInfo grtInfo;

    public EmtNetC211(String applNo, String creUser) {
        super("");
        this.applNo  = applNo;
        this.creUser = StrUtil.nvl(creUser, "");
        this.bean    = new SoapCommonBean();
        this.dao     = new GuaranteeC211Dao();
    }

    @Override
    protected CommonElement makeC211VO() throws Exception {
        CommonElement ce = new CommonElement();
        ce.setResponseCode("0000");

        if (!loadGuaranteeInfo(ce)) return ce;
        if (!loadCompanyInfo(ce))   return ce;

        setCommonElementData();
        setBodyElementData();
        return ce;
    }

    private boolean loadGuaranteeInfo(CommonElement ce) throws Exception {
        if (StrUtil.isEmpty(this.applNo)) {
            setError(ce, "0080", "신청번호가 없습니다.");
            return false;
        }
        this.grtInfo = dao.getGuaranteeInfo(this.applNo);
        if (!this.grtInfo.found) {
            setError(ce, "0080", "보증신청 정보를 읽을 수 없습니다.");
            return false;
        }
        // 재전송 가드: 등록(010) 상태만 전송 허용
        if (!"010".equals(StrUtil.nvl(this.grtInfo.status))) {
            setError(ce, "0085", "이미 신청 처리된 건입니다. (상태:" + this.grtInfo.status + ")");
            return false;
        }
        this.applAmt        = this.grtInfo.applAmt;
        this.applExpireText = this.grtInfo.applExpireText;
        this.grtType        = this.grtInfo.grtType;
        return true;
    }

    private boolean loadCompanyInfo(CommonElement ce) throws Exception {
        // 구매기업 (Sender = 구매기업 MP_CODE)
        this.cpyBuyer = bean.GET_COMPANY_INFO_PROC(this.grtInfo.buyerCpyId);
        if (this.cpyBuyer.CPY_ID == EnumData.longNull) {
            setError(ce, "0081", "구매기업정보를 읽을 수 없습니다.");
            return false;
        }
        super.MPCode = this.cpyBuyer.MP_CODE;

        // 판매기업
        this.cpySeller = bean.GET_COMPANY_INFO_PROC(this.grtInfo.sellerCpyId);
        if (this.cpySeller.CPY_ID == EnumData.longNull) {
            setError(ce, "0082", "판매기업정보를 읽을 수 없습니다.");
            return false;
        }
        return true;
    }

    private void setCommonElementData()
            throws SequenceGenerator.SequenceGenerationException {
        super.kodit_C211VO.getCommonElement().setSender(this.MPCode);
        super.kodit_C211VO.getCommonElement().setTransactionSEQNO(
                SequenceGenerator.getInstance().getTransSeqNO());
        super.kodit_C211VO.getCommonElement().setReceiver(RECEIVER_KODIT);
        super.kodit_C211VO.getCommonElement().setTransactionDate(
                DateTimeUtil.getCurrentDate(""));
        super.kodit_C211VO.getCommonElement().setTransactionTime(
                DateTimeUtil.getCurrentDateTime().substring(8, 14));
    }

    private void setBodyElementData() {
        // 법인번호 사용, 없으면(개인) 13자리 0
        String buyerID = StrUtil.isEmpty(this.cpyBuyer.CPY_INCORPORATE_NO)
                ? ID_ZERO : this.cpyBuyer.CPY_INCORPORATE_NO;
        super.kodit_C211VO.setBuyerID(buyerID);
        super.kodit_C211VO.setBuyerBusinessNO(this.cpyBuyer.CPY_BUSINESS_NO);

        String sellerID = StrUtil.isEmpty(this.cpySeller.CPY_INCORPORATE_NO)
                ? ID_ZERO : this.cpySeller.CPY_INCORPORATE_NO;
        super.kodit_C211VO.setSellerID(sellerID);
        super.kodit_C211VO.setSellerBusinessNO(this.cpySeller.CPY_BUSINESS_NO);

        super.kodit_C211VO.setApplicationNO(this.applNo);
        super.kodit_C211VO.setApplicationAMT(String.valueOf(this.applAmt));
        super.kodit_C211VO.setGuaranteeExpirationText(this.applExpireText);
        super.kodit_C211VO.setGuaranteeType(this.grtType);
        super.kodit_C211VO.setInformation("");
    }

    @Override
    protected void persistResult(C211VO req, C212VO res) throws Exception {
        CommonElement rc = res.getCommonElement();
        String code = StrUtil.nvl(rc.getResponseCode(), "");

        boolean commError = code.isEmpty() || "0099".equals(code) || "4444".equals(code);

        String  okYesNo;
        String  resCode;
        String  resMsg;
        Integer resSeqNo;
        String  resDate;
        String  resTime;

        if ("0000".equals(code)) {                 // 접수 성공
            okYesNo  = "Y";
            resCode  = "0000";
            resMsg   = null;
            resSeqNo = parseIntOrNull(rc.getTransactionSEQNO());
            resDate  = rc.getTransactionDate();
            resTime  = rc.getTransactionTime();
        } else if (!commError) {                   // 신보 업무거절(C212 응답 수신)
            okYesNo  = "N";
            resCode  = code;
            resMsg   = cut(rc.getResponseMessage(), 65);
            resSeqNo = parseIntOrNull(rc.getTransactionSEQNO());
            resDate  = rc.getTransactionDate();
            resTime  = rc.getTransactionTime();
        } else {                                   // 통신오류(응답 없음)
            okYesNo  = null;
            resCode  = null;
            resMsg   = null;
            resSeqNo = null;
            resDate  = null;
            resTime  = null;
        }

        CommonElement sc = req.getCommonElement();
        Integer txSeqNo = parseIntOrNull(sc.getTransactionSEQNO());

        // 통신오류 항목은 빈문자("")로 전달 → 프로시저에서 NULL 처리
        dao.saveC211Result(
            this.applNo, this.creUser, DateTimeUtil.getCurrentDateTime(),
            sc.getSender(), (txSeqNo == null ? 0 : txSeqNo.intValue()),
            sc.getReceiver(), sc.getTransactionDate(), sc.getTransactionTime(),
            req.getBuyerID(),  req.getBuyerBusinessNO(),
            req.getSellerID(), req.getSellerBusinessNO(),
            String.valueOf(this.applAmt), req.getGuaranteeExpirationText(), req.getGuaranteeType(),
            (resSeqNo == null ? "" : String.valueOf(resSeqNo)),
            StrUtil.nvl(resDate, ""), StrUtil.nvl(resTime, ""),
            StrUtil.nvl(resCode, ""), StrUtil.nvl(resMsg, ""), StrUtil.nvl(okYesNo, ""));
    }

    private static Integer parseIntOrNull(String s) {
        try { return (s == null || s.trim().isEmpty()) ? null : Integer.valueOf(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private static String cut(String s, int n) {
        if (s == null) return null;
        return s.length() <= n ? s : s.substring(0, n);
    }

    private void setError(CommonElement ce, String code, String msg) {
        ce.setResponseCode(code);
        ce.setResponseMessage(msg);
    }
}
