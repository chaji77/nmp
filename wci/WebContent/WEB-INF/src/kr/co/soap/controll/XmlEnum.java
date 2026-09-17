package kr.co.soap.controll;

import java.io.File;

import kr.co.funology.fw.mgr.ConfigurationMgr;

public class XmlEnum {
	public static boolean TEST = true;

    public static String TEMPLATE_HOME = ConfigurationMgr.getInstance().getString("XML_TEMPLATE_PATH");
    // "F:\\app\\WorkSpace\\mp\\WebContent\\WEB-INF\\xmltemplate";
    
    // 템플릿 파일 이름 배열
    private static final String[] TEMPLATE_FILES = {
    		"K3XX_RESPONSE.xml", "B311.xml", "B311_SB.xml", "B311_SB_298.xml", "B311_NH.xml",
            "B311_CARD.xml", "B311_LOAN_SB.xml", "B313.xml", "B315.xml", "A311_SKNET.xml", 
            "A311.xml", "A185.xml", "A181.xml", "K312.xml", "K316.xml", "K322.xml", "K612.xml", 
            "K616.xml", "K712.xml", "E231.xml", "E241.xml", "E245.xml", "F231.xml", "F241.xml", 
            "F245.xml", "H221.xml", "H225.xml", "H227.xml", "B211.xml", "B213.xml", "B215.xml", 
            "K231.xml", "K235.xml", "L211.xml", "L213.xml", "L215.xml", "M211.xml", "M213.xml", 
            "M215.xml", "M221.xml", "M225.xml", "A311_KIBO.xml", "B311_KIBO.xml", "A211.xml", "A411.xml", "A181_KIBO.xml", "B315_KIBO.xml"
    };
    
    // 템플릿 파일 경로를 자동으로 생성
    public static String getTemplatePath(String templateName) {
        for (String template : TEMPLATE_FILES) {
            if (template.equals(templateName)) {
            	
            	String path = TEMPLATE_HOME + "/" + template;
                System.out.println("Template Path: " + path); // 경로 확인용 로그
            	
                return TEMPLATE_HOME + "/" + template;
            }
        }
        throw new IllegalArgumentException("Template not found: " + templateName);
    }
    
public static String getOrgCode(int pay_id) {
    	
    	String tmpVal = "";

    	if(104 == pay_id) 	   // 구매자금대출(서울보증재단)
            tmpVal = "2851105";
        else if(114 == pay_id) // 구매자금대출(강원보증재단)
            tmpVal = "2851406";
        else if(124 == pay_id) // 구매자금대출(경기보증재단)
            tmpVal = "2850070";
        else if(134 == pay_id) // 구매자금대출(경남보증재단)
            tmpVal = "2850180";
        else if(144 == pay_id) // 구매자금대출(경북보증재단)
            tmpVal = "2852104";
        else if(154 == pay_id) // 구매자금대출(광주보증재단)
            tmpVal = "2850300";
        else if(164 == pay_id) // 구매자금대출(대구보증재단)
            tmpVal = "2850371";
        else if(174 == pay_id) // 구매자금대출(대전보증재단)
            tmpVal = "2850481";
        else if(184 == pay_id) // 구매자금대출(부산보증재단)
            tmpVal = "2850588";
        else if(194 == pay_id) // 구매자금대출(울산보증재단)
            tmpVal = "2851901";
        else if(204 == pay_id) // 구매자금대출(인천보증재단)
            tmpVal = "2850708";
        else if(214 == pay_id) // 구매자금대출(전남보증재단)
            tmpVal = "2853019";
        else if(224 == pay_id) // 구매자금대출(전북보증재단)
            tmpVal = "2854115";
        else if(234 == pay_id) // 구매자금대출(제주보증재단)
            tmpVal = "2854403";
        else if(244 == pay_id) // 구매자금대출(충남보증재단)
            tmpVal = "2850805";
        else if(254 == pay_id) // 구매자금대출(충북보증재단)
            tmpVal = "2851707";

    	return tmpVal;
    }
}
