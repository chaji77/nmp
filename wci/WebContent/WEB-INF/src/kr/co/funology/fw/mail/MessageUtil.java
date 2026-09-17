package kr.co.funology.fw.mail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.UUID;
import java.util.Map.Entry;

import javax.mail.Address;
import javax.mail.Flags;
import javax.mail.Header;
import javax.mail.Message;
import javax.mail.Message.RecipientType;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Part;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeUtility;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

/**
 * MAIL CONTENTS CONTROL
 *
 * @author PRO
 *
 */
public class MessageUtil {

    private ContentVO vo; // message value object
    private String strMessageId = ""; // message id
    private StringBuffer sbPlainContent; // plain message
    private HashMap<String, String> hmEmbedded; // embedded

    /**
     * constructor
     *
     */
    public MessageUtil() {
        this.vo = new ContentVO();
        this.sbPlainContent = new StringBuffer();
        this.hmEmbedded = new HashMap<>();
    }

    //////////////////////////////////////////////////////////////////////////////////
    //
    // GET MESSAGE
    //
    //////////////////////////////////////////////////////////////////////////////////

    /**
     * get message for list or detail page.
     *
     * @param message message
     * @param withContent whether to include text
     * @param folder folder that included message
     * @return message
     */
    public MailVO get(Message message, boolean withContent, String folder) {
        MailVO mailvo = new MailVO();
        if (this.vo==null) this.vo = new ContentVO();
        try {
            mailvo.strSubject    = StrUtil.nvl(message.getSubject(), "제목없음");
            mailvo.strSender     = getSender(message);
            mailvo.strReceives   = getReceipts(message, RecipientType.TO);
            mailvo.strCarbonCopy = getReceipts(message, RecipientType.CC);
            mailvo.strHiddenCopy = getReceipts(message, RecipientType.BCC);
            mailvo.strDate       = getDate(message);

            // GET HEADER
            Enumeration<Header> headers = message.getAllHeaders();
            while (headers.hasMoreElements()) {
                Header header = headers.nextElement();
                if (header.getName().contentEquals("Message-ID")) {
                    mailvo.messageid = header.getValue();
                    this.strMessageId = mailvo.messageid;
                    if (this.strMessageId.length()>27) this.strMessageId = this.strMessageId.substring(1, 26);
                }
            }

            // GET CONTENT
            if (withContent) {
                mailvo.content   = getContent(message.getMessageNumber(), message);
                mailvo.content   = getEmbeddedUrl(mailvo.content);
                mailvo.files     = this.vo.files;
            }

            mailvo.strSize       = Integer.toString(message.getSize());
            mailvo.messageuid    = getMessageUid(message);

        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return mailvo;
    }

    /**
     * print original message.
     *
     * @param no message number
     * @param message message
     * @param response position to response
     */
    public void getContentTo(int no, Message message, HttpServletResponse response) {
    	try {
			message.writeTo(response.getOutputStream());
		} catch (IOException | MessagingException e) {
			e.printStackTrace();
		}
    }

    /**
     * get message body with message number for detail page.
     *
     * @param no message number
     * @param message message
     * @return message that formatted html
     */
    public String getContent(int no, Message message) {
        Logger logger = Logger.getLogger(this.getClass());
        logger.debug("================================ MESSAGE =================================");
        if (this.vo==null) this.vo = new ContentVO();
        this.vo.files = new ArrayList<>();
        try {
            Object content = message.getContent();
            if (content instanceof Multipart) {
                logger.debug("--------------- MULTI-PART-CONTENT ---------------");
                // ((Multipart) content).writeTo(System.out); // original message
                this.vo.multipartContent = new StringBuffer();
                getMultipartContent(no, content);
                if (this.sbPlainContent.length()>0 && this.vo.multipartContent.length()<1) { // control alternative message
                    this.vo.multipartContent.append(this.sbPlainContent.toString());
                }
                return this.vo.multipartContent.toString();
            } else if (content instanceof String) {
                logger.debug("--------------- PLAIN-CONTENT ---------------");
                logger.debug(message.getContentType());
                if (message.getContentType().contains("text/html")) {
                	return "<div class='html'>" + encode(content.toString()) + "</div>";
                } else {
                  // logger.debug(content.toString());
                    return "<div class='text'>" + encode(
                        content.toString()
                        .replaceAll("\n", "<br/>")
                        ) + "</div>";
                }
            } else {
                logger.debug("--------------- PART-CONTENT ---------------");
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                ((Part) content).writeTo(outputStream);
                return new String(outputStream.toByteArray(), "UTF-8");
            }
        } catch (Exception e) {
            logger.error(e.toString());
        }
        return "";
    }

    /**
     * recursive call to get multipart messages.
     *
     * @param no content number in multipart message
     * @param content message
     */
    private void getMultipartContent(int no, Object content) {
        Logger logger = Logger.getLogger(this.getClass());
        try {
            if (content instanceof javax.mail.Multipart) {
            	javax.mail.Multipart multipart = (javax.mail.Multipart) content;
                for (int i = 0; i < multipart.getCount(); i++) {
                    Part part = multipart.getBodyPart(i);
                    logger.debug("PART : " + (Integer.toString(i)) + " ---------------------------------");

                    String[] cids = part.getHeader("Content-ID");
                    if (cids!=null && cids.length>0) { // CONTENT-ID를 가진 첨부파일 저장
                        for (int c=0; c<cids.length; c++) {
                            logger.debug(">>> Content-Id : "+ cids[c]);
                            logger.debug(">>> Content-Type : " + part.getContentType());
                            if (part.isMimeType("image/*")) {
                                if (part.getContent() instanceof com.sun.mail.util.BASE64DecoderStream) {
                                    logger.debug(">>> BASE64DecoderStream image embedded.");
                                } else {
                                    logger.error(">>> Not BASE64DecoderStream image embedded.");
                                }
                                String key = URLEncoder.encode("cid:"+(cids[c]).substring(1, cids[c].length()-1), "UTF-8");
                                String strExt = "";
                                if (part.getContentType().lastIndexOf(".")>-1) {
                                  strExt  = part.getContentType().substring(part.getContentType().lastIndexOf("."));
                                } else {
                                  if (key.lastIndexOf("/")>-1) {
                                	  strExt = key.substring(key.lastIndexOf("/"));
                                  }
                                }
                                System.out.println(strExt);
                                String strKey = this.strMessageId + "_" + UUID.randomUUID() + strExt;
                                String strLinkUrl = ConfigurationMgr.getInstance().getString("MAIL_EMBED_URL") + getEmbeddedImagePath(part, strKey);
                                logger.debug("[" + key + "] is saved to " + strLinkUrl);
                                this.hmEmbedded.put(key, strLinkUrl);
                            } else logger.debug(">>> Not Embed Image File.");
                            this.addAttachedFile(no, cids[c], part);
                        }
                    } else { // CONTENT-ID가 없는 첨부파일 저장
                        if (part.getFileName()!=null) {
                            logger.debug("-- file that hasn't content-id");
                            String strSize = getSize(part.getSize());
                            String[] add = {Integer.toString(no), MailEnv.strNoContentIdKey+Integer.toString(i), strSize, MimeUtility.decodeText(part.getFileName()), ""};
                            this.vo.files.add(add);
                            logger.debug(MimeUtility.decodeText(part.getFileName()));
                        }
                    }

                    // 첨부파일이 아니면 내용을 저장
                    if (part.getDisposition()==null || !part.getDisposition().equals(Part.ATTACHMENT)) {
                        if (part.isMimeType("text/html")) {
                            this.vo.multipartContent.append("<div class='html'>" + encode(part.getContent().toString()) +"</div>");
                        } else if (part.isMimeType("text/plain") && part.getFileName()==null) {
                            this.sbPlainContent.append("<div class='text'>" + encode(part.getContent().toString().replaceAll(">", "<span style='border-left:1px solid #eee;width:10px;'></span>").replaceAll("\n", "<br/>")) + "</div>");
                        } else if (part.isMimeType("multipart/*")) {
                            getMultipartContent(no, part.getContent()); // recursive
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    /**
     * add attached files.
     *
     * @param no file number
     * @param cid content-id
     * @param part part that included files
     */
    private void addAttachedFile(int no, String cid, Part part) {
        try {
            String strSize = getSize(part.getSize());
            if (part.getFileName()!=null) {
                String[] add = {Integer.toString(no), cid.substring(1, cid.length()-1), strSize, MimeUtility.decodeText(part.getFileName()), ""};
                this.vo.files.add(add);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * replace the content-id of the image embedded in the content to be output with the file path.
     *
     * @param content the content to be output
     * @return replaced content
     */
    private String getEmbeddedUrl(String content) {
        Logger logger = Logger.getLogger(this.getClass());
        logger.debug("--------------- TO MATCH EMBEDDED IMAGE ---------------");
        if (this.hmEmbedded!=null && this.hmEmbedded.size()>0) {
            for (Entry<String, String> ent : this.hmEmbedded.entrySet()) {
                if (content.indexOf(ent.getKey())>-1) {
                  logger.debug("[" + ent.getKey() + "] is contained.");
                  content = content.replace(ent.getKey(), ent.getValue());
                  if (this.vo.files!=null && this.vo.files.size()>0) {
                      for (int i=0; i<this.vo.files.size();) {
                          String[] v = vo.files.get(i);
                          if (("cid%3A"+v[1]).equals(ent.getKey())) {
                              logger.debug("[" + ent.getKey() + "] is replaced to " + ent.getValue());
                              this.vo.files.remove(i);
                          } else {
                              i++;
                          }
                      }
                  }
                } else {
                    logger.debug("[" + ent.getKey() + "] is not contained.");
                }
            }
        } else {
            logger.debug(">>> has not embedded images.");
        }
        return content;
    }

    /**
     * encode special character.
     *
     * @param s content to encode
     * @return replaced content
     */
    private String encode(String s) {
        String result = null;
        try {
          //s = s.replaceAll("<", "&lt;")
          //     .replaceAll(">",  "&gt;");
          result = URLEncoder.encode(s, "UTF-8")
                             .replaceAll("\\+", "%20")
                             .replaceAll("\\%21", "!")
                             .replaceAll("\\%27", "'")
                             .replaceAll("\\%28", "(")
                             .replaceAll("\\%29", ")")
                             .replaceAll("\\%7E", "~");
        } catch (Exception e) {
          result = s;
        }
        return result;
    }

    //////////////////////////////////////////////////////////////////////////////////
    //
    // GET MESSAGE LIST
    //
    //////////////////////////////////////////////////////////////////////////////////

    /**
     * get content for list.
     *
     * @param message message
     * @return value object of message for list
     */
    public MailVO getForList(Message message) {
        MailVO fvo = new MailVO();
        try {
            fvo.intNumber   = message.getMessageNumber();
            fvo.isSeenOrNot = message.isSet(Flags.Flag.SEEN);
            fvo.strSender   = getSender(message);
            fvo.strSubject  = "<a onclick='goDetail("+fvo.intNumber+")' class='"+((fvo.isSeenOrNot)?"seen":"recent")+"'>"+((message.getSubject()==null || message.getSubject().trim().equals("")) ? "제목이 없습니다" : message.getSubject()) + "</a>";
            fvo.strDate     = getDate(message);
            fvo.strSize     = getSize(message);
            fvo.strReceives = getReceipts(message, RecipientType.TO);
            fvo.isAnswered  = message.isSet(Flags.Flag.ANSWERED);
            fvo.isFlaged    = message.isSet(Flags.Flag.FLAGGED);
            fvo.hasFile     = this.hasFile(message);
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.MailVO");
            logger.error(e.toString());
        }
        return fvo;
    }

    /**
     * get contents for list.
     *
     * @param msgs messages
     * @return value object of messages for list
     */
    public ArrayList<MailVO> getForList(Message[] msgs) {
        ArrayList<MailVO> arr = new ArrayList<>();
        try {
            for (int i=msgs.length; i>0; i--) {
                Message message = msgs[i-1];
                MailVO fvo = new MailVO();
                fvo.intNumber   = message.getMessageNumber();
                fvo.isSeenOrNot = message.isSet(Flags.Flag.SEEN);
                fvo.strSender   = getSender(message);
                fvo.strSubject  = "<a onclick='goDetail("+fvo.intNumber+")' class='"+((fvo.isSeenOrNot)?"seen":"recent")+"'>"+((message.getSubject()==null || message.getSubject().trim().equals("")) ? "제목이 없습니다" : message.getSubject()) + "</a>";
                fvo.strDate     = getDate(message);
                fvo.strSize     = getSize(message);
                fvo.strReceives = getReceipts(message, RecipientType.TO);
                fvo.isAnswered  = message.isSet(Flags.Flag.ANSWERED);
                fvo.isFlaged    = message.isSet(Flags.Flag.FLAGGED);
                fvo.hasFile     = this.hasFile(message);
                arr.add(fvo);
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.MailVO");
            logger.error(e.toString());
        }
        return arr;
    }


    private boolean hasFile(Message message) {
        try {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            message.writeTo(outputStream);
            return (new String(outputStream.toByteArray(), "UTF-8").contains("Content-Disposition: attachment"));
        } catch (Exception e) {}
        return false;
    }

    //////////////////////////////////////////////////////////////////////////////////
    //
    // GET SENDER, RECEIPTS, MESSAGE_UID, SIZE, DATE
    //
    //////////////////////////////////////////////////////////////////////////////////

    /**
     * get receipts.
     *
     * @param message message
     * @return all receipts
     */
    public static MailVO getReceiptEmail(Message message) {
        MailVO mailvo = new MailVO();
        try {
            mailvo.messageuid = getMessageUid(message);
            mailvo.strReceiverEmail  = getReceiptEmail(message, RecipientType.TO);
            mailvo.strReceiverEmail += getReceiptEmail(message, RecipientType.CC);
            mailvo.strReceiverEmail += getReceiptEmail(message, RecipientType.BCC);
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getReceiptEmail");
            logger.error(e.toString());
        }
        return mailvo;
    }

    /**
     * replace address.
     *
     * @param link link
     * @return replaced address
     */
    public static String decodeAddress(String link) {
        link = link.replaceAll("</a>", "--></a>");
        link = link.replaceAll("\'>", ";<--");
        link = link.replaceAll("addr=", ">");
        link = link.replaceAll("\'", "");
        // link = link.replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", "");
        link = link.replaceAll("\\<.*?\\>", "");
        return link;
    }

    /**
     * get customized message unique id.
     *
     * @param message message
     * @return message unique id
     */
    public static String getMessageUid(Message message) {
        String strMessageUid = "";
        try {
            strMessageUid = (message.getHeader("message_uid")!=null) ? StrUtil.nvl(message.getHeader("message_uid")[0]) : "";
        } catch (Exception e) {
            //Logger logger = Logger.getLogger("MessageUtil.getMessageUid");
            //logger.error(e.toString());
        }
        return strMessageUid;
    }

    /**
     * get address to output.
     *
     * @param nne address
     * @return address to output
     */
    private static String printAddress(String nne) {
        if (nne.indexOf(MailEnv.strSeparatorBetweenNameAndEmail)>-1) {
            String[] a = nne.split(MailEnv.strSeparatorBetweenNameAndEmail);
            return "<a href='javascript:goWrite(\"" + nne.replaceAll("'",  "").replaceAll("\"",  "") + "\");' addr='" + nne.replaceAll("'",  "").replaceAll("\"",  "") + "'>" + StrUtil.nvl(a[0], a[1]) + "</a>";
        } else {
            return StrUtil.nvl(nne);
        }
    }

    /**
     * get receipt string from internet address.
     *
     * @param message message
     * @param mrt     receipt type
     * @return
     */
    private static String getReceipts(Message message, Message.RecipientType mrt) {
        String to = "";
        try {
            Address[] tos = message.getRecipients(mrt);
            if (tos!=null) {
                for (int t=0; t<tos.length; t++) {
                    to += ";" + printAddress(printAddressKey((InternetAddress)tos[t]));
                }
                to = to.substring(1);
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getReceipts");
            logger.error(e.toString());
        }
        return to;
    }

    /**
     * get sender address.
     *
     * @param message message
     * @return sender address
     */
    private static String getSender(Message message) {
        String from = "";
        try {
            Address[] froms = message.getFrom();
            from = printAddress(printAddressKey((InternetAddress)froms[0]));
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getSender");
            logger.error(e.toString());
        }
        return from;
    }

    /**
     * separate the name and email address from the Internet address and combine them with a delimiter.
     *
     * @param ia internet address
     * @return   customized address
     */
    private static String printAddressKey(InternetAddress ia) {
        return StrUtil.nvl(ia.getPersonal()) + MailEnv.strSeparatorBetweenNameAndEmail + ia.getAddress();
    }

    private static String getReceiptEmail(Message message, Message.RecipientType mrt) {
        String to = "";
        try {
            Address[] tos = message.getRecipients(mrt);
            if (tos!=null) {
                for (int t=0; t<tos.length; t++) {
                    to += ";" + ((InternetAddress)tos[t]).getAddress();
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getReceiptEmail");
            logger.error(e.toString());
        }
        return to;
    }

    /**
     * get date and time from message.
     *
     * @param message message
     * @return formatted date and time
     */
    private static String getDate(Message message) {
        String strDate = "";
        try {
            SimpleDateFormat f = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            strDate = f.format((message.getSentDate()==null) ? message.getReceivedDate() : message.getSentDate());
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getDate");
            logger.error(e.toString());
        }
        return strDate;
    }

    /**
     * get message size
     *
     * @param message message
     * @return message size
     */
    private static String getSize(Message message) {
        try {
            return getSize(message.getSize());
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MessageUtil.getSize");
            logger.error(e.toString());
        }
        return "";
    }

    /**
     * get message size for human
     *
     * @param intSize message size
     * @return human readable file size
     */
    private static String getSize(int intSize) {
        String strSize = "";
        if (intSize<0) strSize = "";
        else {
            double size = Double.parseDouble(Integer.toString(intSize));
            strSize = Integer.toString(intSize) + " B";
            if (size > 1024) strSize = String.format("%.1f", size/1024) + " KB";
            if (size > 1024*1024) strSize = String.format("%.1f", size/(1024*1024)) + " MB";
            if (size > 1024*1024*1024) strSize = String.format("%.1f", size/(1024*1024*1024)) + " GB";
        }
        return strSize;
    }

    /**
     * save a embedded image and return path
     *
     * @param part   message part
     * @param strKey file name to save
     * @return image path
     */
    private static String getEmbeddedImagePath(Part part, String strKey) {
        String strSaveTo = "";
        try {
            strSaveTo = ConfigurationMgr.getInstance().getString("MAIL_EMBED_PATH") + strKey.replace("+", " "); // URLEncoder.encode(UUID.randomUUID().toString(), "UTF-8");
	        // SAVE TEMPORARY FOR REPLY OR FORWARD
	        File file = new File(strSaveTo);
	        if (!file.exists()) file.createNewFile();
	        FileOutputStream fos = new FileOutputStream(file.getAbsolutePath());
	        InputStream is = part.getDataHandler().getInputStream();
	        OutputStream os = new BufferedOutputStream(fos);
	        int d;
	        while ((d=is.read())>-1) {
	            os.write(d);
	        }
	        is.close();
	        os.close();
        } catch (Exception e) {
            System.out.println(e.toString());
        }
        return strSaveTo.replace(ConfigurationMgr.getInstance().getString("MAIL_EMBED_PATH"), "");
    }

    public static void main(String[] args) {


    }
}
