package kr.co.soap.kodit.loan;

import java.io.FileReader;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.A411VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.XmlEnum;

public class Kodit_A411 {
    
    private Document doc = null;
    
    public CommonElement executeA411(A411VO requestVO) {
        CommonElement commonElement = new CommonElement();
        try {
            commonElement = this.readData();
            if (!"0000".equals(commonElement.getResponseCode())) {
                return commonElement;
            }

            this.makeA411XML(requestVO);

            commonElement = this.sendA411();
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
    
    private void makeA411XML(A411VO requestVO) throws Exception {
        try (FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("A411.xml"))) {
            this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
            
            // Common 영역
            //setXMLNodeValue("sb:Sender", requestVO.getSender());
            setXMLNodeValue("sb:TransactionSEQNO", SequenceGenerator.getInstance().getTransSeqNO());
            //setXMLNodeValue("sb:Receiver", requestVO.getReceiver());
            setXMLNodeValue("sb:TransactionDate", DateTimeUtil.getCurrentDate(""));
            setXMLNodeValue("sb:TransactionTime", DateTimeUtil.getCurrentDateTime().substring(8, 14));
            //setXMLNodeValue("sb:ResponseMessage", requestVO.getResponseMessage());
            //setXMLNodeValue("sb:UserField", requestVO.getUserField());

            // Transfer 영역
            setXMLNodeValue("sb:SellerID", requestVO.getSellerID());
            setXMLNodeValue("sb:SellerBusinessNO", requestVO.getSellerBusinessNO());
            setXMLNodeValue("sb:SellerShutoffYN", requestVO.getSellerShutoffYN());
            setXMLNodeValue("sb:SellerClearYN", requestVO.getSellerClearYN());
            
        }
    }
    
    private CommonElement sendA411() throws Exception {
        
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
        newCommonElement.setReceiver(resinfo.getReceiver());
        newCommonElement.setTransactionNO(resinfo.getTransactionNO());
        newCommonElement.setTransactionDate(resinfo.getTransactionDate());
        newCommonElement.setTransactionTime(resinfo.getTransactionTime());
        newCommonElement.setResponseCode(resinfo.getResponseCode());
        newCommonElement.setResponseMessage(resinfo.getResponseMessage());
        return newCommonElement;
    }
    
    private void setXMLNodeValue(String node, String value) {
        if (!StrUtil.isEmpty(value)) {
            XMLUtil.setNodeValue(doc, node, value);
        }
    }
    
    public static void main(String[] args) throws Exception {
        
        A411VO requestVO = new A411VO();
        
        Kodit_A411 a411 = new Kodit_A411();
        a411.executeA411(requestVO);
    }
}
