package kr.co.soap.controll;

/** K231(결제전문) 송신 VO (Common + Transfer) */
public class K231VO {
    private CommonElement commonElement = new CommonElement();
    private String buyerID;
    private String buyerBusinessNO;
    private String sellerID;
    private String sellerBusinessNO;
    private String orderNO;
    private String scheduleSEQNO;
    private String paymentDueAMT;
    private String paymentAMT;
    private String unclearAMT;
    private String paymentDueDate;
    private String paymentDate;

    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement c) { this.commonElement = c; }
    public String getBuyerID() { return buyerID; }
    public void setBuyerID(String v) { this.buyerID = v; }
    public String getBuyerBusinessNO() { return buyerBusinessNO; }
    public void setBuyerBusinessNO(String v) { this.buyerBusinessNO = v; }
    public String getSellerID() { return sellerID; }
    public void setSellerID(String v) { this.sellerID = v; }
    public String getSellerBusinessNO() { return sellerBusinessNO; }
    public void setSellerBusinessNO(String v) { this.sellerBusinessNO = v; }
    public String getOrderNO() { return orderNO; }
    public void setOrderNO(String v) { this.orderNO = v; }
    public String getScheduleSEQNO() { return scheduleSEQNO; }
    public void setScheduleSEQNO(String v) { this.scheduleSEQNO = v; }
    public String getPaymentDueAMT() { return paymentDueAMT; }
    public void setPaymentDueAMT(String v) { this.paymentDueAMT = v; }
    public String getPaymentAMT() { return paymentAMT; }
    public void setPaymentAMT(String v) { this.paymentAMT = v; }
    public String getUnclearAMT() { return unclearAMT; }
    public void setUnclearAMT(String v) { this.unclearAMT = v; }
    public String getPaymentDueDate() { return paymentDueDate; }
    public void setPaymentDueDate(String v) { this.paymentDueDate = v; }
    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String v) { this.paymentDate = v; }
}
