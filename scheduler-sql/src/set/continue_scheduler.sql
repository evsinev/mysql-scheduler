drop procedure if exists continue_scheduler;
delimiter $$
create procedure continue_scheduler()
  begin
    update scheduler_settings
       set setting_value   = 'N'
     where setting_name = 'Scheduler paused';
  end
$$
delimiter ;