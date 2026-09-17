package kr.co.funology.fw.mail;

import java.util.ArrayList;
import java.util.Properties;

// import javax.mail.Authenticator;
import javax.mail.Folder;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.URLName;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

/**
 * MAIL FOLDER CONTROL.
 * OPEN/GET/DROP &amp; MESSAGE MOVE/DROP
 *
 *
 * @author PRO
 *
 */
public class MailFolder extends MailEnv {

    private Session  session;
    private Store    store;
    private Folder   folder;
    private String   strFolder = "INBOX";
    private ArrayList<MailFolderVO> arrDefaultFolder = null;
    /**
     * Constructor
     * 
     * @param id userid
     * @param passwd password
     * @param isLoadFolder with folder list?
     * @param strLang language code
     */
    public MailFolder(String id, String passwd, boolean isLoadFolder, String strLang) {
      try {
            if (id!=null && passwd!=null) {
                connectStore(id, passwd);
                if (isLoadFolder) {
                    loadDefaultFolders();
                }
            } else throw new MessagingException("cannot read id and password");
        } catch (MessagingException e) {
            Logger logger = Logger.getLogger("MailFolder");
            logger.error(e.toString());
            e.printStackTrace();
        }
    }

    /*
    private void setSession(String id, String passwd) {
        Properties props = new Properties();
        if (super.getImapPort() == 993) {
            props.setProperty("mail.imap.ssl.enable", "true");
            this.session = javax.mail.Session.getInstance(props);
        } else {
            props.setProperty("mail.imap.ssl.enable", "false");
            Authenticator auth = super.getAuth(id, passwd);
            this.session = javax.mail.Session.getInstance(props, auth);
        }
    }
    */
    
    private void setSession() {
      if (this.session == null) {
        Properties props = null;
        try {
          props = System.getProperties();
        } catch (SecurityException sex) {
          props = new Properties();
        }
        this.session = Session.getInstance(props, null);
      }
    }

