package kr.co.soap.kodit.loan;

import java.io.FileReader;
import java.io.StringWriter;

import javax.xml.transform.Transformer;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.XmlEnum;

public class Kodit_A181_Send {
	
	protected int intCtId;
	protected String strSeqNo;
	
	protected String MPCode;
	protected String receiver;
	protected String TransactionSEQNO;
	protected String TransactionNO;
	protected String TransactionDate;
	protected String TransactionTime;
	protected String UserField;
	
	private Document doc;
	private Document resDoc;
	
	private String TransactionResultCode;
	private String TransactionResultMessage;

    protected Kodit_A181_Send() {}
    
    protected Kodit_A181_Send(String p_MPCode) {
        this.MPCode = p_MPCode;
    }
    
    protected CommonElement executeA181() {
        CommonElement commonElement = null;
        try {
            commonElement = readData();
            if (!"0000".equals(commonElement.getResponseCode())) {
                return commonElement;
            }
            makeA181XML();
            commonElement = sendA181();
        } catch (Exception ex) {
            if (commonElement == null) {
                commonElement = new CommonElement();
            }
            commonElement.setResponseCode("0099");
            commonElement.setResponseMessage(ex.getMessage());
            ex.printStackTrace();
        }
        return commonElement;
    }
    
    protected CommonElement readData() throws Exception {
    	
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");

        this.receiver = null;
        this.TransactionSEQNO = null;
        this.TransactionNO = null;
        this.TransactionDate = null;
        this.TransactionTime = null;
        this.UserField = null;

        return commonElement;
        
    }
    
    private void makeA181XML() throws Exception {
        try (FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("A181.xml"))) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
        }

        setCommonXMLValues();
        setTransferXMLValues();
    }
    
    private void setCommonXMLValues() throws Exception {
        XMLUtil.setNodeValue(this.doc, "sb:Sender", this.MPCode, 0);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionSEQNO", SequenceGenerator.getInstance().getTransSeqNO(), 0);
        XMLUtil.setNodeValue(this.doc, "sb:Receiver", this.receiver, 0);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionDate", DateTimeUtil.getCurrentDate(""), 0);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionTime", DateTimeUtil.getCurrentDateTime().substring(8, 14), 0);
        XMLUtil.setNodeValue(this.doc, "sb:UserField", this.UserField, 0);
    }
    
    private void setTransferXMLValues() {
        XMLUtil.setNodeValue(this.doc, "sb:Sender", this.MPCode, 1);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionSEQNO", this.TransactionSEQNO, 1);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionNO", this.TransactionNO, 1);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionDate", this.TransactionDate, 1);
        XMLUtil.setNodeValue(this.doc, "sb:TransactionTime", this.TransactionTime, 1);
    }
    
    private CommonElement sendA181() throws Exception {
    	
        //makeA181XML();
    	
    	System.out.println("#####################################");
    	System.out.println(XMLUtil.formatDocToStr(this.doc));
    	System.out.println("#####################################");
        
        this.resDoc = HttpClientUtil.shinboCall(this.doc);

        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();
        CommonElement newCommonElement = mapToCommonElement(resinfo);

        if ("0000".equals(newCommonElement.getResponseCode())) {
            this.TransactionResultCode = XMLUtil.getNodeValue(this.resDoc, "sb:TransactionResultCode");
            if (!"0000".equals(this.TransactionResultCode)) {
                this.TransactionResultMessage = XMLUtil.getNodeValueOption(this.resDoc, "sb:TransactionResultMessage", 0);
            }
        }

        return newCommonElement;
    }
    
    private CommonElement mapToCommonElement(CommonElement source) {
        CommonElement target = new CommonElement();
        target.setSender(source.getSender());
        target.setTransactionSEQNO(source.getTransactionSEQNO());
        target.setReceiver(source.getReceiver());
        target.setTransactionNO(source.getTransactionNO());
        target.setTransactionDate(source.getTransactionDate());
        target.setTransactionTime(source.getTransactionTime());
        target.setResponseCode(source.getResponseCode());
        target.setResponseMessage(source.getResponseMessage());
        target.setUserField(source.getUserField());
        return target;
    }

    public String getTransactionResultCode() {
        return this.TransactionResultCode;
    }

    public String getTransactionResultMessage() {
        return this.TransactionResultMessage;
    }
    
    public static void main(String[] args) throws Exception {
    	String aa = "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\r\n" + 
                "<sb:Payment xmlns:sb=\"http://www.shinbo.co.kr\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n" + 
                " <sb:Common>\r\n" + 
                "  <sb:Sender>0810000</sb:Sender>\r\n" + 
                "  <sb:TransactionSEQNO>67818</sb:TransactionSEQNO>\r\n" + 
                "  <sb:Receiver>EMTNET</sb:Receiver>\r\n" + 
                "  <sb:TransactionNO>K311</sb:TransactionNO>\r\n" + 
                "  <sb:TransactionDate>20250214</sb:TransactionDate>\r\n" + 
                "  <sb:TransactionTime>143050</sb:TransactionTime>\r\n" + 
                "  <sb:ResponseCode>0000</sb:ResponseCode>\r\n" + 
                "  <sb:ResponseMessage></sb:ResponseMessage>\r\n" + 
                "  <sb:UserField>0000</sb:UserField>\r\n" + 
                " </sb:Common>\r\n" + 
                " <sb:Transfer>\r\n" + 
                "  <sb:TradeDate>20250214</sb:TradeDate>\r\n" + 
                "  <sb:OrderNO>EMTNETC25021400001HN</sb:OrderNO>\r\n" + 
                "  <sb:ContractDate>20250210</sb:ContractDate>\r\n" + 
                "  <sb:SettlementStatus>1</sb:SettlementStatus>\r\n" + 
                "  <sb:ScheduleSEQNO>01</sb:ScheduleSEQNO>\r\n" + 
                "  <sb:TradeType>2</sb:TradeType>\r\n" + 
                "  <sb:SettlementType>4</sb:SettlementType>\r\n" + 
                "  <sb:SettlementDueAMT>000000001159840</sb:SettlementDueAMT>\r\n" + 
                "  <sb:SettlementAMT>000000001159840</sb:SettlementAMT>\r\n" + 
                "  <sb:PaymentAMT>000000001159840</sb:PaymentAMT>\r\n" + 
                "  <sb:RefundAMT>000000000000000</sb:RefundAMT>\r\n" + 
                "  <sb:SettlementDueDate>20250220</sb:SettlementDueDate>\r\n" + 
                "  <sb:BuyerFee>0000003300</sb:BuyerFee>\r\n" + 
                "  <sb:SellerFee>0000000000</sb:SellerFee>\r\n" + 
                "  <sb:MPURL>uyp6c.id.zp</sb:MPURL>\r\n" + 
                " </sb:Transfer>\r\n" + 
                "</sb:Payment>";

    HttpClientUtil.shinboCall(XMLEasyUtil.parseXMLDocument(aa));

    }
}
