drop procedure if exists pause_scheduler;
delimiter $$
create procedure pause_scheduler(i_max_wait int(10))
  begin
    declare v_running_tasks_count   int(10);
    declare v_end_wait              int(10);
    set v_end_wait   = unix_timestamp() + i_max_wait;

    update scheduler_settings
       set setting_value   = 'Y'
     where setting_name = 'Scheduler paused';

    select count(1)
      into v_running_tasks_count
      from scheduled_tasks
     where exec_status = 'R';

    while v_running_tasks_count > 0
    do
      do sleep(10);

      select count(1)
        into v_running_tasks_count
        from scheduled_tasks
       where exec_status = 'R';

      if v_end_wait < unix_timestamp() then
        call raise_application_error('time.exceeded');
      end if;
    end while;
  end
$$
delimiter ;
