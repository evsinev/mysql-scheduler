package com.payneteasy.mysql.scheduler.impl;

import com.google.inject.Inject;
import com.payneteasy.mysql.scheduler.ISchedulerService;
import com.payneteasy.mysql.scheduler.dao.ISchedulerDao;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Transactional(propagation = Propagation.REQUIRES_NEW)
public class SchedulerServiceImpl implements ISchedulerService {

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
    
    @Inject private ISchedulerDao theSchedulerDao;
}
