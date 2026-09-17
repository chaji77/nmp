package kr.co.soap.controll;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class CommonElementResInfo extends CommonElement {
	
    private String BuyerID;
    private String BuyerBusinessNO;
    private String SellerID;
    private String SellerBusinessNO;
    private String OrderNO;
    private String ScheduleSEQNO;

    // Getter와 Setter 추가
    public String getBuyerID() {
        return BuyerID;
    }

    public void setBuyerID(String buyerID) {
        this.BuyerID = buyerID;
    }

    public String getBuyerBusinessNO() {
        return BuyerBusinessNO;
    }

    public void setBuyerBusinessNO(String buyerBusinessNO) {
        this.BuyerBusinessNO = buyerBusinessNO;
    }

    public String getSellerID() {
        return SellerID;
    }

    public void setSellerID(String sellerID) {
        this.SellerID = sellerID;
    }

    public String getSellerBusinessNO() {
        return SellerBusinessNO;
    }

    public void setSellerBusinessNO(String sellerBusinessNO) {
        this.SellerBusinessNO = sellerBusinessNO;
    }

    public String getOrderNO() {
        return OrderNO;
    }

    public void setOrderNO(String OrderNO) {
        this.OrderNO = OrderNO;
    }

    public String getScheduleSEQNO() {
        return ScheduleSEQNO;
    }

    public void setScheduleSEQNO(String scheduleSEQNO) {
        this.ScheduleSEQNO = scheduleSEQNO;
    }

    // XML 엘리먼트를 생성하는 공통 헬퍼 메서드
    private Element createElementIfNotNull(Document doc, String nodeName, String text) {
        if (text == null || text.isEmpty()) {
            return null;
        }
        Element element = doc.createElement(nodeName);
        element.appendChild(doc.createTextNode(text));
        return element;
    }

    // Shinbo 공통 엘리먼트를 생성하는 메서드
    public Element makeShinboCommonElement(Document doc) {
        Element commonElem = doc.createElement("sb:Common");

        appendTextNodeIfNotNull(doc, commonElem, "sb:Sender", getSender());
        appendTextNodeIfNotNull(doc, commonElem, "sb:TransactionSEQNO", getTransactionSEQNO());
        appendTextNodeIfNotNull(doc, commonElem, "sb:Receiver", getReceiver());
        appendTextNodeIfNotNull(doc, commonElem, "sb:TransactionNO", getTransactionNO());
        appendTextNodeIfNotNull(doc, commonElem, "sb:TransactionDate", getTransactionDate());
        appendTextNodeIfNotNull(doc, commonElem, "sb:TransactionTime", getTransactionTime());
        appendTextNodeIfNotNull(doc, commonElem, "sb:ResponseCode", getResponseCode());
        appendTextNodeIfNotNull(doc, commonElem, "sb:ResponseMessage", getResponseMessage(), true);
        appendTextNodeIfNotNull(doc, commonElem, "sb:UserField", getUserField(), true);

        return commonElem;
    }

    // 텍스트가 있을 경우에만 추가하는 메서드
    private void appendTextNodeIfNotNull(Document doc, Element parent, String nodeName, String text) {
        appendTextNodeIfNotNull(doc, parent, nodeName, text, false);
    }

    private void appendTextNodeIfNotNull(Document doc, Element parent, String nodeName, String text, boolean notCreateWhenNull) {
        Element temp = createElementIfNotNull(doc, nodeName, text);
        if (temp != null) {
            parent.appendChild(temp);
        }
    }

    // XML 문서에서 이 객체를 생성하는 메서드 (공통 파싱 로직)
    private void parseCommonElementFromDocument(Document doc, String parentTag) {
        NodeList commonNodeList = doc.getElementsByTagName(parentTag);
        if (commonNodeList.getLength() == 0) return;

        Element commonNode = (Element) commonNodeList.item(0);
        NodeList nodeList = commonNode.getElementsByTagName("*");

        for (int i = 0; i < nodeList.getLength(); i++) {
            Node node = nodeList.item(i);
            String nodeName = node.getNodeName();
            String nodeValue = node.getTextContent().trim();

            switch (nodeName) {
                case "sb:Sender":
                    setSender(nodeValue);
                    break;
                case "sb:TransactionSEQNO":
                    setTransactionSEQNO(nodeValue);
                    break;
                case "sb:Receiver":
                    setReceiver(nodeValue);
                    break;
                case "sb:TransactionNO":
                    setTransactionNO(nodeValue);
                    break;
                case "sb:TransactionDate":
                    setTransactionDate(nodeValue);
                    break;
                case "sb:TransactionTime":
                    setTransactionTime(nodeValue);
                    break;
                case "sb:ResponseCode":
                    setResponseCode(nodeValue);
                    break;
                case "sb:ResponseMessage":
                    setResponseMessage(nodeValue);
                    break;
                case "sb:UserField":
                    setUserField(nodeValue);
                    break;
                case "sb:BuyerID":
                    setBuyerID(nodeValue);
                    break;
                case "sb:BuyerBusinessNO":
                    setBuyerBusinessNO(nodeValue);
                    break;
                case "sb:SellerID":
                    setSellerID(nodeValue);
                    break;
                case "sb:SellerBusinessNO":
                    setSellerBusinessNO(nodeValue);
                    break;
                case "sb:OrderNO":
                    setOrderNO(nodeValue);
                    break;
                case "sb:ScheduleSEQNO":
                    setScheduleSEQNO(nodeValue);
                    break;
            }
        }
    }

    // XML 문서에서 이 객체를 생성하는 메서드 (K232 형식)
    public void makeThisObjectFromK232Document(Document doc) {
        parseCommonElementFromDocument(doc, "sb:Response");
    }

    // 기본 문서에서 이 객체를 생성하는 메서드
    public void makeThisObjectFromDocument(Document doc) {
        parseCommonElementFromDocument(doc, "sb:Common");
    }

    // 트랜잭션 번호를 하나 증가시키는 메서드
    public static String getTrNOPlusOne(String reqTrNo) {
        if (reqTrNo == null)
            return "ERR0";
        else
            return reqTrNo.substring(0, 1) + (Integer.parseInt(reqTrNo.substring(1)) + 1);
    }

    // 객체 복사 메서드
    public CommonElementResInfo cloneThis() {
        CommonElementResInfo ret = new CommonElementResInfo();
        ret.setSender(getSender());
        ret.setTransactionSEQNO(getTransactionSEQNO());
        ret.setReceiver(getReceiver());
        ret.setTransactionNO(getTransactionNO());
        ret.setTransactionDate(getTransactionDate());
        ret.setTransactionTime(getTransactionTime());
        ret.setResponseCode(getResponseCode());
        ret.setResponseMessage(getResponseMessage());
        ret.setUserField(getUserField());
        ret.setBuyerID(getBuyerID());
        ret.setBuyerBusinessNO(getBuyerBusinessNO());
        ret.setSellerID(getSellerID());
        ret.setSellerBusinessNO(getSellerBusinessNO());
        ret.setScheduleSEQNO(getScheduleSEQNO());
        return ret;
    }
}
