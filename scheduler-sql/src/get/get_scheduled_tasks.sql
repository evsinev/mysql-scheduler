drop procedure if exists get_schedule_tasks;
delimiter $$
create procedure get_schedule_tasks(i_max_tasks_count int(10))
 main_sql:
  begin
    declare v_run_date   datetime default now();

    select stsk_id task_id, task_name
      from scheduled_tasks
     where exec_status in ('C', 'F') and exec_next_date <= v_run_date
     limit i_max_tasks_count;
  end
$$
delimiter ;
call save_routine_information('get_schedule_tasks', concat('task_id int', ', task_name varchar'));