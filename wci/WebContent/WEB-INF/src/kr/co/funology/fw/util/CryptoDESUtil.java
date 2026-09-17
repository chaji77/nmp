package kr.co.funology.fw.util;

import java.nio.charset.StandardCharsets;
import java.security.Key;

import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.DESedeKeySpec;

import kr.co.funology.fw.mgr.ConfigurationMgr;

public class CryptoDESUtil {

    private static String key = ConfigurationMgr.getInstance().getString("CRYPTO_KEY");

    private static String key(){
        return key;
    }

    private static Key getKey() throws Exception {
        return (key().length() == 24) ? getKey2(key()) : getKey1(key());
    }

    private static Key getKey1(String keyValue) throws Exception {
        DESKeySpec desKeySpec = new DESKeySpec(keyValue.getBytes());
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
        Key key = keyFactory.generateSecret(desKeySpec);
        return key;
    }

    private static Key getKey2(String keyValue) throws Exception {
        DESedeKeySpec desKeySpec = new DESedeKeySpec(keyValue.getBytes());
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DESede");
        Key key = keyFactory.generateSecret(desKeySpec);
        return key;
    }

    public static String encrypt(String str) {
        String strReturn = str;
        if (str == null || str.length() == 0) return "";
        try {
            String instance = (key().length() == 24) ? "DESede/ECB/PKCS5Padding" : "DES/ECB/PKCS5Padding";
            Cipher cipher = Cipher.getInstance(instance);
            cipher.init(1, getKey());
            String amalgam = str;

            byte[] inputBytes1 = amalgam.getBytes("UTF8");
            byte[] outputBytes1 = cipher.doFinal(inputBytes1);
            strReturn = new String(java.util.Base64.getMimeEncoder().encode(outputBytes1), StandardCharsets.UTF_8);
        } catch(Exception e) {
            System.out.println(e.toString());
        }
        return strReturn;
    }

    public static String decrypt(String str) {
        String strResult = str;
        if (str == null || str.length() == 0) return "";
        try {
            String instance = (key().length() == 24) ? "DESede/ECB/PKCS5Padding" : "DES/ECB/PKCS5Padding";
            Cipher cipher = Cipher.getInstance(instance);
            cipher.init(2, getKey());
            byte[] inputBytes1 = java.util.Base64.getMimeDecoder().decode(str);
            byte[] outputBytes2 = cipher.doFinal(inputBytes1);

            strResult = new String(outputBytes2, "UTF8");
        } catch(Exception e) {
            System.out.println(e.toString());
        }
        return strResult;
    }

    public static String decryptForParam(String str) {
        String strResult = str;
        if (str == null || str.length() == 0) return "";
        try {
            String instance = (key().length() == 24) ? "DESede/ECB/PKCS5Padding" : "DES/ECB/PKCS5Padding";
            Cipher cipher = Cipher.getInstance(instance);
            cipher.init(2, getKey());
            byte[] inputBytes1 = java.util.Base64.getMimeDecoder().decode(str);
            byte[] outputBytes2 = cipher.doFinal(inputBytes1);

            strResult = new String(outputBytes2, "UTF8");
            return strResult;
        } catch(Exception e) {
            return "-100";
        }
    }


    public static void main(String[] args) throws Exception{
      key = "CjdmadosTl!@#$dkdlxl";
      System.out.println(CryptoDESUtil.decrypt("+TjwZxRRDq267pKSysAh5Q=="));
      System.out.println(CryptoDESUtil.decrypt("U77wdw1k6TNHOpkbrTTLqw=="));
      System.out.println(CryptoDESUtil.decrypt("fT3eGsSkVZ4="));
      System.out.println(CryptoDESUtil.decrypt("M6OAf5FNbn26HdsrCm6MKg=="));
      System.out.println(CryptoDESUtil.encrypt("dpavldnjs"));
    }
}
