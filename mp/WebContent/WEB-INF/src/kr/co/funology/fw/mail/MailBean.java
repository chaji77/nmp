package kr.co.funology.fw.mail;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;

import javax.mail.Address;
import javax.mail.Flags;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Part;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeUtility;
import javax.mail.search.SearchTerm;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.jsoup.Jsoup;

import com.sun.mail.util.BASE64DecoderStream;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

public class MailBean {

    ///////////////////////////////////////////////////////////////////////////////
    //
    // GET MESSAGE & FOLDER
    //
    ///////////////////////////////////////////////////////////////////////////////

    private ArrayList<MailFolderVO> arrMailBox;
    private int intMessageCount = 0;
    private String strLanguageCode = "kr";
    
    public MailBean(String strLanguage) {
    	this.strLanguageCode = StrUtil.nvl(strLanguage, ConfigurationMgr.getInstance().getString("DEFALUT_LANGUAGE_CD"));
    }

    public ArrayList<MailVO> getList(String folder, String user, String passwd, int intPage, int intRowCnt, boolean isNotSeen, boolean isFlagged) {
        ArrayList<MailVO> arr = null;
        Logger logger = Logger.getLogger(this.getClass());
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            try {
                moveUnseenMailToUserDefinedFolder(mail, user); // Auto Classification
            } catch (Exception e) {
                logger.error(e.toString());
            }

            this.arrMailBox = mail.getSortedDefaultForder(); // Sorted Default Folders
            if (folder!=null) {
                mail.openFolder(folder, Folder.READ_ONLY);
                if (isNotSeen) {
                	this.intMessageCount = mail.getFolder().getUnreadMessageCount();
                }
                else {
                	this.intMessageCount = mail.getMessageCount();
                }
                int intStart = this.intMessageCount - (intPage*intRowCnt) + 1;
                int intEnd   = this.intMessageCount - (intPage*intRowCnt) + intRowCnt;
                if (intEnd > this.intMessageCount) intEnd = this.intMessageCount;
                if (intStart < 1) intStart = 1;

                if (isNotSeen) {
                    arr = new MessageUtil().getForList(this.getUnreadMessage(mail.getFolder().getMessages(), intStart, intEnd));
                } else if (isFlagged) {
                	arr = new MessageUtil().getForList(this.getFlaggedMessage(mail.getFolder().getMessages(), intPage, intRowCnt));
                } else {
                	arr = new MessageUtil().getForList(mail.getFolder().getMessages(intStart, intEnd));
                }
            } else {
                logger.debug("folder is not existed : " + user + ":" + passwd);
            }
            mail.close();
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
        return arr;
    }

    private Message[] getUnreadMessage(Message[] msgs, int intStart, int intEnd) {
    	Message[] m = null;
    	ArrayList<Message> arr = new ArrayList<>();
    	try {
    		for (int i=0; i<msgs.length; i++) {
    			Message msg = msgs[i];
    			if (!msg.getFlags().contains(Flags.Flag.SEEN)) {
    				arr.add(msg);
    			}
    		}
    		System.out.println("UNSEEN LIST ==================");
    		System.out.println(arr.size());
    		System.out.println(intStart);
    		System.out.println(intEnd);
    		if (arr!=null) {
    			ArrayList<Message> arrto = new ArrayList<>();
    			for (int i=intStart; i<=intEnd; i++) {
    			    arrto.add(arr.get(i-1));
    			}
    			System.out.println(arrto.size());
        		m = new Message[arrto.size()];
        		for (int i=0; i<arrto.size(); i++) {
        			m[i] = arrto.get(i);
        		}
    		}
    	} catch (Exception e) {
    		//
    	}
    	return m;
    }

