package kr.co.soap.kodit.loan.emtnet;

import org.w3c.dom.Document;

import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kodit.loan.Kodit_K321;

public class EmtNetK321 extends Kodit_K321 {

	private SoapCommonVO.CtHeaderVO ctheaderVO  = null;
	
	SoapCommonBean bean;
	
	public EmtNetK321(Document p_doc) {
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
		if (!"060".equals(this.ctheaderVO.STATUS)) {
			  
			super.getResCommonElement().setResponseCode("0015");
			super.getResCommonElement().setResponseMessage("인수확인을 할 수 있는 상태가 아닙니다. ORDERNO("+ getKoditXmlK311().getOrderno() + " STATUS(" + this.ctheaderVO.STATUS + ")");
			  
			return "0";
		}

		return "1";
		
	}
	
	/*
	 *
	 protected void processByK3XX() throws Exception
  {
    this.ct_header.setStatus(EnumEmtNet.STATUS_070);
    this.ct_header.setSettledate(DateUtil.getCurrentDate());

    TransactionManager tm = new TransactionManager();
    CUDManager cudManager = CUDManager.getInstance();
    tm.add(cudManager
      .updateQuery(new Ct_headerPK(this.ct_header.getCtid()), 
      this.ct_header));
    tm.excuteQuery();
  }
	 */

	protected void processByK3XX() throws Exception {
		
	    try {
	    	
	    	this.ctheaderVO.STATUS = "070";
	    	bean.RECEIVE_XML_K321_MOD_PROC(this.ctheaderVO);
	    	
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
}
