package kr.co.funology.fw.mail;

import java.util.ArrayList;

public class ContentVO {
    StringBuffer multipartContent;
    ArrayList<String[]> files; // {no, attached_idx, size, file_name, file_path}
}
