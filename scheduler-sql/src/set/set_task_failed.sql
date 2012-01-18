drop procedure if exists set_task_failed;
delimiter $$
create procedure set_task_failed(i_stsk_id int(10), i_error_message text)
  begin
    update scheduled_tasks
       set exec_status   = 'E', exec_start_date = null, exec_end_date = now()
     where i_stsk_id = stsk_id;

    if row_count() <> 1 then
      call raise_application_error('Impossible to set task status', 'task.set.status.failed');
    end if;
  end
$$
delimiter ;