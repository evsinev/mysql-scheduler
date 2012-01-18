package com.payneteasy.mysql.scheduler.dao;

import com.googlecode.jdbcproc.daofactory.annotation.AStoredProcedure;
import com.payneteasy.mysql.scheduler.dao.model.TTask;

import java.util.List;

public interface ISchedulerDao {

    @AStoredProcedure(name = "get_schedule_tasks")
    List<TTask> getTasks(int aMaxTasks);

    @AStoredProcedure(name = "set_task_starting")
    void setTaskStarting(long aTaskId);

    @AStoredProcedure(name = "set_task_running")
    void runTask(long aTaskId);

    @AStoredProcedure(name = "set_task_failed")
    void setTaskFailed(long aTaskId, String aErrorMessage);
}
