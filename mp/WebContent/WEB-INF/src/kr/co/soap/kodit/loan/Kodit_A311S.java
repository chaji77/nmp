package kr.co.soap.kodit.loan;

import java.io.FileReader;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.A311VO;
import kr.co.soap.controll.A312VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.XmlEnum;

public abstract class Kodit_A311S {

    protected String MPCode = null;
    private Document doc    = null;
    private Document resDoc = null;
    protected A311VO kodit_A311VO = new A311VO();
    private A312VO   kodit_A312VO = new A312VO();

    protected Kodit_A311S() {}
    protected Kodit_A311S(String p_MPCode) {
        this.MPCode = p_MPCode;
    }

    public A312VO executeA311S() {
        CommonElement commonElement = null;
        try {
            commonElement = this.makeA311SVO();
            if (!commonElement.getResponseCode().equals("0000")) {
                kodit_A312VO.getCommonElement().setResponseCode(commonElement.getResponseCode());
                kodit_A312VO.getCommonElement().setResponseMessage(commonElement.getResponseMessage());
            } else {
                this.makeA311SXML();
                this.kodit_A312VO = this.sendA311S();
            }
        } catch (Exception ex) {
            executeException(ex);
        }
        return this.kodit_A312VO;
    }

    private void executeException(Exception ex) {
        ex.printStackTrace();
        kodit_A312VO.getCommonElement().setResponseCode("0099");
        String exMsg = ex.getMessage();
        kodit_A312VO.getCommonElement().setResponseMessage(
            (exMsg == null || exMsg.length() < 50) ? exMsg : exMsg.substring(0, 50));
    }

    protected CommonElement makeA311SVO() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        return commonElement;
    }

    private void makeA311SXML() throws Exception {
        String file_name = XmlEnum.getTemplatePath("A311S.xml");
        System.out.println("A311S file_name:::::::::::" + file_name);
        FileReader fileReader = new FileReader(file_name);
        this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
        setXML();
    }

    private void setXML() {
        setXMLNodeValue("sb:Sender",           kodit_A311VO.getCommonElement().getSender());
        setXMLNodeValue("sb:TransactionSEQNO", kodit_A311VO.getCommonElement().getTransactionSEQNO());
        setXMLNodeValue("sb:Receiver",         kodit_A311VO.getCommonElement().getReceiver());
        setXMLNodeValue("sb:TransactionDate",  kodit_A311VO.getCommonElement().getTransactionDate());
        setXMLNodeValue("sb:TransactionTime",  kodit_A311VO.getCommonElement().getTransactionTime());
        setXMLNodeValue("sb:UserField",        kodit_A311VO.getCommonElement().getUserField());

        setBuyerSellerDetails("sb:BuyerID",    kodit_A311VO.getBuyerID());
        setXMLNodeValue("sb:BuyerBusinessNO",  kodit_A311VO.getBuyerBusinessNO());

        setBuyerSellerDetails("sb:SellerID",   kodit_A311VO.getSellerID());
        setXMLNodeValue("sb:SellerBusinessNO", kodit_A311VO.getSellerBusinessNO());

        setXMLNodeValue("sb:SettlementType",   kodit_A311VO.getSettlementType());
        setXMLNodeValue("sb:SettlementDueAMT", kodit_A311VO.getSettlementDueAMT());
    }

    private void setBuyerSellerDetails(String node, String id) {
        String value = StrUtil.isEmpty(StrUtil.nvl(id)) ? "0000000000000" : id;
        setXMLNodeValue(node, value);
    }

    private void setXMLNodeValue(String node, String value) {
        if (!StrUtil.isEmpty(value)) {
            XMLUtil.setNodeValue(doc, node, value);
        }
    }

    private A312VO sendA311S() throws Exception {
        this.resDoc = HttpClientUtil.shinboCall(this.doc);
        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();

        CommonElement commonElement = new CommonElement();
        commonElement.setSender(resinfo.getSender());
        commonElement.setTransactionSEQNO(resinfo.getTransactionSEQNO());
        commonElement.setReceiver(resinfo.getReceiver());
        commonElement.setTransactionNO(resinfo.getTransactionNO());
        commonElement.setTransactionDate(resinfo.getTransactionDate());
        commonElement.setTransactionTime(resinfo.getTransactionTime());
        commonElement.setResponseCode(resinfo.getResponseCode());
        commonElement.setResponseMessage(resinfo.getResponseMessage());
        commonElement.setUserField(resinfo.getUserField());

        A312VO kodit_A312 = new A312VO();
        kodit_A312.setCommonElement(commonElement);

        if ("0000".equals(commonElement.getResponseCode())) {
            setResponseDetails(kodit_A312);
        }
        return kodit_A312;
    }

    private void setResponseDetails(A312VO kodit_A312) {
        kodit_A312.setBuyerID(XMLUtil.getNodeValue(resDoc, "sb:BuyerID"));
        kodit_A312.setBuyerBusinessNO(XMLUtil.getNodeValue(resDoc, "sb:BuyerBusinessNO"));
        kodit_A312.setBuyerB2BMemberYN(XMLUtil.getNodeValue(resDoc, "sb:BuyerB2BMemberYN"));
        kodit_A312.setBuyerSettlementType(XMLUtil.getNodeValue(resDoc, "sb:BuyerSettlementType"));
        kodit_A312.setBuyerSettlementMemberYN(XMLUtil.getNodeValue(resDoc, "sb:BuyerSettlementMemberYN"));

        if ("0070000".equals(kodit_A311VO.getCommonElement().getReceiver())) {
            kodit_A312.setBankLimitYN("N");
        } else {
            kodit_A312.setBankLimitYN(XMLUtil.getNodeValueOption(resDoc, "sb:BankLimitYN", 0));
        }
        kodit_A312.setBankLimitSpareYN(XMLUtil.getNodeValueOption(resDoc, "sb:BankLimitSpareYN", 0));
        kodit_A312.setBankLimitAMT(XMLUtil.getNodeValue(resDoc, "sb:BankLimitAMT"));
        kodit_A312.setBankLimitSpare(XMLUtil.getNodeValue(resDoc, "sb:BankLimitSpare"));

        // ★ 판매기업 약정여부
        kodit_A312.setSellerB2BMemberYN(XMLUtil.getNodeValue(resDoc, "sb:SellerB2BMemberYN"));
    }
}