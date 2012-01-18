package com.payneteasy.mysql.scheduler;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class Start {

    public static void main(String[] args) {
        Injector injector = Guice.createInjector(new SchedulerModule());

        Scheduler scheduler = injector.getInstance(Scheduler.class);

        scheduler.start();
    }
}
