package kr.co.soap.kibo.loan;

import org.w3c.dom.Document;

import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.K311VO;

public class Kibo_K321 extends Kibo_K3XX {
	
	public Kibo_K321(Document p_doc) {
        super(p_doc);
    }
	
	@Override
    protected void getK3XXBodyElement() {
    	K311VO koditXml = getKiboXmlK311();
    	
    	// 기본 정보 매핑
    	koditXml.setTradedate(getXmlValue("TradeDate"));
    	koditXml.setOrderno(getXmlValue("OrderNO"));
    	koditXml.setContractdate(getXmlValue("ContractDate"));
    	koditXml.setTradetype(getXmlValue("TradeType"));
    	koditXml.setSettlementtype(getXmlValue("SettlementType"));
    	koditXml.setSettlementduedate(getXmlValue("SettlementDueDate"));
    	koditXml.setTradedate(getXmlValue("PaymentDueDate"));
    	koditXml.setTradedate(getXmlValue("PaymentDate"));
    	koditXml.setMpurl(getXmlValue("MPURL"));
    	koditXml.setGuaranteeno(getXmlValue("GuaranteeNO"));

        // 숫자 값 매핑
    	koditXml.setScheduleseqno(parseIntField("ScheduleSEQNO"));
    	koditXml.setSettlementdueamt(parseIntField("setSettlementDueAMT"));
    	koditXml.setSettlementamt(parseIntField("SettlementAMT"));
    	koditXml.setPaymentamt(parseIntField("PaymentAMT"));
    	koditXml.setRefundamt(parseIntField("RefundAMT"));
    	koditXml.setBuyerfee(parseIntField("BuyerFee"));
    	koditXml.setSellerfee(parseIntField("SellerFee"));
        
    }

    public void executeK321() throws Exception {
        super.executeK3XX();
    }
    
    // XML 값 가져오는 유틸 메서드
    private String getXmlValue(String tagName) {
        return XMLUtil.getNodeValueOption(getDoc(), tagName);
    }

    private int parseIntField(String tagName) {
        String value = getXmlValue(tagName);
        return (value != null && !value.isEmpty()) ? Integer.parseInt(value) : 0;
    }

    private double parseDoubleField(String tagName) {
        String value = getXmlValue(tagName);
        return (value != null && !value.isEmpty()) ? Double.parseDouble(value) : 0.0;
    }
    
    @Override
	protected void processByK3XX() throws Exception {}
	
}
