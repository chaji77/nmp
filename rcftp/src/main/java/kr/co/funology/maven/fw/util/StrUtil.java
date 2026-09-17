package kr.co.funology.maven.fw.util;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import kr.co.funology.maven.fw.mgr.ConfigurationMgr;

/**
 * String Utility
 *
 *
 * @author DOLGAMZA
 * @version 1.0
 * @since 2012.08
 *
 */
public class StrUtil {

    private StrUtil() {}

    public static String nvl(String str) {
        return (str==null) ? "" : str.trim();
    }

    public static String nvl(String str, String strReplaceWord) {
        return (str==null || str.trim().equals("")) ? strReplaceWord : str.trim();
    }

    public static String input(String str) {
        return (str==null) ? "" : str.trim().replaceAll("'", "&apos;").replaceAll("\"", "&quot;");
    }

    public static String input(String str, String strReplaceWord) {
        return (str==null || str.trim().equals("")) ? strReplaceWord : str.trim().replaceAll("'", "&apos;").replaceAll("\"", "&quot;");
    }


    public static boolean isEmpty(String str) {
        return (str!=null && !str.trim().equals("")) ? false : true;
    }

    public static String changeCharSet(String str, String fromCharSet, String toCharSet) throws UnsupportedEncodingException {
        return new String(nvl(str).getBytes(fromCharSet), toCharSet);
    }

