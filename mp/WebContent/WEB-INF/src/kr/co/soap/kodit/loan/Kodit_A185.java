package kr.co.soap.kodit.loan;

import java.io.FileReader;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.XmlEnum;

public class Kodit_A185 {
	
	protected String MPCode = null;
    protected String receiver = null;
    private Document doc = null;

    protected Kodit_A185() {}

    protected Kodit_A185(String p_MPCode, String p_receiver) {
        this.MPCode = p_MPCode;
        this.receiver = p_receiver;
    }

    public CommonElement executeA185() {
        CommonElement commonElement = new CommonElement();
        try {
            commonElement = this.readData();
            if (!"0000".equals(commonElement.getResponseCode())) {
                return commonElement;
            }

            this.makeA185XML();
            //return this.sendA185();            
            commonElement = this.sendA185();
        } catch (Exception ex) {
            commonElement.setResponseCode("0099");
            commonElement.setResponseMessage(ex.getMessage().substring(0, Math.min(40, ex.getMessage().length())));
        }
        return commonElement;
    }

    protected CommonElement readData() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        return commonElement;
    }

    private void makeA185XML() throws Exception {
        try (FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("A185.xml"))) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
            
            // XML 노드 값 설정
            XMLUtil.setNodeValue(this.doc, "sb:Sender", this.MPCode);
            XMLUtil.setNodeValue(this.doc, "sb:TransactionSEQNO", SequenceGenerator.getInstance().getTransSeqNO());
            XMLUtil.setNodeValue(this.doc, "sb:Receiver", this.receiver);
            XMLUtil.setNodeValue(this.doc, "sb:TransactionDate", DateTimeUtil.getCurrentDate(""));
            XMLUtil.setNodeValue(this.doc, "sb:TransactionTime", DateTimeUtil.getCurrentDateTime().substring(8, 14));
            XMLUtil.setNodeValue(this.doc, "sb:ResponseMessage", "트랜잭션 조회");
            
        }
    }
    
    private CommonElement sendA185() throws Exception {
        
    	//this.makeA185XML();
        
        HttpClientUtil.shinboCall(this.doc);
        
        // HttpClientUtil에서 받은 CommonElement 변환
        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();
        
        if (resinfo == null) {
            throw new Exception("Response information is null");
        }
        
        return mapToNewCommonElement(resinfo);
    }

    private CommonElement mapToNewCommonElement(CommonElementResInfo resinfo) {
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
    
    public static void main(String[] args) throws Exception {
    	System.out.println("Default Charset: " + java.nio.charset.Charset.defaultCharset());
        System.out.println("file.encoding: " + System.getProperty("file.encoding"));
    	
    	Kodit_A185 a185 = new Kodit_A185("EMTNET", "0760000");
    	a185.executeA185();
    }
}
