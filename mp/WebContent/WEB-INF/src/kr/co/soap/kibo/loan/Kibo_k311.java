package kr.co.soap.kibo.loan;

import org.w3c.dom.Document;

import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.K311VO;
import kr.co.soap.controll.XmlEnum;

public class Kibo_k311 extends Kibo_K3XX {
	
	public Kibo_k311(Document p_doc) {
        super(p_doc);
    }

	@Override
    protected void getK3XXBodyElement() {
    	K311VO kiboXml = getKiboXmlK311();
    	
    	// 기본 정보 매핑
    	kiboXml.setTradedate(getXmlValue("TradeDate"));
    	kiboXml.setOrderno(getXmlValue("OrderNO"));
    	kiboXml.setContractdate(getXmlValue("ContractDate"));
    	kiboXml.setSettlementstatus(getXmlValue("SettlementStatus"));
    	kiboXml.setSettlementduedate(getXmlValue("SettlementDueDate"));
    	kiboXml.setMpurl(getXmlValue("MPURL"));
    	kiboXml.setGuaranteeno(getXmlValue("GuaranteeNO"));
    	kiboXml.setTradetype(getXmlValue("TradeType"));
    	kiboXml.setSettlementtype(getXmlValue("SettlementType"));

        // 숫자 값 매핑
    	kiboXml.setScheduleseqno(parseIntField("ScheduleSEQNO"));
    	kiboXml.setSettlementdueamt(parseIntField("SettlementDueAMT"));
    	kiboXml.setSettlementamt(parseIntField("SettlementAMT"));
    	kiboXml.setPaymentamt(parseIntField("PaymentAMT"));
    	kiboXml.setRefundamt(parseIntField("RefundAMT"));
    	kiboXml.setBuyerfee(parseIntField("BuyerFee"));
    	kiboXml.setSellerfee(parseIntField("SellerFee"));
        
    }
	
	public void executeK311() throws Exception {
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

    public static void main(String[] args) {
        // Entry point for debugging if necessary
    }
	
}
