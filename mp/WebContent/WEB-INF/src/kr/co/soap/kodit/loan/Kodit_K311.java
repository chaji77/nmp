package kr.co.soap.kodit.loan;

import org.w3c.dom.Document;

import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.K311VO;
import kr.co.soap.controll.XmlEnum;

public class Kodit_K311 extends Kodit_K3XX {
	
	private static final String RESPONSE_SCHEMA = "ResPaymentTakeOver";

    public Kodit_K311(Document p_doc) {
        super(p_doc);
        this.resTemplate = XmlEnum.getTemplatePath("K312.xml");
    }

    @Override
    protected void getK3XXBodyElement() {
    	K311VO koditXml = getKoditXmlK311();
    	
    	// 기본 정보 매핑
    	koditXml.setTradedate(getXmlValue("sb:TradeDate"));
    	koditXml.setOrderno(getXmlValue("sb:OrderNO"));
    	koditXml.setContractdate(getXmlValue("sb:ContractDate"));
    	koditXml.setSettlementstatus(getXmlValue("sb:SettlementStatus"));
    	koditXml.setSettlementduedate(getXmlValue("sb:SettlementDueDate"));
    	koditXml.setMpurl(getXmlValue("sb:MPURL"));
    	koditXml.setGuaranteeno(getXmlValue("sb:GuaranteeNO"));
    	koditXml.setTradetype(getXmlValue("sb:TradeType"));
    	koditXml.setSettlementtype(getXmlValue("sb:SettlementType"));

        // 숫자 값 매핑
    	koditXml.setScheduleseqno(parseIntField("sb:ScheduleSEQNO"));
    	koditXml.setSettlementdueamt(parseIntField("sb:SettlementDueAMT"));
    	koditXml.setSettlementamt(parseIntField("sb:SettlementAMT"));
    	koditXml.setPaymentamt(parseIntField("sb:PaymentAMT"));
    	koditXml.setRefundamt(parseIntField("sb:RefundAMT"));
    	koditXml.setBuyerfee(parseIntField("sb:BuyerFee"));
    	koditXml.setSellerfee(parseIntField("sb:SellerFee"));
        
    }

    public void executeK311() throws Exception {
        super.executeK3XX();
    }

    public String getResSchema() {
        return RESPONSE_SCHEMA;
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
