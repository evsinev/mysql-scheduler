package com.payneteasy.mysql.scheduler;

import com.google.inject.Inject;

public class Scheduler {

    public Scheduler() {

    }

    @Inject
    private ISchedulerDao theSchedulerDao;

    public void start() {
        theSchedulerDao.getTasks();
    }
}
