drop database if exists sched;

create database `sched` default character set utf8 collate utf8_general_ci;

grant all privileges on sched.* to 'sched'@'localhost' identified by '123sched123' with grant option;