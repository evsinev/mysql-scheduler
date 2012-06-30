drop procedure if exists set_task_starting;
delimiter $$
create procedure set_task_starting(i_stsk_id int(10))
  begin
    update scheduled_tasks
       set exec_status = 'S', exec_start_date = now()
     where i_stsk_id = stsk_id and exec_status in ('F', 'C');

    if row_count() <> 1 then
      call raise_application_error('task.set.status.failed');
    end if;

    insert into scheduled_task_logs(stsk_stsk_id, exec_start_date, exec_status)
         values (i_stsk_id, now(), 'S');
  end
$$
delimiter ;