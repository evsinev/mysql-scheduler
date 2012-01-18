set names utf8 collate utf8_general_ci;

insert into scheduled_tasks(task_name,
                            task_description,
                            task_definition,
                            task_start_date,
                            retry_interval,
                            exec_next_date
                           )
     values ('every_two_minute_task',
             'This task runs every two minutes',
             'do sleep(10)',
             date(now()),
             '2M',
             date(now())
            );

commit;