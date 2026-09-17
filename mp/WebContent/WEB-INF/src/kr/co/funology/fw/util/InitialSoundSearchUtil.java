package kr.co.funology.fw.util;

public class InitialSoundSearchUtil {

    private static final char HANGUL_BEGIN_UNICODE = 44032;
    private static final char HANGUL_LAST_UNICODE = 55203;
    private static final char HANGUL_BASE_UNIT = 588;
    private static final char[] INITIAL_SOUND = { 'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' };

    private static boolean isInitialSound(char searchar){
      for(char c:INITIAL_SOUND){
        if (c == searchar) return true;
      }
      return false;
    }

    private static char getInitialSound(char c) {
      int hanBegin = (c - HANGUL_BEGIN_UNICODE);
      int index = hanBegin / HANGUL_BASE_UNIT;
      return INITIAL_SOUND[index];
    }

    private static boolean isHangul(char c) {
      return HANGUL_BEGIN_UNICODE <= c && c <= HANGUL_LAST_UNICODE;
    }

    public static boolean test(String value, String search){
      value  = value.toLowerCase();
      search = search.toLowerCase();
      int t;
      int seof = value.length() - search.length();
      int slen = search.length();
      if(seof < 0) return false;
      for (int i = 0;i <= seof;i++) {
        t = 0;
        while (t < slen) {
          if (isInitialSound(search.charAt(t)) && isHangul(value.charAt(i+t))){
            if(getInitialSound(value.charAt(i+t))==search.charAt(t)) t++;
            else break;
          } else {
            if(value.charAt(i+t)==search.charAt(t)) t++;
            else break;
          }
        }
        if (t == slen) return true;
      }
      return false;
    }

}