    public static String changeCharSet(String str) {
        try {
            return changeCharSet(str, "8859_1", "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return str;
        }
    }

    public static String revokeCharSet(String str) {
        try {
            return changeCharSet(str, "UTF-8", "8859_1");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return str;
        }
    }

    public static String getParameter(String strParameter, String strReplaceWord, int intLength) {
        strParameter = nvl(strParameter, strReplaceWord); // check null
        strParameter = strParameter.replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", ""); // remove html tag
        strParameter = cutString(strParameter, intLength, "");
        // strParameter = changeCharSet(strParameter); // change Character Set
        return strParameter;
    }

    public static String convertNumberFormat(String strPattern, String intNumber) {
    	try {
    		java.text.DecimalFormat f = new java.text.DecimalFormat(strPattern);
    		return f.format(intNumber);
    	} catch (Exception e) {
    		return "0";
    	}
    }
    
    public static String convertNumberFormat(String strPattern, int intNumber) {
        java.text.DecimalFormat f = new java.text.DecimalFormat(strPattern);
        return f.format(intNumber);
    }

    public static String convertNumberFormat(String strPattern, double dblNumber) {
        java.text.DecimalFormat f = new java.text.DecimalFormat(strPattern);
        return f.format(dblNumber);
    }

    public final static boolean isAlpha(String str) {
        for (int i=0; i<str.length(); i++) {
            if (!Character.isLetterOrDigit(str.charAt(i))) { return false; }
        }
        return (true);
    }

    public final static boolean isOnlyNumeric(String str) {
        for (int i = 0; i < str.length(); i++) {
            if (!Character.isDigit(str.charAt(i))) { return false; }
        }
        return (true);
    }

    public static String addComma(String str) {
        String  strReturn   = "";
        boolean isNegative  = false;
        String  strUnderDot = "";
        String  strComma    = ",";

        str = nvl(str, "0");
        if (str.substring(0, 1).equals("-")) {
            str        = str.substring(1);
            isNegative = true;
        }
        for (int i=0; i<str.length(); i++) {
            if (str.charAt(i) == '.') {
                strUnderDot = str.substring(i);
                str         = str.substring(0, i);
                break;
            }
        }
        for (int i=str.length(), j=0; i>0; i--, j++) {
            if ((j%3)==2) {
                if (str.length() == j+1) strReturn = str.substring(i-1, i) + strReturn;
                else strReturn = strComma + str.substring(i-1, i) + strReturn;
            } else strReturn = str.substring(i-1, i) + strReturn;
        }

        strReturn = (isNegative) ? "-" + strReturn : strReturn;
        return strReturn + strUnderDot;
    }

    public static String addComma(int a) {
        return addComma(Integer.toString(a));
    }

    public static String addComma(Double a) {
        BigDecimal b = new BigDecimal(a);
        return addComma(b.toString());
    }

    public static String addComma(Long a) {
        BigDecimal b = new BigDecimal(a);
        return addComma(b.toString());
    }
    public static String addComma(Float a) {
        BigDecimal b = new BigDecimal(a);
        return addComma(b.toPlainString());
    }
    public static String addCommaAfterRound(Float a) {
        BigDecimal b = new BigDecimal(a);
        return addCommaAfterRound(b.toPlainString());
    }
    public static String addCommaAfterRound(String b) {
        if (b != null && b.contains(".")) {
            b = b.substring(0, b.indexOf("."));
        }
        return addComma(b);
    }

    public static String cutString(String strObj, int intObjLength, String strTail) {
        int intStringLength  = strObj.length();
        if (intStringLength > intObjLength) {
            char chrObj;
            int intStringCutPos=0;
            for (int intMax=intObjLength; intMax>=0;) {
                intStringCutPos=intMax;
                chrObj = strObj.charAt(intMax);
                if(chrObj<128) { break; }
                else { intStringCutPos--; break; }
            }
            strObj = strObj.substring(0,intStringCutPos+1) + strTail;
        }
        else { }
        return strObj;
    }

    public static String replaceString(String strSearch, String strReplace, String strSource) {
        int spot;
        String returnString;
        String origSource = new String(strSource);
        spot = strSource.indexOf(strSearch);
        if (spot > -1) { returnString = ""; }
        else { returnString = strSource; }
        while (spot > -1) {
            if (spot == strSource.length() + 1) {
                returnString = returnString.concat(strSource.substring(0, strSource.length() - 1).concat(strReplace));
                strSource = "";
            }
            else if (spot > 0) {
                returnString = returnString.concat(strSource.substring(0, spot).concat(strReplace));
                strSource = strSource.substring(spot + strSearch.length(), strSource.length());
            }
            else {
                returnString = returnString.concat(strReplace);
                strSource = strSource.substring(spot + strSearch.length(), strSource.length());
            }
            spot = strSource.indexOf(strSearch);
        }
        if (!strSource.equals(origSource)) { return returnString.concat(strSource); }
        else { return returnString; }
    }

    public static boolean isValidEmail(String email) {
        boolean err = false;
        String regex = "^[_a-z0-9-]+(.[_a-z0-9-]+)*@(?:\\w+\\.)+\\w+$";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(email);
        if(m.matches()) err = true;
        return err;
    }

    public static String stripTags(String str) {
        return nvl(str).replaceAll("\\<.*?\\>", "");
    }

    public static String encrypt(String str, String key) {
        return ParameterCryptoUtil.encrypt(nvl(str), nvl(key));
    }

    public static String decrypt(String str, String key) {
        return ParameterCryptoUtil.decrypt(nvl(str), nvl(key));
    }

    public static String xss(String str) {
        str = nvl(str);
        str = HtmlWhiteListUtil.filter(str);
        str = input(str);
        return str;
    }
    
    public static String removeHrefAttribute(String html) {
        return html.replaceAll("<a\\s+([^>]*\\s+)?href=['\"][^'\"]*['\"]([^>]*)>", "<a$1$2>");
    }
    
    public static String fileToString(String p_dir, String p_file) {
        String allString = "";
        try {
            BufferedReader bufferReader = new BufferedReader(new InputStreamReader(new FileInputStream(p_dir + "/" + p_file),"UTF8"));
            String bufferString = "";
            while((bufferString = bufferReader.readLine()) != null) allString += bufferString + "\n";
               bufferReader.close();
        } catch (Exception e) {
            System.out.println(p_dir + p_file + " IS NOT EXISTED.");
        }
        return allString;
    }

    public static String templateToString(String p_file) {
        String rtn = "";
        try {
          rtn = fileToString(ConfigurationMgr.getInstance().getString("TEMPLATE_PATH"), p_file);
        } catch (Exception e) {
          System.out.println("TEMPLETE IS NOT EXISTED.");
        }
        return rtn;
    }
    /**
     * 문자열에서 숫자만 추출하고 지정된 자리수만큼만 반환한다. 자리수보다 부족하면 0을 반환한다.
     * @param input 문자열
     * @param digitLength 지정된 자리수
     * @return
     */
    public static String extractDigits(String input, int digitLength) {
        // 문자열에서 숫자만 추출
    	if (input.indexOf(".")>-1) input = input.split("[.]")[0];
        String digits = input.replaceAll("\\D", "");
        // 지정된 자리수만큼 잘라 반환
        if (digits.length() >= digitLength) {
            return digits.substring(0, digitLength);
        } else {
            return digits;
        }
    }
    public static String extractInteger(String input) {
        input = nvl(input);
        if (input.indexOf(".")>-1) input = input.split("[.]")[0];
        return input.replaceAll("\\D", "");
    }
    public static String extractAndFormat(String input, int totalLength, int decimalPlaces) {
        // 숫자와 점만 추출
    	input = StrUtil.nvl(input, "0");
        String raw = input.replaceAll("[^0-9.]", "");

        // 소수점이 여러 개일 경우 첫 번째만 유지
        raw = raw.replaceAll("\\.(?=.*\\.)", "");

        // 전체 자리수 초과 시 자르기
        if (raw.length() > totalLength) {
            raw = raw.substring(0, totalLength);
        }

        // 소수점 위치 조정
        int dotIndex = raw.indexOf(".");
        if (dotIndex == -1) {
            // 소수점이 없을 경우 끝에 추가
            raw += ".";
            dotIndex = raw.length() - 1;
        }

        // 정수부와 소수부 분리
        String integerPart = raw.substring(0, dotIndex);
        String decimalPart = raw.substring(dotIndex + 1);

        // 소수부 자리수 맞추기
        if (decimalPart.length() > decimalPlaces) {
            decimalPart = decimalPart.substring(0, decimalPlaces);
        } else {
            while (decimalPart.length() < decimalPlaces) {
                decimalPart += "0";
            }
        }

        // 정수부와 소수부 결합
        raw = integerPart + "." + decimalPart;

        // 전체 자리수 다시 확인
        if (raw.length() > totalLength) {
            raw = raw.substring(0, totalLength);
        }

        return raw;
    }
    
    
    public static void main(String[] args) {
      System.out.println(StrUtil.extractDigits("120,860.000", 17));
      System.out.println(StrUtil.extractAndFormat("0.116", 5, 3));
      System.out.println(StrUtil.extractAndFormat(".116", 5, 3));
      System.out.println(StrUtil.extractAndFormat("19000000000000000", 13, 3));
      System.out.println(StrUtil.addCommaAfterRound("190000000.04"));
    }
}
