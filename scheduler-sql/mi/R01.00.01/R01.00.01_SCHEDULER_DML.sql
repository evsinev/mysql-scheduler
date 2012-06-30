set names utf8 collate utf8_general_ci;

insert into scheduler_settings(setting_name,
                               setting_value,
                               number_history,
                               start_date,
                               end_date,
                               username
                              )
     values ('Scheduler paused',
             'N',
             1,
             str_to_date("10000101", "%Y%m%d"),
             str_to_date("29991231", "%Y%m%d"),
             'mcshadow'
            );

commit;