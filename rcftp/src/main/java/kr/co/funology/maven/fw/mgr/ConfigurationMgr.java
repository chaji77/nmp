package kr.co.funology.maven.fw.mgr;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.TreeMap;

import org.apache.log4j.Logger;

import kr.co.funology.maven.fw.GlobalEnv;
import kr.co.funology.maven.fw.util.StrUtil;


/**
 * WebContent Configuration Properties Manager
 *
 * <pre>
 *
 * 1. Required
 *
 *    (1) create file ... WEB-INF\configuration.properties
 *    (2) write like  ... YourKey=hello!!!
 *    (2) check       ... kr.co.sology.fw.GlobalEnv.getWebRootDir()
 *
 * 2. Usage
 *
 *    System.out.println(ConfigurationMgr.getInstance().getString(YourKey));
 *    result : hello!!!
 *
 * </pre>
 *
 * @author DOLGAMZA
 * @version 1.0
 * @since 2012.08
 */
public class ConfigurationMgr {

    private static ConfigurationMgr    instance = null; // this class instance
    private static String strPropertiesFilePath = null; // Properties File Path
    private static Properties             props = null; // Properties
    private static boolean          isDebugMode = true; // Debug Mode Or Not. Change to 'false' For Real Service
    private static long         lngLastModified = 0;    // Auto-restore Properties in 'isDebugMode = true'.

    /**
     * Constructor
     *
     */
    private ConfigurationMgr() {
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
            logger.error("kr.co.sology.fw.mgr.ConfigurationMgr()");
            logger.error(e.toString());
        }
    }

    /**
     * Get Properties File.
     *
     * @return Properties File
     */
    private static File getPropertiesFile() {
        strPropertiesFilePath = GlobalEnv.getWebRootDir() + "/WEB-INF/rcftp-configuration.properties";
        System.out.println(strPropertiesFilePath);
        return new File(strPropertiesFilePath);
    }

    /**
     * Get Instance
     *
     * @return ConfigurationMgr Class Instance
     */
    public synchronized static ConfigurationMgr getInstance() {
        if (instance == null || isDebugMode == true || props == null) {
            instance = new ConfigurationMgr();
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
