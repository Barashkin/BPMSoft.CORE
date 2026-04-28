# Process Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Process troubleshooting, SysProcessLog, SysProcessElementLog, ProcessJob, ScriptTask -->

> Практический чеклист диагностики бизнес-процессов BPMSoft.

## Процесс не запускается

Возможные причины:

- процесс выключен;
- указан неверный name/UId;
- у пользователя нет прав;
- параметры не соответствуют схеме;
- ошибка возникает в первом элементе.

Проверки:

1. Найдите процесс в `ProcessSchemaManager`.
2. Проверьте `Instance.Enabled`.
3. Проверьте `SysProcessLog`.
4. Проверьте server log на exception из `IProcessExecutor`.
5. Для клиента проверьте ответ `ProcessEngineService`.

## Параметр не приходит в процесс

Проверки:

- имя параметра совпадает с `ProcessSchemaParameter.Name`;
- direction допускает входное значение;
- тип можно преобразовать из переданного значения;
- для JS запуска параметры проходят через conversion в `ProcessModuleUtilities`;
- для Quartz используется `Dictionary<string, object>`, а не только string.

## ReadDataUserTask возвращает пустой результат

Проверки:

- корректный `EntitySchemaUId`;
- фильтры действительно применились;
- `UseAdminRights = false` не скрывает записи правами;
- `EntityColumnMetaPathes` содержит существующие meta paths;
- `ResultRowsCount > 0` проверяется перед чтением `ResultEntity`.

См. [ESQ troubleshooting](esq-troubleshooting.md).

## ChangeData/DeleteData падает на пустом фильтре

Это штатная защита. `ChangeDataUserTask` и `DeleteDataUserTask` не должны массово менять или удалять все записи без условий.

Проверьте:

- `IsMatchConditions`;
- сериализованный `DataSourceFilters`;
- параметры, подставляемые в right expression;
- mapping filter parameter values.

## ScriptTask не компилируется или падает

Проверки:

- все `using` и package dependencies доступны;
- method name совпадает с `AddScriptTaskMethod`;
- возвращается `true`;
- `Get<T>()` читает существующий параметр;
- exception логируется с контекстом.

Для сложной логики вынесите код в C# helper/service.

## ProcessJob не запускает процесс

Проверки:

- job создан в нужном scheduler instance;
- `jobName`, `groupName`, `triggerName` не конфликтуют;
- trigger имеет next fire time;
- workspace и user name указаны корректно;
- process name существует;
- параметры job соответствуют process parameters.

См. [Process Quartz Jobs](process-quartz-jobs.md) и [Quartz troubleshooting](quartz-troubleshooting.md).

## Процесс завис на ожидании

Проверки:

1. Откройте `SysProcessLog`.
2. Найдите последний `SysProcessElementLog`.
3. Определите waiting user task.
4. Проверьте process listener на target record.
5. Проверьте колонку `ProcessListeners`.
6. Убедитесь, что entity event действительно произошёл.

## Клиентский запуск показывает ошибку

Проверьте:

- используется `executeProcess`, а не obsolete `runProcess`;
- `sysProcessName` указан верно;
- callback корректно читает response shape;
- включение feature `GetProcessStepsViaResponse` не ломает старый handler;
- нет ошибки в `ProcessEngineService`.

## Мини-чеклист перед доработкой процесса

- У процесса есть понятный owner и сценарий запуска.
- Параметры имеют стабильные имена и типы.
- CRUD tasks не работают с пустым фильтром.
- Долгая логика вынесена в helper/job.
- Scheduled process имеет детерминированные имена job/trigger.
- Ошибки пишутся в logs с business id.
- Есть ссылка на связанные entity и Quartz/EventListener docs.

## Связанные документы

- [Process Overview](process-overview.md)
- [Process listeners and logs](process-listeners-and-logs.md)
- [Process starting](process-starting.md)
- [Quartz troubleshooting](quartz-troubleshooting.md)
