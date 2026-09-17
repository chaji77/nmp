package kr.co.funology.fw.mail;

import static java.util.regex.Matcher.quoteReplacement;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.Properties;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.Flags.Flag;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Part;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.internet.MimeUtility;

import org.apache.log4j.Logger;

import com.sun.mail.smtp.SMTPMessage;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;

public class MailSend extends MailEnv {

    private static Properties props;
    private static final String encoding = "UTF-8";

    private MailSend() {

    }

    /**
     * get properties.
     *
     * @return
     */
    private static Properties getSmtpProperties() {
        Properties props = new Properties();
        props.put("mail.smtp.host", getHostSmtp());
        props.put("mail.smtp.port", getSmtpPort());
        if (getSmtpPort().equals("465")) {
            props.put("mail.smtp.socketFactory.port", getSmtpPort());
            props.put("mail.smtp.socketFactory.class", factory);
        } else { // 587 port
            props.put("mail.smtp.starttls.enable", "true");
        }
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.trust", getHostSmtp());
        props.put("mail.mime.charset", encoding);
        return props;
    }

    /**
     * send mail.
     *
     * @param sender     sender email
     * @param senderName sender name
     * @param passwd     password
     * @param receiver   receivers email
     * @param receiverName receivers name
     * @param subject    subject
     * @param contents   contents
     * @param intSendOption sending option
     * @return sent or not
     */
    public static synchronized boolean sendMail(String sender, String senderName, String passwd, String receiver, String receiverName, String subject, String contents, int intSendOption) {
        boolean isSent = true;
        try {
            if (props==null) props = getSmtpProperties();
            Session mailSession = Session.getInstance(props, getAuth(sender, passwd));
            MimeMessage message = new MimeMessage(mailSession);

            InternetAddress fromAddr = new InternetAddress(sender, senderName, encoding);
            message.setFrom(fromAddr);

            // add message unique id and confirm receipt image
            String message_uid = sender + "----" + UUID.randomUUID().toString();
            message.setHeader("message_uid", message_uid);
            message.setHeader("Disposition-Notification-To", sender);
            message.setHeader("Return-Receipt-To", sender);
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(receiver, StrUtil.nvl(receiverName), encoding));
            message.setSubject(subject, encoding);
            message.setContent(contents, "text/html; charset=utf-8");

            // Transport.send(message);

            SMTPMessage smtpmsg = new SMTPMessage(message);
            smtpmsg.setNotifyOptions(SMTPMessage.NOTIFY_SUCCESS);
            Transport.send(smtpmsg);

            moveToBoxAfterWrite(message, intSendOption, sender, passwd);
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailSend.sendMail");
            logger.error(e.toString());
            isSent = false;
        }
        return isSent;
    }

    public static synchronized String sendMail(String sender, String senderName, String passwd, String[] receiver, String[] receiverName, String subject, String contents, int intSendOption) {
        String message_uid = sender + "----" + UUID.randomUUID().toString();
        try {
            if (props==null) props = getSmtpProperties();
            Session mailSession = Session.getInstance(props, getAuth(sender, passwd));
            MimeMessage message = new MimeMessage(mailSession);

            InternetAddress fromAddr = new InternetAddress(sender, senderName, encoding);
            message.setFrom(fromAddr);

            // add message unique id and confirm receipt image
            message.setHeader("message_uid", message_uid);
            message.setHeader("Disposition-Notification-To", sender);
            message.setHeader("Return-Receipt-To", sender);
            // contents += "<img src='"+ConfigurationMgr.getInstance().getString("MAIL_CALLBACK_URL")+message_uid+"&s=' width=0 height=0 loading=\"lazy\">";

            InternetAddress[] tos = new InternetAddress[receiver.length];
            for (int i=0; i<receiver.length;i++) {
                InternetAddress to = new InternetAddress(receiver[i], StrUtil.nvl(receiverName[i], ""), encoding);
                tos[i] = to;
            }
            message.setRecipients(Message.RecipientType.TO, tos);
            message.setSubject(subject, encoding);
            message.setContent(contents, "text/html; charset=utf-8");

            // Transport.send(message);

            SMTPMessage smtpmsg = new SMTPMessage(message);
            smtpmsg.setNotifyOptions(SMTPMessage.NOTIFY_SUCCESS);
            Transport.send(smtpmsg);

            moveToBoxAfterWrite(message, intSendOption, sender, passwd);
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailSend.sendMail");
            logger.error(e.toString());
            message_uid = null;
        }
        return message_uid;
    }

    /**
     * send mail.
     *
     * @param sender sender
     * @param passwd password
     * @param vo message to send
     * @return message unique id 
     */
    public static synchronized String sendMail(String sender, String passwd, MailSmtpVO vo) {
        String message_uid = sender + "----" + UUID.randomUUID().toString();
        /*
        System.out.println(vo.from);
        System.out.println(vo.senderName);
        System.out.println(vo.subject);
        System.out.println(vo.receivers);
        System.out.println(vo.cc);
        System.out.println(vo.bcc);
        System.out.println(vo.messageText);
        */
        try {
            if (props==null) props = getSmtpProperties();
            if (vo.files!=null) props.put("mail.mime.encodefilename", true);

            Session mailSession = Session.getInstance(props, getAuth(sender, passwd));
            MimeMessage message = new MimeMessage(mailSession);

            /******************** 수신확인모듈 **********************/
            // add message unique id and confirm receipt image
            message.setHeader("message_uid", message_uid);
            vo.messageText += "<img src='"+ConfigurationMgr.getInstance().getString("MAIL_CALLBACK_URL")+message_uid+"&s=' width=0 height=0 loading=\"lazy\">";

            // sender
            InternetAddress fromAddr = new InternetAddress(sender, vo.senderName, encoding);
            message.setFrom(fromAddr);

            // receiver
            InternetAddress[] tos = new InternetAddress[vo.receivers.size()];
            for (int i=0; i<vo.receivers.size();i++) {
                String[] str = vo.receivers.get(i).split(strSeparatorBetweenNameAndEmail);
                InternetAddress to = new InternetAddress(str[1], StrUtil.nvl(str[0], ""), encoding);
                tos[i] = to;
            }
            message.setRecipients(Message.RecipientType.TO, tos);

            // carbon-copy
            if (vo.cc!=null && vo.cc.size()>0) {
               tos = new InternetAddress[vo.cc.size()];
               for (int i=0; i<vo.cc.size();i++) {
                   String[] str = vo.cc.get(i).split(strSeparatorBetweenNameAndEmail);
                   InternetAddress to = new InternetAddress(str[1], StrUtil.nvl(str[0], ""), encoding);
                   tos[i] = to;
               }
               message.setRecipients(Message.RecipientType.CC, tos);
            }

            if (vo.bcc!=null && vo.bcc.size()>0) {
               tos = new InternetAddress[vo.bcc.size()];
               for (int i=0; i<vo.bcc.size(); i++) {
                   String[] str = vo.bcc.get(i).split(strSeparatorBetweenNameAndEmail);
                   InternetAddress to = new InternetAddress(str[1], StrUtil.nvl(str[0], ""), encoding);
                   tos[i] = to;
               }
               message.setRecipients(Message.RecipientType.BCC, tos);
            }

            // subject
            message.setSubject(vo.subject, encoding);
            message.setContent(getBody(sender, vo));

            // System.out.println(vo.sendOption);
            if (vo.sendOption == 1) { // send
                message.setSentDate(new Date());
                Transport.send(message);
            } else {
                message.setHeader("message_uid", message_uid);
                if (vo.reserveddt!=null && vo.reserveddt.length()==12) {
                    MailDatabaseCtrl.reservate(sender, message_uid, vo.reserveddt);
                }
            }
            moveToBoxAfterWrite(message, vo.sendOption, sender, passwd);
            deleteFile(vo.files, vo.strfilePath);
        } catch(Exception e) {
            message_uid = null;
            Logger logger = Logger.getLogger("MailSend.sendMessage");
            logger.error(e.toString());
        }
        
        return message_uid;
    }

    private static Multipart getBody(String user, MailSmtpVO vo) {
        Logger logger = Logger.getLogger("MailSend.getBody");
        Multipart mp = new MimeMultipart();
        try {

            /* embedded images */
            ArrayList<MimeBodyPart> mbps = new ArrayList<>();
            ArrayList<String> arrEmbedded = getImagesInHtml(vo.messageText); // html내 img src에서 경로추출
            if (arrEmbedded!=null && arrEmbedded.size()>0) {
                for (int i=0; i<arrEmbedded.size(); i++) {
                    String s = arrEmbedded.get(i);
                    //System.out.println("############################## INLINE IMAGE ###############################");
                    //System.out.println(s);
                    //System.out.println(vo.messageText);
                    MimeBodyPart mbp = addEmbeddedImage(s, i, user); // 이미지를 content-id를 가진 base64 생성
                    mbps.add(mbp);
                    s = s.replaceAll("[?]", "[?]").replaceAll("[$]", "["+quoteReplacement("$")+"]");
                    // System.out.println(vo.messageText);
                    System.out.println(s);
                    vo.messageText = vo.messageText.replaceAll(s, "cid:emb"+Integer.toString(i)+""); // 이미지의 src를 content-id로 대체
                    //System.out.println("#############################################################");
                }
            }

            /* large file : supply link, not attach to body */
            if (vo.files!=null && vo.files.size()>0) {
                String strLargeFiles = "";
                for (int a=0; a<vo.files.size();) {
                    String fn = vo.files.get(a);
                    File f = new File(vo.strfilePath + fn);
                    if (f.exists()) {
                        if (f.length()>=20000000) {
                            String filename = fn;
                            if (filename.indexOf("/")>-1) {
                                filename = filename.substring(filename.lastIndexOf("/")+1);
                            }
                            String strSize = StrUtil.addComma(f.length()/1024/1024) + " MB";
                            strLargeFiles += "<li><a href='" + ConfigurationMgr.getInstance().getString("MAIL_FILE_URL") + filename + "' target='_new'>" + filename + " ("+strSize+")</a></li>";
                            vo.files.remove(a);
                        } else a++;
                    } else a++;
                }
                strLargeFiles = (strLargeFiles.length()>0) ? "<div style='border:1px solid #ddd;padding:10px;'><b>대용량첨부파일</b> ("+ DateTimeUtil.diff(DateTimeUtil.getCurrentDate("/"), -7, "/") +" 까지 다운로드 가능)<ul style='margin-top:10px'>"+strLargeFiles+"</ul></div>" : "";
                vo.messageText += strLargeFiles;
            }

            // logger.debug("rest-file-size:" + Integer.toString(vo.files.size()));
            /* attach file to body */
            int i = 1;
            if (vo.files!=null && vo.files.size()>0) {
                for (String filename : vo.files) {
                    File f = new File(vo.strfilePath + filename);
                    if (f.exists() && f.isFile() && filename.length()>3) {
                    	logger.debug(filename + " is Exited!!!!!!!!!!!!!!!!!");

	                    MimeBodyPart part = new MimeBodyPart();
	                    FileDataSource fds = new FileDataSource(vo.strfilePath + filename);
	                    DataHandler dh = new DataHandler(fds);
	                    part.setDataHandler(dh);
	                    
	                    Path path = Paths.get(vo.strfilePath + filename);
	                    String mt = Files.probeContentType(path);
	                    
	                    if (filename.indexOf("/")>-1) {
	                        filename = filename.substring(filename.lastIndexOf("/")+1);
	                    }
	                    part.setHeader("Content-ID", "<att"+Integer.toString(i++)+">"); // for google
	                    // part.setHeader("Content-Type", mt);
	                    // part.setFileName(MimeUtility.encodeText(filename, encoding, "B"));
	                    // part.setDisposition(Part.ATTACHMENT);
	                    
	                    part.setHeader("Content-Type", mt + ";\n	name=\"" + MimeUtility.encodeText(filename, encoding, "B") + "\"");
	                    part.setHeader("Content-Disposition", Part.ATTACHMENT +";\n	filename=\"" + MimeUtility.encodeText(filename, encoding, "B") + "\"");
	                    
	                    mp.addBodyPart(part);
                    }
                }
            }

            MimeBodyPart htmlpart = new MimeBodyPart();
            htmlpart.setContent(vo.messageText, "text/html; charset=utf-8");
            mp.addBodyPart(htmlpart);

            // add embedded
            if (mbps!=null && mbps.size()>0) {
                for (MimeBodyPart mbp : mbps) {
                    mp.addBodyPart(mbp);
                }
            }

            /*
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            mp.writeTo(outputStream);
            logger.debug(outputStream.toString(StandardCharsets.UTF_8.name()));
            */
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
        return mp;
    }

    // get image file path from html
    private static ArrayList<String> getImagesInHtml(String str) {
        ArrayList<String> arr = new ArrayList<>();
        try {
            Pattern image_source_grabber = Pattern.compile("<img[^>]*src=[\"']?([^>\"']+)[\"']?[^>]*>");
            Matcher captured = image_source_grabber.matcher(str);
            while(captured.find()) {
                if (captured.group(1).indexOf(MailEnv.strPathForEditor)>-1) { // 편집기에서 추출되었으면?
//                	String s = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH") + "editor/" + captured.group(1).split(MailEnv.strPathForEditor)[1];
                    arr.add(captured.group(1));
                }
                if (captured.group(1).indexOf(MailEnv.strUrlForEmbedImg)>-1) { // 임베디드된 이미지라면?
                    arr.add(captured.group(1));
                }
            }
        } catch (Exception e) {

        }
        return arr;
    }

    private static MimeBodyPart addEmbeddedImage(String img, int i, String user) {
        MimeBodyPart part = new MimeBodyPart();
        try {
            String strFileName = img;
            String strFileExt  = img;
            if (img.indexOf(MailEnv.strPathForEditor)>-1) {
                img = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH") + "editor/" + img.split(MailEnv.strPathForEditor)[1];
                if (img.indexOf("/")>-1) {
                    strFileName = strFileName.substring(strFileName.lastIndexOf("/")+1);
                    strFileExt  = strFileName.substring(strFileName.lastIndexOf(".")+1);
                }
            } else if (img.indexOf(MailEnv.strUrlForEmbedImg)>-1) {
                img = MailEnv.getEmbedFilePath(img, user);
                strFileName = "fwd"+Integer.toString(i)+".png";
                strFileExt  = "png";
            }
            FileDataSource fds = new FileDataSource(img);
            DataHandler dh = new DataHandler(fds);
            part.setDataHandler(dh);
            part.setHeader("Content-ID", "<emb"+Integer.toString(i)+">");
            if (!strFileName.equals("")) {
                part.setHeader("Content-Type", "image/"+strFileExt+"; "+MimeUtility.encodeText("name="+strFileName, encoding, "B"));
            }
        } catch (Exception e) {
        	e.printStackTrace();
        }
        return part;
    }

    /**
     * move to message after mail is sent.
     *
     * @param message
     * @param isSent
     * @throws Exception
     */
    private static void moveToBoxAfterWrite(MimeMessage message, int intSendOption, String sender, String passwd) throws Exception {
        try {
            MailFolder mail = new MailFolder(sender, passwd, false, "kr");
            if (intSendOption==1) { // sent folder
                mail.openFolder(strDefaultBoxSent, Folder.READ_WRITE);
                message.setFlag(Flag.SEEN, true);
            } else if (intSendOption==2) { // draft folder
                mail.openFolder(strDefaultBoxDraft, Folder.READ_WRITE);
                message.setFlag(Flag.DRAFT, true);
            } else if (intSendOption==3) { // reserve folder
                mail.openFolder(strDefaultBoxReserve, Folder.READ_WRITE);
                message.setFlag(Flag.DRAFT, true);
            }
            if (intSendOption>0) { // 0 = not save
                mail.getFolder().appendMessages(new Message[] {message});
            }
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailSend.moveToBoxAfterWrite");
            logger.error(e.toString());
        }
    }

    /**
     * delete file.
     *
     * @param files
     * @param filePath
     */
    private static void deleteFile(ArrayList<String> files, String filePath) {
        try {
            if (files!=null && files.size()>0) {
                for (int i=0; i<files.size();) {
                    File f = new File(filePath + files.remove(0));
                    if (f.exists()) f.delete();
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailSend.deleteFile");
            logger.error(e.toString());
        }
    }

    public static void main(String[] args) {
        try {
        	String filename = "2023년 10월 KT email 명세서(문서열기암호：사업자등록번호 뒤 5자리).pdf";
        	System.out.println(MimeUtility.encodeText(filename, encoding, "B"));
        	
            Path path = Paths.get("C:\\Users\\ryanm\\Downloads\\2023년 10월 KT email 명세서(문서열기암호：사업자등록번호 뒤 5자리).pdf");
            String mt = Files.probeContentType(path);
        	System.out.println(mt);
            
        	MimeBodyPart part = new MimeBodyPart();
        	part.setFileName(MimeUtility.encodeText(filename, encoding, "B"));
        	
        	System.out.println(part.getContent());
        	
        } catch (Exception e) {
            System.out.println(e.toString());
        }
    }
}
