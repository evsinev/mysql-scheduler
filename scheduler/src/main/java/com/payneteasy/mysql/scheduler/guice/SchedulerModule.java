package com.payneteasy.mysql.scheduler.guice;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.Singleton;
import com.google.inject.binder.AnnotatedBindingBuilder;
import com.googlecode.jdbcproc.daofactory.DAOMethodInfo;
import com.googlecode.jdbcproc.daofactory.guice.InitJdbcProcModule;
import com.googlecode.jdbcproc.daofactory.guice.StoredProcedureDaoProvider;
import com.googlecode.jdbcproc.daofactory.impl.dbstrategy.ICallableStatementSetStrategyFactory;
import com.googlecode.jdbcproc.daofactory.impl.dbstrategy.impl.CallableStatementSetStrategyFactoryIndexImpl;
import com.payneteasy.mysql.scheduler.dao.ISchedulerDao;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionInterceptor;

import javax.sql.DataSource;

import static com.google.inject.matcher.Matchers.annotatedWith;
import static com.google.inject.matcher.Matchers.any;

public class SchedulerModule extends AbstractModule {

    private static final Logger LOG = LoggerFactory.getLogger(SchedulerModule.class);

    @Override
    protected void configure() {

        install(new InitJdbcProcModule() {
            @Override
            protected void bindCallableStatementSetStrategyFactory(AnnotatedBindingBuilder<ICallableStatementSetStrategyFactory> aBuilder) {
                aBuilder.to(CallableStatementSetStrategyFactoryIndexImpl.class);
            }
        });

        install(new DataSourceModule());

        PlatformTransactionManager transactionManager = new GuiceDataSourceTransactionManager();

        requestInjection(transactionManager);

        TransactionInterceptor interceptor = new TransactionInterceptor(transactionManager,new AnnotationTransactionAttributeSource());

        bindInterceptor(annotatedWith(Transactional.class), any(), interceptor);
        bindInterceptor(any(), annotatedWith(Transactional.class), interceptor);

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
