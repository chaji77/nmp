package kr.co.soap.controll;

/**
 * C211(담보보증 신청) 송신 전문 VO
 * - Common 부 + Transfer 부
 */
public class C211VO {

    private CommonElement commonElement = new CommonElement();

    private String buyerID;
    private String buyerBusinessNO;
    private String sellerID;
    private String sellerBusinessNO;
    private String applicationNO;
    private String applicationAMT;
    private String guaranteeExpirationText;
    private String guaranteeType;
    private String information;

    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement commonElement) { this.commonElement = commonElement; }

    public String getBuyerID() { return buyerID; }
    public void setBuyerID(String v) { this.buyerID = v; }

    public String getBuyerBusinessNO() { return buyerBusinessNO; }
    public void setBuyerBusinessNO(String v) { this.buyerBusinessNO = v; }

    public String getSellerID() { return sellerID; }
    public void setSellerID(String v) { this.sellerID = v; }

    public String getSellerBusinessNO() { return sellerBusinessNO; }
    public void setSellerBusinessNO(String v) { this.sellerBusinessNO = v; }

    public String getApplicationNO() { return applicationNO; }
    public void setApplicationNO(String v) { this.applicationNO = v; }

    public String getApplicationAMT() { return applicationAMT; }
    public void setApplicationAMT(String v) { this.applicationAMT = v; }

    public String getGuaranteeExpirationText() { return guaranteeExpirationText; }
    public void setGuaranteeExpirationText(String v) { this.guaranteeExpirationText = v; }

    public String getGuaranteeType() { return guaranteeType; }
    public void setGuaranteeType(String v) { this.guaranteeType = v; }

    public String getInformation() { return information; }
    public void setInformation(String v) { this.information = v; }
}
