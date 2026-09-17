package kr.co.soap.kibo.loan;

import org.w3c.dom.Document;

import kr.co.soap.controll.kibo.CommonElement;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.K311VO;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.SoapCommonBean;

public abstract class Kibo_K3XX {
	private final K311VO xmlK311 = new K311VO();
    private final CommonElement resCommonElement = new CommonElement();
    
    private Document doc;
    private Document resDoc;
    private String transactionNO;
   
    protected String resTemplate;

    protected Kibo_K3XX() {}

    public Kibo_K3XX(Document inputDoc) {
        this.doc = inputDoc;
        if (this.doc != null) initializeResponseCommonElement();
    }
    
    private void initializeResponseCommonElement() {
    	
        this.transactionNO = XMLUtil.getNodeValue(this.doc, "TransactionNO");
        this.resCommonElement.setResponseCode("0000");
        this.resCommonElement.setSender(XMLUtil.getNodeValue(this.doc, "Sender"));
        this.resCommonElement.setTransactionSEQNO(XMLUtil.getNodeValue(this.doc, "TransactionSEQNO"));
        this.resCommonElement.setReceiver(XMLUtil.getNodeValue(this.doc, "Receiver"));

        String resTransactionNO = XMLUtil.getNodeValue(this.doc, "TransactionNO");
        
        this.resCommonElement.setTransactionNO(
        		resTransactionNO.substring(0, 3) + (Integer.parseInt(resTransactionNO.substring(3, 4)) + 1)
        );

        this.resCommonElement.setTransactionDate(XMLUtil.getNodeValue(this.doc, "TransactionDate"));
        this.resCommonElement.setTransactionTime(XMLUtil.getNodeValue(this.doc, "TransactionTime"));
        this.resCommonElement.setOrderNO(XMLUtil.getNodeValue(this.doc, "OrderNO"));
        this.resCommonElement.setContractDate(XMLUtil.getNodeValue(this.doc, "ContractDate"));
    }
    
    protected Document executeK3XX() throws Exception {
        try {
        	
            getCommonElement();				//K311VO set...
            getCommonTransferElement();		//주문번호, seq set...
            getK3XXBodyElement();			//그외 set...
            saveToDB();						//RECEIVE_XML_K311 insert

            if (!validateCommon().equals("1")) return this.resDoc;
            if (!validateByK3XX().equals("1")) return this.resDoc;

            processByK3XX();
            
        } catch (Exception ex) {
            ex.printStackTrace();
            this.resCommonElement.setResponseCode("9901");
            if ((ex.getMessage() != null) && (ex.getMessage().length() > 60))
              this.resCommonElement.setResponseMessage(ex.getMessage().substring(0, 59));
            else
              this.resCommonElement.setResponseMessage(ex.getMessage());
        }
        return this.resDoc;
    }
    
    private void getCommonElement() {
        this.xmlK311.setSender(XMLUtil.getNodeValue(this.doc, "Sender"));
        this.xmlK311.setTransactionseqno(XMLUtil.getNodeValue(this.doc, "TransactionSEQNO"));
        this.xmlK311.setReceiver(XMLUtil.getNodeValue(this.doc, "Receiver"));
        this.xmlK311.setTransactionno(XMLUtil.getNodeValue(this.doc, "TransactionNO"));
        this.xmlK311.setTransactiondate(XMLUtil.getNodeValue(this.doc, "TransactionDate"));
        this.xmlK311.setTransactiontime(XMLUtil.getNodeValue(this.doc, "TransactionTime"));
        this.xmlK311.setResponsecode(XMLUtil.getNodeValue(this.doc, "ResponseCode"));
        this.xmlK311.setResponsemessage(XMLUtil.getNodeValue(this.doc, "ResponseMessage"));
        this.xmlK311.setUserfield(XMLUtil.getNodeValue(this.doc, "UserField"));
        
        this.xmlK311.setFund("KIBO");
        
    }
    
    private void getCommonTransferElement() throws Exception {
        this.xmlK311.setOrderno(XMLUtil.getNodeValue(this.doc, "OrderNO"));
        
        LoanUtil loanUtil = new LoanUtil();
        this.xmlK311.setSeqno(loanUtil.getSeqNO_Kodit_xml_k311(this.xmlK311.getOrderno()));
    }
    
    protected void getK3XXBodyElement() {}
    
    private void saveToDB() throws Exception {
    	
    	if(this.xmlK311 == null) { System.out.println("saveToDB this.xmlK311 null"); }
    	
    	SoapCommonBean bean = new SoapCommonBean();
    	bean.RECEIVE_XML_K311_ADD_PROC(this.xmlK311);
    }

    protected String validateCommon() throws Exception {
        return "1";
    }

    protected String validateByK3XX() throws Exception {
        return "1";
    }

    public void updateDBWithResponse() throws Exception {
    	setXmlK311Data();
    	saveReceiveXmlK311();
    }
    
    private void setXmlK311Data() {
    	this.xmlK311.setRessender(this.resCommonElement.getSender());
        this.xmlK311.setRestransactionseqno(this.resCommonElement.getTransactionSEQNO());
        this.xmlK311.setResreceiver(this.resCommonElement.getReceiver());
        this.xmlK311.setRestransactionno(this.resCommonElement.getTransactionNO());
        this.xmlK311.setRestransactiondate(this.resCommonElement.getTransactionDate());
        this.xmlK311.setResuserfield(this.resCommonElement.getUserField());
        this.xmlK311.setRestransactiontime(this.resCommonElement.getTransactionTime());
        this.xmlK311.setResresponsecode(this.resCommonElement.getResponseCode());
        this.xmlK311.setResresponsemessage(this.resCommonElement.getResponseMessage());
        this.xmlK311.setResorderno(this.resCommonElement.getOrderNO());
        this.xmlK311.setRescontractdate(this.resCommonElement.getContractDate());
    }
    
    private void saveReceiveXmlK311() {
    	SoapCommonBean bean = new SoapCommonBean();
    	bean.RECEIVE_XML_K311_RES_MOD_PROC(this.xmlK311);
    }

    protected abstract void processByK3XX() throws Exception;

    protected K311VO getKiboXmlK311() {
        return this.xmlK311;
    }

    protected Document getDoc() {
        return this.doc;
    }

    public Document getResDoc() {
        return this.resDoc;
    }

    public CommonElement getResCommonElement() {
        return this.resCommonElement;
    }

    public String getTransactionNO() {
        return this.transactionNO;
    }

    public static void main(String[] args) {}
    
}