    private Message[] getFlaggedMessage(Message[] msgs, int intPage, int intRowCnt) {
    	Message[] m = null;
    	ArrayList<Message> arr = new ArrayList<>();
    	try {
    		for (int i=0; i<msgs.length; i++) {
    			Message msg = msgs[i];
    			if (msg.getFlags().contains(Flags.Flag.FLAGGED)) {
    				arr.add(msg);
    			}
    		}
    		this.intMessageCount = arr.size();

            int intStart = this.intMessageCount - (intPage*intRowCnt) + 1;
            int intEnd   = this.intMessageCount - (intPage*intRowCnt) + intRowCnt;
            if (intEnd > this.intMessageCount) intEnd = this.intMessageCount;
            if (intStart < 1) intStart = 1;

    		System.out.println("FLAGGED LIST ==================");
    		System.out.println(arr.size());
    		System.out.println(intStart);
    		System.out.println(intEnd);

    		if (arr!=null) {
    			for (int i=arr.size(); i>intEnd; i--) {
    				if (arr.size()>intEnd) arr.remove(intEnd);
    			}
    			for (int i=0; i<intStart; i++) {
    				if (arr.size()>intStart) arr.remove(0);
    			}

        		m = new Message[arr.size()];
        		for (int i=0; i<arr.size(); i++) {
        			m[i] = arr.get(i);
        		}
    		}
    	} catch (Exception e) {
    		//
    	}
    	return m;
    }



