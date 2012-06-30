set names utf8 collate utf8_general_ci;

drop table if exists scheduler_settings;

create table scheduler_settings (
  sett_id          int(10) unsigned not null auto_increment,
  setting_name     varchar(32) not null,
  setting_value    varchar(512),
  number_history   int(10) unsigned not null,
  start_date       datetime,
  end_date         datetime,
  update_date      datetime,
  username         varchar(64),
  primary key pk_scheduler_settings (sett_id,number_history),
  index idx_scheduler_settings_start_end_dates (sett_id,start_date,end_date),
  index idx_scheduler_settings_setting_name (setting_name)
) engine=innodb;

commit;