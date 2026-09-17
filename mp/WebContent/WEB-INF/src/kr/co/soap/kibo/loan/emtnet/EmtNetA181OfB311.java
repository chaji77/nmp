package kr.co.soap.kibo.loan.emtnet;

import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.kibo.loan.Kibo_A181_Send;

public class EmtNetA181OfB311 extends Kibo_A181_Send {
	
	private SoapCommonVO.ReadXmlA181VO readXmlA181VO;
	private SoapCommonVO.SendXmlB311VO sendXmlB311VO;
	
	private final SoapCommonBean bean;
	
	public EmtNetA181OfB311(int p_intCtId, String p_strSeqNo) {
		
		super.intCtId = p_intCtId;
		super.strSeqNo = p_strSeqNo;
		
		this.bean = new SoapCommonBean(); // 생성자에서 한 번만 초기화
		
		try {
			
	        // 기본 데이터 세팅
	        this.readXmlA181VO = bean.GET_XML_A181_PROC(p_intCtId, p_strSeqNo); // ct_header외 관련 테이블
	        // MPCode를 이 시점에 세팅
	        super.MPCode = this.readXmlA181VO.MP_CODE;
	        
	    } catch (Exception e) {
	        System.err.println("오류 발생: " + e.getMessage());
	        e.printStackTrace(); // 로그로 출력
	        // readXmlA181VO를 기본값으로 초기화하여 오류 상황에 대비
	        this.readXmlA181VO.MP_CODE = "ERROR"; // 기본값 설정
	    }
		
	}
	
	public CommonElement executeA181OfB311() throws Exception {
        CommonElement commonElement = super.executeA181();
        saveToDatabase();
        return commonElement;
    }
	
	protected CommonElement readData() throws Exception {
		
	    CommonElement commonElement = new CommonElement();
	    commonElement.setResponseCode("0000");
	    
	    this.receiver = this.readXmlA181VO.RECEIVER;
	    this.TransactionSEQNO = this.readXmlA181VO.TRANSACTIONSEQNO; //this.strSeqNo
	    this.TransactionNO    = this.readXmlA181VO.TRANSACTIONNO;
	    this.TransactionDate  = this.readXmlA181VO.TRANSACTIONDATE;
	    this.TransactionTime  = this.readXmlA181VO.TRANSACTIONTIME;
	    this.UserField		  = this.readXmlA181VO.USERFIELD;

	    return commonElement;
	}
	
	private void saveToDatabase() throws Exception {
		
		if ((getTransactionResultCode() != null) && (getTransactionResultCode().equals("0000"))) {
			this.receiver = this.readXmlA181VO.RECEIVER;
		    this.TransactionSEQNO = super.TransactionSEQNO;
		    this.TransactionNO    = super.TransactionNO;
		    this.TransactionDate  = super.TransactionDate;
		    this.TransactionTime  = super.TransactionTime;
		    this.UserField		  = super.UserField;
		    
			sendXmlB311VO = new SoapCommonVO().new SendXmlB311VO();
	    	sendXmlB311VO.CTID = this.intCtId;
	    	sendXmlB311VO.STATUS = super.getTransactionResultCode().equals("0000") ? "040" : "030";
	    	sendXmlB311VO.SEQNO = super.TransactionSEQNO;
	    	sendXmlB311VO.FUND = "KIBO";	
	    	sendXmlB311VO.RESRESPONSECODE = super.getTransactionResultCode();
	    	sendXmlB311VO.RESRESPONSEMSG = super.getTransactionResultMessage();
	    	
	    	sendXmlB311VO.CONTRACTDATE = "";
	    	sendXmlB311VO.TRADEDATE = "";
	    	sendXmlB311VO.SETTLEDUEDATE = "";
	    	
	    	sendXmlB311VO.TRANSACTIONNO = super.TransactionNO;
	    	
	    	bean.SEND_XML_B311_MOD_PROC(sendXmlB311VO);
		}
	}
	
	public static void main(String[] agrs) {
		try {
		EmtNetA181OfB311 A181OfB311 = new EmtNetA181OfB311(2024410, "00026");
		CommonElement commonElement = A181OfB311.executeA181OfB311();
		System.out.println(commonElement.getResponseCode() + " == ResultCode :[" + A181OfB311.getTransactionResultCode() + 
	        "] ResultMessage : [" + A181OfB311.getTransactionResultCode() + "]");
	    } catch (Exception ex) {
	      ex.printStackTrace();
	    }
	}
}
