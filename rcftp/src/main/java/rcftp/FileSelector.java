package rcftp;

import java.io.File;
import java.util.Arrays;
import java.util.Comparator;

import org.apache.log4j.Logger;

public class FileSelector {
    public static String findOldestFileName(String directoryPath, String prefix) {
        Logger logger = Logger.getLogger("FileSelector.findOldestFileName");
        File dir = new File(directoryPath);
        if (!dir.exists() || !dir.isDirectory()) {
            logger.error(directoryPath + " : 디렉토리가 존재하지 않습니다.");
            return null;
        }
        File[] files = dir.listFiles((dir1, name) -> name.startsWith(prefix) && name.endsWith(".txt"));
        if (files == null || files.length == 0) {
            logger.debug(directoryPath + " : 파일이 없습니다.");
            return null; // 파일 없음
        }
        return Arrays.stream(files)
              .min(Comparator.comparing(File::getName))
              .map(File::getName)
              .orElse(null);
    }
    public static void deleteEmptyFiles(String directoryPath) {
        Logger logger = Logger.getLogger("FileSelector");
        File dir = new File(directoryPath);
        if (!dir.exists() || !dir.isDirectory()) {
            logger.error(directoryPath + " : 디렉토리가 존재하지 않습니다.");
            return;
        }

        // 디렉토리 내 파일 목록 가져오기
        File[] files = dir.listFiles();

        if (files == null || files.length == 0) {
            logger.debug(directoryPath + " : 디렉토리에 파일이 없습니다.");
            return;
        }

        int deletedCount = 0;

        for (File file : files) {
            if (file.isFile() && file.length() == 0) { // 파일이며 크기가 0인지 확인
                if (file.delete()) {
                    logger.debug("삭제됨: " + file.getName());
                    deletedCount++;
                } else {
                    logger.error("삭제 실패: " + file.getName());
                }
            }
        }

        logger.debug("총 삭제된 파일 개수: " + deletedCount);
    }
    public static int countFilesWithPrefix(String directoryPath) {
        Logger logger = Logger.getLogger("FileSelector.countFilesWithPrefix");
        File dir = new File(directoryPath);
        if (!dir.exists() || !dir.isDirectory()) {
            logger.error(directoryPath + " : 디렉토리가 존재하지 않습니다.");
            return 0;
        }
        return dir.listFiles().length;
    }
}
