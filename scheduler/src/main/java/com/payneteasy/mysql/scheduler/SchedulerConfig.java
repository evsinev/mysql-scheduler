package com.payneteasy.mysql.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class SchedulerConfig {
    
    private static final Logger LOG = LoggerFactory.getLogger(SchedulerConfig.class);
    
    private static final String MYSQL_URL_PREFIX = "jdbc:mysql:";
    private static final String MARIADB_URL_PREFIX = "jdbc:mariadb:";

    private static final Properties theFileProperties = new Properties();

    private static Map<Config, String> theMap ;
    
    public enum Config { 
        
          MAX_THREADS("40")
        , MAX_IDLE("15")
        , SLEEP_MS("20000")
        , URL("jdbc:mariadb://localhost:3306/sched")
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
        // 1. system property
        // 2. environment
        // 3. CONFIG_FILE
        // 4. default
        final String config_file = System.getProperty("CONFIG_FILE");
        if(StringUtils.hasText(config_file)) {
            LOG.info("Loading config file {}...", config_file);
            try (FileReader in = new FileReader(config_file)) {
                theFileProperties.load(in);
            } catch (IOException e) {
                LOG.error("Error reading properties from "+config_file, e);
                System.exit(1);
            }
        }
        
        LOG.info("Config values:");
        theMap = new HashMap<Config, String>();        
        for (Config config : Config.values()) {
            // an empty value from CONFIG_FILE (e.g. PASSWORD=) is kept, the default is used only for a missing key
            String value = getValue(config);
            if(value == null) {
                value = config.theValue;
            }

            LOG.info("    {} = {}", config, config.name().contains("PASSWORD") ? "xxxx" : value);
            theMap.put(config, value);
        }

        // MariaDB Connector/J does not accept jdbc:mysql: URLs, so old configs are rewritten
        String url = theMap.get(Config.URL);
        if (url.startsWith(MYSQL_URL_PREFIX)) {
            theMap.put(Config.URL, MARIADB_URL_PREFIX + url.substring(MYSQL_URL_PREFIX.length()));
            LOG.warn("    URL: replaced {} with {}", MYSQL_URL_PREFIX, MARIADB_URL_PREFIX);
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

        // get from FILE
        if(isEmpty(value)) {
            value = theFileProperties.getProperty(key);
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
