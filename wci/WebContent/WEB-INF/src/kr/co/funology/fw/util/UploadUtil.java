package kr.co.funology.fw.util;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;

public class UploadUtil  {

    ArrayList<String>  arrFileNames;
    ArrayList<Long>    arrFileSizes;
    HashMap<String, String> hmParams;
    ArrayList<UploadFieldFileVO> arrFieldFile;

    Logger logger = Logger.getLogger(this.getClass());
    String strUploadPath = "";

    public UploadUtil() {
        arrFileNames = new ArrayList<String>();
        arrFileSizes = new ArrayList<Long>();
        hmParams     = new HashMap<String, String>();
        arrFieldFile = new ArrayList<UploadFieldFileVO>();
    }

    /**
     * Upload File
     *
     * @param request
     */
    public void uploadFile(HttpServletRequest request) {
        int intMaxSize = 1024*1024*(ConfigurationMgr.getInstance().getInt("UPLOAD_FILE_MAX_SIZE_MB"));
        try {
            boolean isMultipart = ServletFileUpload.isMultipartContent(request);
            if (isMultipart==true) {
                DiskFileItemFactory factory  = new DiskFileItemFactory();
                factory.setRepository(getUploadTempFilePath());
                factory.setSizeThreshold(intMaxSize);
                ServletFileUpload upload = new ServletFileUpload(factory);
                upload.setSizeMax(intMaxSize);
                upload.setHeaderEncoding("utf-8");
                List<FileItem> items = upload.parseRequest(request);
                Iterator<FileItem> iter = items.iterator();
                while (iter.hasNext()) {
                    FileItem item = iter.next();
                    if (item.isFormField() == false) moveUploadedFile(item);
                    else setParameter(item);
                }
            }
        } catch (Exception e) {
            logger.error("File Upload is Failure." + e.toString());
        }
    }


    /**
     * Upload File
     *
     * @param request
     */
    public void uploadFile(HttpServletRequest request, String strEncodeType) {
        int intMaxSize = 1024*1024*(ConfigurationMgr.getInstance().getInt("UPLOAD_FILE_MAX_SIZE_MB"));
        try {
            boolean isMultipart = ServletFileUpload.isMultipartContent(request);
            if (isMultipart==true) {
                DiskFileItemFactory factory  = new DiskFileItemFactory();
                factory.setRepository(getUploadTempFilePath());
                factory.setSizeThreshold(intMaxSize);
                ServletFileUpload upload = new ServletFileUpload(factory);
                upload.setSizeMax(intMaxSize);
                upload.setHeaderEncoding(strEncodeType);
                List<FileItem> items = upload.parseRequest(request);
                Iterator<FileItem> iter = items.iterator();
                while (iter.hasNext()) {
                    FileItem item = iter.next();
                    if (item.isFormField() == false) moveUploadedFile(item);
                    else setParameter(item, strEncodeType);
                }
            }
        } catch (Exception e) {
            logger.error("File Upload is Failure." + e.toString());
        }
    }


    /**
     * Upload File
     *
     * @param request
     * @param strEncodeType
     * @param strSubPath
     *
     */
    public void uploadFile(HttpServletRequest request, String strEncodeType, String strSubPath) {
        int intMaxSize = 1024*1024*700;
        try {
            boolean isMultipart = ServletFileUpload.isMultipartContent(request);
            if (isMultipart==true) {
                DiskFileItemFactory factory  = new DiskFileItemFactory();
                factory.setRepository(getUploadTempFilePath());
                factory.setSizeThreshold(intMaxSize);
                ServletFileUpload upload = new ServletFileUpload(factory);
                upload.setSizeMax(intMaxSize);
                upload.setHeaderEncoding(strEncodeType);
                List<FileItem> items = upload.parseRequest(request);
                Iterator<FileItem> iter = items.iterator();
                while (iter.hasNext()) {
                    FileItem item = iter.next();
                    if (item.isFormField() == false) moveUploadedFile(item, strSubPath);
                    else setParameter(item, strEncodeType);
                }
            }
        } catch (Exception e) {
            logger.error("File Upload is Failure." + e.toString());
        }
    }


