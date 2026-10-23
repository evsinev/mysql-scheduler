FROM eclipse-temurin:21-jre-alpine

ADD https://github.com/evsinev/mysql-scheduler/releases/download/mysql-scheduler-2.0-1/scheduler-2.0-1.jar /scheduler.jar

ENV URL="jdbc:mariadb://mysql:3306/sched"
CMD ["java", "-jar", "/scheduler.jar"]
