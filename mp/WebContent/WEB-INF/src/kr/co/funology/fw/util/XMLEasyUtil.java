package kr.co.funology.fw.util;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.HashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class XMLEasyUtil {

    // XML 문자열을 Document 객체로 파싱하는 메서드
    public static Document parseXMLDocument(String xmlString) throws Exception {
        if (xmlString == null || xmlString.isEmpty()) {
            throw new IllegalArgumentException("XML string cannot be null or empty");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true); // 네임스페이스 처리 활성화
            DocumentBuilder builder = factory.newDocumentBuilder();
            InputStream inputStream = new ByteArrayInputStream(xmlString.getBytes("EUC-KR"));
            return builder.parse(inputStream);
        } catch (Exception e) {
            throw new Exception("Failed to parse XML string", e);
        }
    }
    
    public static Document parseXMLDocument(String xmlString, String encoding) throws Exception {
        if (xmlString == null || xmlString.isEmpty()) {
            throw new IllegalArgumentException("XML string cannot be null or empty");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true); // 네임스페이스 처리

            DocumentBuilder builder = factory.newDocumentBuilder();

            // StringReader를 통한 인코딩 명시
            InputSource is = new InputSource(new StringReader(xmlString));
            is.setEncoding(encoding);

            return builder.parse(is);
        } catch (Exception e) {
            throw new Exception("Failed to parse XML string", e);
        }
    }

    // InputStream을 통해 XML을 Document 객체로 파싱하는 메서드
    public static Document parseXMLDocument(InputStream inputStream) throws Exception {
        if (inputStream == null) {
            throw new IllegalArgumentException("InputStream cannot be null");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            return builder.parse(inputStream);
        } catch (Exception e) {
            throw new Exception("Failed to parse XML InputStream", e);
        }
    }

    // InputSource를 통해 XML을 Document 객체로 파싱하는 메서드
    public static Document parseXMLDocument(InputSource inputSource) throws Exception {
        if (inputSource == null) {
            throw new IllegalArgumentException("InputSource cannot be null");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true); // 네임스페이스를 인식하도록 설정
            DocumentBuilder builder = factory.newDocumentBuilder();
            return builder.parse(inputSource);
        } catch (Exception e) {
            // 더 구체적인 에러 메시지를 포함하여 예외 처리
            throw new Exception("Failed to parse XML InputSource: " + e.getMessage(), e);
        }
    }
    
 // StringReader를 사용하여 XML을 Document로 파싱하는 메서드 추가
    public static Document parseXMLDocument(StringReader reader) throws Exception {
        if (reader == null) {
            throw new IllegalArgumentException("StringReader cannot be null");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            InputSource inputSource = new InputSource(reader);
            return builder.parse(inputSource);
        } catch (Exception e) {
            throw new Exception("Failed to parse XML from StringReader", e);
        }
    }
    
    // Document 객체에서 XML 인코딩을 가져오는 메서드
    public static String getEncoding(Document doc) {
        return "EUC-KR";  // EUC-KR 기본 인코딩 반환
    }

    // Document 객체를 문자열로 변환하는 메서드
    public static String documentToString(Document doc) throws Exception {
        if (doc == null) {
            throw new IllegalArgumentException("Document cannot be null");
        }
        try {
            // Transformer를 사용하여 Document를 XML 문자열로 변환
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes"); // 예쁘게 포매팅
            transformer.setOutputProperty(OutputKeys.ENCODING, "EUC-KR");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));

            return writer.toString();
        } catch (Exception e) {
            throw new Exception("Failed to convert Document to String", e);
        }
    }
    
    public HashMap<String, String> getRtnXmlData(Document doc) {
    	HashMap<String, String> resultMap = new HashMap<>();
    	NodeList nodeList = doc.getElementsByTagName("*");
    	
    	for (int i = 0; i < nodeList.getLength(); i++) {
            Element element = (Element) nodeList.item(i);
            String tagName = element.getTagName();
            String value = getChildCharacterData(element);
            if (value != null) {
            	if (resultMap.containsKey(tagName)) {
                    // 기존 값이 있으면 "&"로 연결하여 새로운 값으로 설정
                    String oldValue = resultMap.get(tagName);
                    resultMap.put(tagName, oldValue + "&" + value);
                } else {
                    // 기존 값이 없으면 새로운 값으로 설정
                    resultMap.put(tagName, value);
                }
            }
        }

        return resultMap;
    }
    
    private String getChildCharacterData(Element element) {
        NodeList childNodes = element.getChildNodes();
        for (int i = 0; i < childNodes.getLength(); i++) {
            Node node = childNodes.item(i);
            if (node.getNodeType() == Node.TEXT_NODE || node.getNodeType() == Node.CDATA_SECTION_NODE) {
                return node.getNodeValue().trim();
            }
        }

        return null;

    }
}
