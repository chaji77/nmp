package rcftp;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

public class Receiver {
    private static final int BATCH_SIZE = 50;
    private ExecutorService executor;
    private Map<String, List<VO>> transactionMap = new ConcurrentHashMap<>();
    private Set<String> failedLines = ConcurrentHashMap.newKeySet(); // 실패한 라인
    private Map<String, String> orderNoToLineMap = new ConcurrentHashMap<>(); // ORDER_NO -> 원본 줄

    public Receiver(String strJobCode, String strFilePath) {
        if (strFilePath != null) {
            this.executor = Executors.newFixedThreadPool(4);

            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(strFilePath), StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] data = line.split("\\|\\|");
                    if ((strJobCode.equals("B") && data.length < 20) || (strJobCode.equals("S") && data.length < 7)) {
                        failedLines.add(line);
                        continue;
                    }
                    String orderNo = data[3];
                    orderNoToLineMap.put(orderNo, line);
                    try {
                        VO contract = (strJobCode.equals("B")) ? new ContractVO(data) : new SettleVO(data);
                        transactionMap.computeIfAbsent(orderNo, k -> new ArrayList<>()).add(contract);
                    } catch (Exception e) {
                        failedLines.add(line);
                        transactionMap.remove(orderNo);
                        orderNoToLineMap.remove(orderNo);
                    }

                    if (transactionMap.size() >= BATCH_SIZE) {
                        executeBatchAsync();
                    }
                }

                if (!transactionMap.isEmpty()) {
                    executeBatchAsync();
                }

                executor.shutdown();
                executor.awaitTermination(1, TimeUnit.HOURS);

                // 실패한 주문번호 기반으로 실패한 라인만 남김
                Set<String> failedOrderNos = orderNoToLineMap.keySet().stream()
                        .filter(orderNo -> failedLines.contains(orderNoToLineMap.get(orderNo)))
                        .collect(Collectors.toSet());

                for (String orderNo : failedOrderNos) {
                    failedLines.add(orderNoToLineMap.get(orderNo));
                }

                // 성공한 라인 제거 → 실패한 라인만 원본 파일에 덮어쓰기
                try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(strFilePath),
                        StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING)) {
                    for (String lineToWrite : failedLines) {
                        writer.write(lineToWrite);
                        writer.newLine();
                    }
                }

            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public void executeBatchAsync() {
        Map<String, List<VO>> batch = new HashMap<>();
        for (String orderNo : new ArrayList<>(transactionMap.keySet())) {
            batch.put(orderNo, transactionMap.get(orderNo));
            if (batch.size() >= BATCH_SIZE) break;
        }
        executor.submit(() -> executeBatch(batch));
    }

    public void executeBatch(Map<String, List<VO>> batch) {
        List<VO> batchList = new ArrayList<>();
        batch.values().forEach(batchList::addAll);
        System.out.println(batch.size());
        boolean success = insert(batchList);

        if (success) {
            batch.keySet().forEach(transactionMap::remove);
        } else {
            for (String failedOrder : batch.keySet()) {
                transactionMap.remove(failedOrder);
                if (orderNoToLineMap.containsKey(failedOrder)) {
                    failedLines.add(orderNoToLineMap.get(failedOrder));
                }
            }
        }
    }
    
    public boolean insert(List<VO> batch) {
      return true;
    }
}
