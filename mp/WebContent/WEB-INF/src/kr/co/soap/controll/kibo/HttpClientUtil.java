package kr.co.soap.controll.kibo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.w3c.dom.Document;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.EnvironmentPropertiesDAO;
import kr.co.soap.controll.LoanUtil;

public class HttpClientUtil {
	
    private static final boolean DEBUG = true;
    private static final int TIMEOUT = 60000;
    
    private static CommonElement commonElement;
    //private static CommonElementResInfo commonElementResInfo;

    private static String getUrl(String code) {
    	
    	System.out.println("code : " + code);
    	System.out.println("code : " + code);
    	
        if (code == null || code.isEmpty()) {
            throw new IllegalArgumentException("Invalid HTTP URL for: " + code);
        } else {
            return EnvironmentPropertiesDAO.getInstance().getEnv(code);
        }
    }

    public static Document kiboCall(Document doc) throws Exception {
    	EnvironmentPropertiesDAO.getInstance().load(GlobalEnv.getWebRootDir() + "WEB-INF/environment.properties");
        return sendRequest(doc, "kibo_sURL");
    }

    public static Document kiboCall(Document doc, String strGubun) throws Exception {
    	EnvironmentPropertiesDAO.getInstance().load(GlobalEnv.getWebRootDir() + "WEB-INF/environment.properties");
        return sendRequest(doc, strGubun);
    }

    private static Document sendRequest(Document doc, String strGubun) throws Exception {
        log("strGubun: " + strGubun);

        StringWriter sw = new StringWriter();
        XMLUtil.displayXML(doc, sw);
        LoanUtil.fileWriteKibo(sw.toString());
        String reqXml = sw.toString();
        log("전송할 요청 전문", reqXml);
        
        System.out.println("#########################");
        System.out.println("#########################");
        System.out.println(reqXml);
        System.out.println("#########################");
        System.out.println("#########################");
        String httpURL = getUrl(strGubun);
        byte[] response;
        
        System.out.println("httpURL : " + httpURL);

        HttpURLConnection conn = null;
        try {
            URL url = new URL(httpURL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("XEDICS-Timeout", String.valueOf(TIMEOUT));
            conn.setRequestProperty("User-Agent", "XEDICS-RC 17");
            conn.setDoOutput(true);
            conn.setConnectTimeout(TIMEOUT);
            conn.setReadTimeout(TIMEOUT);

            //String postData = "inXML=" + URLEncoder.encode(reqXml, StandardCharsets.UTF_8.name());
            String postData = "inXML=" + URLEncoder.encode(reqXml, "EUC-KR");

            try (OutputStream os = conn.getOutputStream()) {
            	os.write(postData.getBytes("EUC-KR"));
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK) {
                throw new IOException("HTTP request failed with response code: " + responseCode);
            }

            try (InputStream is = conn.getInputStream()) {
                response = readInputStream(is);  
            }
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

        if (response == null || response.length == 0) {
            throw new Exception("No response received from server.");
        }

        logResponseHeaders(response);
        LoanUtil.fileWriteKibo(new String(response, "EUC-KR").trim());
        Document resDoc = parseResponse(response);
        commonElement = new CommonElement(resDoc);
        return resDoc;
    }
    
    private static byte[] readInputStream(InputStream is) throws IOException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        byte[] data = new byte[4096];
        int bytesRead;
        while ((bytesRead = is.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, bytesRead);
        }
        return buffer.toByteArray();
    }

    private static Document parseResponse(byte[] response) throws Exception {
        if (response[0] != '<') {
        	System.out.println("111");
        	System.out.println("111");
        	System.out.println("111");
            return XMLEasyUtil.parseXMLDocument(new StringReader(new String(response, "EUC-KR").trim()));
        } else {
        	System.out.println("222");
        	System.out.println("222");
        	System.out.println("222");
            return XMLEasyUtil.parseXMLDocument(new ByteArrayInputStream(response));
        }
    }

    private static void log(String message) {
        if (DEBUG) {
            synchronized (System.out) {
                System.out.println("[DEBUG] " + message);
            }
        }
    }

    private static void log(String title, String content) {
        if (DEBUG) {
            synchronized (System.out) {
                System.out.println("■■ " + title + " ■■ [" + DateTimeUtil.getCurrentDateTime() + "]");
                System.out.println(content);
                System.out.println("■■ END ■■");
            }
        }
    }

    private static void logResponseHeaders(byte[] response) {
        if (DEBUG) {
            synchronized (System.out) {
                System.out.println("■■ Response Headers ■■");
                System.out.println(new String(response));
                System.out.println("■■ END ■■");
            }
        }
    }

    public static CommonElement getCommonElement() {
        return commonElement;
    }
    
    /*
    public static CommonElementResInfo getCommonElementResInfo() {
        return commonElementResInfo;
    }
    */
}
