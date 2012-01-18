package com.payneteasy.mysql.scheduler;

import com.google.inject.Inject;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class Scheduler {

    private static final Logger LOG = LoggerFactory.getLogger(Scheduler.class);
    private static final int MAX_THREADS = 2 ;
    private static final int SLEEP_MS = 1000 ;

    public void start() {
        theIsStarted = true;
         while ( theIsStarted ) {

             runTasks();
             
             try {
                 Thread.sleep(SLEEP_MS);
             } catch (InterruptedException e) {
                 LOG.warn("Sleep interrupted: "+SLEEP_MS+" ms");
             }

//             theIsStarted = false;
         }
    }

    public void stop() {
        theIsStarted = false;
    }

    private void runTasks() {


        List<TTask> tasks = theSchedulerService.getTasks(getAvailableThreadsCount());

        for (TTask task : tasks) {
            LOG.info("Starting {}...", task.getTaskName());
            theSchedulerService.setTaskStarting(task.getTaskId());

            try {
                theSchedulerService.runTask(task.getTaskId());
            } catch (Exception e) {
                LOG.error("can't run "+task.getTaskName(), e);
                //theSchedulerService.setTaskFailed(task.getTaskId(), e.getMessage());
            }
        }


    }

    private int getAvailableThreadsCount() {
        return theTaskExecutor.getCorePoolSize() - theTaskExecutor.getActiveCount();
    }


    private final TaskExecutor theTaskExecutor = new TaskExecutor(MAX_THREADS);

    @Inject
    private ISchedulerService theSchedulerService;

    private volatile boolean theIsStarted = false;

}
