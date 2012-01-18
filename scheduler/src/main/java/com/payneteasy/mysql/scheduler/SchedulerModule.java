package com.payneteasy.mysql.scheduler;

import com.google.inject.AbstractModule;
import com.google.inject.Inject;
import com.google.inject.Provides;
import com.google.inject.Singleton;
import com.googlecode.jdbcproc.daofactory.DAOMethodInfo;
import com.googlecode.jdbcproc.daofactory.guice.InitJdbcProcModule;
import com.googlecode.jdbcproc.daofactory.guice.StoredProcedureDaoProvider;
import com.payneteasy.mysql.scheduler.dao.ISchedulerDao;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionInterceptor;

import javax.sql.DataSource;
import java.util.Arrays;
import java.util.List;

import static com.google.inject.matcher.Matchers.annotatedWith;
import static com.google.inject.matcher.Matchers.any;

public class SchedulerModule extends AbstractModule {

    private static final Logger LOG = LoggerFactory.getLogger(SchedulerModule.class);

    @Override
    protected void configure() {
        install(new InitJdbcProcModule());
        install(new DataSourceModule());

        PlatformTransactionManager transactionManager = new DataSourceTransactionManager() {
            @Override
            @Inject
            public void setDataSource(DataSource dataSource) {
                super.setDataSource(dataSource);
            }
        };

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
//    ISchedulerDao provideCompanyDao() {
    ISchedulerDao provideCompanyDao(JdbcTemplate jdbcTemplate, DAOMethodInfo daoMethodInfo) {
        return new StoredProcedureDaoProvider<ISchedulerDao>(ISchedulerDao.class, jdbcTemplate, daoMethodInfo).get();
//        return new ISchedulerDao() {
//            public List<TTask> getTasks(int aMaxTasks) {
//                TTask t = new TTask();
//                t.setTaskId(1);
//                t.setTaskName("task-1");
//                return Arrays.asList(t);
//            }
//
//            public void setTaskStarting(long aTaskId) {
//            }
//
//            public void runTask(long aTaskId) {
//            }
//
//            public void setTaskFailed(long aTaskId, String aErrorMessage) {
//            }
//        };
    }

}
