set names utf8 collate utf8_general_ci;

insert into scheduled_tasks(task_name,
                            task_description,
                            task_definition,
                            task_start_date,
                            retry_interval,
                            exec_next_date
                           )
     values ('every_two_minute_task', 'Runs every two minutes', 'do sleep(10)', date(now()), '2MI', date(now())),
            ('every_two_hour_task', 'Runs every two hours', 'do sleep(10)', date(now()), '2HH', date(now())),
            ('every_two_day_task', 'Runs every two days', 'do sleep(10)', date(now()), '2D', date(now())),
            ('every_two_month_task', 'Runs every two months', 'do sleep(10)', date(now()), '2M', date(now())),
            ('every_two_year_task', 'Runs every two years', 'do sleep(10)', date(now()), '2Y', date(now())),
            ('every_minute_task', 'Runs every one minute', 'do sleep(10)', date(now()), '1MI', date(now())),
            ('every_hour_task', 'Runs every one hour', 'do sleep(10)', date(now()), '1HH', date(now())),
            ('every_day_task', 'Runs every one day', 'do sleep(10)', date(now()), '1D', date(now())),
            ('every_month_task', 'Runs every one month', 'do sleep(10)', date(now()), '1M', date(now())),
            ('every_year_task', 'Runs every one year', 'do sleep(10)', date(now()), '1Y', date(now())),
            ('every_ten_minute_task', 'Runs every ten minutes', 'do sleep(10)', date(now()), '10MI', date(now())),
            ('every_ten_hour_task', 'Runs every ten hours', 'do sleep(10)', date(now()), '10HH', date(now())),
            ('every_ten_day_task', 'Runs every ten days', 'do sleep(10)', date(now()), '10D', date(now())),
            ('every_ten_month_task', 'Runs every ten months', 'do sleep(10)', date(now()), '10M', date(now())),
            ('every_ten_year_task', 'Runs every ten years', 'do sleep(10)', date(now()), '10Y', date(now()));

commit;