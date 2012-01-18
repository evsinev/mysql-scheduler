package com.payneteasy.mysql.scheduler.guice;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.Singleton;
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
        dataSource.setUrl("jdbc:mysql://localhost:3306/sched?logger=Slf4JLogger");
//        dataSource.addConnectionProperty("noAccessToProcedureBodies", "true");
        dataSource.setUsername("java_sched");
        dataSource.setPassword("123java_sched123");
        dataSource.setDefaultAutoCommit(true);
        dataSource.setValidationQuery("call create_collections()");

        return dataSource;
    }



}
