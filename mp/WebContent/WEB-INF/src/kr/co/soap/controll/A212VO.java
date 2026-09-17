package kr.co.soap.controll;
import java.util.ArrayList;

public class A212VO {

	private CommonElement common;
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
    private String BuyerCustomerYN;
    private int LimitCount;
    private String SellerCustomerYN;
    private String ExternalAuditYN;
    private String SellerGuaranteeUseYN;
    private String SellerKEDinfoYN;
    private String SellerShutoffYN;
    private String SellerClearYN;
    private ArrayList<LimitVO> LimitList;

    public CommonElement getCommon() {
        return common;
    }

    public void setCommon(CommonElement common) {
        this.common = common;
    }

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

    public String getBuyerCustomerYN() {
        return this.BuyerCustomerYN;
    }

    public void setBuyerCustomerYN(String buyerCustomerYN) {
        this.BuyerCustomerYN = buyerCustomerYN;
    }

    public long getLimitCount() {
        return this.LimitCount;
    }

    public void setLimitCount(int limitCount) {
        this.LimitCount = limitCount;
    }

    public String getSellerCustomerYN() {
        return this.SellerCustomerYN;
    }

    public void setSellerCustomerYN(String sellerCustomerYN) {
        this.SellerCustomerYN = sellerCustomerYN;
    }

    public String getExternalAuditYN() {
        return this.ExternalAuditYN;
    }

    public void setExternalAuditYN(String externalAuditYN) {
        this.ExternalAuditYN = externalAuditYN;
    }

    public String getSellerGuaranteeUseYN() {
        return this.SellerGuaranteeUseYN;
    }

    public void setSellerGuaranteeUseYN(String sellerGuaranteeUseYN) {
        this.SellerGuaranteeUseYN = sellerGuaranteeUseYN;
    }

    public String getSellerKEDinfoYN() {
        return this.SellerKEDinfoYN;
    }

    public void setSellerKEDinfoYN(String sellerKEDinfoYN) {
        this.SellerKEDinfoYN = sellerKEDinfoYN;
    }

    public String getSellerShutoffYN() {
        return this.SellerShutoffYN;
    }

    public void setSellerShutoffYN(String sellerShutoffYN) {
        this.SellerShutoffYN = sellerShutoffYN;
    }

    public String getSellerClearYN() {
        return this.SellerClearYN;
    }

    public void setSellerClearYN(String sellerClearYN) {
        this.SellerClearYN = sellerClearYN;
    }
    
    public ArrayList<LimitVO> getLimitList() {
        return LimitList;
    }

    public void setLimitList(ArrayList<LimitVO> limitList) {
        this.LimitList = limitList;
    }

    public class LimitVO {
    	public String LimitCode;
    	public String LimitAMT;
    	public String LimitBalance;
    	public String LimitApare;
    	public String LimitExpirationDate;
    }
}
