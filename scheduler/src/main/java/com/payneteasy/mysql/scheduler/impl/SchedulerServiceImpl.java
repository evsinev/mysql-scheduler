package com.payneteasy.mysql.scheduler.impl;

import com.google.inject.Inject;
import com.payneteasy.mysql.scheduler.ISchedulerService;
import com.payneteasy.mysql.scheduler.dao.ISchedulerDao;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.apache.commons.dbcp.BasicDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

import static com.payneteasy.mysql.scheduler.SchedulerConfig.Config.*;
import static com.payneteasy.mysql.scheduler.SchedulerConfig.getConfig;


@Transactional(propagation = Propagation.REQUIRES_NEW)
public class SchedulerServiceImpl implements ISchedulerService {

    private static final Logger LOG = LoggerFactory.getLogger(SchedulerServiceImpl.class);

    public List<TTask> getTasks(int aMaxTasks) {
        return theSchedulerDao.getTasks(aMaxTasks);
    }

    public void setTaskStarting(long aTaskId) {
        theSchedulerDao.setTaskStarting(aTaskId);
    }

    public void runTask(long aTaskId) {
        theSchedulerDao.runTask(aTaskId);
    }

    public void setTaskFailed(long aTaskId, String aErrorMessage) {
        theSchedulerDao.setTaskFailed(aTaskId, aErrorMessage);
    }

    @Override
    public void runRawQueries(List<String> aQueries) throws SQLException {
        if(aQueries.isEmpty()) {
            return;
        }

        BasicDataSource dataSource = new BasicDataSource();
        try {
            dataSource.setDriverClassName("com.mysql.jdbc.Driver");
            dataSource.setUrl(getConfig(URL));
            dataSource.setUsername(getConfig(PRIVILEGED_USERNAME));
            dataSource.setPassword(getConfig(PRIVILEGED_PASSWORD));
            dataSource.setDefaultAutoCommit(true);
            dataSource.setValidationQuery("call create_collections()");
            dataSource.setMaxActive(1);
            dataSource.setMaxIdle(1);

            Connection connection = dataSource.getConnection();
            try {
                for (String query : aQueries) {
                    LOG.info("Running {} ...", query);
                    Statement statement = connection.createStatement();
                    try {
                        statement.execute(query);
                    } finally {
                        statement.close();
                    }
                }
            } finally {
                connection.close();
            }
        } finally {
            dataSource.close();
        }
    }

    @Inject private ISchedulerDao theSchedulerDao;
}
