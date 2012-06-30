drop procedure if exists set_task_completed;
delimiter $$
create procedure set_task_completed(i_stsk_id int(10))
  begin
    declare v_exec_end_date   datetime default now();

    update scheduled_tasks
       set exec_status       = 'C',
           exec_start_date   = null,
           exec_end_date     = v_exec_end_date,
           exec_next_date      =
             case
               when schedule_strategy = 'E' then
                 case
                   when substring(retry_interval, -2) = 'MI' then
                     date_add(v_exec_end_date,
                              interval substring(retry_interval, 1, length(retry_interval) - 2) minute
                             )
                   when substring(retry_interval, -2) = 'HH' then
                     date_add(v_exec_end_date, interval substring(retry_interval, 1, length(retry_interval) - 2) hour)
                   when substring(retry_interval, -1) = 'D' then
                     date_add(v_exec_end_date, interval substring(retry_interval, 1, length(retry_interval) - 1) day)
                   when substring(retry_interval, -1) = 'M' then
                     date_add(v_exec_end_date, interval substring(retry_interval, 1, length(retry_interval) - 1) month)
                   when substring(retry_interval, -1) = 'Y' then
                     date_add(v_exec_end_date, interval substring(retry_interval, 1, length(retry_interval) - 1) year)
                 end
               when schedule_strategy = 'S' then
                 case
                   when substring(retry_interval, -2) = 'MI' then
                     date_add(
                       task_start_date,
                       interval   substring(retry_interval, 1, length(retry_interval) - 2)
                                * (  floor(
                                         time_to_sec(timediff(v_exec_end_date, task_start_date))
                                       / 60
                                       / substring(retry_interval, 1, length(retry_interval) - 2)
                                     )
                                   + 1) minute
                     )
                   when substring(retry_interval, -2) = 'HH' then
                     date_add(
                       task_start_date,
                       interval   substring(retry_interval, 1, length(retry_interval) - 2)
                                * (  floor(
                                         time_to_sec(timediff(v_exec_end_date, task_start_date))
                                       / 60
                                       / 60
                                       / substring(retry_interval, 1, length(retry_interval) - 2)
                                     )
                                   + 1) hour
                     )
                   when substring(retry_interval, -1) = 'D' then
                     date_add(
                       task_start_date,
                       interval   substring(retry_interval, 1, length(retry_interval) - 1)
                                * (  floor(
                                         datediff(v_exec_end_date, task_start_date)
                                       / substring(retry_interval, 1, length(retry_interval) - 1)
                                     )
                                   + 1) day
                     )
                   when substring(retry_interval, -1) = 'M' then
                     date_add(
                       task_start_date,
                       interval   substring(retry_interval, 1, length(retry_interval) - 1)
                                * (  floor(
                                         period_diff(date_format(v_exec_end_date, '%Y%m'),
                                                     date_format(task_start_date, '%Y%m')
                                                    )
                                       / substring(retry_interval, 1, length(retry_interval) - 1)
                                     )
                                   + 1) month
                     )
                   when substring(retry_interval, -1) = 'Y' then
                     date_add(
                       task_start_date,
                       interval   substring(retry_interval, 1, length(retry_interval) - 1)
                                * (  floor(
                                         period_diff(date_format(v_exec_end_date, '%Y%m'),
                                                     date_format(task_start_date, '%Y%m')
                                                    )
                                       / 12
                                       / substring(retry_interval, 1, length(retry_interval) - 1)
                                     )
                                   + 1) year
                     )
                 end
             end,
           task_start_date      =
             case
               when schedule_strategy = 'E' then
                 task_start_date
               when schedule_strategy = 'S' then
                 case
                   when substring(retry_interval, -2) = 'MI' then
                     date_sub(exec_next_date, interval substring(retry_interval, 1, length(retry_interval) - 2) minute)
                   when substring(retry_interval, -2) = 'HH' then
                     date_sub(exec_next_date, interval substring(retry_interval, 1, length(retry_interval) - 2) hour)
                   when substring(retry_interval, -1) = 'D' then
                     date_sub(exec_next_date, interval substring(retry_interval, 1, length(retry_interval) - 1) day)
                   when substring(retry_interval, -1) = 'M' then
                     date_sub(exec_next_date, interval substring(retry_interval, 1, length(retry_interval) - 1) month)
                   when substring(retry_interval, -1) = 'Y' then
                     date_sub(exec_next_date, interval substring(retry_interval, 1, length(retry_interval) - 1) year)
                 end
             end
     where i_stsk_id = stsk_id;

    if row_count() <> 1 then
      call raise_application_error('task.set.status.failed');
    end if;

    insert into scheduled_task_logs(stsk_stsk_id, exec_end_date, exec_status)
         values (i_stsk_id, now(), 'C');
  end
$$
delimiter ;