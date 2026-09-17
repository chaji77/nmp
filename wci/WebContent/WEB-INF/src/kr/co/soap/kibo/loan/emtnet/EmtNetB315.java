package kr.co.soap.kibo.loan.emtnet;

import java.text.ParseException;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.kibo.loan.Kibo_B315;

public class EmtNetB315 extends Kibo_B315 {
	
	private SoapCommonVO.XmlB311VO xmlB311VO  = null;
	private SoapCommonVO.SendXmlB311VO sendXmlB311VO = null;
	
	SoapCommonBean bean;
	
	public EmtNetB315() {
		super("");
        super.kind = "R";
        this.bean = new SoapCommonBean(); // 생성자에서 한 번만 초기화
	}
	
	public CommonElement executeB315(int intCtId) {
		return super.executeB31X(intCtId);
	}
	
	@Override
    protected CommonElement readSyncTableData(int intCtId) throws Exception
    {
    	
         CommonElement commonElement = new CommonElement();
         commonElement.setResponseCode("0000");
         
         //basic main data set.
         this.xmlB311VO = bean.GET_XML_B311_PROC(intCtId);
         
         // MPCode를 이 시점에 세팅.
         super.MPCode  = this.xmlB311VO.MP_CODE; 
         super.strUser = this.xmlB311VO.PRS_LOGIN;

         // 매매계약 정보 읽기, 주문 품목 정보 읽기, 구매기업 정보 읽기, 판매기업 정보 읽기, 은행 정보 읽기, 은행 대출 상품 정보 읽기
         if (this.xmlB311VO == null) 
        	 return setErrorResponse(commonElement, "0090", "매매계약정보를 읽을 수 없습니다.");
         if (null == this.xmlB311VO.BNK_CD) 
        	 return setErrorResponse(commonElement, "0082", "은행정보를 읽을 수 없습니다.");
         if (null == this.xmlB311VO.TAXISSUEYN) 
        	 return setErrorResponse(commonElement, "0091", "은행 대출상품정보를 읽을 수 없습니다.");

        return commonElement;
    }
	
	protected CommonElement validateProcess() throws Exception {
    	CommonElement commonElement = new CommonElement();
    	commonElement.setResponseCode("0000");
    	return commonElement;
    }
	
	protected void makeB31X(int intCtId, String p_user) throws Exception {
		
		LoanUtil loanUtil = new LoanUtil();
		
		this.xml_b311.setSender(this.MPCode);
		this.xml_b311.setTransactionSEQNO(SequenceGenerator.getInstance().getTransSeqNO());
		this.xml_b311.setReceiver(this.xmlB311VO.BNK_NO);
		this.xml_b311.setTransactionNO("B315");
		this.xml_b311.setTransactionDate(DateTimeUtil.getCurrentDate(""));
		this.xml_b311.setTransactionTime(DateTimeUtil.getCurrentDateTime().substring(8, 14));
		this.xml_b311.setResponseCode("0000");
		this.xml_b311.setResponseMessage(null);
		this.xml_b311.setUserField(StrUtil.isEmpty(this.xmlB311VO.USERFIELD) ? "" : this.xmlB311VO.USERFIELD);
		
		this.xml_b311.setSeqNO(loanUtil.getSeqNO_Kodit_xml_b311(this.xmlB311VO.CTNO));
		this.xml_b311.setTradeDate(this.xmlB311VO.TRADEDATE);
		this.xml_b311.setOrderNO(this.xmlB311VO.CTNO);
		this.xml_b311.setContractDate(this.xmlB311VO.CONTRACTDATE);
		this.xml_b311.setHandAcceptYN(this.xmlB311VO.HANDACCEPTYN); //수기접수여부(1.XML 2.수기)
		
		if (this.xmlB311VO.PAY_ID > 100)
	    {
			this.xml_b311.setOrgCode(XmlEnum.getOrgCode(this.xmlB311VO.PAY_ID));
	    }
	    	else this.xml_b311.setOrgCode("");
		
		this.xml_b311.setFund("KIBO"); // 기보
		this.xml_b311.setCtId(intCtId);
	}
	
	protected void updateDBWithResponse(CommonElement p_commonElement) throws Exception {
		sendXmlB311VO = new SoapCommonVO().new SendXmlB311VO();
    	sendXmlB311VO.CTID = this.xml_b311.getCtId();
    	sendXmlB311VO.STATUS = "080";
    	sendXmlB311VO.SEQNO = this.xml_b311.getSeqNO();
    	sendXmlB311VO.FUND = this.xml_b311.getFund();
    	sendXmlB311VO.RESRESPONSECODE = p_commonElement.getResponseCode();
    	sendXmlB311VO.RESRESPONSEMSG = p_commonElement.getResponseMessage();
    	sendXmlB311VO.CANUSER	= "B315 Cancel";
    	sendXmlB311VO.CANTIME	= DateTimeUtil.getCurrentDateTime();
    	
    	bean.SEND_XML_B315_MOD_PROC(sendXmlB311VO);
    	
	    /**
	     * 하단에 sms 사용하면 넣어야함.
	     * 하단에 sms 사용하면 넣어야함.
	     * 하단에 sms 사용하면 넣어야함.
	     * 하단에 sms 사용하면 넣어야함.
	     * 하단에 sms 사용하면 넣어야함.
	     * 
	    if (p_commonElement.getResponseCode().equals("0000"))
	    {
	      String sms_msg = CurrencyUtil.getCurrency(this.header.getTotalcontractamt()) + "원 계약이 취소되었습니다. T:1688-7400";

	      SendSMS.goSMS(this.header.getCpybuyer(), this.header.getCpyseller(), "<ACTION_CPY_NAME>" + sms_msg);
	      SendSMS.goSMS(this.header.getCpyseller(), this.header.getCpybuyer(), "<ACTION_CPY_NAME>" + sms_msg);
	    }
	    */
	}
	
	private CommonElement setErrorResponse(CommonElement commonElement, String responseCode, String responseMessage) {
		commonElement.setResponseCode(responseCode);
		commonElement.setResponseMessage(responseMessage);
		return commonElement;
    }
	
	public static void main(String[] agrs) throws ParseException {
    	
    	try
        {
    		EmtNetB315 b315 = new EmtNetB315();
    		CommonElement commonElement = b315.executeB315(2024035);
    		System.out.println(commonElement.getResponseCode() + ":" + commonElement.getResponseMessage());
        }
        catch (Exception ex)
        {
          ex.printStackTrace();
        }
    	/*
    	System.out.println(DateTimeUtil.getCurrentDate(""));
    	
    	System.out.println(DateTimeUtil.diff(DateTimeUtil.getCurrentDate(""), 30));
    	System.out.println(DateTimeUtil.diff(DateTimeUtil.getCurrentDate(""), -30));
    	System.out.println("1111".length());
    	System.out.println(StrUtil.isEmpty(""));
    	System.out.println(DateTimeUtil.getCurrentDateTime());
    	*/
    }
}