    /**
     * Set Request Parameters
     *
     * @param item
     */
    private void setParameter(FileItem item, String strEncodeType) {
        try {
            hmParams.put(item.getFieldName(), StrUtil.nvl(item.getString(strEncodeType)));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }


    /**
     * Move File From Repository To Upload Directory
     *
     * @param item
     * @throws Exception
     */
    private void moveUploadedFile(FileItem item) throws Exception {
        if (item.getSize()>0) {
            String  strFileName    = getFileName(item.getName());
            String  strContentType = item.getContentType();
            long    lngByteSize    = item.getSize();

            setUploadFiledFile(item, strFileName, lngByteSize);
            System.out.println("FileUpload : " + strFileName + "(" + lngByteSize + "byte, " + strContentType + ")");

            try {
                File uploadedFile = new File(getUploadFilePath(), strFileName);
                item.write(uploadedFile);
                item.delete();
            } catch (Exception e) {
                System.out.println("File Upload is Failure." + e.toString());
            }
        }

    }

    /**
     * Move File From Repository To Upload Directory
     *
     * @param item
     * @param strSubPath
     * @throws Exception
     */
    private void moveUploadedFile(FileItem item, String strSubPath) throws Exception {
        if (item.getSize()>0) {
            String  strFileName    = getFileName(item.getName());
            String  strContentType = item.getContentType();
            long    lngByteSize    = item.getSize();

            setUploadFiledFile(item, strFileName, lngByteSize);
            System.out.println("FileUpload : " + strFileName + "(" + lngByteSize + "byte, " + strContentType + ")");

            try {
                File uploadedFile = new File(getUploadFilePath() + strSubPath, strFileName);
                item.write(uploadedFile);
                item.delete();
            } catch (Exception e) {
                System.out.println("File Upload is Failure." + e.toString());
            }
        }
    }

    /**
     * FileName Filter
     *
     * @param str
     * @return
     */
    private String getFileName(String str) {

    	// String strDateTime = Long.toString(System.currentTimeMillis());
        String strDateTime = (DateTimeUtil.getCurrentDate("") + DateTimeUtil.getCurrentTime().replace(":", "")); // .substring(6);
        String slash = "________";
        String fileExtension = "";

        str = str.replaceAll("&amp;", "&");
        if(str.lastIndexOf(".") > 0) {
            String filename      = str.substring(0, str.lastIndexOf("."));
            fileExtension = str.substring(str.lastIndexOf("."), str.length());
            str = filename;
        }

        str = str.replace("/", slash);
        str = str.replace("\\", slash);
        String[] s = str.split(slash);

        String result = "";
        if (s[s.length-1].indexOf("_")>-1 && StrUtil.isOnlyNumeric(s[s.length-1].substring(s[s.length-1].lastIndexOf("_")+1))) {
            s[s.length-1] = s[s.length-1].substring(0, s[s.length-1].lastIndexOf("_"));
        }
        result = StrUtil.cutString(s[s.length-1], 100, "").replaceAll("'",  "").replaceAll("\"",  "") + "_" + strDateTime;
        System.out.println((result + fileExtension).length());
        return result + fileExtension;
    }


    /**
     * Set UploadFieldFile
     *
     * @param item
     * @param strFileName
     * @param lngByteSize
     */
    private void setUploadFiledFile(FileItem item, String strFileName, long lngByteSize) {
        UploadFieldFileVO vo = new UploadFieldFileVO();
        vo.FIELD_NM = item.getFieldName();
        vo.FILE_NM  = strFileName;
        vo.FILE_SIZE = lngByteSize;
        arrFieldFile.add(vo);

        arrFileNames.add(strFileName);
        arrFileSizes.add(lngByteSize);
    }


    /**
     * Set Request Parameters
     *
     * @param item
     */
    private void setParameter(FileItem item) {
        hmParams.put(item.getFieldName(), StrUtil.nvl(item.getString()));
    }


    public void setUploadFilePath(String strPath) {
        this.strUploadPath = strPath;
    }

    /**
     * Get Upload File Path From ConfigurationMgr
     *
     * @return upload file path
     */
    public String getUploadFilePath() {
        String  strPath = (this.strUploadPath==null || this.strUploadPath.equals("")) ? ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH") : this.strUploadPath;
        System.out.println("UploadFiles Directory is " + strPath);
        return strPath;
    }

    /**
     * Get Upload Repository From ConfigurationMgr
     *
     * @return repository
     */
    private File getUploadTempFilePath() {
        String  strPath = ConfigurationMgr.getInstance().getString("UPLOAD_TEMP_FILE_PATH");
        System.out.println("Repository is " + strPath);
        return new File(strPath);
    }

    /**
     * Get Uploaded File List
     *
     * @return filename
     */
    public ArrayList<String> getUploadedFileList() {
        return this.arrFileNames;
    }

    /**
     * Get Uploaded File Sizes
     *
     * @return size(byte)
     */
    public ArrayList<Long> getUploadedFileSizes() {
        return this.arrFileSizes;
    }

    /**
     * Get Form Parameters
     *
     * @return request parameters
     */
    public HashMap<String, String> getParameters() {
        return this.hmParams;
    }

    public ArrayList<UploadFieldFileVO> getFiledFile() {
        return this.arrFieldFile;
    }
    
    
    public static void main(String[] args) {
    	System.out.println(System.currentTimeMillis()/100);
    	System.out.println("20221109160533");
    }
}



