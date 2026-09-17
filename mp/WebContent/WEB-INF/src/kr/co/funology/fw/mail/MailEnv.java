package kr.co.funology.fw.mail;

import java.net.URLDecoder;

import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

public class MailEnv {

    public static final String strSeparatorBetweenNameAndEmail = "__________";
    protected    static String factory            = "javax.net.ssl.SSLSocketFactory";
    private      static String strHostImap        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("MAIL_HOST_IMAP"), "gm.sology.co.kr");
    private      static String strHostSmtp        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("MAIL_HOST_SMTP"), "gm.sology.co.kr");
    private      static String strImapPort        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("IMAP_PORT"), "143"); // 143, 993
    private      static String strSmtpPort        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("SMTP_PORT"), "587"); // "465" "587"
    public static final String strDefaultBoxIn    = "INBOX";
    public static final String strDefaultBoxSent  = "Sent";
    public static final String strDefaultBoxTrash = "Trash";
    public static final String strDefaultBoxDraft = "Drafts";
    public static final String strDefaultBoxJunk  = "Junk";
    public static final String strDefaultBoxReserve = "Reserve";

    public static final String strUrlForEmbedImg  = "/gw/mail/Embed.jsp";
    public static final String strNoContentIdKey  = "nocid";
    public static final String strPathForEditor   = "/uploadfiles/editor/";

    /**
     * set mail host.
     *
     * @param host mail host
     */
    public static void setHostImap(String host) {
        strHostImap = (host==null) ? strHostImap : host;
    }
    
    public static void setHostSmtp(String host) {
        strHostSmtp = (host==null) ? strHostSmtp : host;
    }

    /**
     * get mail host.
     *
     * @return mail host name
     */
    public static String getHostImap() {
        return strHostImap;
    }

    public static String getHostSmtp() {
        return strHostSmtp;
    }
    
    /**
     * set imap port.
     *
     * @param port imap port number
     */
    public static void setImapPort(String port) {
        strImapPort = port;
    }

    /**
     * get imap port.
     *
     * @return imap port number
     */
    public static int getImapPort() {
        return Integer.parseInt(strImapPort);
    }

    /**
     * set smtp port.
     *
     * @param port smtp port number
     */
    public static void setSmtpPort(String port) {
        strSmtpPort = port;
    }

    /**
     * get smtp port.
     *
     * @return smtp port number
     */
    public static String getSmtpPort() {
        return strSmtpPort;
    }

    /**
     * get password authentication.
     *
     * @param strUserId user id
     * @param strPasswd password
     * @return authenticated key
     */
    protected static Authenticator getAuth(String strUserId, String strPasswd) {
        Authenticator auth = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(strUserId, strPasswd);
            }
        };
        return auth;
    }

    public static String setEmbedFilePath(String user, String folder, int no, String cid, String mid) {
        return ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH")+"mail/tmp/" + user+"_"+folder+"_"+Integer.toString(no)+"_"+cid;
    }

    public static String getEmbedFilePath(String path, String user) {
        path = path.replaceAll("&amp;", "_").replaceAll("&", "_").replaceAll("box=", "").replaceAll("no=", "").replaceAll("cid=", "").replaceAll("mid=", "");
        try {
          if (path.indexOf("?")>-1) path = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH")+"mail/tmp/" + user + "_" + URLDecoder.decode(path.substring(path.lastIndexOf("?")+1), "UTF-8");
        } catch (Exception e) {
          e.printStackTrace();
        }
        return path;
    }

}
