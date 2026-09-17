package kr.co.funology.fw.mgr;

import java.io.File;
import java.io.FileInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.StrUtil;

public class LanguageMgr {

	private static String            strDefaultLangCode = "en";
	private static String        strBasicPropertiesCode = "common";
    private static long              lang_props_version = 0;
    private static Map<String, Properties>   lang_props = null; // Properties
    private String                   strLanguageCodeKey = null;

    private String getKeyName(String strPageCode) {
        return this.strLanguageCodeKey+"_"+strPageCode;
    }

    public LanguageMgr(String strLanguageCode) {
    	this.strLanguageCodeKey = strLanguageCode;
    	if (LanguageMgr.lang_props==null) {
    		LanguageMgr.lang_props = new HashMap<>();
    		LanguageMgr.lang_props_version = 0;
    		this.loadProperties(strBasicPropertiesCode);
    	}
    }

    private void loadProperties(String strPageCode) {
        String strPropertiesFilePath = GlobalEnv.getWebRootDir() + "WEB-INF/lang/"+this.strLanguageCodeKey+"/"+strPageCode+".properties";
        try {
            File f = new File(strPropertiesFilePath);
            if (!f.canRead()) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.error(strPropertiesFilePath + " file is not found.");
                logger.error("strLanguagePageCodeKey : " + this.getKeyName(strPageCode));
                this.strLanguageCodeKey = strDefaultLangCode;
                this.loadProperties(strPageCode);
                return;
            } else {
                if (LanguageMgr.lang_props.get(this.getKeyName(strPageCode)) == null || LanguageMgr.lang_props_version == 0 || LanguageMgr.lang_props_version < f.lastModified()) { // Check Last Modified Datetime.
                	System.out.println(strPropertiesFilePath);
                    Properties p = new java.util.Properties();
                    FileInputStream fs = new FileInputStream(f);
                    p.load(new java.io.BufferedInputStream(fs));
                    fs.close();
                    if (f.lastModified() > LanguageMgr.lang_props_version) {
						LanguageMgr.lang_props_version = f.lastModified();
					}
                    LanguageMgr.lang_props.remove(getKeyName(strPageCode));
                    LanguageMgr.lang_props.put(getKeyName(strPageCode), p);
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error("kr.co.sology.fw.mgr.LanguageMgr()");
            logger.error(e.toString());
        }
    }

    /**
     * Get Value By Key.
     *
     * @param strKey Key
     * @return Value
     */
    public String getString(String strPageCode, String strKey) {
       	try {
          this.loadProperties(strPageCode);
          return StrUtil.nvl(LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).getProperty(strKey), "");
       	} catch (Exception e) {
       	  System.out.println(e.toString());
       	  return "";
       	}
    }

    /**
     * Get Value By Key.
     *
     * @param strKey Key
     * @return Value
     */
    public int getInt(String strPageCode, String strKey) {
       	this.loadProperties(strPageCode);
        return Integer.parseInt(StrUtil.nvl(LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).getProperty(strKey), "0"));
    }

    public String translate(String strKey, String strDefaultValue) {
    	String strKeyName = this.strLanguageCodeKey+"_trans";
   		this.loadProperties("trans");
    	return StrUtil.nvl(LanguageMgr.lang_props.get(strKeyName).getProperty(strKey), strDefaultValue);
    }

    public StringBuffer setProperties(String strVariableName, String strPageCode) {
    	if (strPageCode==null) {
			strPageCode = "common";
		}
        StringBuffer sb = new StringBuffer();
        sb.append(strVariableName+" = {\n");
    	try {
    		this.loadProperties(LanguageMgr.strBasicPropertiesCode);
	    	java.util.Iterator<Object> it = LanguageMgr.lang_props.get(this.strLanguageCodeKey+"_common").keySet().iterator();
	    	while (it.hasNext()) {
	    	    String strKey = (String)it.next();
	    	    sb.append("\"COMMON_"+strKey+"\":\""+LanguageMgr.lang_props.get(this.strLanguageCodeKey+"_common").getProperty(strKey).replaceAll("\"",  "\'")+"\",\n");
	    	}
	        if (!this.strLanguageCodeKey.equals("common")) {
	            this.loadProperties(strPageCode);
	        	it = LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).keySet().iterator();
	            while (it.hasNext()) {
	                String strKey = (String)it.next();
	                sb.append("\""+strPageCode.toUpperCase()+"_"+strKey+"\":\""+LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).getProperty(strKey).replaceAll("\"",  "\'")+"\",\n");
	            }
	        }
    	} catch (Exception e) {
    		//
    	}
    	sb.append("\"EOD\":\"\"};\n");
        return sb;
    }

    public StringBuffer setPropertiesToLocalStorage(String strPageCode) {
    	if (strPageCode==null) {
			strPageCode = "common";
		}
        StringBuffer sb = new StringBuffer();
        sb.append("<script>\n");
        sb.append("// generated LanguageMgr.setProperties() \n");
        try {
        	this.loadProperties(LanguageMgr.strBasicPropertiesCode);
	    	java.util.Iterator<Object> it = LanguageMgr.lang_props.get(this.strLanguageCodeKey+"_common").keySet().iterator();
	    	while (it.hasNext()) {
	    	    String strKey = (String)it.next();
	    	    sb.append("localStorage.setItem(\"COMMON."+strKey+"\", \""+LanguageMgr.lang_props.get(this.strLanguageCodeKey+"_common").getProperty(strKey).replaceAll("\"",  "\'")+"\");\n");
	    	}
	        if (!this.strLanguageCodeKey.equals("common")) {
	            this.loadProperties(strPageCode);
	        	it = LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).keySet().iterator();
	            while (it.hasNext()) {
	                String strKey = (String)it.next();
	                sb.append("localStorage.setItem(\""+strPageCode.toUpperCase()+"."+strKey+"\", \""+LanguageMgr.lang_props.get(this.getKeyName(strPageCode)).getProperty(strKey).replaceAll("\"",  "\'") + "\");\n");
                }
	        }
        } catch (Exception e) {
        	//
        }
        sb.append("</script>");
        return sb;
    }

    public static void setCookie(HttpServletResponse response, String strLangCode) {
        strLangCode = StrUtil.nvl(strLangCode, "kr");
        Cookie cookie = new Cookie("LANG", strLangCode);
        cookie.setMaxAge(60*60*24*120);
        cookie.setPath("/");
        response.addCookie(cookie);
    }

    public static String getCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies!=null) {
            for (Cookie c : cookies) {
                if (c.getName().equals("LANG")) {
                    return c.getValue();
                }
            }
        }
        return "kr";
    }
}
