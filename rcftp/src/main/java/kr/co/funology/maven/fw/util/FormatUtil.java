package kr.co.funology.maven.fw.util;

import kr.co.funology.maven.fw.mgr.ConfigurationMgr;

public class FormatUtil {

    public static String addSeparatorDate(String str) {
        if (StrUtil.nvl(str, "").length()!=8) {
            return str;
        }
        String strSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
        return str.substring(0, 4) + strSeparator + str.substring(4, 6) + strSeparator + str.substring(6);
    }
    
    public static String addSeparatorDate(String str, String strSeparator) {
        if (StrUtil.nvl(str, "").length()!=8) {
            return str;
        }
        return str.substring(0, 4) + strSeparator + str.substring(4, 6) + strSeparator + str.substring(6);
    }
    
    public static String addSeparatorDateTime(String str, String strSepartor) {
    	if (StrUtil.nvl(str, "").length()!=14) return str;
    	return str.substring(0, 4) + strSepartor + str.substring(4, 6) + strSepartor + str.substring(6, 8) + " " + str.substring(8, 10) + ":" + str.substring(10, 12) + ":" + str.substring(12);
    }

    public static String addDashBizNo(String str) {
        if (StrUtil.nvl(str, "").length()!=10) {
            return str;
        }
        return str.substring(0, 3) + "-" + str.substring(3, 5) + "-" + str.substring(5);
    }
    
    public static String getFileSize(String size) {
        if (size==null) return "";
        String strUnit = "B";
        Double dblOrignal  = Double.parseDouble(size);;
        Double dblFileSize = Double.parseDouble(size);
        if (dblFileSize > 1024) {
            strUnit = "KB";
            dblFileSize = dblOrignal/1024;
        }
        if (dblFileSize > 1024) {
            strUnit = "MB";
            dblFileSize = dblOrignal/1024/1024;
        }
        if (dblFileSize > 1024) {
            strUnit = "GB";
            dblFileSize = dblOrignal/1024/1024/1024;
        }
        int intFileSize = (int) Math.round(dblFileSize);
        return StrUtil.addComma(Integer.toString(intFileSize)) + " " + strUnit;
    }
    
    private static String[] getPhoneNumberArray(String strPhoneNumber) {
        String[] arr = new String[3];
        if (strPhoneNumber!=null && strPhoneNumber.trim().length()>8) {
            arr[0] = (strPhoneNumber.substring(0,2).equals("02")) ? strPhoneNumber.substring(0,2) : strPhoneNumber.substring(0,3);
            arr[2] = strPhoneNumber.substring(strPhoneNumber.length()-4, strPhoneNumber.length());
            arr[1] = "";
            for (int i=arr[0].length(); i<strPhoneNumber.length()-4; i++) {
                arr[1] += strPhoneNumber.substring(i, i+1);
            }
        } else {
            arr[0] = "";
            arr[1] = "";
            arr[2] = strPhoneNumber;
        }
        return arr;
    }

    public static String addDashPhoneNumber(String strPhoneNumber) {
        String[] arr = getPhoneNumberArray(strPhoneNumber.replaceAll("-", ""));
        if (StrUtil.isOnlyNumeric(arr[0]) && StrUtil.isOnlyNumeric(arr[1]) && StrUtil.isOnlyNumeric(arr[2])) return arr[0] + "-" + arr[1] + "-" + arr[2];
        else return StrUtil.stripTags(strPhoneNumber);
    }
}
