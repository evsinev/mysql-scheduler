drop procedure if exists set_task_running;
delimiter $$
create procedure set_task_running(i_stsk_id int(10))
  begin
    declare v_task_definition   text;

    update scheduled_tasks
       set exec_status   = 'R'
     where i_stsk_id = stsk_id and exec_status in ('S');

    if row_count() <> 1 then
      call raise_application_error('task.set.status.failed');
    end if;

    insert into scheduled_task_logs(stsk_stsk_id, exec_status)
         values (i_stsk_id, 'R');

    commit;

    select task_definition
      into v_task_definition
      from scheduled_tasks
     where i_stsk_id = stsk_id and exec_status in ('R');

    if v_task_definition is null then
      call raise_application_error('no.task.to.run');
    else
      set @sv_task_ddl_statement   = v_task_definition;
      prepare v_task_stmt from @sv_task_ddl_statement;
      execute v_task_stmt;
      deallocate prepare v_task_stmt;
      call set_task_completed(i_stsk_id);
    end if;
  end
$$
delimiter ;