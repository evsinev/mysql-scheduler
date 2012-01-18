package com.payneteasy.mysql.scheduler;

import com.google.inject.Guice;
import com.google.inject.Injector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Start {

    private static final Logger LOG = LoggerFactory.getLogger(Start.class);
    
    public static void main(String[] args) {
        Injector injector = Guice.createInjector(new SchedulerModule());

        final Scheduler scheduler = injector.getInstance(Scheduler.class);

        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                LOG.info("Shutting down ...");
                scheduler.stop();
            }
        });

        scheduler.start();
    }
}
