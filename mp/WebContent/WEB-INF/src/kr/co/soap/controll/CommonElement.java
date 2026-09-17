package kr.co.soap.controll;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class CommonElement 
{
	private String Sender;
	private String TransactionSEQNO;
	private String Receiver;
	private String TransactionNO;
	private String TransactionDate;
	private String TransactionTime;
	private String ResponseCode;
	private String ResponseMessage;
	private String UserField;   
	private String OrderNO;
	private String TradeDate;
	private String ContractDate;
	private String ClearSEQNO; 
	private String ResTransactionNO;
    private Document doc;
    
    public CommonElement() {}

    public CommonElement(Document doc) {
        this.doc = doc;
        parseDocument(doc);
    }
	
	public String getSender()
	{
		return this.Sender;
	}
    
	public void setSender(String p_Sender)
	{
		this.Sender = p_Sender;
	}
	
	public String getTransactionSEQNO()
	{
		return this.TransactionSEQNO;
	}
    
	public void setTransactionSEQNO(String p_TransactionSEQNO)
	{
		this.TransactionSEQNO = p_TransactionSEQNO;
	}
	
	public String getReceiver()
	{
		return this.Receiver;
	}
    
	public void setReceiver(String p_Receiver)
	{
		this.Receiver = p_Receiver;
	}
    
	public String getTransactionNO()
	{
		return this.TransactionNO;
	}
    
	public void setTransactionNO(String p_TransactionNO)
	{
		this.TransactionNO = p_TransactionNO;
	}
	
	public String getTransactionDate()
	{
		return this.TransactionDate;
	}
    
	public void setTransactionDate(String p_TransactionDate)
	{
		this.TransactionDate = p_TransactionDate;
	}
	
	public String getTransactionTime()
	{
		return this.TransactionTime;
	}
    
	public void setTransactionTime(String p_TransactionTime)
	{
		this.TransactionTime = p_TransactionTime;
	}
	
	public String getResponseCode()
	{
		return this.ResponseCode;
	}
    
	public void setResponseCode(String p_ResponseCode)
	{
		this.ResponseCode = p_ResponseCode;
	}
	
	public String getResponseMessage()
	{
		return this.ResponseMessage;
	}
    
	public void setResponseMessage(String p_ResponseMessage)
	{
		this.ResponseMessage = p_ResponseMessage;
	}
    
	public String getUserField()
	{
		return this.UserField;
	}
    
	public void setUserField(String p_UserField)
	{
		this.UserField = p_UserField;
	}
	
	public String getOrderNO()
	{
		return this.OrderNO;
	}
    
	public void setOrderNO(String p_OrderNO)
	{
		this.OrderNO = p_OrderNO;
	}	
	
	public String getContractDate()
	{
		return this.ContractDate;
	}
    
	public void setContractDate(String p_ContractDate)
	{
		this.ContractDate = p_ContractDate;
	}
	
	public String getClearSEQNO()
	{
		return this.ClearSEQNO;
	}
    
	public void setClearSEQNO(String p_ClearSEQNO)
	{
		this.ClearSEQNO = p_ClearSEQNO;
	}
	
	private Element createElementWithText(Document doc, String nodeName, String text, boolean ignoreNull) {
        if (ignoreNull && text == null) return null;
        Element element = doc.createElement(nodeName);
        if (text != null) element.appendChild(doc.createTextNode(text));
        return element;
    }

    private String getTextValue(Node node) {
        return (node != null && node.getFirstChild() != null) ? node.getFirstChild().getNodeValue() : "";
    }

    public Element createCommonElement(Document doc) {
        Element commonElem = doc.createElement("CommPart");
        appendChildElements(commonElem, doc, false);
        return commonElem;
    }

    public Element createCommonElementForResponse(Document ownerDoc) {
        this.doc = ownerDoc;
        Element commonElem = ownerDoc.createElement("CommPart");
        this.TransactionNO = incrementTransactionNO(this.TransactionNO);
        appendChildElements(commonElem, ownerDoc, true);
        return commonElem;
    }

    private void appendChildElements(Element commonElem, Document doc, boolean isResponse) {
        String TransactionNO = isResponse ? incrementTransactionNO(this.TransactionNO) : this.TransactionNO;
        String[][] elements = {
            {"Sender", Sender},
            {"TransactionSEQNO", TransactionSEQNO},
            {"Receiver", Receiver},
            {"TransactionNO", TransactionNO},
            {"TransactionDate", TransactionDate},
            {"TransactionTime", TransactionTime},
            {"ResponseCode", ResponseCode},
            {"ResponseMessage", ResponseMessage},
            {"UserField", UserField}
        };
        
        for (String[] element : elements) {
            Element temp = createElementWithText(doc, element[0], element[1], true);
            if (temp != null) commonElem.appendChild(temp);
        }
    }

    private void parseDocument(Document doc) {
        Element commonNode = (Element) doc.getElementsByTagName("CommPart").item(0);
        if (commonNode == null) return;
        
        NodeList nodes = commonNode.getElementsByTagName("*");
        for (int i = 0; i < nodes.getLength(); i++) {
            Node node = nodes.item(i);
            switch (node.getNodeName()) {
                case "Sender": Sender = getTextValue(node); break;
                case "TransactionSEQNO": TransactionSEQNO = getTextValue(node); break;
                case "Receiver": Receiver = getTextValue(node); break;
                case "TransactionNO": TransactionNO = getTextValue(node); break;
                case "TransactionDate": TransactionDate = getTextValue(node); break;
                case "TransactionTime": TransactionTime = getTextValue(node); break;
                case "ResponseCode": ResponseCode = getTextValue(node); break;
                case "ResponseMessage": ResponseMessage = getTextValue(node); break;
                case "UserField": UserField = getTextValue(node); break;
            }
        }
        parseAdditionalDocument(doc);
    }

    private void parseAdditionalDocument(Document doc) {
        Element transferNode = (Element) doc.getElementsByTagName("IndivPart").item(0);
        if (transferNode == null) return;
        
        NodeList nodes = transferNode.getElementsByTagName("*");
        for (int i = 0; i < nodes.getLength(); i++) {
            Node node = nodes.item(i);
            switch (node.getNodeName()) {
                case "TradeDate": TradeDate = getTextValue(node); break;
                case "OrderNO": OrderNO = getTextValue(node); break;
            }
        }
    }

    private String incrementTransactionNO(String TransactionNO) {
        if (TransactionNO == null || TransactionNO.length() < 2) return "ERR0";
        return TransactionNO.substring(0, 1) + (Integer.parseInt(TransactionNO.substring(1)) + 1);
    }

    public CommonElement clone() {
        CommonElement clone = new CommonElement();
        clone.Sender = this.Sender;
        clone.TransactionSEQNO = this.TransactionSEQNO;
        clone.Receiver = this.Receiver;
        clone.TransactionNO = this.TransactionNO;
        clone.TransactionDate = this.TransactionDate;
        clone.TransactionTime = this.TransactionTime;
        clone.ResponseCode = this.ResponseCode;
        clone.ResponseMessage = this.ResponseMessage;
        clone.UserField = this.UserField;
        clone.ResTransactionNO = this.ResTransactionNO;
        return clone;
    }

    @Override
    public String toString() {
        return String.format(
            "[Common:\n\tSender=%s/\n\tTransactionSEQNO=%s/\n\tReceiver=%s/\n\tTransactionNO=%s/\n\tTransactionDate=%s/\n\tTransactionTime=%s/\n\tResponseCode=%s/\n\tResponseMessage=%s/\n\tUserField=%s]\n",
            Sender, TransactionSEQNO, Receiver, TransactionNO, TransactionDate, TransactionTime, ResponseCode, ResponseMessage, UserField
        );
    }
}


