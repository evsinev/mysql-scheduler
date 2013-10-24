use ${db_sched};
drop procedure if exists mi_create_java_sched;
delimiter $$
create procedure mi_create_java_sched(i_create_date datetime)
 main_sql:
  begin
    declare ex_no_records_found   int(10) default 0;
    declare v_grant_str           varchar(512);

    declare
      cur_privileges cursor for select concat("grant execute on procedure ",
                                              routine_schema,
                                              ".",
                                              routine_name,
                                              " to '${grant_user}'@'${grant_host}'"
                                             )
                                  from information_schema.routines
                                 where     routine_schema = 'sched'
                                       and (   routine_name in ('create_collections')
                                            or routine_name like 'get%'
                                            or routine_name like 'set%');

    declare continue handler for not found set ex_no_records_found = 1;

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