# EventListener Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, troubleshooting, BaseEntityEventListener, IAppEventListener, EventsProcess -->

> Чеклист диагностики EventListener'ов: listener не срабатывает, срабатывает не там, ломает сохранение или создаёт нагрузку.

## Listener не срабатывает

Проверьте:

- есть ли `[EntityEventListener(SchemaName = "...")]`;
- точно ли указано имя схемы, а не caption;
- класс наследуется от `BaseEntityEventListener`;
- файл скомпилирован в актуальном пакете;
- событие относится к нужной стадии (`OnSaving` vs `OnSaved`, `OnUpdating` vs `OnUpdated`);
- изменение выполняется через Entity API, а не прямой SQL `Update`/`Insert`.

Прямые SQL builders не обязаны запускать entity event pipeline.

## Срабатывает не тот hook

Ориентируйтесь на стадию:

| Нужно | Hook |
| --- | --- |
| проверить данные перед любой записью | `OnSaving` |
| заполнить значения только при создании | `OnInserting` |
| проверить update существующей записи | `OnUpdating` |
| создать связанную запись после insert | `OnInserted` |
| очистить cache после update | `OnUpdated` |
| запретить удаление | `OnDeleting` |
| удалить внешний индекс после удаления | `OnDeleted` |

Если логика должна выполняться только после успешной записи, не размещайте её в before hook.

## Исключение ломает сохранение

Проверьте:

- исключение выброшено в before hook намеренно или случайно;
- есть ли локализованное сообщение для пользователя;
- не выполняется ли внешний API-вызов синхронно;
- нужна ли отмена через `e.IsCanceled`;
- можно ли перенести side effect в after hook или async job.

Для необязательной after-логики лучше использовать `try/catch` и логирование, как в global search indexing.

## Рекурсия или повторное сохранение

Признаки:

- listener вызывает `entity.Save()`;
- тот же listener срабатывает повторно;
- stack trace содержит повторяющиеся event methods;
- сохранение зависает или падает по timeout.

Что проверить:

- не сохраняется ли та же entity внутри `OnSaving`, `OnUpdating`, `OnDeleting`;
- есть ли guard-флаг или изменение состояния, которое предотвращает повторный вход;
- можно ли заменить повторный `Save()` на изменение колонок до исходного save;
- можно ли вынести операцию в сервис или job.

## Changed columns не определяются

Проверьте:

- колонка реально загружена и изменена через Entity API;
- используется правильное имя колонки (`Name`, `OwnerId`, `ChatQueueId`);
- lookup column может иметь `ColumnName` и `ColumnValueName`;
- в after hook можно смотреть `e.ModifiedColumnValues`;
- old value доступно через changed values или `GetColumnOldValue`, если оно было загружено.

## App listener не регистрирует job

Проверьте:

- выполняется ли `OnAppStart`;
- корректно ли получен `AppConnection` из `context.Application`;
- используется ли `SystemUserConnection`;
- не возвращает ли `DoesJobExist` `true` для старой версии job;
- job name и group стабильны;
- cron или interval валидны;
- SysSettings не отключает регистрацию.

Смежные документы:

- [Quartz troubleshooting](quartz-troubleshooting.md)
- [Quartz registration patterns](quartz-registration-patterns.md)

## Performance проблемы

Проверьте:

- listener запускается на базовой схеме вроде `BaseEntity`;
- нет ли тяжёлых ESQ/SQL без фильтров;
- есть ли early return по changed columns;
- не выполняется ли внешняя интеграция синхронно;
- не блокируется ли пользовательская операция долгой after-логикой;
- можно ли использовать async executor или Quartz.

## Конфликт с EventsProcess

Если поведение не находится в listener class:

- проверьте generated `EventsProcess` в `{Entity}Schema.Base.cs`;
- проверьте partial methods в `{Entity}.Base.cs`;
- ищите `ThrowEvent`, `OnExecuted`, `ScriptTask`;
- смотрите stack trace на `BaseEventsProcess`.

## Быстрый чеклист

- SchemaName указан правильно.
- Выбран правильный hook.
- `base` вызывается осознанно.
- Before hook не делает тяжёлую необязательную работу.
- After hook фильтруется по changed columns.
- Исключения в after hook не ломают основную операцию без причины.
- Повторный `Save()` защищён от рекурсии или отсутствует.
- Quartz/job registration идемпотентна.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener entity hooks](event-listeners-entity-hooks.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
- [EventListener EventsProcess](event-listeners-eventsprocess.md)
- [EventListener async and jobs](event-listeners-async-and-jobs.md)
