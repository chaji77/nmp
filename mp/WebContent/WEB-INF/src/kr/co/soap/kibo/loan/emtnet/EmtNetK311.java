package kr.co.soap.kibo.loan.emtnet;

import org.w3c.dom.Document;

import kr.co.mp.kakaotalk.TalkCtrl;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kibo.loan.Kibo_k311;

public class EmtNetK311 extends Kibo_k311 {
	
	private SoapCommonVO.CtHeaderVO ctheaderVO  = null;
	
	SoapCommonBean bean;

	public EmtNetK311(Document p_doc) {
		super(p_doc);
		bean = new SoapCommonBean();
	}
	
	@Override
    protected String validateCommon() throws Exception {
		
		this.ctheaderVO = bean.GET_CT_HEADER_PROC(super.getKiboXmlK311().getOrderno());
		
		if (this.ctheaderVO == null) { 
			setResponseError("9999", "주문정보가 존재하지 않습니다. ORDERNO(" + getKiboXmlK311().getOrderno());
			return "0";
		}
		if (-9999 == this.ctheaderVO.CTID) {
			setResponseError("9999", "존재하지 않는 주문번호입니다. ORDERNO(" + getKiboXmlK311().getOrderno() + ")");
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
		
		if ((!"040".equals(this.ctheaderVO.STATUS)) && 
				(!"050".equals(this.ctheaderVO.STATUS)) && 
				(!"080".equals(this.ctheaderVO.STATUS))) {
			  
			super.getResCommonElement().setResponseCode("0010");
			super.getResCommonElement().setResponseMessage("결제완료를 할 수 있는 상태가 아닙니다.");
			  
			return "0";
		}

		return "1";
		
	}
	
	protected void processByK3XX() throws Exception {
		
	    try {
	    	this.ctheaderVO.SETTLEMENTSTATUS = Integer.parseInt(getKiboXmlK311().getSettlementstatus());
	    	
	    	System.out.println("########################  kibo  ###################################");
	    	System.out.println("this.ctheaderVO.SETTLEMENTSTATUS : " + this.ctheaderVO.SETTLEMENTSTATUS);
	    	System.out.println("########################  kibo  ###################################");
	    	bean.RECEIVE_XML_K311_MOD_PROC(this.ctheaderVO);
	    	
	    	//mptax issue
	    	kr.co.mp.mptax.TaxPublish.run(this.ctheaderVO.CTID, 0);
	    	
	    	/**
	    	 * SMS 추가
	    	 */
	    	kr.co.mp.trade.CtHeaderVO headerVO = new kr.co.mp.trade.TradeBean().CT_HEADER_DETAIL_PROC(this.ctheaderVO.CTID);
	    	if ("060".equals(headerVO.STATUS)) {
	    		TalkCtrl.sendBySystem("M011", 0, this.ctheaderVO.CTID, 0);	// 판매사에게 결제완료 알림 
	    	} else if ("050".equals(headerVO.STATUS)) {
	    		if (!this.ctheaderVO.BNKCD.equalsIgnoreCase("TB")) TalkCtrl.sendBySystem("M017", 0, this.ctheaderVO.CTID, 0);	// 판매사 추심완료 후 구매사에게 카카오톡 전송 
	    	}
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
