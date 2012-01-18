package com.payneteasy.mysql.scheduler.guice;

import com.google.inject.Inject;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;

public class GuiceDataSourceTransactionManager extends DataSourceTransactionManager {

    @Override
    @Inject
    public void setDataSource(DataSource dataSource) {
        super.setDataSource(dataSource);
    }
}
