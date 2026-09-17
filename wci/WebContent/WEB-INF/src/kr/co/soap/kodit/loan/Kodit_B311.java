package kr.co.soap.kodit.loan;

import java.io.FileReader;
import java.util.ArrayList;

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


public class Kodit_B311 extends Kodit_B31X {

    protected String taxIssueYN = "Y";
    protected String paymentApprovalTypeYN = "Y";
    protected String expirationDateYN = "Y";
    protected String paymentDueDateYN = "Y";
    protected String tmpTaxapprovalno = "";
	
    protected Kodit_B311(String p_MPCode) {
        super.MPCode = p_MPCode;
    }
    
    protected void createB31XXML(int intCtId, String p_seqNO) throws Exception {
    	
        SoapCommonVO xmlItemVO = new SoapCommonBean().GET_XML_B311_ITEM_PROC(intCtId);

        this.tmpTaxapprovalno = xml_b311.getTaxApprovalNO();
        
        String templatePath = this.getTemplate(xml_b311);
        this.createB31X_makeXML(xmlItemVO.allItems.size(), templatePath);
        this.createB31X_setValue(xml_b311, xmlItemVO.allItems);
        
    }

    protected void createB31X_makeXML(int p_itemCount, String strTemplate) throws Exception {
        try (FileReader fileReader = new FileReader(strTemplate)) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
            this.doc = this.makeDocument(this.doc);

            NodeList transferNodes = this.doc.getElementsByTagName("sb:Transfer");
            for (int i = 0; i < p_itemCount; i++) {
                Element orderDetail = this.doc.createElement("sb:OrderDetail");
                orderDetail.setAttribute("seq", String.valueOf(i + 1));
                transferNodes.item(0).appendChild(orderDetail);

                String[] elements = {"sb:OrderSEQNO", "sb:Item", "sb:Size", "sb:Quantity", "sb:QuantityUnit", 
                                      "sb:UnitPrice", "sb:SupplyAMT", "sb:TaxAMT", "sb:TotalAMT"};
                for (String elementName : elements) {
                    Element el = this.doc.createElement(elementName);
                    orderDetail.appendChild(el);
                }
            }
        }
    }

    protected void createB31X_setValue(B311VO p_b311, ArrayList<SoapCommonVO.XmlB311ItemVO> p_b311_ItemList) throws Exception {
        XMLUtil.setNodeValue(this.doc, "sb:Sender", p_b311.getSender());
        XMLUtil.setNodeValue(this.doc, "sb:TransactionSEQNO", p_b311.getTransactionSEQNO());
        XMLUtil.setNodeValue(this.doc, "sb:Receiver", p_b311.getReceiver());
        XMLUtil.setNodeValue(this.doc, "sb:TransactionNO", p_b311.getTransactionNO());
        XMLUtil.setNodeValue(this.doc, "sb:TransactionDate", p_b311.getTransactionDate());
        XMLUtil.setNodeValue(this.doc, "sb:TransactionTime", p_b311.getTransactionTime());
        XMLUtil.setNodeValue(this.doc, "sb:ResponseCode", p_b311.getResponseCode());
        XMLUtil.setNodeValue(this.doc, "sb:UserField", p_b311.getUserField());
        
        XMLUtil.setNodeValue(this.doc, "sb:TradeDate", p_b311.getTradeDate());
        XMLUtil.setNodeValue(this.doc, "sb:OrderNO", p_b311.getOrderNO());
        XMLUtil.setNodeValue(this.doc, "sb:ContractDate", p_b311.getContractDate());
        XMLUtil.setNodeValue(this.doc, "sb:HandAcceptYN", p_b311.getHandAcceptYN());
        XMLUtil.setNodeValue(this.doc, "sb:ContractType", p_b311.getContractType());
        
        setBusinessNumbers(p_b311);
        
        XMLUtil.setNodeValue(this.doc, "sb:TotalContractAMT", p_b311.getTotalContractAMT());
        XMLUtil.setNodeValue(this.doc, "sb:BuyerFee", p_b311.getBuyerFee());
        XMLUtil.setNodeValue(this.doc, "sb:SellerFee", p_b311.getSellerFee());
        XMLUtil.setNodeValue(this.doc, "sb:FeeType", p_b311.getFeeType());
        XMLUtil.setNodeValue(this.doc, "sb:SellerName", p_b311.getSellerName());
        
        if (this.paymentApprovalTypeYN.equals("Y")) XMLUtil.setNodeValue(this.doc, "sb:PaymentApprovalType", p_b311.getPaymentApprovalType());
        if (!StrUtil.isEmpty(p_b311.getTaxApprovalNO())) XMLUtil.setNodeValue(this.doc, "sb:TaxApprovalNO", p_b311.getTaxApprovalNO());
        
        //if (this.taxIssueYN.equals("Y")) {
        	XMLUtil.setNodeValue(this.doc, "sb:TaxBillDate", p_b311.getTaxBillDate());
        	XMLUtil.setNodeValue(this.doc, "sb:TaxBillAMT", p_b311.getTaxBillAMT());
        	XMLUtil.setNodeValue(this.doc, "sb:TaxBillNO", p_b311.getTaxBillNO());
        	XMLUtil.setNodeValue(this.doc, "sb:TaxBillSupplyAMT", p_b311.getTaxBillSupplyAMT());
        	XMLUtil.setNodeValue(this.doc, "sb:MainItem", p_b311.getMainItem());
        //}
        
        XMLUtil.setNodeValue(this.doc, "sb:SettlementScheduleCount", String.valueOf(p_b311.getSettlementScheduleCount()));
        XMLUtil.setNodeValue(this.doc, "sb:ScheduleSEQNO", String.valueOf(p_b311.getScheduleSEQNO()));
        XMLUtil.setNodeValue(this.doc, "sb:TradeType", p_b311.getTradeType());
        XMLUtil.setNodeValue(this.doc, "sb:SettlementType", p_b311.getSettlementType());
        //XMLUtil.setNodeValue(this.doc, "sb:SettlementDueAMT", String.valueOf(StrUtil.nvl(p_b311.getSettlementDueAMT(), "0"))); // 2025.02.06 현재 값없음
        XMLUtil.setNodeValue(this.doc, "sb:SettlementDueAMT", String.valueOf(StrUtil.nvl(p_b311.getTotalContractAMT(), "0")));
        XMLUtil.setNodeValue(this.doc, "sb:RefundAMT", String.valueOf(p_b311.getRefundAMT()));

        XMLUtil.setNodeValue(this.doc, "sb:SettlementDueDate", p_b311.getSettlementDueDate());

        if (this.paymentDueDateYN.equals("Y")) XMLUtil.setNodeValue(this.doc, "sb:PaymentDueDate", p_b311.getPaymentDueDate());
        if (this.expirationDateYN.equals("Y")) XMLUtil.setNodeValue(this.doc, "sb:ExpirationDate", p_b311.getExpirationDate());

        XMLUtil.setNodeValue(this.doc, "sb:OrderCount", String.valueOf(p_b311.getOrderCount()));


        for (int i = 0; i < p_b311_ItemList.size(); i++) {
        	SoapCommonVO.XmlB311ItemVO xml_b311_item = p_b311_ItemList.get(i);
            //XMLUtil.setNodeValue(this.doc, "sb:OrderSEQNO", String.valueOf(xml_b311_item.get), i);
        	XMLUtil.setNodeValue(this.doc, "sb:OrderSEQNO", String.valueOf(i+1), i);	//orderseq ct_item에 없어서 순번 넣음
            XMLUtil.setNodeValue(this.doc, "sb:Item", xml_b311_item.ITEMNAME, i);
            XMLUtil.setNodeValue(this.doc, "sb:Size", xml_b311_item.SIZE, i);
            XMLUtil.setNodeValue(this.doc, "sb:Quantity", String.format("%.0f", xml_b311_item.QTY), i);
            XMLUtil.setNodeValue(this.doc, "sb:QuantityUnit", xml_b311_item.UNIT, i);
            XMLUtil.setNodeValue(this.doc, "sb:UnitPrice", String.format("%.0f", xml_b311_item.UNITPRICE), i);
            XMLUtil.setNodeValue(this.doc, "sb:SupplyAMT", String.valueOf(xml_b311_item.SUPPLYAMT), i);
            XMLUtil.setNodeValue(this.doc, "sb:TaxAMT", String.valueOf(xml_b311_item.TAXAMT), i);
            XMLUtil.setNodeValue(this.doc, "sb:TotalAMT", String.valueOf(xml_b311_item.TOTALAMT), i);
        }
    }

    private void setBusinessNumbers(B311VO p_b311) {
        if (!StrUtil.isEmpty(p_b311.getBuyerID()) && p_b311.getBuyerID().length() >= 20) {
            XMLUtil.setNodeValue(this.doc, "sb:BuyerID", "0000000000000");
        } else {
            XMLUtil.setNodeValue(this.doc, "sb:BuyerID", p_b311.getBuyerID());
        }
        
        XMLUtil.setNodeValue(this.doc, "sb:BuyerBusinessNO", p_b311.getBuyerBusinessNO());
        
        if (!StrUtil.isEmpty(p_b311.getSellerID()) && p_b311.getSellerID().length() >= 20) {
            XMLUtil.setNodeValue(this.doc, "sb:SellerID", "0000000000000");
        } else {
            XMLUtil.setNodeValue(this.doc, "sb:SellerID", p_b311.getSellerID());
        }
        
        XMLUtil.setNodeValue(this.doc, "sb:SellerBusinessNO", p_b311.getSellerBusinessNO());
    }

    protected Document makeDocument(Document p_doc) {
    	NodeList transferNL = this.doc.getElementsByTagName("sb:Transfer");
        NodeList schedueleNL = this.doc.getElementsByTagName("sb:ScheduleDetail");
        /*
        if (this.taxIssueYN.equals("N"))
        {
          NodeList subElement = p_doc.getElementsByTagName("sb:TaxBillNO");
          transferNL.item(0).removeChild(subElement.item(0));

          NodeList subElement1 = p_doc.getElementsByTagName("sb:TaxBillAMT");
          transferNL.item(0).removeChild(subElement1.item(0));

          NodeList subElement2 = p_doc.getElementsByTagName("sb:TaxBillDate");
          transferNL.item(0).removeChild(subElement2.item(0));

          NodeList subElement3 = p_doc.getElementsByTagName("sb:MainItem");
          transferNL.item(0).removeChild(subElement3.item(0));

          NodeList subElement4 = p_doc.getElementsByTagName("sb:TaxBillSupplyAMT");
          transferNL.item(0).removeChild(subElement4.item(0));

          NodeList subElement5 = p_doc.getElementsByTagName("sb:TaxApprovalNO");

          if (StrUtil.isEmpty(this.tmpTaxapprovalno)) {
            transferNL.item(0).removeChild(subElement5.item(0));
          }
        }
        else
        {
          NodeList subElement5 = p_doc.getElementsByTagName("sb:TaxApprovalNO");
          if (StrUtil.isEmpty(this.tmpTaxapprovalno)) {
            transferNL.item(0).removeChild(subElement5.item(0));
          }

        }
        */

        if (this.paymentApprovalTypeYN.equals("N"))
        {
          NodeList subElement = p_doc.getElementsByTagName("sb:PaymentApprovalType");
          transferNL.item(0).removeChild(subElement.item(0));
        }

        if (this.expirationDateYN.equals("N"))
        {
          NodeList subElement = p_doc.getElementsByTagName("sb:ExpirationDate");
          if ((subElement.item(0) != null) && (!"".equals(subElement.item(0))))
          {
            schedueleNL.item(0).removeChild(subElement.item(0));
          }
        }

        if (this.paymentDueDateYN.equals("N"))
        {
          NodeList subElement = p_doc.getElementsByTagName("sb:PaymentDueDate");
          schedueleNL.item(0).removeChild(subElement.item(0));
        }
        
        return p_doc;
    }
}
