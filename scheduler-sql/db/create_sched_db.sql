drop database if exists ${db_sched};

create database `${db_sched}` default character set utf8 collate utf8_general_ci;

grant all privileges on ${db_sched}.* to '${db_sched}'@'localhost' identified by '123sched123' with grant option;