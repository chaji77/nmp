package kr.co.mp.trade;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.TreeMap;

import org.apache.log4j.Logger;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.StrUtil;

public class AbnormalConfiguration {
    private static AbnormalConfiguration instance = null; // this class instance
    private static String   strPropertiesFilePath = null; // Properties File Path
    private static Properties               props = null; // Properties
    private static boolean            isDebugMode = true; // Debug Mode Or Not. Change to 'false' For Real Service
    private static long           lngLastModified = 0;    // Auto-restore Properties in 'isDebugMode = true'.

    /**
     * Constructor
     *
     */
    private AbnormalConfiguration() {
        try {
            File f = getPropertiesFile();
            if (!f.canRead()) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.error(strPropertiesFilePath + " file is not found.");
            } else {
                if (lngLastModified != f.lastModified()) { // Check Last Modified Datetime.
                    props = new java.util.Properties();
                    FileInputStream fs = new FileInputStream(f);
                    props.load(new java.io.BufferedInputStream(fs));
                    fs.close();
                    lngLastModified = f.lastModified();
                }
            }
        } catch (IOException e) {
            props           = null;
            lngLastModified = 0;
            Logger logger = Logger.getLogger(this.getClass());
            logger.error("kr.co.mp.trade.AbnormalConfiguration()");
            logger.error(e.toString());
        }
    }

    /**
     * Get Properties File.
     *
     * @return Properties File
     */
    private static File getPropertiesFile() {
        strPropertiesFilePath = GlobalEnv.getWebRootDir() + "WEB-INF/abnormaltransaction.properties";
        return new File(strPropertiesFilePath);
    }

    /**
     * Get Instance
     *
     * @return ConfigurationMgr Class Instance
     */
    public synchronized static AbnormalConfiguration getInstance() {
        if (instance == null || isDebugMode == true || props == null) {
            instance = new AbnormalConfiguration();
        }
        return instance;
    }

    /**
     * Get Value By Key.
     *
     * @param strKey Key
     * @return Value
     */
    public String getString(String strKey) {
        return (props!=null) ? StrUtil.nvl(props.getProperty(strKey), "") : "";
    }

    /**
     * Get Value By Key.
     *
     * @param strKey Key
     * @return Value
     */
    public int getInt(String strKey) {
        return (props!=null) ? Integer.parseInt(StrUtil.nvl(props.getProperty(strKey), "0")) : 0;
    }

    public boolean getBoolean(String strKey) {
        return (props!=null) ? Boolean.parseBoolean(StrUtil.nvl(props.getProperty(strKey), "false")) : false;
    }

    /**
     * Get all properties in msg.properties.
     *
     * @return StringBuffer
     */
    public StringBuffer showProperties() {
        java.util.Iterator<Object> it = props.keySet().iterator();
        StringBuffer sb = new StringBuffer();
        while (it.hasNext()) {
            String strKey = (String)it.next();
            sb.append(strKey + "=" + props.getProperty(strKey) + "\n");
        }
        return sb;
    }

    public StringBuffer showPropertiesForWeb() {
    	TreeMap<String, String> sortedMap = new TreeMap<>();
        for (String key : props.stringPropertyNames()) {
            sortedMap.put(key, props.getProperty(key));
        }
        StringBuffer sb = new StringBuffer();
        sortedMap.forEach((key, value) -> sb.append("<tr><td>")
        		.append(key).append("</td><td>")
        		.append(value).append("</td></tr>"));
        return sb;
    }
}
