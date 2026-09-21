package kr.co.soap.controll;

/**
 * B211(매매계약서 발송) 송신 헤더 VO (Common + Transfer 헤더 + 결제스케줄 1건)
 * 주문상세(OrderDetail)는 List<B211ItemVO> 로 별도 보관.
 */
public class B211VO {

    private CommonElement commonElement = new CommonElement();

    private String applicationNO;
    private String guaranteeNO;
    private String tradeDate;
    private String orderNO;
    private String contractDate;
    private String buyerID;
    private String buyerBusinessNO;
    private String sellerID;
    private String sellerBusinessNO;
    private String totalContractAMT;

    private String settlementScheduleCount; // 보통 "1"
    private String scheduleSEQNO;
    private String settlementType;
    private String settlementDueAMT;
    private String deliveryDueDate;
    private String paymentDueDate;

    private String orderCount;

    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement c) { this.commonElement = c; }

    public String getApplicationNO() { return applicationNO; }
    public void setApplicationNO(String v) { this.applicationNO = v; }
    public String getGuaranteeNO() { return guaranteeNO; }
    public void setGuaranteeNO(String v) { this.guaranteeNO = v; }
    public String getTradeDate() { return tradeDate; }
    public void setTradeDate(String v) { this.tradeDate = v; }
    public String getOrderNO() { return orderNO; }
    public void setOrderNO(String v) { this.orderNO = v; }
    public String getContractDate() { return contractDate; }
    public void setContractDate(String v) { this.contractDate = v; }
    public String getBuyerID() { return buyerID; }
    public void setBuyerID(String v) { this.buyerID = v; }
    public String getBuyerBusinessNO() { return buyerBusinessNO; }
    public void setBuyerBusinessNO(String v) { this.buyerBusinessNO = v; }
    public String getSellerID() { return sellerID; }
    public void setSellerID(String v) { this.sellerID = v; }
    public String getSellerBusinessNO() { return sellerBusinessNO; }
    public void setSellerBusinessNO(String v) { this.sellerBusinessNO = v; }
    public String getTotalContractAMT() { return totalContractAMT; }
    public void setTotalContractAMT(String v) { this.totalContractAMT = v; }
    public String getSettlementScheduleCount() { return settlementScheduleCount; }
    public void setSettlementScheduleCount(String v) { this.settlementScheduleCount = v; }
    public String getScheduleSEQNO() { return scheduleSEQNO; }
    public void setScheduleSEQNO(String v) { this.scheduleSEQNO = v; }
    public String getSettlementType() { return settlementType; }
    public void setSettlementType(String v) { this.settlementType = v; }
    public String getSettlementDueAMT() { return settlementDueAMT; }
    public void setSettlementDueAMT(String v) { this.settlementDueAMT = v; }
    public String getDeliveryDueDate() { return deliveryDueDate; }
    public void setDeliveryDueDate(String v) { this.deliveryDueDate = v; }
    public String getPaymentDueDate() { return paymentDueDate; }
    public void setPaymentDueDate(String v) { this.paymentDueDate = v; }
    public String getOrderCount() { return orderCount; }
    public void setOrderCount(String v) { this.orderCount = v; }
}
