package kr.co.funology.fw.mail;

import java.util.ArrayList;

public class MailSmtpVO {

    public ArrayList<String> receivers;
    public ArrayList<String> cc;
    public ArrayList<String> bcc;
    public String subject;
    public String messageText;
    public String from;
    public String senderName;
    public int    sendOption;
    public String strfilePath;
    public ArrayList<String> files;
    public String reserveddt;

}
