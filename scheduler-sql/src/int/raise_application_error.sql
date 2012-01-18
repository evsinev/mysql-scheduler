drop procedure if exists raise_application_error;
delimiter $$
create procedure raise_application_error(i_error_message text, i_error_core varchar(32))
 main_sql:
  begin
    set @v_ddl_statement      =
          concat('call `|ERROR: ',
                 i_error_core,
                 '|',
                 i_error_message,
                 '|`'
                );
    prepare v_stmt from @v_ddl_statement;
    execute v_stmt;
    deallocate prepare v_stmt;
  end
$$
delimiter ;