package kr.co.funology.fw.mail;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.mail.Flags;
import javax.mail.Flags.Flag;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.search.FlagTerm;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.sun.mail.imap.IMAPFolder;

import kr.co.funology.fw.util.DateTimeUtil;

/**
 * RECEIVED MAIL CONTROL
 *
 * @author PRO
 *
 */
public class MailReceive extends MailFolder {

	/**
	 * Constructor
	 * 
	 * @param id             사용자아이디
	 * @param passwd         비밀번호
	 * @param isLoadFolder   폴더를 같이 가져올건지의 여부
	 * @param strLang        언어코드
	 */
    public MailReceive(String id, String passwd, boolean isLoadFolder, String strLang) {
        super(id, passwd, isLoadFolder, strLang);
    }

    /**
     * get Message
     *
     * @param no mail number
     * @return message
     * @throws MessagingException messaging exception 
     */
    public Message getMessage(int no) throws MessagingException {
        if (!super.getFolder().isOpen()) throw new MessagingException("Already closed folder.");
        return super.getFolder().getMessage(no);
    }

    /**
     * get messages in folder.
     *
     * @return message
     * @throws MessagingException messaging exception
     */
    public Message[] getMessages() throws MessagingException {
        if (!super.getFolder().isOpen()) throw new MessagingException("Already closed folder.");
        return super.getFolder().getMessages();
    }

    /**
     * get recent messages in box.
     *
     * @param cnt list count to get
     * @return recent messages
     * @throws MessagingException messaging exception
     */
    public Message[] getRecentMessages(int cnt) throws MessagingException {
        if (!super.getFolder().isOpen()) throw new MessagingException("Already closed folder.");
        int size = super.getFolder().getMessageCount();
        return super.getFolder().getMessages(size-cnt+1, size);
    }

    /**
     * get message count
     *
     * @return count to get
     * @throws MessagingException messaging exception
     */
    public int getMessageCount() throws MessagingException {
        if (!super.getFolder().isOpen()) throw new MessagingException("Already closed folder.");
        return super.getFolder().getMessageCount();
    }

    public boolean hasNewMessage(Folder folder) throws MessagingException {
        return folder.hasNewMessages();
    }

    /**
     * get message number.
     *
     * @param msg message
     * @return count of message id
     * @throws MessagingException messaging exception
     */
    public String getUid(Message msg) throws MessagingException {
        if (super.getFolder() instanceof IMAPFolder) return new Long(((IMAPFolder)super.getFolder()).getUID(msg)).toString();
        else throw new MessagingException("Cannot support.");
    }

    /**
     * get unread messages.
     *
     * @return unread messages
     * @throws MessagingException messaging exception
     */
    public Message[] getUnReadMessages() throws MessagingException {
        return getFolder().search(new FlagTerm(new Flags(Flags.Flag.SEEN), false));
    }

    ///////////////////////// MESSAGE CONTROL ///////////////////////////

    /**
     * Move Messages to Destination Folder.
     *
     * @param message message
     * @param dest folder to move
     * @throws MessagingException messaging exception
     */
    public void moveMessage(Message message, String dest) throws MessagingException {
        Message[] msg = {message};
        moveMessage(msg, getFolder(), getStore().getFolder(dest));
    }

    /**
     * Move Messages to Destination Folder.
     *
     * @param message messages to move
     * @param dest    target folder 
     * @throws MessagingException messaging exception
     */
    public void moveMessage(Message[] message, String dest) throws MessagingException {
        moveMessage(message, getFolder(), getStore().getFolder(dest));
    }

    /**
     * Move Messages to Destination Folder.
     *
     * @param message message
     * @param src     folder to move
     * @param dest    target folder
     * @throws MessagingException messaging exception
     */
    public void moveMessage(Message[] message, Folder src, Folder dest) throws MessagingException {
        try {
            if(!dest.exists()) dest.create(Folder.HOLDS_MESSAGES);
            src.copyMessages(message, dest);
            dropMessage(message, src);
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailReceiver.moveMessage");
            logger.error(e.toString());
        }
    }

    /**
     * delete message
     *
     * @param message messages to delete
     * @param src     folder of message
     * @throws MessagingException messaging exception
     */
    public void dropMessage(Message[] message, Folder src) throws MessagingException {
        src.setFlags(message, new Flags(Flags.Flag.DELETED), true);
        src.expunge(); // permanently remove Flag.DELETED Messages
    }


    /**
     * set read flag to message.
     *
     * @param message message
     * @throws MessagingException messaging exception
     */
    public void setSeenFlag(Message message) throws MessagingException {
        setFlag(message, Flags.Flag.SEEN, true);
    }

    /**
     * set unread flag to message.
     *
     * @param message message
     * @throws MessagingException messaging exception
     */
    public void setUnSeenFlag(Message message) throws MessagingException {
        setFlag(message, Flags.Flag.SEEN, false);
    }

    public void setFlaged(Message message, boolean set) throws MessagingException {
        setFlag(message, Flags.Flag.FLAGGED, set);
    }

    public void setRead(String[] no, boolean isRead) throws MessagingException {
       for (int i=0; i<no.length; i++) {
            Message message = getFolder().getMessage(Integer.parseInt(no[i]));
            message.setFlag(Flags.Flag.SEEN, isRead);
       }
    }

    public void setReply(String[] no, boolean isReply) throws MessagingException {
        for (int i=0; i<no.length; i++) {
             Message message = getFolder().getMessage(Integer.parseInt(no[i]));
             message.setFlag(Flags.Flag.ANSWERED, isReply);
        }
     }

    /**
     * set some flag.
     *
     * @param message message 
     * @param flag    flag key to set
     * @param set     flag value to set
     * @throws MessagingException messaging exception
     */
    private void setFlag(Message message, Flag flag, boolean set) throws MessagingException {
        message.setFlag(flag, set);
    }

    public void saveEmail(int[] no, HttpServletResponse response) {
        String[] strTitles  = new String[no.length];
        try {
            String fn = DateTimeUtil.getCurrentDateTime();
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition",  String.format("attachment; filename=\"%s\"", URLEncoder.encode(fn+".zip","UTF-8")));
            ZipOutputStream zos = new ZipOutputStream(response.getOutputStream());

            for (int i=0; i<no.length; i++) {
                Message message = getMessage(no[i]);
                String t = message.getSubject();
                SimpleDateFormat f = new SimpleDateFormat("yyyy_MM_dd HH_mm_ss");
                String strDate = f.format((message.getSentDate()==null) ? message.getReceivedDate() : message.getSentDate());
                t = "["+strDate+"] " + t;
                strTitles[i] = t;
                // System.out.println(convertToCapableWordAtWindow(t)+".eml");
                zos.putNextEntry(new ZipEntry(convertToCapableWordAtWindow(t)+".eml"));
                message.writeTo(zos);
                zos.closeEntry();
            }
            zos.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailReceiver.saveEmail");
            logger.error(e.toString());
        }
    }

    private String convertToCapableWordAtWindow(String str) {
        str = str.replace("\\", " ");
        str = str.replace("/", " ");
        str = str.replace(":", " ");
        str = str.replace("*", " ");
        str = str.replace("?", " ");
        str = str.replace("\"", " ");
        str = str.replace("<", " ");
        str = str.replace(">", " ");
        str = str.replace("|", " ");
        return str;
    }
}
