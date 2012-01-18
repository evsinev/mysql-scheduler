set names utf8 collate utf8_general_ci;

insert into scheduled_tasks(task_name,
                            task_description,
                            task_definition,
                            task_start_date,
                            retry_interval,
                            exec_next_date
                           )
  values ('every_two_minute_task', 'This task runs every two minutes', 'do sleep(10)', date(now()), '2MI', date(now())),
         ('every_two_hour_task', 'This task runs every two hours', 'do sleep(10)', date(now()), '2HH', date(now())),
         ('every_two_day_task', 'This task runs every two days', 'do sleep(10)', date(now()), '2D', date(now())),
         ('every_two_month_task', 'This task runs every two months', 'do sleep(10)', date(now()), '2M', date(now())),
         ('every_two_year_task', 'This task runs every two yearss', 'do sleep(10)', date(now()), '2Y', date(now()));

commit;