package com.payneteasy.mysql.scheduler;

import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TaskRunner implements Runnable {

    private static final Logger LOG = LoggerFactory.getLogger(TaskRunner.class);

    public TaskRunner(ISchedulerService aSchedulerService, TTask aTask) {
        theSchedulerService = aSchedulerService;
        theTask = aTask;
    }

    public void run() {
        try {
            LOG.info("Task {} running ...", theTask.getTaskName());
            theSchedulerService.runTask(theTask.getTaskId());
            LOG.info("Task {} done", theTask.getTaskName());
        } catch (Exception e) {
            LOG.error("Can't run "+theTask.getTaskName(), e);
            theSchedulerService.setTaskFailed(theTask.getTaskId(), e.getMessage());
        }

    }

    private final ISchedulerService theSchedulerService;
    private final TTask theTask;
}
