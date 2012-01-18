package com.payneteasy.mysql.scheduler;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.Singleton;
import com.googlecode.jdbcproc.daofactory.DAOMethodInfo;
import com.googlecode.jdbcproc.daofactory.guice.InitJdbcProcModule;
import com.googlecode.jdbcproc.daofactory.guice.StoredProcedureDaoProvider;
import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

public class SchedulerModule extends AbstractModule {

    @Override
    protected void configure() {
        install(new InitJdbcProcModule());
    }

    @Provides
    @Singleton
    DataSource provideDataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/jdbcprocdb");
        dataSource.setUsername("jdbcproc");
        dataSource.setPassword("jdbcproc");
        dataSource.setDefaultAutoCommit(true);
        dataSource.setValidationQuery("call create_collections()");

        return dataSource;
    }

    @Provides
    JdbcTemplate provideJDBCTemplate(DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }

    @Provides
    @Singleton
    ISchedulerDao provideCompanyDao(JdbcTemplate jdbcTemplate, DAOMethodInfo daoMethodInfo) {
        return new StoredProcedureDaoProvider<ISchedulerDao>(ISchedulerDao.class, jdbcTemplate, daoMethodInfo).get();
    }

}
