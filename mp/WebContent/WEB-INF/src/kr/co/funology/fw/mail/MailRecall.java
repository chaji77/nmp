package kr.co.funology.fw.mail;

import javax.mail.Flags;
import javax.mail.Folder;
import javax.mail.Message;

import org.apache.log4j.Logger;

import kr.co.funology.fw.util.StrUtil;

public class MailRecall extends MailFolder {

    public MailRecall(String id, String passwd, boolean isLoadFolder) {
        super(id, passwd, false, "kr");
        Logger logger = Logger.getLogger("MailCtrl");
        try {
            super.openFolder(MailEnv.strDefaultBoxIn, Folder.READ_WRITE);
        } catch (Exception e) {
            logger.error(e.toString());
        }
    }

    public int recall(String strMessageUid) {
        Logger logger = Logger.getLogger("MailCtrl.recall");
        strMessageUid = (strMessageUid.indexOf("----")>-1) ? strMessageUid.split("----")[1] : strMessageUid;
        logger.debug("to recall : " + strMessageUid);
        int intResult = 0;
        try {
            Message[] messages = super.getFolder().getMessages();
            for (Message message : messages) {
                if (strMessageUid!=null && strMessageUid.length()>10 && message.getHeader("message_uid")!=null && StrUtil.nvl(message.getHeader("message_uid")[0]).contains(strMessageUid) && !message.isExpunged() && !message.isSet(Flags.Flag.SEEN)) {
                    message.setFlag(Flags.Flag.DELETED, true);
                    logger.debug("recalled");
                }
            }
            Message[] msg = super.getFolder().expunge(); // permanently remove Flag.DELETED Messages
            intResult = (msg!=null) ? msg.length : 0;
            super.close();
        } catch(Exception e) {
            e.printStackTrace();
            logger.error(e.toString());
        }
        return intResult;
    }
}
