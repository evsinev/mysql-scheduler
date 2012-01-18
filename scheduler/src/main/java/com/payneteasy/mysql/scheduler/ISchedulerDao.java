package com.payneteasy.mysql.scheduler;

import com.googlecode.jdbcproc.daofactory.annotation.AStoredProcedure;

public interface ISchedulerDao {

    @AStoredProcedure(name = "create_collections")
    void getTasks();
}
