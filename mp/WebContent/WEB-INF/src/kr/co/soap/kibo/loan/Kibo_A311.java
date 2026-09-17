package kr.co.soap.kibo.loan;

import java.io.FileReader;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.A312VO;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.kibo.HttpClientUtil;
import kr.co.soap.controll.kibo.Kibo_A311VO;

public abstract class Kibo_A311 {
	protected String MPCode = null;
    private Document doc  = null;
    private Document resDoc = null;
    protected Kibo_A311VO kibo_A311VO = new Kibo_A311VO();
    private A312VO kibo_A312VO = new A312VO();
    private String strGubun = "KIBO";

    protected Kibo_A311() { }

    protected Kibo_A311(String p_MPCode)
    {
        this.MPCode = p_MPCode;
    }

    public A312VO executeA311()
    {
        CommonElement commonElement = null;
        try
        {
            commonElement = this.makeA311VO();
            if(!commonElement.getResponseCode().equals("0000"))
            {
                this.kibo_A312VO.getCommonElement().setResponseCode(commonElement.getResponseCode());
                this.kibo_A312VO.getCommonElement().setResponseMessage(commonElement.getResponseMessage());
            }
            else
            {
                this.makeA311XML();
                this.kibo_A312VO = this.sendA311();
            }
        }
        catch (Exception ex)
        {
        	executeException(ex);
        }
        return this.kibo_A312VO;
    }
    
    private void executeException(Exception ex) {
        ex.printStackTrace();
        kibo_A312VO.getCommonElement().setResponseCode("0099");
        String exMsg = ex.getMessage();
        kibo_A312VO.getCommonElement().setResponseMessage((exMsg == null || exMsg.length() < 50) ? exMsg : exMsg.substring(0, 50));
    }

    protected CommonElement makeA311VO() throws Exception
    {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        return commonElement;
    }

    private void makeA311XML() throws Exception
    {
        String file_name = "";
        file_name = XmlEnum.getTemplatePath("A311_KIBO.xml");
        System.out.println("file_name:::::::::::"+file_name);
        
        FileReader fileReader = new FileReader(file_name);
        this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));

        setXML();
    }
    
    private void setXML() {
    	
    	System.out.println("################################");
    	System.out.println(this.kibo_A311VO.getPayId());
    	System.out.println("################################");
    	
    	if (100 < Integer.parseInt(this.kibo_A311VO.getPayId())) {
    		NodeList nl = this.doc.getElementsByTagName("IndivPart");
    		Element OrgCode = this.doc.createElement("OrgCode");
    		nl.item(0).appendChild(OrgCode);
        }
    	
        setXMLNodeValue("Sender", kibo_A311VO.getCommonElement().getSender());
        setXMLNodeValue("TransactionSEQNO", kibo_A311VO.getCommonElement().getTransactionSEQNO());
        setXMLNodeValue("Receiver", kibo_A311VO.getCommonElement().getReceiver());
        setXMLNodeValue("TransactionNO", "A311");
        setXMLNodeValue("TransactionDate", kibo_A311VO.getCommonElement().getTransactionDate());
        setXMLNodeValue("TransactionTime", kibo_A311VO.getCommonElement().getTransactionTime());
        setXMLNodeValue("ResponseCode", "0000");
        setXMLNodeValue("UserField", kibo_A311VO.getCommonElement().getUserField());

        setBuyerSellerDetails("BuyerID", kibo_A311VO.getBuyerID());
        setXMLNodeValue("BuyerBusinessNO", kibo_A311VO.getBuyerBusinessNO());
        setBuyerSellerDetails("SellerID", kibo_A311VO.getSellerID());
        setXMLNodeValue("SellerBusinessNO", kibo_A311VO.getSellerBusinessNO());

        setXMLNodeValue("SettlementType", kibo_A311VO.getSettlementType());
        setXMLNodeValue("SettlementDueAMT", kibo_A311VO.getSettlementDueAMT());
        
        if (100 < Integer.parseInt(this.kibo_A311VO.getPayId())) {
        	this.strGubun = "kibo_yun_sURL";
        	setXMLNodeValue("OrgCode", kibo_A311VO.getOrgCode());
        }
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
    

    private A312VO sendA311() throws Exception
    {
         //this.makeA311XML();
    	 System.out.println("this.strGubun : " + this.strGubun);
    	
         //kiboCall...
         this.resDoc = (this.strGubun.equals("kibo_yun_sURL") ? HttpClientUtil.kiboCall(this.doc, "kibo_yun_sURL") : HttpClientUtil.kiboCall(this.doc));

         CommonElement resinfo = HttpClientUtil.getCommonElement();

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

         A312VO kibo_A312 = new A312VO();
         kibo_A312.setCommonElement(commonElement);

         if ("0000".equals(commonElement.getResponseCode())) {
             setResponseDetails(kibo_A312);
         }
         
         return kibo_A312;
    }
    
    private void setResponseDetails(A312VO kibo_A312) {
    	kibo_A312.setBuyerID(XMLUtil.getNodeValue(resDoc, "BuyerID"));
    	kibo_A312.setBuyerBusinessNO(XMLUtil.getNodeValue(resDoc, "BuyerBusinessNO"));
    	kibo_A312.setBuyerB2BMemberYN(XMLUtil.getNodeValue(resDoc, "BuyerB2BMemberYN"));
    	kibo_A312.setBuyerSettlementType(XMLUtil.getNodeValue(resDoc, "BuyerSettlementType"));
    	kibo_A312.setBuyerSettlementMemberYN(XMLUtil.getNodeValue(resDoc, "BuyerSettlementMemberYN"));
    	kibo_A312.setBankLimitYN(XMLUtil.getNodeValueOption(resDoc, "BankLimitYN", 0));
        kibo_A312.setBankLimitSpareYN(XMLUtil.getNodeValueOption(resDoc, "BankLimitSpareYN", 0));
        kibo_A312.setBankLimitAMT(XMLUtil.getNodeValue(resDoc, "BankLimitAMT"));
        kibo_A312.setBankLimitSpare(XMLUtil.getNodeValue(resDoc, "BankLimitSpare"));
        //kibo_A312.setBankLimitSpare("Y".equals(XMLUtil.getNodeValueOption(resDoc, "BankLimitSpareYN", 0))
        //    ? XMLUtil.getNodeValue(resDoc, "BankLimitSpare") : "0");
    }
}
