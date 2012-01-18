package com.payneteasy.mysql.scheduler;

import com.google.inject.Inject;
import com.payneteasy.mysql.scheduler.dao.ISchedulerDao;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class Scheduler {

    private static final Logger LOG = LoggerFactory.getLogger(Scheduler.class);
    private static final int MAX_THREADS = 2 ;
    private static final int SLEEP_MS = 10 ;

    public void start() {
        theIsStarted = true;
         while ( theIsStarted ) {

             runTasks();
             
             try {
                 Thread.sleep(SLEEP_MS);
             } catch (InterruptedException e) {
                 LOG.warn("Sleep interrupted: "+SLEEP_MS+" ms");
             }
         }
    }

    public void stop() {
        theIsStarted = false;
    }

    private void runTasks() {


        List<TTask> tasks = theSchedulerDao.getTasks(getAvailableThreadsCount());


        for (TTask task : tasks) {
            theSchedulerDao.setTaskStarting(task.getTaskId());

            try {
                theSchedulerDao.runTask(task.getTaskId());
            } catch (Exception e) {
                theSchedulerDao.setTaskFailed(task.getTaskId(), e.getMessage());
            }
        }


    }

    private int getAvailableThreadsCount() {
        return theTaskExecutor.getCorePoolSize() - theTaskExecutor.getActiveCount();
    }


    private final TaskExecutor theTaskExecutor = new TaskExecutor(MAX_THREADS);

    @Inject
    private ISchedulerDao theSchedulerDao;

    private volatile boolean theIsStarted = false;

}