    public ArrayList<MailVO> getSearchList(String folder, String user, String passwd, int intPage, int intRowCnt, boolean isNotSeen, boolean isFlagged, String strPosition, String strValue) {
        ArrayList<MailVO> arr = new ArrayList<>();
        Logger logger = Logger.getLogger(this.getClass());
        final String strSearchKeyword = strValue.toLowerCase();
        final boolean isUnread = isNotSeen;
        final boolean isImportant = isFlagged;
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            moveUnseenMailToUserDefinedFolder(mail, user);         // Auto Classification
            this.arrMailBox = mail.getSortedDefaultForder();       // Sorted Default Folders
            if (folder!=null) {
                SearchTerm searchTerm = new SearchTerm() {
                    private static final long serialVersionUID = 1L;
                    @Override
                    public boolean match(Message message) {
                        try {
                        	if (isUnread) if (message.getFlags().contains(Flags.Flag.SEEN)) return false;
                        	if (isImportant) if (!message.getFlags().contains(Flags.Flag.FLAGGED)) return false;
                        	if (!strSearchKeyword.equals("")) {
	                            if (strPosition.toLowerCase().contains("subject")) {
	                                if (message.getSubject().toLowerCase().contains(strSearchKeyword)) return true;
	                            } else if (strPosition.contains("from")) {
	                                Address[] f = message.getFrom();
	                                InternetAddress ia = (InternetAddress)f[0];
	                                if (ia.getPersonal().toLowerCase().contains(strSearchKeyword) || ia.getAddress().toLowerCase().contains(strSearchKeyword)) return true;
	                            } else if (strPosition.toLowerCase().contains("to")) {
	                                Address[] f = message.getAllRecipients();
	                                for (int i=0; i<f.length; i++) {
	                                    InternetAddress ia = (InternetAddress)f[i];
	                                    if (ia.getPersonal().toLowerCase().contains(strValue) || ia.getAddress().toLowerCase().contains(strSearchKeyword)) return true;
	                                }
	                            } else if (strPosition.contains("body")) {
	                                if (Jsoup.parse(message.getContent().toString()).toString().toLowerCase().contains(strSearchKeyword)) return true;
	                            } else {
	                                if (message.getSubject().toLowerCase().contains(strSearchKeyword)) return true;
	                                if (Jsoup.parse(message.getContent().toString()).toString().toLowerCase().contains(strSearchKeyword)) return true;
	                            }
                        	} else return true;
                        	return false;
                        } catch (Exception e) {
                            logger.error(e.toString());
                        }
                        return false;
                    }
                };
                mail.openFolder(folder, Folder.READ_ONLY);
                Message[] msgs = mail.getFolder().search(searchTerm);
                if (msgs!=null) {
                    this.intMessageCount = msgs.length;
                    int intStart = this.intMessageCount - (intPage*intRowCnt) + 1;
                    int intEnd   = this.intMessageCount - (intPage*intRowCnt) + intRowCnt;
                    if (intEnd > this.intMessageCount) intEnd = this.intMessageCount;
                    if (intStart < 0) intStart = 0;
                    for (int i=intEnd; i>intStart; i--) {
                        arr.add(new MessageUtil().getForList(msgs[i-1]));
                    }
                }
                msgs=null;
            }
            mail.close();
        } catch (Exception e) {
            logger.error(e.toString());
        }
        return arr;
    }


    public int getMessageCount() {
        return this.intMessageCount;
    }

    private void moveUnseenMailToUserDefinedFolder(MailReceive mail, String user) {
        try {
            mail.openFolder(MailEnv.strDefaultBoxIn, Folder.READ_WRITE);
            Message[] msgs = mail.getUnReadMessages();
            if (msgs==null || msgs.length<1) {
                mail.closeFolder();
                return;
            }

            ArrayList<MailClassifyVO> arr = MailDatabaseCtrl.getUserRule(user);
            if (arr==null || arr.size()==0) return;

            for (int i = 0; i < msgs.length; i++) {
                MailVO mailvo = new MessageUtil().get(msgs[i], false, "");
                for (int j=0; j<arr.size(); j++) {
                    boolean toMove = false;
                    MailClassifyVO vo = arr.get(j);
                    if (vo.position.equals("sender") && mailvo.strSender.toLowerCase().indexOf(vo.rule.toLowerCase())>-1) {
                        toMove = true;
                    }
                    if (vo.position.equals("title") && mailvo.strSubject.toLowerCase().indexOf(vo.rule.toLowerCase())>-1) {
                        toMove = true;
                    }
                    if (toMove) {
                        mail.moveMessage(msgs[i], vo.folder);
                    }
                }
            }
            mail.closeFolder();

        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }


    /**
     * Get Only MailBox without List or Message. i.e. WRITE/SIGN
     *
     * @param user    사용자
     * @param passwd  비밀번호
     * @return 사용자 메일함
     */
    public ArrayList<MailFolderVO> getOnlyMailBox(String user, String passwd) {
        ArrayList<MailFolderVO> arr = new ArrayList<>();
        try {
        	System.out.println(this.strLanguageCode);
            MailReceive mail = new MailReceive(user, passwd, true, this.strLanguageCode);
            arr = mail.getSortedDefaultForder();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return arr;
    }

    /**
     * Get MailBox
     *
     * @return 사용자 메일함
     */
    public ArrayList<MailFolderVO> getMailBox() {
        return this.arrMailBox;
    }


    /**
     * Get Message For MailDetail.jsp
     *
     * @param folder  저장된 메일함
     * @param user    사용자이메일주소
     * @param passwd  비밀번호
     * @param no      메일번호
     * @param withContent 메일본문까지 가져올지의 여부
     * @return 메일내용
     */
    public MailVO getMessage(String folder, String user, String passwd, int no, boolean withContent) {
        MailVO vo = new MailVO();
        try {
            MailReceive mail = new MailReceive(user, passwd, true, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_WRITE);
            Message message = mail.getMessage(no);
            message.setFlag(Flags.Flag.SEEN, true);
            vo = new MessageUtil().get(message, withContent, folder);
            this.arrMailBox = mail.getSortedDefaultForder();
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return vo;
    }

    public void getMessageToOut(String folder, String user, String passwd, int no, HttpServletResponse response) {
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            message.writeTo(response.getOutputStream());
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    private MessageUtil messageUtilForDetailContent;

    /**
     * get mail contents for iframe tag in MailDetail.jsp.
     *
     * @param folder 메일함
     * @param user   사용자
     * @param passwd 비밀번호
     * @param no     메일번호
     * @return 메일내용
     */
    public String getMessageContent(String folder, String user, String passwd, int no) {
        String rtn = "";
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            this.messageUtilForDetailContent = new MessageUtil();
            rtn = this.messageUtilForDetailContent.getContent(message.getMessageNumber(), message);
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return rtn;
    }

    /**
     * get attach file
     *
     * @param user       사용자이메일
     * @param passwd     비밀번호
     * @param no         메일번호
     * @param cid        첨부파일의 아이디
     * @param folder     메일함
     * @param response   출력위치
     */
    public void getAttachedFile(String user, String passwd, int no, String cid, String folder, HttpServletResponse response) {
        Logger logger = Logger.getLogger("MailBean.getAttachedFile");
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            Object content = message.getContent();
            if (cid.indexOf(MailEnv.strNoContentIdKey)>-1) { // for file that has not content-id. 2022/02/25
                cid = cid.replaceAll(MailEnv.strNoContentIdKey, "");
                if (StrUtil.isOnlyNumeric(cid)) {
                    getAttachedFileHasnotCid(content, Integer.parseInt(cid), response);
                }
            } else getAttachedFileInMultiple(content, cid, response);
            mail.close();
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    private void getAttachedFileInMultiple(Object content, String cid, HttpServletResponse response) {
        Logger logger = Logger.getLogger("MailBean.getAttachedFileInMultiple");
        try {
            if (content instanceof Multipart) {
                for (int i=0; i<((Multipart) content).getCount(); i++) {
                    Part part = ((Multipart) content).getBodyPart(i);
                    logger.debug(part.getContentType());
                    logger.debug(part.getContent().toString());
                    if (part.isMimeType("multipart/*")) {
                        getAttachedFileInMultiple(part.getContent(), cid, response);
                    } else {
                        String[] cids = part.getHeader("Content-ID");
                        if (cids!=null && cids.length>0) {
                            for (int c=0; c<cids.length; c++) {
                                String key = cids[c].substring(1, cids[c].length()-1);
                                if (key.equals(cid)) {
                                    outputFile(part, response);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    private void outputFile(Part part, HttpServletResponse response) {
        Logger logger = Logger.getLogger("MailBean.outputFile");
        try {
            String fn = URLEncoder.encode(MimeUtility.decodeText(part.getFileName()), "UTF-8").replaceAll("\\+", " ");
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment;filename=" + fn);
            InputStream is = part.getInputStream();
            OutputStream os = new BufferedOutputStream(response.getOutputStream());
            int c;
            while ((c=is.read())>-1) {
                os.write(c);
            }
            is.close();
            os.close();
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    /**
     * get attached file that hasn't content-id
     * @param user
     * @param passwd
     * @param no
     * @param intBodyIdx
     * @param folder
     * @param response
     */
    private void getAttachedFileHasnotCid(Object content, int intBodyIdx, HttpServletResponse response) {
        try {
            if (content instanceof Multipart) {
                Part part = ((Multipart) content).getBodyPart(intBodyIdx);
                if (part.isMimeType("multipart/*")) {
                    getAttachedFileHasnotCid(part.getContent(), intBodyIdx, response);
                } else {
                    if (part.getFileName()!=null) {
                        outputFile(part, response);
                    }
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailBean.getAttachedFile");
            logger.error(e.toString());
        }
    }


    /**
     * get Attached File For ReWrite
     *
     * @param user    userid
     * @param passwd  password
     * @param no      mail number
     * @param cid     content id
     * @param folder  folder
     * @param request request
     * @return attached files list
     */
    public String saveAttachedFileForRewrite(String user, String passwd, int no, String cid, String folder, HttpServletRequest request) {
        String strFilePath = "";
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            Object content = message.getContent();

            if (cid.indexOf(MailEnv.strNoContentIdKey)>-1) { // for file that has not content-id. 2022/02/25
                cid = cid.replaceAll(MailEnv.strNoContentIdKey, "");
                if (StrUtil.isOnlyNumeric(cid)) {
                    strFilePath = getAttachedFileHasnotCid(content, Integer.parseInt(cid), request);
                }
            } else strFilePath = getAttachedFileInMultiple(content, cid, request);

            mail.close();

        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailBean.saveAttachedFileForRewrite");
            logger.error(e.toString());
        }
        // System.out.println(strFilePath);
        return strFilePath;
    }

    /**
     * recursive method to get attached file
     *
     * @param content
     * @param cid
     * @param request
     * @return
     */
    private String getAttachedFileInMultiple(Object content, String cid, HttpServletRequest request) {
        Logger logger = Logger.getLogger("MailBean.getAttachedFileInMultiple");
        try {
            if (content instanceof Multipart) {
                for (int i=0; i<((Multipart) content).getCount(); i++) {
                    Part part = ((Multipart) content).getBodyPart(i);
                    if (part.isMimeType("multipart/*")) {
                        getAttachedFileInMultiple(part.getContent(), cid, request);
                    } else {
                        String[] cids = part.getHeader("Content-ID");
                        if (cids!=null && cids.length>0) {
                            for (int c=0; c<cids.length; c++) {
                                String key = cids[c].substring(1, cids[c].length()-1);
                                if (key.equals(cid)) {
                                    return outputFile(part, request);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
        return "";
    }

    /**
     * recursive method to get attached file that hasn't content-id
     * @param user
     * @param passwd
     * @param no
     * @param intBodyIdx
     * @param folder
     * @param response
     */
    private String getAttachedFileHasnotCid(Object content, int intBodyIdx, HttpServletRequest request) {
        try {
            if (content instanceof Multipart) {
                Part part = ((Multipart) content).getBodyPart(intBodyIdx);
                if (part.isMimeType("multipart/*")) {
                    getAttachedFileHasnotCid(part.getContent(), intBodyIdx, request);
                } else {
                    if (part.getFileName()!=null) {
                        return outputFile(part, request);
                    }
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailBean.getAttachedFile");
            logger.error(e.toString());
        }
        return "";
    }


    /**
     * save file to cache
     *
     * @param part
     * @param request
     * @return
     */
    private String outputFile(Part part, HttpServletRequest request) {
        Logger logger = Logger.getLogger("MailBean.outputFile");
        String strFilePath = "";
        try {
            String fn = MimeUtility.decodeText(part.getFileName()).replaceAll("\\+", " ");
            File file = new File(ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH")+"mail/cache/" + fn);
            if (!file.exists()) file.createNewFile();
            strFilePath = request.getContextPath() + ConfigurationMgr.getInstance().getString("UPLOAD_FILE_URL") + "mail/cache/" + file.getName();
            FileOutputStream fos = new FileOutputStream(file.getAbsolutePath());
            InputStream is = part.getInputStream();
            OutputStream os = new BufferedOutputStream(fos);
            int c;
            while ((c=is.read())>-1) {
                os.write(c);
            }
            is.close();
            os.close();
        } catch (Exception e) {
            logger.error(e.toString());
            e.printStackTrace();
        }
        return strFilePath;
    }

    /**
     * get embedded image
     *
     * @param user      mail-user
     * @param passwd    password
     * @param no        message number
     * @param cid       content-id in message
     * @param folder    mail box
     * @param mid       message id
     * @param response  image output
     */
    public void getEmbeddedFile(String user, String passwd, int no, String cid, String folder, String mid, HttpServletResponse response) {
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            getMultipartEmbededFile(message.getContent(), cid, response, MailEnv.setEmbedFilePath(user, folder, no, cid, mid));
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailBean.getAttachedFile");
            logger.error(e.toString());
        }
    }

    /**
     * recursive method to get embedded image
     *
     * @param content
     * @param cid
     * @param response
     */
    private void getMultipartEmbededFile(Object content, String cid, HttpServletResponse response, String sk) {
        try {
            if (content instanceof javax.mail.Multipart) {
                Multipart multipart = (javax.mail.Multipart) content;
                for (int i = 0; i < multipart.getCount(); i++) {
                    Part part = multipart.getBodyPart(i);
                    String[] cids = part.getHeader("Content-ID");
                    if (cids!=null && cids.length>0 && part.isMimeType("image/*")) {
                        for (int c=0; c<cids.length; c++) {
                            String key = "cid:"+cids[c].substring(1, cids[c].length()-1);
                            if (key.equals(cid)) {
                                // System.out.println("CALL BY EMBEDDED FILE ::::::::: " + cid + "=" + key);
                                if (part.getContent() instanceof BASE64DecoderStream) {

                                    // WRITE TO RESPONSE
                                    byte[] img = IOUtils.toByteArray(part.getInputStream());
                                    response.setContentType(part.getContentType());
                                    response.getOutputStream().write(img);

                                    // SAVE TEMPORARY FOR REPLY OR FORWARD
                                    File file = new File(sk);
                                    if (!file.exists()) file.createNewFile();
                                    FileOutputStream fos = new FileOutputStream(file.getAbsolutePath());
                                    InputStream is = part.getInputStream();
                                    OutputStream os = new BufferedOutputStream(fos);
                                    int d;
                                    while ((d=is.read())>-1) {
                                        os.write(d);
                                    }
                                    is.close();
                                    os.close();


                                    return;
                                }
                            }
                        }
                    }
                    if (part.isMimeType("multipart/*")) { // recursive
                        getMultipartEmbededFile(part.getContent(), cid, response, sk);
                    }
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger("MailBean.getAttachedFile");
            logger.error(e.toString());
            e.printStackTrace();
        }
    }


    ///////////////////////////////////////////////////////////////////////////////
    //
    // MESSAGE/FOLDER CONTROL
    //
    ///////////////////////////////////////////////////////////////////////////////

    /**
     * Drop Message
     *
     * @param user    userid
     * @param passwd  password
     * @param no      mail number
     * @param box     mailbox(folder)
     */
    public void dropMessage(String user, String passwd, String[] no, String box) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(box, Folder.READ_WRITE);

            Message[] messages = new Message[no.length];
            for (int i=0; i<no.length; i++) {
                messages[i] = mf.getFolder().getMessage(Integer.parseInt(no[i]));
            }
            mf.dropMessage(messages, mf.getFolder());
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    /**
     * Send message to trash
     *
     *
     * @param user   userid
     * @param passwd password
     * @param no     mail numbers
     * @param box    mail box(folder)
     */
    public void goTrash(String user, String passwd, String[] no, String box) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(box, Folder.READ_WRITE);

            Message[] messages = new Message[no.length];
            for (int i=0; i<no.length; i++) {
                messages[i] = mf.getFolder().getMessage(Integer.parseInt(no[i]));
            }
            mf.moveMessage(messages, MailEnv.strDefaultBoxTrash);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    public void moveMessageTo(String user, String passwd, String[] no, String box, String tobox) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(box, Folder.READ_WRITE);

            Message[] messages = new Message[no.length];
            for (int i=0; i<no.length; i++) {
                messages[i] = mf.getFolder().getMessage(Integer.parseInt(no[i]));
            }
            mf.moveMessage(messages, tobox);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    /**
     * Clear Trash
     *
     * @param user   userid
     * @param passwd password
     * @return clear or not
     */
    public boolean clearTrash(String user, String passwd) {
        boolean is = true;
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(MailEnv.strDefaultBoxTrash, Folder.READ_WRITE);
            Message[] messages = mf.getFolder().getMessages();
            mf.dropMessage(messages, mf.getFolder());
            mf.close();
        } catch (Exception e) {
            is = false;
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return is;
    }

    public void saveEmail(String folder, String user, String passwd, int[] no, HttpServletResponse response) {
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            mail.saveEmail(no, response);
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    //
    // FLAG CONTROL
    //
    ///////////////////////////////////////////////////////////////////////////////

    public void setFlag(String user, String passwd, String strBox, int no, boolean isFlag) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(strBox, Folder.READ_WRITE);
            mf.setFlaged(mf.getFolder().getMessage(no), isFlag);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    public void setRead(String user, String passwd, String strBox, String[] no, boolean isRead) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(strBox, Folder.READ_WRITE);
            mf.setRead(no, isRead);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    public void setReply(String user, String passwd, String strBox, String[] no, boolean isReply) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(strBox, Folder.READ_WRITE);
            mf.setReply(no, isReply);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    //
    // FOLDER VIEW CONTROL
    //
    ///////////////////////////////////////////////////////////////////////////////

    private static boolean isDefaultFolder(String nm) {
        if (nm.equals(MailEnv.strDefaultBoxDraft) ||
            nm.equals(MailEnv.strDefaultBoxIn) ||
            nm.equals(MailEnv.strDefaultBoxSent) ||
            nm.equals(MailEnv.strDefaultBoxJunk) ||
            nm.equals(MailEnv.strDefaultBoxReserve) ||
            nm.equals(MailEnv.strDefaultBoxTrash)) {
            return true;
        }
        return false;
    }

    public static String getFolderView(ArrayList<MailFolderVO> arrFolder) {
        String strLeftMenus = "";
        try {
            if (arrFolder!=null && arrFolder.size()>0) {
              for (int f=0; f<arrFolder.size(); f++) {
                  MailFolderVO fvo = arrFolder.get(f);
                  String img = "";
                  if (isDefaultFolder(fvo.nm)) img = "<img src='../images/mail/" + fvo.nm + ".png'>";
                  else {
                      String imgs = "<img src='../images/mail/blank.png'>";
                      if (fvo.depth>0) {
                        for (int g=0; g<fvo.depth; g++) {
                          img += imgs;
                        }
                      }
                  }
                  String draggable = "";
                  if (!fvo.nm.equals(MailEnv.strDefaultBoxDraft) && !fvo.nm.equals(MailEnv.strDefaultBoxReserve)) {
                      draggable = "class='droppable'";
                  }

                  strLeftMenus += "<li>"+img+"<a "+draggable+" box='"+fvo.fullname+"' encodebox='"+URLEncoder.encode(fvo.fullname, "utf-8")+"' onclick='goMailBox(this);'>"+StrUtil.cutString(fvo.local, 15-(fvo.depth*2), "..")+"</a>";
                  strLeftMenus += " <span class='more'>";
                  if (fvo.nm.equals(MailEnv.strDefaultBoxIn)) strLeftMenus += "<a href='javascript:goNotReadList(\\\""+MailEnv.strDefaultBoxIn+"\\\");' title='Not Read Messages'>" + StrUtil.addComma(fvo.cnt) + "</a>";
                  if (!fvo.nm.equals(MailEnv.strDefaultBoxIn)) {
                      if (fvo.nm.contentEquals(MailEnv.strDefaultBoxDraft) && fvo.total_cnt>0) strLeftMenus += StrUtil.addComma(fvo.total_cnt);
                      else {
                          if (fvo.cnt>0) strLeftMenus += StrUtil.addComma(fvo.cnt);
                      }
                  }
                  if (fvo.nm.equals(MailEnv.strDefaultBoxTrash)) strLeftMenus += "<img src='../images/mail/sweep.png' onclick='clearTrash();' title='Empty' style='cursor:pointer;margin-left:10px;margin-right:-7px;'>";
                  if (!isDefaultFolder(fvo.nm)) strLeftMenus += "<img src='../images/mail/more.png' onclick='showFolderControl(\\\""+fvo.fullname+"\\\")' style='cursor:pointer;margin-left:10px;margin-right:-7px;'>";
                  strLeftMenus += "</span></li>";
              }
            }
        } catch(Exception e) {
            Logger logger = Logger.getLogger("MailBean.getFolderView");
            logger.error(e.toString());
        }
        return strLeftMenus;
    }

    public static String getFolderViewForMove(ArrayList<MailFolderVO> arrFolder) {
        String strLeftMenus = "";
        try {
            if (arrFolder!=null && arrFolder.size()>0) {
              for (int f=0; f<arrFolder.size(); f++) {
                  MailFolderVO fvo = arrFolder.get(f);
                  if (fvo.fullname.contains(MailEnv.strDefaultBoxReserve) || fvo.fullname.contains(MailEnv.strDefaultBoxDraft)) {}
                  else {
                      String img = "";
                      if (isDefaultFolder(fvo.nm)) img = "<img src='../images/mail/" + fvo.nm + ".png'>";
                      else {
                          String imgs = "<img src='../images/mail/blank.png'>";
                          if (fvo.depth>0) {
                            for (int g=0; g<fvo.depth; g++) {
                              img += imgs;
                            }
                          }
                      }
                      strLeftMenus += "<li box='"+fvo.fullname+"'>"+img+fvo.local+"</li>";
                  }
              }
            }
        } catch(Exception e) {
            Logger logger = Logger.getLogger("MailBean.getFolderViewForMove");
            logger.error(e.toString());
        }
        return strLeftMenus;
    }

    ///////////////////////////////////////////////////////////////////////////////
    //
    // RECALL
    //
    ///////////////////////////////////////////////////////////////////////////////

    public MailVO getReceiverMail(String folder, String user, String passwd, int no) {
        MailVO vo = new MailVO();
        try {
            MailReceive mail = new MailReceive(user, passwd, false, this.strLanguageCode);
            mail.openFolder(folder, Folder.READ_ONLY);
            Message message = mail.getMessage(no);
            vo = MessageUtil.getReceiptEmail(message);
            mail.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return vo;
    }

    public int recall(ArrayList<String[]> arr, String strMessageUid) {
        int intResult = 0;
        if (arr!=null && arr.size()>0) {
            for (int i=0; i<arr.size();) {
                String[] str = arr.remove(0);
                MailRecall recall = new MailRecall(str[0], str[1], false); // str[0] = email, str[1] = password
                intResult += recall.recall(strMessageUid);
            }
        }
        return intResult;
    }

    ///////////////////////////////////////////////////////////////////////////////
    //
    // CUSTOM FOLDER CONTROL
    //
    ///////////////////////////////////////////////////////////////////////////////

    public boolean createFolder(String user, String passwd, String strParent, String strFolder) {
        boolean isCreated = false;
        try {
            //System.out.println(strParent);
            //System.out.println(strFolder);
            MailFolder mf = new MailFolder(user, passwd, false, this.strLanguageCode);
            if (strParent.contentEquals("")) isCreated = mf.createFolder(strFolder);
            else isCreated = mf.createFolder(strParent, strFolder);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return isCreated;
    }

    public boolean dropFolder(String user, String passwd, String strFolder) {
        boolean isDrop = false;
        try {
            MailFolder mf = new MailFolder(user, passwd, false, this.strLanguageCode);
            isDrop = mf.removeFolder(strFolder);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return isDrop;
    }

    public boolean renameFolder(String user, String passwd, String strFolder, String strToFolder) {
        boolean isChanged = false;
        try {
            MailFolder mf = new MailFolder(user, passwd, false, this.strLanguageCode);
            isChanged = mf.renameFolder(strFolder, strToFolder);
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return isChanged;
    }



    ///////////////////////////////////////////////////////////////////////////////
    //
    // SEND TEMPORARY MESSAGE IS SAVED AUTO
    //
    ///////////////////////////////////////////////////////////////////////////////

    public void dropTemporaryMessage(String user, String passwd, String messageuid) {
        try {
            MailReceive mf = new MailReceive(user, passwd, false, this.strLanguageCode);
            mf.openFolder(MailEnv.strDefaultBoxDraft, Folder.READ_WRITE);

            Message[] messages = mf.getMessages();
            for (int i=0; i<messages.length; i++) {
                if (MessageUtil.getMessageUid(messages[i]).contains(messageuid)) {
                    Message[] rm = {messages[i]};
                    mf.dropMessage(rm, mf.getFolder());
                    break;
                }
            }
            mf.close();
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

}

