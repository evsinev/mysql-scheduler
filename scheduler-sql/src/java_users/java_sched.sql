use sched;
drop procedure if exists mi_create_java_sched;
delimiter $$
create procedure mi_create_java_sched(i_create_date datetime)
 main_sql:
  begin
    declare ex_no_records_found   int(10) default 0;
    declare v_grant_str           varchar(512);
    declare v_user_count          int(10);

    declare
      cur_privileges cursor for select concat("grant execute on procedure ",
                                              routine_schema,
                                              ".",
                                              routine_name,
                                              " to 'java_sched'@'localhost'"
                                             )
                                  from information_schema.routines
                                 where     routine_schema = 'sched'
                                       and (   routine_name in ('create_collections')
                                            or routine_name like 'get%'
                                            or routine_name like 'set%');

    declare continue handler for not found set ex_no_records_found = 1;
    select count(1)
      into v_user_count
      from mysql.user
     where user = 'java_sched';

    if v_user_count = 0 then
      set @sv_ddl_statement   = "create user 'java_sched'@'localhost' identified by '123java_sched123'";

      prepare v_stmt from @sv_ddl_statement;
      execute v_stmt;

      deallocate prepare v_stmt;
    end if;

    set ex_no_records_found   = 0;

    open cur_privileges;

    repeat
      fetch cur_privileges into v_grant_str;

      if not ex_no_records_found then
        set @sv_ddl_statement     = v_grant_str;

        prepare v_stmt from @sv_ddl_statement;
        execute v_stmt;

        deallocate prepare v_stmt;
        set ex_no_records_found   = 0;
      end if;
    until ex_no_records_found
    end repeat;

    close cur_privileges;
  end
$$
delimiter ;
call mi_create_java_sched(now());
drop procedure if exists mi_create_java_sched;
grant select on mysql.proc to 'java_sched' @'localhost';