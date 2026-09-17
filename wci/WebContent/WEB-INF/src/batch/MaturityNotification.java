package batch;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Properties;

import kr.co.funology.fw.util.StrUtil;

public class MaturityNotification {
  private Properties props   = null;
  private String   strCode = "";
  
  public MaturityNotification(String strCode, String path) {
    this.strCode = strCode;
    try {
      File f = new File(path);
      if (f.canRead()) {
        props = new java.util.Properties();
        FileInputStream fs = new FileInputStream(f);
        this.props.load(new java.io.BufferedInputStream(fs));
        fs.close();
      }
    } catch (IOException e) {
      this.props = null;
    }
  }
  
  private String getString(String strKey) {
    return (props!=null) ? StrUtil.nvl(props.getProperty(strKey), "") : "";
  }

  public String sendByCron() {
    String strUrl = this.getString("DOMAIN_URL") 
                  + this.getString("CONTEXT_PATH")
                  + this.getString("KAKAO_SEND_PAGE");
    strUrl += "?tcd="+this.strCode+"&cpyid=0&ctid=0";
    System.out.println(strUrl);
    BufferedReader in = null;
    String strResult = "";
    try {
      URL url = new URL(strUrl);
      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      in = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
      String l = "";
      while((l=in.readLine())!=null) strResult+=l;
    } catch (Exception e) {
    	
    } finally {
      if(in != null) try { in.close(); } catch(Exception e) { e.printStackTrace(); }
    }
    return strResult;
  }
  
  public static void main(String[] args) {
    if (args==null || args.length!=2) {
      args = new String[2];
      args[0] = "M004";
      args[1] = "D:/WorkSpace/mp/WebContent/WEB-INF/configuration.properties";
    }
    MaturityNotification m = new MaturityNotification(args[0], args[1]);
    m.sendByCron();
  }
  
}
