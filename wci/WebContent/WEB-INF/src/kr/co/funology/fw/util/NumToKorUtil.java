package kr.co.funology.fw.util;

public class NumToKorUtil {

    public static String convertNumToKor(String amt){
        // System.out.println(StrUtil.addComma(amt));
        String amt_msg = "";
        String[] arrayNum  = {"","일","이","삼","사","오","육","칠","팔","구"};
        String[] arrayUnit = {"","십","백","천"};
        String[] arrayPart = {"","","만","억","조","경","해"};
        int intLength   = amt.length();
        int intFirstDiv = intLength%4;
        int intDiv = intLength/4;
        if (intFirstDiv>0) intDiv++;

        int j = 0;
        for (int i=intDiv; i>0; i--) {
          String str = "";
          int k = 0;
          if (i==intDiv && intFirstDiv>0) k = j + intFirstDiv;
          else k = j + 4;
          str = amt.substring(j, k);
          j = k;
          for (int m=0; m<str.length(); m++) {
              int s = Integer.parseInt(str.substring(m, m+1));
              int u = str.length()-m-1;
              amt_msg += arrayNum[s];
              if (s>0) amt_msg += arrayUnit[u];
          }
          amt_msg += arrayPart[i];
        }
        return amt_msg;
    }

    public static void main(String[] args) {
        System.out.println(NumToKorUtil.convertNumToKor("770088000"));
        System.out.println(NumToKorUtil.convertNumToKor("1234"));
        System.out.println(NumToKorUtil.convertNumToKor("7"));
        System.out.println(NumToKorUtil.convertNumToKor("5678700088000"));
        System.out.println(NumToKorUtil.convertNumToKor("770088000"));
        System.out.println(NumToKorUtil.convertNumToKor("770088000"));
    }

}
