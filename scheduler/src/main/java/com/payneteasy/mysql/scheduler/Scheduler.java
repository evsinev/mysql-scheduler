package com.payneteasy.mysql.scheduler;

import com.google.inject.Inject;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import com.payneteasy.mysql.scheduler.util.ExecutorServiceUtils;
import com.payneteasy.mysql.scheduler.util.TaskExecutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;

import static com.payneteasy.mysql.scheduler.SchedulerConfig.getShutdownQueries;
import static com.payneteasy.mysql.scheduler.SchedulerConfig.getStartupQueries;

public class Scheduler {

    private static final Logger LOG = LoggerFactory.getLogger(Scheduler.class);
    private static final int MAX_THREADS = SchedulerConfig.getIntConfig(SchedulerConfig.Config.MAX_THREADS) ;
    private static final int SLEEP_MS = SchedulerConfig.getIntConfig(SchedulerConfig.Config.SLEEP_MS) ;

    public void start() {
        theIsStarted = true;

        try {
            theSchedulerService.runRawQueries(getStartupQueries());
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot execute startup queries", e);
        }

        while ( theIsStarted ) {

             try {
                 runTasks();
             } catch (Exception e) {
                 LOG.error("Can't execute tasks", e);
             } finally {
                 if (theIsStarted) {
                     try {
                         Thread.sleep(SLEEP_MS);
                     } catch (InterruptedException e) {
                         LOG.warn("Sleep interrupted: "+SLEEP_MS+" ms");
                     }
                 }
             }

//             theIsStarted = false;
         }
    }

    public void stop() {
        theIsStarted = false;

        try {
            theSchedulerService.runRawQueries(getShutdownQueries());
        } catch (Exception e) {
            LOG.error("Cannot execute shutdown queries", e);
        }

        try {
            ExecutorServiceUtils.shutdownAndAwaitTermination(theTaskExecutor, "scheduler");
        } catch (InterruptedException e) {
            LOG.error("Can't stop executor", e);
        }
    }

    private void runTasks() {


        List<TTask> tasks = theSchedulerService.getTasks(getAvailableThreadsCount());

        for (TTask task : tasks) {
            LOG.debug("Starting {}...", task.getTaskName());
            theSchedulerService.setTaskStarting(task.getTaskId());
            theTaskExecutor.execute(new TaskRunner(theSchedulerService, task));

        }


    }

    private int getAvailableThreadsCount() {
        return theTaskExecutor.getCorePoolSize() - theTaskExecutor.getActiveCount();
    }


    private final TaskExecutor theTaskExecutor = ExecutorServiceUtils.createTaskExecutor(MAX_THREADS);

    @Inject
    private ISchedulerService theSchedulerService;

    private volatile boolean theIsStarted = false;

}
