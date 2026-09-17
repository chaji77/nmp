package kr.co.soap.controll;

public class A211VO {
	
    private String TransactionID;
    private String CodeType;
    private int TransactionLength;
    private String Sender;
    private String TransactionSEQNO;
    private String Receiver;
    private String TransactionNO;
    private String TransactionDate;
    private String TransactionTime;
    private String ResponseCode;
    private String ResponseMessage;
    private String UserField;
    private String BuyerID;
    private String BuyerBusinessNO;
    private String SellerID;
    private String SellerBusinessNO;

    public String getTransactionID() {
        return this.TransactionID;
    }

    public void setTransactionID(String transactionID) {
        this.TransactionID = transactionID;
    }

    public String getCodeType() {
        return this.CodeType;
    }

    public void setCodeType(String codeType) {
        this.CodeType = codeType;
    }

    public long getTransactionLength() {
        return this.TransactionLength;
    }

    public void setTransactionLength(int transactionLength) {
        this.TransactionLength = transactionLength;
    }

    public String getSender() {
        return this.Sender;
    }

    public void setSender(String sender) {
        this.Sender = sender;
    }

    public String getTransactionSEQNO() {
        return this.TransactionSEQNO;
    }

    public void setTransactionSEQNO(String transactionSEQNO) {
        this.TransactionSEQNO = transactionSEQNO;
    }

    public String getReceiver() {
        return this.Receiver;
    }

    public void setReceiver(String receiver) {
        this.Receiver = receiver;
    }

    public String getTransactionNO() {
        return this.TransactionNO;
    }

    public void setTransactionNO(String transactionNO) {
        this.TransactionNO = transactionNO;
    }

    public String getTransactionDate() {
        return this.TransactionDate;
    }

    public void setTransactionDate(String transactionDate) {
        this.TransactionDate = transactionDate;
    }

    public String getTransactionTime() {
        return this.TransactionTime;
    }

    public void setTransactionTime(String transactionTime) {
        this.TransactionTime = transactionTime;
    }

    public String getResponseCode() {
        return this.ResponseCode;
    }

    public void setResponseCode(String responseCode) {
        this.ResponseCode = responseCode;
    }

    public String getResponseMessage() {
        return this.ResponseMessage;
    }

    public void setResponseMessage(String responseMessage) {
        this.ResponseMessage = responseMessage;
    }

    public String getUserField() {
        return this.UserField;
    }

    public void setUserField(String userField) {
        this.UserField = userField;
    }

    public String getBuyerID() {
        return this.BuyerID;
    }

    public void setBuyerID(String buyerID) {
        this.BuyerID = buyerID;
    }

    public String getBuyerBusinessNO() {
        return this.BuyerBusinessNO;
    }

    public void setBuyerBusinessNO(String buyerBusinessNO) {
        this.BuyerBusinessNO = buyerBusinessNO;
    }

    public String getSellerID() {
        return this.SellerID;
    }

    public void setSellerID(String sellerID) {
        this.SellerID = sellerID;
    }

    public String getSellerBusinessNO() {
        return this.SellerBusinessNO;
    }

    public void setSellerBusinessNO(String sellerBusinessNO) {
        this.SellerBusinessNO = sellerBusinessNO;
    }
}
