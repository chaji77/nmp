package kr.co.soap.kodit.loan;

import java.io.FileReader;
import java.util.ArrayList;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.A211VO;
import kr.co.soap.controll.A212VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.XmlEnum;

public class Kodit_A211 {

    private Document doc = null;
    
    public A212VO executeA211(A211VO requestVO) {
        
        A212VO a212VO = new A212VO();
        
        try {
            this.readData();  
            this.makeA211XML(requestVO);
            a212VO = this.sendA211();
        } catch (Exception ex) {
            CommonElement errorElement = new CommonElement();
            errorElement.setResponseCode("0099");
            errorElement.setResponseMessage(ex.getMessage().substring(0, Math.min(40, ex.getMessage().length())));
            a212VO.setCommon(errorElement);
        }
        
        return a212VO;
        
    }
    
    protected CommonElement readData() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        return commonElement;
    }
    
    private void makeA211XML(A211VO requestVO) throws Exception {
        try (FileReader fileReader = new FileReader(XmlEnum.getTemplatePath("A211.xml"))) {
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
            XMLUtil.setNodeValue(doc, "sb:BuyerID", requestVO.getBuyerID());
            XMLUtil.setNodeValue(doc, "sb:BuyerBusinessNO", requestVO.getBuyerBusinessNO());
            XMLUtil.setNodeValue(doc, "sb:SellerID", requestVO.getSellerID());
            XMLUtil.setNodeValue(doc, "sb:SellerBusinessNO", requestVO.getSellerBusinessNO());
        }
    }
    
    private A212VO sendA211() throws Exception {
        
        Document resDoc = HttpClientUtil.shinboCall(this.doc);
        
        // HttpClientUtil에서 받은 CommonElement 변환
        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();
        
        if (resinfo == null) {
            throw new Exception("Response information is null");
        }
        
        CommonElement newCommonElement = new CommonElement();
        newCommonElement.setSender(resinfo.getSender());
        newCommonElement.setReceiver(resinfo.getReceiver());
        newCommonElement.setTransactionNO(resinfo.getTransactionNO());
        newCommonElement.setTransactionDate(resinfo.getTransactionDate());
        newCommonElement.setTransactionTime(resinfo.getTransactionTime());
        newCommonElement.setResponseCode(resinfo.getResponseCode());
        newCommonElement.setResponseMessage(resinfo.getResponseMessage());
        
        A212VO a212vo = new A212VO();
        a212vo.setCommon(newCommonElement);
        
        if ("0000".equals(resinfo.getResponseCode())) {
            // 기본 응답 필드 세팅
            a212vo.setBuyerCustomerYN(XMLUtil.getNodeValue(resDoc, "sb:BuyerCustomerYN", "-"));
            a212vo.setSellerCustomerYN(XMLUtil.getNodeValue(resDoc, "sb:SellerCustomerYN", "-"));
            a212vo.setExternalAuditYN(XMLUtil.getNodeValue(resDoc, "sb:ExternalAuditYN", "-"));
            a212vo.setSellerGuaranteeUseYN(XMLUtil.getNodeValue(resDoc, "sb:SellerGuaranteeUseYN", "-"));
            a212vo.setSellerKEDinfoYN(XMLUtil.getNodeValue(resDoc, "sb:SellerKEDinfoYN", "-"));
            a212vo.setSellerShutoffYN(XMLUtil.getNodeValue(resDoc, "sb:SellerShutoffYN", "-"));
            a212vo.setSellerClearYN(XMLUtil.getNodeValue(resDoc, "sb:SellerClearYN", "-"));

            // 한도 정보 추가
            String limitCountStr = XMLUtil.getNodeValue(resDoc, "sb:LimitCount", "0");
            int limitCount = 0;
            try {
                limitCount = Integer.parseInt(limitCountStr);
            } catch (NumberFormatException e) {
                limitCount = 0;
            }
            a212vo.setLimitCount(limitCount);

            ArrayList<A212VO.LimitVO> limitList = new ArrayList<A212VO.LimitVO>();
            for (int i = 0; i < Math.min(limitCount, 3); i++) {
                A212VO.LimitVO vo = new A212VO().new LimitVO();
                //limitList.LimitCode = XMLUtil.getNodeValue(resDoc, "sb:LimitCode", i);
                //String limitAmt = XMLUtil.getNodeValue(resDoc, "sb:LimitAMT", i);
                //if (limitCode == null && limitAmt == null) continue;
                vo.LimitCode = XMLUtil.getNodeValue(resDoc, "sb:LimitCode", i);
                vo.LimitAMT = XMLUtil.getNodeValue(resDoc, "sb:LimitAMT", i);
                vo.LimitBalance = XMLUtil.getNodeValue(resDoc, "sb:LimitBalance", i);
                vo.LimitApare = XMLUtil.getNodeValue(resDoc, "sb:LimitApare", i);
                vo.LimitExpirationDate = XMLUtil.getNodeValue(resDoc, "sb:LimitExpirationDate", i);
                limitList.add(vo);
            }
            a212vo.setLimitList(limitList);

        } else {
            // 실패 시 기본값
            a212vo.setBuyerCustomerYN("-");
            a212vo.setSellerCustomerYN("-");
            a212vo.setExternalAuditYN("-");
            a212vo.setSellerGuaranteeUseYN("-");
            a212vo.setSellerKEDinfoYN("-");
            a212vo.setSellerShutoffYN("-");
            a212vo.setSellerClearYN("-");
            a212vo.setLimitCount(0);
            a212vo.setLimitList(new ArrayList<>());
        }
        
        return a212vo;
        
    }
    
    private void setXMLNodeValue(String node, String value) {
        if (!StrUtil.isEmpty(value)) {
            XMLUtil.setNodeValue(doc, node, value);
        }
    }
    
    public static void main(String[] args) {
        A211VO a211vo = new A211VO();
        a211vo.setBuyerID("1101113582627");
        a211vo.setBuyerBusinessNO("1198194650");
        a211vo.setSellerID("1101113582627");
        a211vo.setSellerBusinessNO("1198194650");
        
        Kodit_A211 a211 = new Kodit_A211();
        A212VO a212VO = a211.executeA211(a211vo);
        
        System.out.println("외감기업여부: " + a212VO.getExternalAuditYN());
        System.out.println("판매기업보증이용여부: " + a212VO.getSellerGuaranteeUseYN());
        System.out.println("판매기업KED정보보유: " + a212VO.getSellerKEDinfoYN());
        System.out.println("판매기업사전차단여부: " + a212VO.getSellerShutoffYN());
        System.out.println("판매기업차단해제여부: " + a212VO.getSellerClearYN());
    }
}
