package kr.co.soap.kodit.loan.emtnet;

import org.w3c.dom.Document;

import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kodit.loan.Kodit_K315;

public class EmtNetK315 extends Kodit_K315 {

	private SoapCommonVO.CtHeaderVO ctheaderVO  = null;
	
	SoapCommonBean bean;
	
	public EmtNetK315(Document p_doc) {
		super(p_doc);
		bean = new SoapCommonBean();
	}
	
	@Override
    protected String validateCommon() throws Exception {
		
		this.ctheaderVO = bean.GET_CT_HEADER_PROC(super.getKoditXmlK311().getOrderno());
		
		if (this.ctheaderVO == null) { 
			setResponseError("9999", "주문정보가 존재하지 않습니다. ORDERNO(" + getKoditXmlK311().getOrderno());
			return "0";
		}
		if (-9999 == this.ctheaderVO.CTID) {
			setResponseError("9999", "존재하지 않는 주문번호입니다. ORDERNO(" + getKoditXmlK311().getOrderno() + ")");
			return "0";
		}
		
		/**
		 * 
		 * 필요한 유효성 체크 추가
		 * 
		 */
		
        return "1";
	}
	
	protected String validateByK3XX() throws Exception {
		if ((!"060".equals(this.ctheaderVO.STATUS)) && 
				(!"050".equals(this.ctheaderVO.STATUS)) && 
				(!"080".equals(this.ctheaderVO.STATUS))) {
			  
			super.getResCommonElement().setResponseCode("0011");
			super.getResCommonElement().setResponseMessage("결제취소를 할 수 있는 상태가 아닙니다.");
			  
			return "0";
		}

		return "1";
		
	}
	
	protected void processByK3XX() throws Exception {
		
	    try {
	    	
	    	this.ctheaderVO.SETTLEMENTSTATUS = Integer.parseInt(getKoditXmlK311().getSettlementstatus());
	    	bean.RECEIVE_XML_K315_MOD_PROC(this.ctheaderVO);
	    	
	    	/**
	    	 * SMS 추가
	    	 */
	    }
	    catch (Exception e)
	    {
	      System.out.println("상태업데이트오류");
	      System.out.println(e.toString());
	    }
	}
	
	
	private void setResponseError(String code, String message) {
		  super.getResCommonElement().setResponseCode(code);
		  super.getResCommonElement().setResponseMessage(message);
	  }

	  public static void main(String[] args) {}
}
