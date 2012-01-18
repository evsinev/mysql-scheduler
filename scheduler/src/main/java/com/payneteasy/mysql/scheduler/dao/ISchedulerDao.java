package com.payneteasy.mysql.scheduler.dao;

import com.googlecode.jdbcproc.daofactory.annotation.AStoredProcedure;
import com.payneteasy.mysql.scheduler.dao.model.TTask;

import java.util.List;

public interface ISchedulerDao {

    @AStoredProcedure(name = "create_collections")
    List<TTask> getTasks(int aMaxTasks);

    void setTaskStarting(long aTaskId);

    void runTask(long aTaskId);

    void setTaskFailed(long aTaskId, String aErrorMessage);
}
