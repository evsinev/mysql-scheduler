package com.payneteasy.mysql.scheduler.dao.model;

import javax.persistence.Column;

public class TTask {

    /** Task name */
    @Column(name="task_name")
    public String getTaskName() { return theTaskName; }
    public void setTaskName(String aTaskName) { theTaskName = aTaskName; }

    /** Task id */
    @Column(name="task_id")
    public long getTaskId() { return theTaskId; }
    public void setTaskId(long aTaskId) { theTaskId = aTaskId; }

    /** Task id */
    private long theTaskId;
    /** Task name */
    private String theTaskName;
}
