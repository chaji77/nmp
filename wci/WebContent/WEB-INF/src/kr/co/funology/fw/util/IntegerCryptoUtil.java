package kr.co.funology.fw.util;

public class IntegerCryptoUtil {
	private static long key = 0x41823677L;
	private static String pre = "M";
	public static String crypt(String c) {
		c = StrUtil.nvl(c);
		try {
			boolean isEn = true;
			if (c.contains(pre)) {
				c = c.replaceAll(pre, "");
				isEn = false;
			}
			long n = Long.parseLong(c);
			n = n^key;
			c = Long.toString(n);
			return (isEn) ? pre+c : c;
		} catch (Exception e) {
			return "0";
		}
	}
	public static String crypt(int c) {
		return crypt(Integer.toString(c));
	}
	public static boolean isEncrypted(String c) {
		c = StrUtil.nvl(c);
		if (c.contains(pre) && c.substring(0, 1).equals(pre) && StrUtil.isOnlyNumeric(c.substring(1))) {
			return true;
		}
		return false;
	}
	public static void main(String[] args) {
		for (int i=1; i<20; i++) {
			System.out.println(crypt(Integer.toString(i)));
		}
	}
}
