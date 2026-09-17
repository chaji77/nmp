package kr.co.soap.kibo;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Enumeration;
import java.util.Hashtable;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;

import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.kibo.CommonElement;
import kr.co.soap.kibo.loan.emtnet.EmtNetRcvBM;

@WebServlet(name="KiboResponseTransaction", urlPatterns="/KiboResponseTransaction")
public class KiboResponseTransaction extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger(KiboResponseTransaction.class);

    // 문자 인코딩 변환 유틸 메서드들
    private String asc2ksc(String str) {
        if (str == null) return "";
        try {
            return new String(str.getBytes("8859_1"), "KSC5601");
        } catch (Exception e) {
        	logger.error("asc2ksc 변환 오류", e);
            return str;
        }
    }

    private String asc2utf(String str) {
        if (str == null) return "";
        try {
            return new String(str.getBytes("8859_1"), "UTF-8");
        } catch (Exception e) {
        	logger.error("asc2utf 변환 오류", e);
            return str;
        }
    }

    // XML에 유효하지 않은 문자를 공백으로 치환
    private String stripNonValidXMLCharacters(String in) {
        if (in == null || in.isEmpty()) return "";
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < in.length(); i++) {
            char current = in.charAt(i);
            if ((current == 0x9) ||
                (current == 0xA) ||
                (current == 0xD) ||
                ((current >= 0x20) && (current <= 0xD7FF)) ||
                ((current >= 0xE000) && (current <= 0xFFFD)) ||
                ((current >= 0x10000) && (current <= 0x10FFFF))) {
                out.append(current);
            } else {
                out.append(" ");
            }
        }
        return out.toString();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html; charset=utf-8");
        PrintWriter out = response.getWriter();
        
        try {
            String name = null;
            String value = null;
            String ret = "";
            
            String paramType = "XML";
            Enumeration<?> paramNames = request.getParameterNames();
            Hashtable<String, String> hash = new Hashtable<>();
            while (paramNames.hasMoreElements()) {
                name = (String) paramNames.nextElement();
                value = asc2ksc(request.getParameter(name));
                hash.put(name, value);
            }
            
            if ("XML".equals(paramType)) {
                String inXML = (String)hash.get("inXML");
                logger.debug("##inXML = [" + inXML + "]");
                Document doc = null;
                try {
                    doc = XMLEasyUtil.parseXMLDocument(inXML, "utf-8");
                    System.out.println("111111111111111111111111111");
                } catch (Exception e) {
                	System.out.println("11111111111111111111111111122222222222222222222222");
                    inXML = stripNonValidXMLCharacters(inXML);
                    doc = XMLEasyUtil.parseXMLDocument(inXML, "utf-8");
                }
                System.out.println("11111111111111111111111111122222222222222222222222333333333333333333333333");
                // CommonElement 생성 
                CommonElement reqCommonElement = new CommonElement(doc);
                
                // 거래 전문(TransactionNO)에 따라 처리 분기
                if(reqCommonElement.getTransactionNO().equals("A187")){
        			ret = "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\n" +
        			"<" + reqCommonElement.incrementTransactionNO(reqCommonElement.getTransactionNO()) + ">\n" +
        			"	<Header>\n" +
        			"	</Header>\n" +
        			"	<Body>\n" +
        			"		<CommPart>\n" +
        			"			<TransactionID>" +  "</TransactionID>\n" +
        			"			<CodeType>" + "</CodeType>\n" +
        			"			<TransactionLength></TransactionLength>\n" +
        			"			<Sender>" + reqCommonElement.getSender() + "</Sender>\n" +
        			"			<TransactionSEQNO>" + reqCommonElement.getTransactionSEQNO() +"</TransactionSEQNO>\n" +
        			"			<Receiver>" + reqCommonElement.getReceiver() + "</Receiver>\n" +
        			"			<TransactionNO>" + reqCommonElement.incrementTransactionNO(reqCommonElement.getTransactionNO()) + "</TransactionNO>\n" +
        			"			<TransactionDate>" + reqCommonElement.getTransactionDate() + "</TransactionDate>\n" +
        			"			<TransactionTime>" + reqCommonElement.getTransactionTime() + "</TransactionTime>\n" +
        			"			<ResponseCode>0000</ResponseCode>\n" +
        			"			<ResponseMessage></ResponseMessage>\n" +
        			"			<UserField></UserField>\n" +
        			"		</CommPart>\n" +
        			"	</Body>\n" +
        			"</" + reqCommonElement.incrementTransactionNO(reqCommonElement.getTransactionNO()) + ">";
        		}
                else if (reqCommonElement.getTransactionNO().equals("K311") ||
                		 reqCommonElement.getTransactionNO().equals("K315") ||
                		 reqCommonElement.getTransactionNO().equals("B331") ||
                		 reqCommonElement.getTransactionNO().equals("B341") ||
                		 reqCommonElement.getTransactionNO().equals("K325") ||
                		 reqCommonElement.getTransactionNO().equals("K321") ||
                		 reqCommonElement.getTransactionNO().equals("B413")) {
                    if (reqCommonElement.getOrderNO() != null) {
                        EmtNetRcvBM rcvBM = new EmtNetRcvBM();
                        ret = rcvBM.receiveBM(inXML);
                        System.out.println(ret);
                    } 
                } 
                else {
                    System.out.println("기보 " + reqCommonElement.getTransactionNO() + "담보");
                    ret = forwardToBServer(doc);
                }
                logger.debug("##Returned from innerApp ==>(" + ret + ")");
                out.print(ret);
            } else {
            	logger.debug("지정된 Receiver.ParameterType이 없습니다.");
            }
        } catch (Exception e) {
        	logger.error("AppReceive Exception " + e.toString(), e);
            out.print(e.toString() + " : 에러");
        }
    }
    
    private String forwardToBServer(Document doc) {
    	
    	System.out.println("Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::");
    	System.out.println("Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::");
    	System.out.println("Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::");
    	System.out.println("Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::Loan::");
    	
        String targetUrl = "http://210.112.124.3:7770/mps/AppReceive.jsp";

        try {
            String resultXML = XMLEasyUtil.documentToString(doc);
            logger.debug(">> Forwarding XML to AppReceive.jsp:\n" + resultXML);

            URL url = new URL(targetUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=EUC-KR");

            try (OutputStream os = conn.getOutputStream()) {
                os.write("inXML=".getBytes("US-ASCII"));
                os.write(resultXML.getBytes("EUC-KR"));
            }

            StringBuilder response = new StringBuilder();
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "EUC-KR"))) {
                String line;
                while ((line = in.readLine()) != null) {
                    response.append(line);
                }
            }

            return response.toString();

        } catch (Exception e) {
            logger.error("서버 포워딩 중 오류 발생", e);
            return "<error>포워딩 오류: " + e.getMessage() + "</error>";
        }
        
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
