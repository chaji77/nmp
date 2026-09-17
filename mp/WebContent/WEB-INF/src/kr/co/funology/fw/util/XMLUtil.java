package kr.co.funology.fw.util;

import java.io.OutputStream;
import java.io.StringWriter;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class XMLUtil {

    public XMLUtil() {}

    public static String getNodeValue(Document p_doc, String p_tagName) {
        return getNodeValue(p_doc, p_tagName, 0);
    }

    public static String getNodeValue(Document p_doc, String p_tagName, int p_itemIndex) {
        if (p_doc != null) {
            NodeList nl = p_doc.getElementsByTagName(p_tagName);
            if (nl.getLength() > p_itemIndex && nl.item(p_itemIndex).getFirstChild() != null) {
                return nl.item(p_itemIndex).getFirstChild().getNodeValue();
            } 
        }
        return null;
    }
    
    public static String getNodeValue(Document p_doc, String p_tagName, String defaultValue) {
        String value = getNodeValue(p_doc, p_tagName, 0);
        return value != null ? value : defaultValue;
    }

    public static String getNodeValueOption(Document p_doc, String p_tagName, int p_itemIndex) {
        try {
            return getNodeValue(p_doc, p_tagName, p_itemIndex);
        } catch (Exception ex) {
            System.out.println(p_tagName + "을 찾을 수 없거나 값이 없습니다.");
        }
        return null;
    }
    
    public static String getNodeValueOption(Document p_doc, String p_tagName) {
        if (p_doc != null) {
            return getNodeValueOption(p_doc, p_tagName, 0);
        }
        return null;
    }

    public static void setNodeValue(Document p_doc, String p_tagName, String p_tagValue) {
        setNodeValue(p_doc, p_tagName, p_tagValue, 0);
    }

    public static void setNodeValue(Document p_doc, String p_tagName, String p_tagValue, int p_itemIndex) {
        if (p_doc != null) {
            NodeList nl = p_doc.getElementsByTagName(p_tagName);
            if (nl.getLength() > p_itemIndex) {
                Element element = (Element) nl.item(p_itemIndex);
                element.setTextContent(p_tagValue != null ? p_tagValue : "");
            }
        }
    }

    public static void setAttributeValue(Document p_doc, String p_tagName, String p_attName, String p_attValue) {
        setAttributeValue(p_doc, p_tagName, p_attName, p_attValue, 0);
    }

    public static void setAttributeValue(Document p_doc, String p_tagName, String p_attName, String p_attValue, int p_itemIndex) {
        if (p_doc != null && p_attValue != null) {
            NodeList nl = p_doc.getElementsByTagName(p_tagName);
            if (nl.getLength() > p_itemIndex) {
                ((Element) nl.item(p_itemIndex)).setAttribute(p_attName, p_attValue);
            }
        }
    }

    public static Document formatXml(Document doc) {
        try {
            String formattedXml = formatDocToStr(doc);
            return XMLEasyUtil.parseXMLDocument(formattedXml);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String formatXml(String sDoc) {
        try {
            return formatDocToStr(XMLEasyUtil.parseXMLDocument(sDoc));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String formatDocToStr(Document doc) throws Exception {
        if (doc == null) return "";
        Document standardDoc = XMLEasyUtil.parseXMLDocument(docToString(doc));
        Transformer transformer = createTransformer();

        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(standardDoc), new StreamResult(writer));
        return writer.toString();
    }

    private static String docToString(Document doc) throws Exception {
        Transformer transformer = createTransformer();
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(doc), new StreamResult(writer));
        return writer.toString();
    }

    public static void displayXML(Document doc, StringWriter sw) {
        displayXML(doc, new StreamResult(sw));
    }

    public static void displayXML(Document doc, OutputStream os) {
        displayXML(doc, new StreamResult(os));
    }

    private static void displayXML(Document doc, StreamResult result) {
        try {
            Transformer transformer = createTransformer();
            transformer.transform(new DOMSource(doc), result);
        } catch (TransformerException e) {
            e.printStackTrace();
        }
    }

    private static Transformer createTransformer() throws TransformerConfigurationException {
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer();

        transformerFactory.setAttribute("indent-number", 2);
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty(OutputKeys.ENCODING, "EUC-KR");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
        transformer.setOutputProperty(OutputKeys.CDATA_SECTION_ELEMENTS, "yes");

        return transformer;
    }
}