    /**
     * connect store.
     *
     * @throws MessagingException
     */
    private void connectStore(String id, String passwd) throws MessagingException {
        setSession();
        if (getImapPort() == 993) {
          try {
            URLName url = new URLName("imaps", super.getHostImap(), super.getImapPort(), this.strFolder, id, passwd);
            this.store = this.session.getStore(url);
            this.store.connect();
          } catch (Exception e) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.error(e.toString());
                logger.error(getImapPort());
                logger.error(id);
                logger.error(passwd);
                throw new MessagingException("Cannot connect store.");
          }
        } else {
            try {
                this.store = this.session.getStore("imaps");
                this.store.connect(super.getHostImap(), id, passwd);
            } catch (Exception e) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.error(e.toString());
                logger.error(getImapPort());
                logger.error(id);
                logger.error(passwd);
                throw new MessagingException("Cannot connect store.");
            }
        }
    }

    /**
     * create folder if is not existed.
     *
     * @throws MessagingException
     */
    protected void createFolderIfIsNotExist() throws MessagingException {
        boolean isExistFolder = false;
        if (this.arrDefaultFolder==null || this.arrDefaultFolder.size()==0) loadDefaultFolders();
        for (int i=0; i<this.arrDefaultFolder.size(); i++) {
            if (this.strFolder.equals(this.arrDefaultFolder.get(i).nm)) {
                isExistFolder = true;
                break;
            }
        }
        if (!isExistFolder) createFolder(this.strFolder);
    }

    /**
     * open folder.
     *
     * @param folder mail folder
     * @param intOpenOption open option 
     * @throws MessagingException messaging exception
     */
    public void openFolder(String folder, int intOpenOption) throws MessagingException {
        this.strFolder = (folder==null) ? strDefaultBoxIn : folder; // Trash,Sent,INBOX
        if (!this.store.isConnected()) throw new MessagingException("Store is not openned.");
        // if (this.arrDefaultFolder==null || this.arrDefaultFolder.size()<1) throw new MessagingException("Default folders are not loaded.");
        createFolderIfIsNotExist();
        try {
            this.folder = this.store.getFolder(this.strFolder);
            this.folder.open(intOpenOption);
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
            throw new MessagingException("Cannot open folder.");
        }
    }

    /**
     * close
     *
     * @throws MessagingException messaging exception
     */
    public void close() throws MessagingException {
        if (this.folder!=null && this.folder.isOpen()) this.folder.close(true);
        if (this.store!=null && this.store.isConnected()) this.store.close();
    }


    public void closeFolder() throws MessagingException {
        if (this.folder!=null && this.folder.isOpen()) this.folder.close(true);
    }

    ///////////////////////// GETTER ///////////////////////////

    /**
     * get store is opened.
     *
     * @return store
     * @throws MessagingException messaging exception
     */
    public Store getStore() throws MessagingException {
        if (!this.store.isConnected()) throw new MessagingException("Already closed store.");
        return this.store;
    }

    /**
     * get folder is opened.
     *
     * @return folder list
     * @throws MessagingException messaging exception
     */
    public Folder getFolder() throws MessagingException {
        if (!this.folder.isOpen()) throw new MessagingException("Already closed folder.");
        return this.folder;
    }

    /**
     * Load Default Folders' name.
     *
     * @throws MessagingException messaging exception
     */
    private void loadDefaultFolders() throws MessagingException {
        this.arrDefaultFolder = new ArrayList<>();
        try {
            Folder[] fs = this.store.getDefaultFolder().list("*");
            for (int i=0; i<fs.length; i++) {
                if (!fs[i].getName().contentEquals("Temporary")) {
                    MailFolderVO v = new MailFolderVO();
                    v.nm = fs[i].getName();
                    v.fullname = fs[i].getFullName();
                    v.local = StrUtil.nvl(ConfigurationMgr.getInstance().getString("MAIL_FOLDER_"+v.nm), v.nm);
                    // change to language properties
                    // v.local = StrUtil.nvl(new LanguageMgr(this.strLanguageCode).getString("mail","MAIL_FOLDER_"+v.nm), v.nm);
                    v.total_cnt = fs[i].getMessageCount();
                    // v.cnt = fs[i].getNewMessageCount(); // this.store.getFolder(v.fullname).getUnreadMessageCount();
                    v.cnt = fs[i].getUnreadMessageCount();
                    this.arrDefaultFolder.add(v);
                }
            }
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
    }

    public ArrayList<MailFolderVO> getDefaultForder() throws MessagingException {
        return this.arrDefaultFolder;
    }

    /**
     * get Default Folders that is sorted.
     *
     * @return default folder list
     * @throws MessagingException messaging exception
     */
    public ArrayList<MailFolderVO> getSortedDefaultForder() throws MessagingException {
        if (this.arrDefaultFolder==null) loadDefaultFolders();
        ArrayList<MailFolderVO> arrReturnFolder = new ArrayList<>();
        try {
            if (this.arrDefaultFolder!=null && this.arrDefaultFolder.size()>0) {
                String[] ord = ConfigurationMgr.getInstance().getString("MAIL_FOLDER_ORDER").split(","); // order by configuration.properties
                for (int i=0; i<ord.length; i++) {
                    for (int f=0; f<this.arrDefaultFolder.size(); f++) {
                        if (ord[i].equals(this.arrDefaultFolder.get(f).nm)) {
                            arrReturnFolder.add(this.arrDefaultFolder.remove(f));
                            break;
                        }
                    }
                }
                for (int f=0; f<this.arrDefaultFolder.size();) { // rest
                    arrReturnFolder.add(this.arrDefaultFolder.remove(0));
                }
            }
            this.arrDefaultFolder = sortHierarch(arrReturnFolder, new ArrayList<MailFolderVO>(), null);
        } catch (Exception e) {
            Logger logger = Logger.getLogger(this.getClass());
            logger.error(e.toString());
        }
        return this.arrDefaultFolder;
    }

    /**
     * sort folders hierarchically.
     *
     * @param origin  original list
     * @param ordered reordered list
     * @param vo changing folder
     * @return reordered list
     */
    private ArrayList<MailFolderVO> sortHierarch(ArrayList<MailFolderVO> origin, ArrayList<MailFolderVO> ordered, MailFolderVO vo) {
        if (vo==null) {
            if (origin!=null && origin.size()>0) {
                vo = origin.remove(0);
                vo.depth = 1;
                ordered.add(vo);
            }
        }
        if (origin!=null && origin.size()>0) {
            for (int i=0; i<origin.size();) {
                if (origin.get(i).fullname.indexOf(vo.fullname + ".")>-1) {
                    MailFolderVO newVo = origin.remove(i);
                    newVo.depth = vo.depth+1;
                    ordered.add(newVo);
                    ordered.get(ordered.size()-1).hasChild = true;
                    sortHierarch(origin, ordered, newVo);
                } else i++;
            }
            if (vo.depth==1) sortHierarch(origin, ordered, null);
        }
        return ordered;
    }

    /**
     * get Shared Folders.
     *
     * @return get shared folder list
     * @throws MessagingException messaging exception
     */
    public String[] getSharedFolders() throws MessagingException {
        String[] folders;
        Folder[] fs = this.store.getSharedNamespaces();
        folders = new String[fs.length];
        for (int i=0; i<fs.length; i++) {
            folders[i] = fs[i].getName();
        }
        return folders;
    }

    /**
     * get Personal Folders.
     *
     * @return get personal folders
     * @throws MessagingException messaging exception
     */
    public String[] getPersonalFolders() throws MessagingException {
        String[] folders;
        Folder[] fs = this.store.getPersonalNamespaces();
        folders = new String[fs.length];
        for (int i=0; i<fs.length; i++) {
            folders[i] = fs[i].getName();
        }
        return folders;
    }


    ///////////////////////// FOLDER CONTROL ///////////////////////////

    /**
     * Create Folder.
     *
     * @param name folder name to create
     * @return success or not
     * @throws MessagingException messaging exception
     */
    public boolean createFolder(String name) throws MessagingException {
        boolean is = false;
        if (
            name.equals(MailEnv.strDefaultBoxIn) ||
            name.equals(MailEnv.strDefaultBoxSent) ||
            name.equals(MailEnv.strDefaultBoxDraft) ||
            name.equals(MailEnv.strDefaultBoxJunk) ||
            name.equals(MailEnv.strDefaultBoxReserve) ||
            name.equals(MailEnv.strDefaultBoxTrash)) {
            return false;
        }
        Folder f = getStore().getFolder(name);
        if(!f.exists()) is = f.create(Folder.HOLDS_MESSAGES);
        return is;
    }
    public boolean createFolderForInit(String name) throws MessagingException {
        boolean is = false;
        Folder f = getStore().getFolder(name);
        if(!f.exists()) is = f.create(Folder.HOLDS_MESSAGES);
        return is;
    }

    /**
     * Create SubFolder.
     *
     * @param strParent parent folder name
     * @param name folder name to add
     * @return success or not
     * @throws MessagingException messaging exception
     */
    public boolean createFolder(String strParent, String name) throws MessagingException {
        boolean is = false;
        try {
          if (
              //strParent.indexOf(MailEnv.strDefaultBoxIn)>-1 ||
              //strParent.indexOf(MailEnv.strDefaultBoxSent)>-1 ||
              strParent.indexOf(MailEnv.strDefaultBoxDraft)>-1 ||
              strParent.indexOf(MailEnv.strDefaultBoxJunk)>-1 ||
              strParent.indexOf(MailEnv.strDefaultBoxReserve)>-1 ||
              strParent.indexOf(MailEnv.strDefaultBoxTrash)>-1) {
              return false;
          }
          Folder pf = getStore().getFolder(strParent);
          if (!pf.exists()) createFolder(strParent);
          Folder f = pf.getFolder(name);
          if(!f.exists()) is = f.create(Folder.HOLDS_MESSAGES);
          else System.out.println(name + " is existed.");
        } catch(Exception e) {
          System.out.println(e.toString());
        }
        return is;
    }


    /**
     * Remove folder with sub folder.
     *
     * @param name folder name to delete
     * @return delete or not
     * @throws MessagingException messaging exception
     */
    public boolean removeFolder(String name) throws MessagingException {
        Folder[] fs = this.store.getDefaultFolder().list("*");
        for (int i=0; i<fs.length;i++) {
          if (fs[i].getFullName().contains(name)) {
            System.out.println("delete ::::::::: " + fs[i].getFullName());
            if(fs[i].exists()) {
              fs[i].delete(false);
            }
          }
        }
        return true;
    }

    /**
     * Rename Folder
     *
     * @param name folder name to edit
     * @param toName new folder name
     * @return success or not
     * @throws MessagingException messaging exception
     */
    public boolean renameFolder(String name, String toName) throws MessagingException {
        if (
          name.equals(MailEnv.strDefaultBoxIn)      ||
          name.equals(MailEnv.strDefaultBoxSent)    ||
          name.equals(MailEnv.strDefaultBoxDraft)   ||
          name.equals(MailEnv.strDefaultBoxJunk)    ||
          name.equals(MailEnv.strDefaultBoxReserve) ||
          name.equals(MailEnv.strDefaultBoxTrash)) {
          return false;
        }
        Folder[] fs = this.store.getDefaultFolder().list("*");
        for (int i=0; i<fs.length;i++) {
          if (fs[i].getFullName().equals(toName)) {
            System.out.println(fs[i].getFullName() + " is existed.");
            return false;
          }
        }
        for (int i=0; i<fs.length;i++) {
          if (fs[i].getFullName().contains(name)) {
            System.out.println(fs[i].getFullName() + ">>>" + toName);
            if(fs[i].exists()) {
              String strToName = fs[i].getFullName().replace(name, toName);
              Folder pf = getStore().getFolder(strToName);
              fs[i].renameTo(pf);
            }
          }
        }
        return true;
    }

    /**
     * initialize folder for new user.
     * 
     */
    public void initialize() {
        try {
          createFolderForInit(MailEnv.strDefaultBoxIn);
          createFolderForInit(MailEnv.strDefaultBoxDraft);
          createFolderForInit(MailEnv.strDefaultBoxSent);
          createFolderForInit(MailEnv.strDefaultBoxJunk);
          createFolderForInit(MailEnv.strDefaultBoxReserve);
          createFolderForInit(MailEnv.strDefaultBoxTrash);
        } catch (Exception e) {
          Logger logger = Logger.getLogger(this.getClass());
          logger.error(e.toString());
        }
    }

}
