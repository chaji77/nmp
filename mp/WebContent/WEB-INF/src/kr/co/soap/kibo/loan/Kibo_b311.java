package kr.co.soap.kibo.loan;

import java.io.FileReader;
import java.util.ArrayList;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.B311VO;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;

public class Kibo_b311 extends Kibo_b31X {
	
	protected String taxIssueYN = "Y";
    protected String paymentApprovalTypeYN = "Y";
    protected String expirationDateYN = "Y";
    protected String paymentDueDateYN = "Y";
	
    protected Kibo_b311(String p_MPCode) {
        super.MPCode = p_MPCode;
    }
    
    protected void createB31XXML(int intCtId, String p_seqNO) throws Exception {
    	
        SoapCommonVO xmlItemVO = new SoapCommonBean().GET_XML_B311_ITEM_PROC(intCtId);

        String templatePath = this.getTemplate(xml_b311);
        this.createB31X_makeXML(xmlItemVO.allItems.size(), templatePath);
        this.createB31X_setValue(xml_b311, xmlItemVO.allItems);
        
    }
    
    protected void createB31X_makeXML(int p_itemCount, String strTemplate) throws Exception {
        try (FileReader fileReader = new FileReader(strTemplate)) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
            this.doc = this.makeDocument(this.doc);

            NodeList nl = this.doc.getElementsByTagName("IndivPart");
            Element orderInfoList = this.doc.createElement("OrderInfoList");
            Attr attrOrderCount = this.doc.createAttribute("OrderCount");
            orderInfoList.setAttributeNode(attrOrderCount);
            orderInfoList.setAttribute("OrderCount", String.valueOf(p_itemCount));
            nl.item(0).appendChild(orderInfoList);
            
            for (int i = 0; i < p_itemCount; i++) {
                Element orderInfo = this.doc.createElement("OrderInfo");
                orderInfoList.appendChild(orderInfo);

                String[] elements = {"OrderSEQNO", "Item", "Size", "Quantity", "QuantityUnit", 
                                      "UnitPrice", "SupplyAMT", "TaxAMT", "TotalAMT"};
                for (String elementName : elements) {
                    Element el = this.doc.createElement(elementName);
                    orderInfo.appendChild(el);
                }
            }
            
            Element el2 = this.doc.createElement("EscrowVirtualAccount");
            nl.item(0).appendChild(el2);
            el2 = this.doc.createElement("GeneralVirtualAccount");
            nl.item(0).appendChild(el2);
            el2 = this.doc.createElement("Information");
            nl.item(0).appendChild(el2);
            
            if ((this.xml_b311.getOrgCode() != null) && (!"".equals(this.xml_b311.getOrgCode())))
            {
              el2 = this.doc.createElement("OrgCode");
              nl.item(0).appendChild(el2);
            }
        }
    }
    
    protected void createB31X_setValue(B311VO p_b311, ArrayList<SoapCommonVO.XmlB311ItemVO> p_b311_ItemList) throws Exception {
        XMLUtil.setNodeValue(this.doc, "Sender", p_b311.getSender());
        XMLUtil.setNodeValue(this.doc, "TransactionSEQNO", p_b311.getTransactionSEQNO());
        XMLUtil.setNodeValue(this.doc, "Receiver", p_b311.getReceiver());
        XMLUtil.setNodeValue(this.doc, "TransactionNO", p_b311.getTransactionNO());
        XMLUtil.setNodeValue(this.doc, "TransactionDate", p_b311.getTransactionDate());
        XMLUtil.setNodeValue(this.doc, "TransactionTime", p_b311.getTransactionTime());
        XMLUtil.setNodeValue(this.doc, "ResponseCode", p_b311.getResponseCode());
        XMLUtil.setNodeValue(this.doc, "UserField", p_b311.getUserField());
        
        XMLUtil.setNodeValue(this.doc, "TradeDate", p_b311.getTradeDate());
        XMLUtil.setNodeValue(this.doc, "OrderNO", p_b311.getOrderNO());
        XMLUtil.setNodeValue(this.doc, "ContractDate", p_b311.getContractDate());
        XMLUtil.setNodeValue(this.doc, "HandAcceptYN", p_b311.getHandAcceptYN());
        XMLUtil.setNodeValue(this.doc, "ContractType", p_b311.getContractType());
        
        setBusinessNumbers(p_b311);
        
        XMLUtil.setNodeValue(this.doc, "TotalContractAMT", p_b311.getTotalContractAMT());
        XMLUtil.setNodeValue(this.doc, "BuyerFee", p_b311.getBuyerFee());
        XMLUtil.setNodeValue(this.doc, "SellerFee", p_b311.getSellerFee());
        XMLUtil.setNodeValue(this.doc, "FeeType", p_b311.getFeeType());
        XMLUtil.setNodeValue(this.doc, "SellerName", p_b311.getSellerName());
        
        if (this.paymentApprovalTypeYN.equals("Y")) XMLUtil.setNodeValue(this.doc, "PaymentApprovalType", p_b311.getPaymentApprovalType());
        
        if (this.taxIssueYN.equals("Y")) {
        	XMLUtil.setNodeValue(this.doc, "TaxApprovalNO", p_b311.getTaxApprovalNO());
        	XMLUtil.setNodeValue(this.doc, "TaxBillDate", p_b311.getTaxBillDate());
        	XMLUtil.setNodeValue(this.doc, "TaxBillAMT", p_b311.getTaxBillAMT());
        	XMLUtil.setNodeValue(this.doc, "TaxBillNO", p_b311.getTaxBillNO());
        	XMLUtil.setNodeValue(this.doc, "TaxBillSupplyAMT", p_b311.getTaxBillSupplyAMT());
        	XMLUtil.setNodeValue(this.doc, "MainItem", p_b311.getMainItem());
        }
        
        XMLUtil.setNodeValue(this.doc, "ScheduleSEQNO", String.valueOf(p_b311.getScheduleSEQNO()));
        XMLUtil.setNodeValue(this.doc, "TradeType", p_b311.getTradeType());
        XMLUtil.setNodeValue(this.doc, "SettlementType", p_b311.getSettlementType());
        XMLUtil.setNodeValue(this.doc, "SettlementDueAMT", String.valueOf(StrUtil.nvl(p_b311.getTotalContractAMT(), "0")));
        XMLUtil.setNodeValue(this.doc, "RefundAMT", String.valueOf(p_b311.getRefundAMT()));

        XMLUtil.setNodeValue(this.doc, "SettlementDueDate", p_b311.getSettlementDueDate());
        XMLUtil.setNodeValue(this.doc, "SettlementDueTime", p_b311.getSettlementDueTime());

        if (this.paymentDueDateYN.equals("Y")) 
        	XMLUtil.setNodeValue(this.doc, "PaymentDueDate", p_b311.getPaymentDueDate());
        if (this.expirationDateYN.equals("Y")) 
        	XMLUtil.setNodeValue(this.doc, "ExpirationDate", p_b311.getExpirationDate());

        for (int i = 0; i < p_b311_ItemList.size(); i++) {
        	
        	SoapCommonVO.XmlB311ItemVO xml_b311_item = p_b311_ItemList.get(i);
        	
        	XMLUtil.setNodeValue(this.doc, "OrderSEQNO", String.valueOf(i+1), i);	//orderseq ct_item에 없어서 순번 넣음
            XMLUtil.setNodeValue(this.doc, "Item", xml_b311_item.ITEMNAME, i);
            XMLUtil.setNodeValue(this.doc, "Size", StrUtil.nvl(xml_b311_item.SIZE, "-"), i);
            XMLUtil.setNodeValue(this.doc, "Quantity", String.format("%.0f", xml_b311_item.QTY), i);
            XMLUtil.setNodeValue(this.doc, "QuantityUnit", xml_b311_item.UNIT, i);
            XMLUtil.setNodeValue(this.doc, "UnitPrice", String.format("%.0f", xml_b311_item.UNITPRICE), i);
            XMLUtil.setNodeValue(this.doc, "SupplyAMT", String.valueOf(xml_b311_item.SUPPLYAMT), i);
            XMLUtil.setNodeValue(this.doc, "TaxAMT", String.valueOf(xml_b311_item.TAXAMT), i);
            XMLUtil.setNodeValue(this.doc, "TotalAMT", String.valueOf(xml_b311_item.TOTALAMT), i);
        }
        
        if ((this.xml_b311.getOrgCode() != null) || (!"".equals(this.xml_b311.getOrgCode())))
          XMLUtil.setNodeValue(this.doc, "OrgCode", p_b311.getOrgCode());
    }

    private void setBusinessNumbers(B311VO p_b311) {
        if (!StrUtil.isEmpty(p_b311.getBuyerID()) && p_b311.getBuyerID().length() >= 20) {
            XMLUtil.setNodeValue(this.doc, "BuyerID", "0000000000000");
        } else {
            XMLUtil.setNodeValue(this.doc, "BuyerID", p_b311.getBuyerID());
        }
        
        XMLUtil.setNodeValue(this.doc, "BuyerBusinessNO", p_b311.getBuyerBusinessNO());
        
        if (!StrUtil.isEmpty(p_b311.getSellerID()) && p_b311.getSellerID().length() >= 20) {
            XMLUtil.setNodeValue(this.doc, "SellerID", "0000000000000");
        } else {
            XMLUtil.setNodeValue(this.doc, "SellerID", p_b311.getSellerID());
        }
        
        XMLUtil.setNodeValue(this.doc, "SellerBusinessNO", p_b311.getSellerBusinessNO());
    }
    
    protected Document makeDocument(Document p_doc) {
        NodeList transferNL = this.doc.getElementsByTagName("IndivPart");
        NodeList schedueleNL = this.doc.getElementsByTagName("SettlementScheduleInfo");

        if (this.taxIssueYN.equals("N")) {
            NodeList subElement = p_doc.getElementsByTagName("TaxBillNO");
            NodeList subElement1 = p_doc.getElementsByTagName("TaxBillAMT");
            NodeList subElement2 = p_doc.getElementsByTagName("TaxBillDate");
            NodeList subElement3 = p_doc.getElementsByTagName("MainItem");
            NodeList subElement4 = p_doc.getElementsByTagName("TaxBillSupplyAMT");

            if (transferNL.item(0) != null) {
                if (subElement.item(0) != null) transferNL.item(0).removeChild(subElement.item(0));
                if (subElement1.item(0) != null) transferNL.item(0).removeChild(subElement1.item(0));
                if (subElement2.item(0) != null) transferNL.item(0).removeChild(subElement2.item(0));
                if (subElement3.item(0) != null) transferNL.item(0).removeChild(subElement3.item(0));
                if (subElement4.item(0) != null) transferNL.item(0).removeChild(subElement4.item(0));
            }
        }

        if (this.paymentApprovalTypeYN.equals("N")) {
            NodeList subElement = p_doc.getElementsByTagName("PaymentApprovalType");
            if (transferNL.item(0) != null && subElement.item(0) != null) {
                transferNL.item(0).removeChild(subElement.item(0));
            }
        }

        if (this.expirationDateYN.equals("N")) {
            NodeList subElement = p_doc.getElementsByTagName("ExpirationDate");
            if (schedueleNL.item(0) != null && subElement.item(0) != null) {
                schedueleNL.item(0).removeChild(subElement.item(0));
            }
        }

        if (this.paymentDueDateYN.equals("N")) {
            NodeList subElement = p_doc.getElementsByTagName("PaymentDueDate");
            if (schedueleNL.item(0) != null && subElement.item(0) != null) {
                schedueleNL.item(0).removeChild(subElement.item(0));
            }
        }

        return p_doc;
    }
}
