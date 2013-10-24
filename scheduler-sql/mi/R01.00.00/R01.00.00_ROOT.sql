set names utf8 collate utf8_general_ci;

drop database if exists ${db_sched};
create database if not exists `${db_sched}` default character set utf8 collate utf8_general_ci;
grant all privileges on ${db_sched}.* to '${db_sched}'@'localhost' identified by '123${db_sched}123' with grant option;
