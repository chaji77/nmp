package kr.co.funology.fw.util;

import java.nio.charset.StandardCharsets;
import java.security.Key;

import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESedeKeySpec;

public class ParameterCryptoUtil {

    private static Key getKey(String keyValue) throws Exception {
        DESedeKeySpec desKeySpec = new DESedeKeySpec(keyValue.getBytes());
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DESede");
        Key key = keyFactory.generateSecret(desKeySpec);
        return key;
    }

    public static String encrypt(String str, String key) {
        key = ("CP" + StrUtil.nvl(key) + "EEEEEEEEEEEEEEEEEEEEEEEE").substring(0, 24);
        System.out.println(key);
        System.out.println(key.length());
        String strReturn = str;
        if (str == null || str.length() == 0) return "";
        try {
            String instance = "DESede/ECB/PKCS5Padding";
            Cipher cipher = Cipher.getInstance(instance);
            cipher.init(1, getKey(key));
            String amalgam = str;
            byte[] inputBytes1 = amalgam.getBytes("UTF8");
            byte[] outputBytes1 = cipher.doFinal(inputBytes1);
            strReturn = new String(java.util.Base64.getMimeEncoder().encode(outputBytes1), StandardCharsets.UTF_8);
        } catch(Exception e) {
            System.out.println(e.toString());
        }
        return strReturn;
    }

    public static String decrypt(String str, String key) {
        key = ("CP" + StrUtil.nvl(key) + "EEEEEEEEEEEEEEEEEEEEEEEE").substring(0, 24);
        String strResult = str;
        if (str == null || str.length() == 0) return "";
        try {
            String instance = "DESede/ECB/PKCS5Padding";
            Cipher cipher = Cipher.getInstance(instance);
            cipher.init(2, getKey(key));
            byte[] inputBytes1 = java.util.Base64.getMimeDecoder().decode(str);
            byte[] outputBytes2 = cipher.doFinal(inputBytes1);
            strResult = new String(outputBytes2, "UTF8");
            return strResult;
        } catch(Exception e) {
            return "0";
        }
    }
}
