package kr.co.soap.kodit.loan;

import java.io.FileReader;

import org.xml.sax.InputSource;

import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.XmlEnum;

public class Kodit_B315 extends Kodit_B31X {
	
	protected Kodit_B315(String p_MPCode) {
	    this.MPCode = p_MPCode;
	}

	protected void createB31XXML(int intCtId, String p_seqNO) throws Exception {
		FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("B315.xml"));
		this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
		
		XMLUtil.setNodeValue(this.doc, "sb:Sender", this.xml_b311.getSender());
		XMLUtil.setNodeValue(this.doc, "sb:TransactionSEQNO", this.xml_b311.getTransactionSEQNO());
		XMLUtil.setNodeValue(this.doc, "sb:Receiver", this.xml_b311.getReceiver());
		
		XMLUtil.setNodeValue(this.doc, "sb:TransactionDate", this.xml_b311.getTransactionDate());
		XMLUtil.setNodeValue(this.doc, "sb:TransactionTime", this.xml_b311.getTransactionTime());
		XMLUtil.setNodeValue(this.doc, "sb:ResponseCode", this.xml_b311.getResponseCode());
		XMLUtil.setNodeValue(this.doc, "sb:UserField", this.xml_b311.getUserField());
		XMLUtil.setNodeValue(this.doc, "sb:TradeDate", this.xml_b311.getTradeDate());
		XMLUtil.setNodeValue(this.doc, "sb:OrderNO", this.xml_b311.getOrderNO());
		XMLUtil.setNodeValue(this.doc, "sb:ContractDate", this.xml_b311.getContractDate());
		XMLUtil.setNodeValue(this.doc, "sb:HandAcceptYN", this.xml_b311.getHandAcceptYN());
	}
	
}
