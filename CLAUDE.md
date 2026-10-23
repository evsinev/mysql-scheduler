# mysql-scheduler

Планировщик задач для MariaDB/MySQL: Java-процесс в цикле забирает из базы `sched` задачи, у которых
подошло время, и выполняет их хранимыми процедурами (`get_schedule_tasks`, `set_task_starting`,
`set_task_running`, `set_task_failed`). SQL задачи (`scheduled_tasks.task_definition`) выполняет
`set_task_running` через `prepare/execute`.

- `scheduler/` — Java (Maven, Java 21). Точка входа `Start`, Guice-модули в `guice/`, DAO на jdbc-proc
  (`dao/ISchedulerDao` → хранимые процедуры).
- `scheduler-sql/` — схема и процедуры. Установка — MI-скрипты (`mi/all_mi.sh`, берут
  `~/env/instance_sched.sh`, см. README), процедуры — `src/all-proc.sql`, права java-пользователя —
  `java_users/java_sched.sql`.
- `docker/Dockerfile` — образ из jar GitHub-релиза.

## Сборка

```bash
cd scheduler && mvn -B clean verify   # target/scheduler-<version>.jar — fat jar
```

Юнит-тестов нет; тест — живой прогон `scripts/live-test.sh` (ниже), CI запускает его на каждый push/PR.

## Что легко сломать

- **jdbc-proc 2.0-x** берётся только из `https://maven.pne.io` (на Central — до 2.0-5). В нём:
  `InitJdbcProcModule.configure()` не вызывает `bindParameterConverterService()` — привязка сделана
  в `SchedulerModule`; gson объявлен `provided`, но нужен в рантайме — подключён явно. Spring в
  jdbc-proc 3.0.0, версию задаёт `spring-framework-bom` в нашем pom.
- **Spring 7**: `TransactionInterceptor` требует `spring-context`. `@Transactional` работает через
  Guice AOP (`bindInterceptor` в `SchedulerModule`), `aopalliance` исключён из guice — эти классы есть
  в spring-aop.
- **URL**: `jdbc:mysql:` заменяется на `jdbc:mariadb:` при старте (`SchedulerConfig`), чтобы не трогать
  конфиги установок. Параметры Connector/J 5.1 драйвер игнорирует, но TLS не переводится один в один:
  `useSSL=true` → `verify-full`, `verifyServerCertificate=false` не учитывается.
- **Fat jar** собирает maven-assembly; `Multi-Release: true` в manifest обязателен (Java 11+-классы
  mariadb-java-client). Новые зависимости проверять на конфликт `META-INF/services` и ресурсов.
- Ошибка зависимостей часто видна только в рантайме (`NoClassDefFoundError`, Guice
  `CreationException`), а не при компиляции — поэтому после любых изменений pom обязателен живой прогон.

## Живой прогон

`scripts/live-test.sh [jar]` (нужен docker, jar сначала собрать): поднимает MariaDB 10.6.18
(`MARIADB_IMAGE`, `DB_PORT`, `KEEP_DB=1` — оставить контейнер), ставит схему штатными MI-скриптами
(`all_mi.sh`), запускает jar с успешной и падающей задачами и проверяет: успешная → `C` и её SQL выполнен,
падающая → `F` с текстом ошибки в `scheduled_task_logs`, startup/shutdown-запросы выполнены, остановка по
SIGTERM. Два прогона: старый `jdbc:mysql:` URL из переменных окружения и всё из `CONFIG_FILE`.

- Без `--skip-name-resolve=0` MI-скрипты не войдут как `sched@localhost` по TCP.
- `all_mi.sh` всегда завершается с кодом 0 — ошибки ищем в его выводе.
- Новое поведение — новая проверка в скрипте, и сначала убедиться, что без исправления она падает.

## Проверки перед PR

- **OWASP**: `../cve-fix/check-owasp.sh $PWD/scheduler` (dependency-check 12.2.1 + OSS Index, как
  серверный коллектор; сериализован блокировкой). Смотреть не только итог, но и что Sonatype-анализатор
  не отключился и в отчёт попали все jar. Suppression-файлы, чтобы спрятать CVE, не добавляем.
  Типовые решения по CVE — `../cve-fix/RUNBOOK.md`.
- **Ревью codex** (как в `../vedger`): `codex exec -C $PWD -s read-only -c model_reasoning_effort='"high"' -o <файл> "<что делалось, что проверено, на что смотреть>" < /dev/null`
  (без `< /dev/null` висит). Первая строка ответа — «идти можно» / «идти нельзя», находки помечены
  БЛОКИРУЮЩАЯ / БОЕВАЯ, не больше пяти. Блокирующие исправить, боевые — исправить или явно отклонить с
  причиной; после исправлений — повторный раунд. В PR — вердикт codex. В запросе к codex не утверждать
  того, что не проверено.
- Версии библиотек — только реально существующие (`curl -s https://repo1.maven.org/maven2/<group>/<artifact>/maven-metadata.xml`, для jdbc-proc — maven.pne.io).

## Релиз

В git версия всегда `-SNAPSHOT`. Релиз — тег `mysql-scheduler-<major>.<minor>-<build>` (например
`mysql-scheduler-2.0-1`) на коммит в master: `.github/workflows/release.yml` ставит версию из тега,
собирает и публикует GitHub Release с `scheduler-<version>.jar` и `.sha256`. Тег другого формата
отклоняется. После релиза — поднять версию в `docker/Dockerfile` и `-SNAPSHOT` в pom.

## Правила

- Изменения — в ветке и через PR в master; CI (`maven.yml`) должен быть зелёным.
- Коммиты — Conventional Commits, по-английски, одной строкой, через skill `commit-message`.
- Описание PR — по-английски. Документы и комментарии в этом файле — по-русски, идентификаторы — по-английски.
