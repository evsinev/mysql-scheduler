package com.payneteasy.mysql.scheduler.guice;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.Singleton;
import com.payneteasy.mysql.scheduler.SchedulerConfig;
import org.apache.commons.dbcp.BasicDataSource;

import javax.sql.DataSource;

public class DataSourceModule extends AbstractModule {
    @Override
    protected void configure() {
    }

    @Provides
    @Singleton
        DataSource provideDataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl(SchedulerConfig.getConfig(SchedulerConfig.Config.URL));
        dataSource.setUsername(SchedulerConfig.getConfig(SchedulerConfig.Config.USERNAME));
        dataSource.setPassword(SchedulerConfig.getConfig(SchedulerConfig.Config.PASSWORD));
        dataSource.setDefaultAutoCommit(false);
        dataSource.setValidationQuery("call create_collections()");
        dataSource.setMaxActive(SchedulerConfig.getIntConfig(SchedulerConfig.Config.MAX_THREADS));
        dataSource.setMaxIdle(SchedulerConfig.getIntConfig(SchedulerConfig.Config.MAX_IDLE));

        return dataSource;
    }



}
