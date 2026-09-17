package kr.co.soap.kibo.loan;

import java.io.FileReader;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.XmlEnum;

public class Kibo_B315 extends Kibo_b31X {
	
	protected Kibo_B315(String p_MPCode) {
	    this.MPCode = p_MPCode;
	}
	
	protected void createB31XXML(int intCtId, String p_seqNO) throws Exception {
		FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("B315_KIBO.xml"));
		this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
		
		XMLUtil.setNodeValue(this.doc, "Sender", this.xml_b311.getSender());
		XMLUtil.setNodeValue(this.doc, "TransactionSEQNO", this.xml_b311.getTransactionSEQNO());
		XMLUtil.setNodeValue(this.doc, "Receiver", this.xml_b311.getReceiver());
		XMLUtil.setNodeValue(this.doc, "TransactionNO", this.xml_b311.getTransactionNO());
		XMLUtil.setNodeValue(this.doc, "TransactionDate", this.xml_b311.getTransactionDate());
		XMLUtil.setNodeValue(this.doc, "TransactionTime", this.xml_b311.getTransactionTime());
		XMLUtil.setNodeValue(this.doc, "ResponseCode", this.xml_b311.getResponseCode());
		XMLUtil.setNodeValue(this.doc, "UserField", this.xml_b311.getUserField());
		XMLUtil.setNodeValue(this.doc, "TradeDate", this.xml_b311.getTradeDate());
		XMLUtil.setNodeValue(this.doc, "OrderNO", this.xml_b311.getOrderNO());
		XMLUtil.setNodeValue(this.doc, "ContractDate", this.xml_b311.getContractDate());
		XMLUtil.setNodeValue(this.doc, "HandAcceptYN", this.xml_b311.getHandAcceptYN());
		
		if ((this.xml_b311.getOrgCode() != null) && (!"".equals(this.xml_b311.getOrgCode())))
	    {
			NodeList nl = this.doc.getElementsByTagName("IndivPart");
			Element o = this.doc.createElement("OrgCode");
			nl.item(0).appendChild(o);
			XMLUtil.setNodeValue(this.doc, "OrgCode", this.xml_b311.getOrgCode());
	    }
	}
}
