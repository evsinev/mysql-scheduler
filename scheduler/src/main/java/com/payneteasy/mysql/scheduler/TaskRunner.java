package com.payneteasy.mysql.scheduler;

import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TaskRunner implements Runnable {

    private final Logger LOG;

    public TaskRunner(ISchedulerService aSchedulerService, TTask aTask) {
        LOG = LoggerFactory.getLogger("task."+aTask.getTaskName());
        theSchedulerService = aSchedulerService;
        theTask = aTask;
    }

    public void run() {
        long startTime = System.currentTimeMillis();
//        final String taskName = theTask.getTaskName();
        try {
            LOG.info("starting ...");
            theSchedulerService.runTask(theTask.getTaskId());
            LOG.info("done in {} ms", System.currentTimeMillis()-startTime);
        } catch (Exception e) {
            LOG.error("done in {} ms with errors:\n{}", new Object[] {System.currentTimeMillis()-startTime, getExceptionsText(e)});
            theSchedulerService.setTaskFailed(theTask.getTaskId(), getMessages(e));
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

    private String getExceptionsText(Exception aException) {
        Throwable e = aException;
        StringBuilder sb = new StringBuilder();
        int count=1;
        while(e!=null) {
            sb.append("    ").append(count).append(". ").append(e.getMessage()).append("\n");
            e = e.getCause();
            count++;
        }
        LOG.debug("Detailed exception:", e);
        return sb.toString();
    }

    private final ISchedulerService theSchedulerService;
    private final TTask theTask;
}
