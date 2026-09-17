package kr.co.funology.fw.mgr;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Properties;
import org.apache.log4j.Logger;

import kr.co.funology.fw.GlobalEnv;

public class LanguageAllProperties {

    private Properties loadProperties(String strLanguageCode, String strPageCode) {
        String strPropertiesFilePath = GlobalEnv.getWebRootDir() + "WEB-INF/lang/"+strLanguageCode+"/"+strPageCode+".properties";
        Properties prop = null;
        try {
            File f = new File(strPropertiesFilePath);
            if (!f.canRead()) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.error(strPropertiesFilePath + " is not exist.");
            } else {
                prop = new java.util.Properties();
                FileInputStream fs = new FileInputStream(f);
                prop.load(new java.io.BufferedInputStream(fs));
                fs.close();
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error("kr.co.sology.fw.mgr.LanguageAllProperties()");
            logger.error(e.toString());
        }
        return prop;
    }
	
    public ArrayList<String[]> getALLProperties(String[] strLanguageCode, String strPageCode) {
    	if (strPageCode==null) strPageCode = "common";
    	ArrayList<String[]> arr = new ArrayList<>();
    	try {
    		for (int i = 0; i<strLanguageCode.length; i++) {
    			System.out.println(strLanguageCode[i]);
    			Properties p = loadProperties(strLanguageCode[i], strPageCode);
	    	    java.util.Iterator<Object> it = p.keySet().iterator();
	    	    while (it.hasNext()) {
	    	    	String[] str = new String[3];
	    	    	str[0] = strLanguageCode[i];
	    	    	str[1] = (String)it.next();
	    	    	str[2] = p.getProperty(str[1]);
	    	    	arr.add(str);
	    	    }
    		}
    	} catch (Exception e) {
    		//
    	}
        return arr;
    }
	
}
