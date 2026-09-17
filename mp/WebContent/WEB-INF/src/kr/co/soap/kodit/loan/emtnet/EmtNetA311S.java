package kr.co.soap.kodit.loan.emtnet;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.EnumData;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kodit.loan.Kodit_A311S;

public class EmtNetA311S extends Kodit_A311S {

    private SoapCommonVO.CompanyVO      cpyBuyer    = null;
    private SoapCommonVO.BankVO         bank        = null;
    private SoapCommonVO.BankProductsVO bankProduct = null;

    private String bankCode;
    private int    payId;
    private int    companyId;
    private double settlementDueAmount = 0.0;

    // ★ A311S 추가 파라미터
    private String sellerBizNo;   // 판매기업 사업자번호
    private String sellerCorpNo;  // 판매기업 법인번호

    SoapCommonBean bean;

    public EmtNetA311S(int companyId, String bankCode, int payId,
                       double settlementDueAmount,
                       String sellerBizNo, String sellerCorpNo) {
        super("");
        this.companyId           = companyId;
        this.bankCode            = bankCode;
        this.payId               = payId;
        this.settlementDueAmount = settlementDueAmount;
        this.sellerBizNo         = sellerBizNo;
        this.sellerCorpNo        = sellerCorpNo;
        this.bean                = new SoapCommonBean();
    }

    @Override
    protected CommonElement makeA311SVO() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");

        if (!loadCompanyInfo(commonElement))     return commonElement;
        if (!loadBankInfo(commonElement))        return commonElement;
        if (!loadBankProductInfo(commonElement)) return commonElement;

        setCommonElementData();
        setBodyElementData();

        return commonElement;
    }

    private boolean loadCompanyInfo(CommonElement commonElement) throws Exception {
        this.cpyBuyer = bean.GET_COMPANY_INFO_PROC(this.companyId);
        if (this.cpyBuyer.CPY_ID == EnumData.longNull) {
            setError(commonElement, "0081", "구매기업정보를 읽을 수 없습니다.");
            return false;
        }
        super.MPCode = this.cpyBuyer.MP_CODE;
        return true;
    }

    private boolean loadBankInfo(CommonElement commonElement) throws Exception {
        this.bank = bean.GET_BANK_INFO_PROC(this.bankCode);
        if (this.bank.BNK_CD == null) {
            setError(commonElement, "0083", "은행정보를 읽을 수 없습니다.");
            return false;
        }
        return true;
    }

    private boolean loadBankProductInfo(CommonElement commonElement) throws Exception {
        this.bankProduct = bean.GET_BANK_PRODUCTS_INFO_PROC(
                super.MPCode, this.bankCode, this.payId, 2);
        if (this.bankProduct.BNK_CD == null) {
            setError(commonElement, "0091", "은행 대출상품정보를 읽을 수 없습니다.");
            return false;
        }
        if ("N".equals(this.bankProduct.LIMITYN)) {
            setError(commonElement, "0093",
                    this.bank.BNK_CD + "은 한도조회를 지원하지 않습니다.");
            return false;
        }
        return true;
    }

    private void setCommonElementData()
            throws SequenceGenerator.SequenceGenerationException {
        super.kodit_A311VO.getCommonElement().setSender(this.MPCode);
        super.kodit_A311VO.getCommonElement().setTransactionSEQNO(
                SequenceGenerator.getInstance().getTransSeqNO());
        super.kodit_A311VO.getCommonElement().setReceiver(this.bank.BNK_NO);
        super.kodit_A311VO.getCommonElement().setTransactionDate(
                DateTimeUtil.getCurrentDate(""));
        super.kodit_A311VO.getCommonElement().setTransactionTime(
                DateTimeUtil.getCurrentDateTime().substring(8, 14));
        super.kodit_A311VO.getCommonElement().setUserField(this.bankProduct.USERFIELD);
    }

    private void setBodyElementData() {
        // 구매기업 ID (법인번호 우선, 없으면 대표자번호)
        String buyerID = StrUtil.isEmpty(this.cpyBuyer.CPY_INCORPORATE_NO)
                ? this.cpyBuyer.CPY_CEO_NO
                : this.cpyBuyer.CPY_INCORPORATE_NO;
        System.out.println("A311S buyerID : " + buyerID);

        super.kodit_A311VO.setBuyerID(buyerID);
        super.kodit_A311VO.setBuyerBusinessNO(this.cpyBuyer.CPY_BUSINESS_NO);
        super.kodit_A311VO.setSettlementType(
                String.valueOf(this.bankProduct.SETTLEMENTTYPE));
        super.kodit_A311VO.setSettlementDueAMT(getSettlementDueAmount());

        // ★ 판매기업 ID (법인번호 우선, 없으면 사업자번호)
        String sellerID = StrUtil.isEmpty(this.sellerCorpNo)
                ? this.sellerBizNo
                : this.sellerCorpNo;
        System.out.println("A311S sellerID : " + sellerID);

        super.kodit_A311VO.setSellerID(sellerID);
        super.kodit_A311VO.setSellerBusinessNO(this.sellerBizNo);
    }

    private String getSettlementDueAmount() {
        if (("UR".equals(this.bankCode) || "SH".equals(this.bankCode)
                || "SC".equals(this.bankCode)) && this.settlementDueAmount == 0.0) {
            return "100";
        }
        return String.valueOf((long) this.settlementDueAmount);
    }

    private void setError(CommonElement ce, String code, String msg) {
        ce.setResponseCode(code);
        ce.setResponseMessage(msg);
    }
}