set names utf8 collate utf8_general_ci;

select distinct concat(char(35), char(35), char(35)) marker, u.user, u.password
  from mysql.user u, mysql.db d
 where u.host = 'localhost'
       and u.user = d.db 
       and d.db = '${db_sched}';

update mysql.user u, mysql.db d
   set u.password = password('${mi_password}')
 where u.host = 'localhost' 
       and u.user = d.db 
       and d.db = '${db_sched}';

flush privileges;
