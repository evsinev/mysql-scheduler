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
            long startTime = System.currentTimeMillis();
            LOG.info("Task {} running ...", theTask.getTaskName());
            theSchedulerService.runTask(theTask.getTaskId());
            LOG.info("Task {} done in {} ms", theTask.getTaskName(), System.currentTimeMillis()-startTime);
        } catch (Exception e) {
            LOG.error("Task {} ERROR:"+theTask.getTaskName());
            theSchedulerService.setTaskFailed(theTask.getTaskId(), getMessages(e));
            logException(e, theTask.getTaskName());

        }

    }

    private String getMessages(Exception aException) {
        Throwable e = aException;
        
        StringBuilder sb = new StringBuilder();
        while(e!=null) {
            sb.append(e.getMessage());
            sb.append("; \n");
            e = e.getCause();
        }
        return sb.toString();
    }

    private void logException(Exception aException, String aTaskName) {
        Throwable e = aException;
        
        while(e!=null) {
            LOG.error("    {}: {} - {}", new String[] {aTaskName, e.getClass().getSimpleName(), e.getMessage()});
            e = e.getCause();
        }
        LOG.debug("Detailed exception: ", e);
    }

    private final ISchedulerService theSchedulerService;
    private final TTask theTask;
}
