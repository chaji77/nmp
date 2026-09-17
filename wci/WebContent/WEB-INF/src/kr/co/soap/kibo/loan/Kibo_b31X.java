package kr.co.soap.kibo.loan;

import java.util.ArrayList;

import org.w3c.dom.Document;

import kr.co.soap.controll.B311ItemVO;
import kr.co.soap.controll.B311VO;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.kibo.HttpClientUtil;

public class Kibo_b31X {
	
	private static final String SUCCESS_CODE = "0000";
    private static final String ERROR_CODE = "0999";
    private String strGubun = "KIBO";

    protected String MPCode = null;     
    protected String kind = null;
    protected String strUser = null;
    protected Document doc = null;
    protected B311VO xml_b311 = new B311VO();
    protected ArrayList<B311ItemVO> xml_b311_itemList = new ArrayList<>();
    private boolean DEBUG = true;
    
    protected Kibo_b31X() { }

    protected Kibo_b31X(String p_MPCode) {
        this.MPCode = p_MPCode;
    }
    
    public CommonElement executeB31X(int intCtId) {
        CommonElement commonElement = new CommonElement();
        try {
            // Read or Sync Table Data
            commonElement = this.readSyncTableData(intCtId);
            
            if (SUCCESS_CODE.equals(commonElement.getResponseCode())) {
                commonElement = this.validateProcess();

                if (SUCCESS_CODE.equals(commonElement.getResponseCode())) {
                    // Process the makeB31X, saveToDB, sendB31X
                	commonElement = this.createAndSendB31X(intCtId, strUser);
                    // After receiving response, update DB
                    this.updateDBWithResponse(commonElement);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            commonElement.setResponseCode(ERROR_CODE);
            commonElement.setResponseMessage(ex.getMessage());
        }

        return commonElement;
    }

    private CommonElement createAndSendB31X(int intCtId, String strUser) throws Exception {
    	
        makeB31X(intCtId, strUser);
        saveToDB();	//SEND_XML_B311 TABLE => DATA INSERT
        
        // Send B31X and handle response
        CommonElement commonElement = this.sendB31X(this.xml_b311.getCtId(), this.xml_b311.getSeqNO());
        
        return commonElement; 
    }

    // Override
    protected CommonElement readSyncTableData(int intCtId) throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode(SUCCESS_CODE);
        return commonElement;
    }

    protected void readSyncTableData() {}

    protected String getTemplate(B311VO p_xml_b311) {
        return XmlEnum.getTemplatePath("B311_KIBO.xml");
    }

    protected CommonElement validateProcess() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode(SUCCESS_CODE);
        return commonElement;
    }

    protected void makeB31X(int intCtId, String strUser) throws Exception {}

    protected void updateDBWithResponse(CommonElement commonElement) throws Exception {}

    // Send B31X request and handle response
    protected CommonElement sendB31X(int intCtId, String p_seqNO) throws Exception {
    	
        this.createB31XXML(intCtId, p_seqNO); // kodit_b311

        if ((this.xml_b311.getOrgCode() == null) || ("".equals(this.xml_b311.getOrgCode()))) {
        	System.out.println("111111111111111 kibo");
        	HttpClientUtil.kiboCall(this.doc);
        } else {
        	System.out.println("111111111111111 kibo2");
        	this.strGubun = "kibo_yun_sURL";
            HttpClientUtil.kiboCall(this.doc, this.strGubun);
        }
        
        CommonElement resinfo = HttpClientUtil.getCommonElement(); // HttpClientUtil에서 받은 CommonElement 변환

        if (resinfo == null) {
            throw new Exception("Response information is null");
        }
        
        return mapToCommonElement(resinfo);
    }

    private CommonElement mapToCommonElement(CommonElement resinfo) {
    	if (resinfo == null) {
            throw new IllegalArgumentException("CommonElementResInfo cannot be null");
        }
        CommonElement newCommonElement = new CommonElement();
        
        newCommonElement.setSender(resinfo.getSender());
        newCommonElement.setTransactionSEQNO(resinfo.getTransactionSEQNO());
        newCommonElement.setReceiver(resinfo.getReceiver());
        newCommonElement.setTransactionNO(resinfo.getTransactionNO());
        newCommonElement.setTransactionDate(resinfo.getTransactionDate());
        newCommonElement.setTransactionTime(resinfo.getTransactionTime());
        newCommonElement.setResponseCode(resinfo.getResponseCode());
        newCommonElement.setResponseMessage(resinfo.getResponseMessage());
        newCommonElement.setUserField(resinfo.getUserField());
        
        return newCommonElement;
    }

    // Methods to create XML for B31X
    protected void createB31XXML(int intCtId, String p_seqNO) throws Exception {}

    protected void createB31X_makeXML(int p_itemCount) throws Exception {}

    protected void createB31X_setValue(B311VO p_b311, ArrayList<SoapCommonVO.XmlB311ItemVO> p_b311_ItemList) throws Exception {}

    // Save data to DB
    protected void saveToDB() throws Exception {
    	
    	SoapCommonBean bean = new SoapCommonBean();
    	bean.SEND_XML_B311_ADD_PROC(this.xml_b311);
    	
    }

    // Get Document
    public Document getDocument() {
        return this.doc;
    }
    
}
