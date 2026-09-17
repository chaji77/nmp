package kr.co.soap.kibo.loan.emtnet;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.A312VO;
import kr.co.soap.controll.EnumData;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SequenceGenerator.SequenceGenerationException;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.kibo.loan.Kibo_A311;

public class EmtNetA311 extends Kibo_A311 {
	
	private SoapCommonVO.CompanyVO cpyBuyer = null;
    private SoapCommonVO.BankVO bank 		= null;
    private SoapCommonVO.BankProductsVO bankProduct  = null;
	
    private String bankCode;
    private String settlementType;
    private int payId;
    private int companyId;
    private double settlementDueAmount = 0.0;
    
    SoapCommonBean bean;
    
    public EmtNetA311(int companyId, String bankCode, int payId, double settlementDueAmount) {
        super("");
        this.companyId = companyId;
        this.bankCode = bankCode;
        this.payId = payId;
        this.settlementDueAmount = settlementDueAmount;
        this.bean = new SoapCommonBean(); // 생성자에서 한 번만 초기화
    }
    
    @Override
    protected CommonElement makeA311VO() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");

        if (!loadCompanyInfo(commonElement)) return commonElement;
        if (!loadBankInfo(commonElement)) return commonElement;
        if (!loadBankProductInfo(commonElement)) return commonElement;

        setCommonElementData();
        setBodyElementData();

        return commonElement;
    }
    
    private boolean loadCompanyInfo(CommonElement commonElement) throws Exception {
    	
    	//company 읽기
    	this.cpyBuyer = bean.GET_COMPANY_INFO_PROC(this.companyId);
    	
        if (this.cpyBuyer.CPY_ID == EnumData.longNull) {
            setErrorResponse(commonElement, "0081", "구매기업정보를 읽을 수 없습니다.");
            return false;
        }
        
        // MPCode를 이 시점에 세팅
        super.MPCode = this.cpyBuyer.MP_CODE; // loadCompanyInfo에서 MPCode 세팅
        
        return true;
    }

    private boolean loadBankInfo(CommonElement commonElement) throws Exception {
    	//bank 읽기
    	this.bank = bean.GET_BANK_INFO_PROC(this.bankCode);
    	
        if (this.bank.BNK_CD == null) {
            setErrorResponse(commonElement, "0083", "은행정보를 읽을 수 없습니다.");
            return false;
        }
        
        return true;
    }

    private boolean loadBankProductInfo(CommonElement commonElement) throws Exception {
    	//bankProduct 읽기
    	this.bankProduct = bean.GET_BANK_PRODUCTS_INFO_PROC(super.MPCode, this.bankCode, this.payId, 2);
    	
        if (this.bankProduct.BNK_CD == null) {
            setErrorResponse(commonElement, "0091", "은행 대출상품정보를 읽을 수 없습니다.");
            return false;
        }
    	 
        if ("N".equals(this.bankProduct.LIMITYN)) {
            setErrorResponse(commonElement, "0093", this.bank.BNK_CD + "은 한도조회를 지원하지 않습니다.");
            return false;
        }
        return true;
    }

    private void setCommonElementData() throws SequenceGenerationException {
        super.kibo_A311VO.getCommonElement().setSender(this.MPCode);
        super.kibo_A311VO.getCommonElement().setTransactionSEQNO(SequenceGenerator.getInstance().getTransSeqNO());
        super.kibo_A311VO.getCommonElement().setReceiver(this.bank.BNK_NO);
        super.kibo_A311VO.getCommonElement().setTransactionDate(DateTimeUtil.getCurrentDate(""));
        super.kibo_A311VO.getCommonElement().setTransactionTime(DateTimeUtil.getCurrentDateTime().substring(8, 14));
        super.kibo_A311VO.getCommonElement().setUserField(this.bankProduct.USERFIELD);
    }

    private void setBodyElementData() {
        
    	String buyerID = StrUtil.isEmpty(this.cpyBuyer.CPY_INCORPORATE_NO)
                ? this.cpyBuyer.CPY_CEO_NO
                : this.cpyBuyer.CPY_INCORPORATE_NO;

    	System.out.println("buyerID : " + buyerID);
    	
        super.kibo_A311VO.setBuyerID(buyerID);
        super.kibo_A311VO.setBuyerBusinessNO(this.cpyBuyer.CPY_BUSINESS_NO);
        super.kibo_A311VO.setSettlementType(String.valueOf(this.bankProduct.SETTLEMENTTYPE));
        super.kibo_A311VO.setSettlementDueAMT(getSettlementDueAmount());
        if(this.payId > 100) super.kibo_A311VO.setOrgCode(XmlEnum.getOrgCode(this.payId));
        super.kibo_A311VO.setPayId(Integer.toString(this.payId));
    }

    private String getSettlementDueAmount() {
        if (("UR".equals(this.bankCode) || "SH".equals(this.bankCode) || "SC".equals(this.bankCode)) &&
                this.settlementDueAmount == 0.0) {
            return "100";
        }
        return String.valueOf((double) this.settlementDueAmount);
    }

    private void setErrorResponse(CommonElement commonElement, String responseCode, String responseMessage) {
        commonElement.setResponseCode(responseCode);
        commonElement.setResponseMessage(responseMessage);
    }

    public static void main(String[] args) {
        //EmtNetA311 kibo_A311 = new EmtNetA311(11229, "SB", 14, 0.0);
    	EmtNetA311 kibo_A311 = new EmtNetA311(122309, "SB", 14, 0.0);
    	A312VO kibo_A312VO = kibo_A311.executeA311();

        System.out.println("\nResponse Code: " + kibo_A312VO.getCommonElement().getResponseCode());
        System.out.println("Response Message: " + kibo_A312VO.getCommonElement().getResponseMessage());
        System.out.println("Buyer ID: " + kibo_A312VO.getBuyerID());
    }
}
