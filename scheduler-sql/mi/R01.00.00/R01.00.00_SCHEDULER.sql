set names utf8 collate utf8_general_ci;
drop table if exists scheduled_task_logs;
drop table if exists scheduled_tasks;

create table scheduled_tasks (
   stsk_id                    int(10) unsigned not null auto_increment,
   task_name                  varchar(32),
   task_description           varchar(256),
   task_definition            text,
   task_start_date            datetime,
   retry_interval             varchar(128),
   schedule_strategy          varchar(1) not null default 'S',
   exec_next_date             datetime,
   exec_start_date            datetime,
   exec_end_date              datetime,
   exec_status                varchar(1) not null default 'C',
   exce_max_run_time          int(10) not null default 15,
   primary key pk_scheduled_tasks(stsk_id),
   index idx_scheduled_tasks_runnable(exec_status, exec_start_date)
)
engine = innodb;

create table scheduled_task_logs(
  slog_id           int(10) unsigned not null auto_increment,
  stsk_stsk_id      int(10) unsigned,
  exec_next_date    datetime,
  exec_start_date   datetime,
  exec_end_date     datetime,
  exec_status       varchar(1),
  error_message     text,
  primary key pk_scheduled_task_logs(slog_id),
  constraint fk_scheduled_task_logs_scheduled_tasks foreign key(stsk_stsk_id) references scheduled_tasks(stsk_id)
)
engine = innodb;

commit;