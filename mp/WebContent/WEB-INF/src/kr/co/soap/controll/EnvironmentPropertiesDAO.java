package kr.co.soap.controll;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class EnvironmentPropertiesDAO {
    private Properties properties;
    private static EnvironmentPropertiesDAO instance;

    private EnvironmentPropertiesDAO() {
        properties = new Properties();
    }

    public static EnvironmentPropertiesDAO getInstance() {
        if (instance == null) {
            synchronized (EnvironmentPropertiesDAO.class) {
                if (instance == null) {
                    instance = new EnvironmentPropertiesDAO();
                }
            }
        }
        return instance;
    }

    public void load(String filePath) throws IOException {
    	System.out.println("##########");
    	System.out.println("filePath : " + filePath);
    	System.out.println("##########");
        try (FileInputStream input = new FileInputStream(filePath)) {
            properties.load(input);
        }
    }

    public String getEnv(String envName) {
        return properties.getProperty(envName);
    }
}
