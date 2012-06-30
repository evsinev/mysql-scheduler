drop procedure if exists set_task_failed;
delimiter $$
create procedure set_task_failed(i_stsk_id int(10), i_error_message text)
  begin
    update scheduled_tasks
       set exec_status = 'F', exec_start_date = null, exec_end_date = now()
     where i_stsk_id = stsk_id;

    if row_count() <> 1 then
      call raise_application_error('task.set.status.failed');
    end if;

    insert into scheduled_task_logs(stsk_stsk_id,
                                    exec_start_date,
                                    exec_end_date,
                                    exec_status,
                                    error_message
                                   )
         values (i_stsk_id,
                 null,
                 now(),
                 'F',
                 i_error_message
                );
  end
$$
delimiter ;