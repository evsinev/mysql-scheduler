package com.payneteasy.mysql.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class SchedulerConfig {
    
    private static final Logger LOG = LoggerFactory.getLogger(SchedulerConfig.class);
    
    private static Map<Config, String> theMap ;
    
    public enum Config { 
        
          MAX_THREADS("40")
        , MAX_IDLE("15")
        , SLEEP_MS("20000")
        , URL("jdbc:mysql://localhost:3306/sched" +
                "?logger=Slf4JLogger" +
                "&noAccessToProcedureBodies=true" +
                "&useInformationSchema=true" +
                "&autoReconnect=false" +
                "&characterEncoding=utf8")
        , USERNAME("java_sched")
        , PASSWORD("123java_sched123")
        , PRIVILEGED_USERNAME("root")
        , PRIVILEGED_PASSWORD("")
        , WAIT_SHUTDOWN_SECONDS("900")
        ;
        
        Config(String aValue) {
            theValue = aValue;
        }
        
        
        private String theValue;
    }

    
    static {

        // priority
        // 1. file
        // 2. environment
        // 3. property
        Properties fileProperties = new Properties();

        final String config_file = System.getProperty("CONFIG_FILE");
        if(StringUtils.hasText(config_file)) {
            LOG.info("Loading config file {}...", config_file);
            try {
                FileReader in = new FileReader(config_file);
                try {
                    fileProperties.load(in);
                } catch (IOException e) {
                    in.close();
                }
            } catch (IOException e) {
                LOG.error("Error reading properties from "+config_file, e);
                System.exit(1);
            }
        }
        
        LOG.info("Config values:");
        theMap = new HashMap<Config, String>();        
        for (Config config : Config.values()) {
            String value = getValue(config);

            // get from FILE
            if(isEmpty(value)) {
                value = fileProperties.getProperty(config.name(), config.theValue);
            }

            LOG.info("    {} = {}", config, config.name().contains("PASSWORD") ? "xxxx" : value);
            theMap.put(config, value);
        }
        LOG.info("    Startup queries (STARTUP_QUERY_*):");
        for (String query : getStartupQueries()) {
            LOG.info("        {}", query);
        }
        LOG.info("    Shutdown queries (SHUTDOWN_QUERY_*):");
        for (String query : getShutdownQueries()) {
            LOG.info("        {}", query);
        }
    }

    private static String getValue(Config config) {
        String key = config.name();
        return getValue(key);
    }

    private static String getValue(String key) {
        // get from property
        String value = System.getProperty(key);

        // get from ENV
        if(isEmpty(value)) {
            value = System.getenv(key);
        }
        return value;
    }

    private static boolean isEmpty(String value) {
        return !StringUtils.hasText(value);
    }

    public static String getConfig(Config aConfig) {
        return theMap.get(aConfig);
    }

    public static int getIntConfig(Config aConfig) {
        return Integer.parseInt(theMap.get(aConfig));
    }

    public static List<String> getStartupQueries() {
        return getStringListValues("STARTUP_QUERY_");
    }

    public static List<String> getShutdownQueries() {
        return getStringListValues("SHUTDOWN_QUERY_");
    }

    private static List<String> getStringListValues(String aPrefix) {
        List<String> list = new ArrayList<String>();
        for(int i=0; i<100; i++) {
            String key = aPrefix + i;
            String value = getValue(key);
            if(isEmpty(value)) {
                break;
            }
            list.add(value);
        }
        return list;
    }
}
