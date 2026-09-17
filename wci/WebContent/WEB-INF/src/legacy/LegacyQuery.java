package legacy;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class LegacyQuery {
  Document document = null;
  public LegacyQuery(String strPath) {
    try {
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder builder = factory.newDocumentBuilder();
      this.document = builder.parse(strPath);
    } catch (Exception e) {
      System.out.println(e.toString());
    }
  }
  public String getQuery(String id) throws Exception {
    Element root = this.document.getDocumentElement();
    System.out.println(root.getNodeName());
    NodeList sqls = root.getChildNodes();
    System.out.println(sqls.getLength());
    for (int i=0; i<sqls.getLength(); i++) {
      Node sql = sqls.item(i);
      if (sql.getNodeName().equals("query")) {
        Element e = (Element)sql;
        if (e.getAttribute("id").equals(id)) return sql.getTextContent();
      }
    }
    return "";
  }
  public ArrayList<Map<String, String>> select(String strQueryId, String[] args) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<Map<String, String>> arr = new ArrayList<>();
    try {
      String query  = getQuery(strQueryId);
      ps = new WrapPreparedStatementUtil(conn, query);
      for (int i=0; i<args.length; i++) {
        ps.setString((i+1), args[i]);
      }
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        ResultSetMetaData md = rs.getMetaData();
        Map<String, String> cvo  = new HashMap<>();
        cvo.put("COL_CNT", Integer.toString(md.getColumnCount()));
        for (int i=1; i<=md.getColumnCount(); i++) {
          cvo.put(Integer.toString(i), md.getColumnName(i));
        }
        arr.add(cvo);
        while(rs.next()) {
          Map<String, String> vo = new HashMap<>();
          for (int i=1; i<=md.getColumnCount(); i++) {
            vo.put(md.getColumnName(i), StrUtil.nvl(rs.getString(md.getColumnName(i))));
          }
          arr.add(vo);
        }
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return arr;
  }
}
