package com.payneteasy.mysql.scheduler;

import com.google.inject.ImplementedBy;
import com.payneteasy.mysql.scheduler.dao.model.TTask;
import com.payneteasy.mysql.scheduler.impl.SchedulerServiceImpl;

import java.util.List;

@ImplementedBy(SchedulerServiceImpl.class)
public interface ISchedulerService {

    List<TTask> getTasks(int aMaxTasks);

    void setTaskStarting(long aTaskId);

    void runTask(long aTaskId);

    void setTaskFailed(long aTaskId, String aErrorMessage);

}
