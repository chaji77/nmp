package kr.co.soap.kibo.loan;

import java.io.FileReader;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.kibo.HttpClientUtil;

public class Kibo_A181_Send {
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
	
	//연합회 구분용
    protected int intPayId;
    private String strGubun = "kibo_sURL";
    
    public void setPayId(int lng) {
    	this.intPayId = lng;
    }

    protected Kibo_A181_Send() {}
    
    protected Kibo_A181_Send(String p_MPCode) {
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
        try (FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("A181_KIBO.xml"))) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
        }
        
        setCommPartXMLValues();
        setIndivPartXMLValues();
    }
    
    private void setCommPartXMLValues() throws Exception {
    	
    	//연합회일경우 
 	    if(100 < this.intPayId) {
 	    	NodeList nl = this.doc.getElementsByTagName("IndivPart");	
 	 	    Element OrgCode = this.doc.createElement("OrgCode");
 			nl.item(0).appendChild(OrgCode);
 	    }
    	
 	    System.out.println(DateTimeUtil.getCurrentDate(""));
 	  	System.out.println(this.TransactionDate);
 	   	System.out.println(this.TransactionDate);
 	  	System.out.println(DateTimeUtil.getCurrentDate(""));
 	    
        XMLUtil.setNodeValue(this.doc, "Sender", this.MPCode, 0);
        XMLUtil.setNodeValue(this.doc, "TransactionSEQNO", SequenceGenerator.getInstance().getTransSeqNO(), 0);
        XMLUtil.setNodeValue(this.doc, "Receiver", this.receiver, 0);
        XMLUtil.setNodeValue(this.doc, "TransactionNO", "A181");     
        XMLUtil.setNodeValue(this.doc, "TransactionDate", DateTimeUtil.getCurrentDate(""), 0);
        XMLUtil.setNodeValue(this.doc, "TransactionTime", DateTimeUtil.getCurrentDateTime().substring(8, 14), 0);
        XMLUtil.setNodeValue(this.doc, "ResponseCode", "0000");
        XMLUtil.setNodeValue(this.doc, "UserField", this.UserField, 0);
    }
    
    private void setIndivPartXMLValues() {
        XMLUtil.setNodeValue(this.doc, "OrgSender", this.MPCode, 0);
        XMLUtil.setNodeValue(this.doc, "OrgTransactionSEQNO", this.TransactionSEQNO, 0);
        XMLUtil.setNodeValue(this.doc, "OrgTransactionNO", this.TransactionNO, 0);
        XMLUtil.setNodeValue(this.doc, "OrgTransactionDate" , this.TransactionDate, 0);
        XMLUtil.setNodeValue(this.doc, "OrgTransactionTime", this.TransactionTime, 0);
        
        //연합회일경우 
	    if(100 < this.intPayId) {
	    	this.strGubun = "kibo_yun_sURL";
	    	XMLUtil.setNodeValue(this.doc, "OrgCode", XmlEnum.getOrgCode(this.intPayId));
 	    }
    }
    
    private CommonElement sendA181() throws Exception {
    	
        //makeA181XML();
    	
    	CommonElement commonElement = null;
    	
    	//System.out.println("#####################################");
    	//System.out.println(XMLUtil.formatDocToStr(this.doc));
    	//System.out.println("#####################################");
        
        this.resDoc = HttpClientUtil.kiboCall(this.doc, this.strGubun);

        CommonElement resinfo = HttpClientUtil.getCommonElement();
        CommonElement newCommonElement = mapToCommonElement(resinfo);

        if ("0000".equals(newCommonElement.getResponseCode())) {
            this.TransactionResultCode = XMLUtil.getNodeValue(this.resDoc, "TransactionResultCode");
            if (!"0000".equals(this.TransactionResultCode)) {
                this.TransactionResultMessage = XMLUtil.getNodeValueOption(this.resDoc, "TransactionResultMessage", 0);
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
}
