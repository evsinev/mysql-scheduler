FROM openjdk:8-jre-alpine

ADD https://github.com/evsinev/mysql-scheduler/releases/download/mysql-scheduler-1.0-9/scheduler-1.0-10-SNAPSHOT.jar /scheduler.jar

CMD ["/usr/bin/java", "-jar", "/scheduler.jar"]
