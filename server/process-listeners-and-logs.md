# Process Listeners And Logs

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessListener, ProcessListeners, SysProcessLog, SysProcessElementLog, ContinueExecuting -->

> Process listeners связывают выполнение процесса с изменениями записей, а process logs помогают диагностировать состояние и ошибки.

## Process listener

Process listener позволяет приостановить выполнение до изменения записи или выполнения условия.

```csharp
IProcessEngine processEngine = UserConnection.ProcessEngine;
processEngine.AddProcessListener(RecordId, ObjectSchemaId, UId, serializedFilters);
```

Типичный пример: `OpenEditPageUserTask` открывает карточку и ждёт сохранения или изменения нужной колонки.

## ProcessListeners column

Для сущностей может генерироваться колонка `ProcessListeners`. Она хранит признак событий, которые должны продолжить процесс.

При создании новой записи task может проставить listener на inserted event:

```csharp
defaultColumnValues["ProcessListeners"] =
    SerializeEntityColumn(columns.GetByName("ProcessListeners"), (int)EntityChangeType.Inserted);
```

## Entity change and ContinueExecuting

Entity schema/event flow может найти process listeners и продолжить ожидающие процессы.

Важно различать:

- `ProcessListener` — runtime ожидание конкретного процесса;
- `ProcessSchemaListener` — metadata/схемный listener;
- `EntityChangeType` — событие entity, которое должно продолжить процесс.

## SysProcessLog

`SysProcessLog` хранит верхнеуровневую запись о запуске процесса:

- процесс;
- статус;
- время старта и завершения;
- пользователь;
- связь с entity/context.

Используйте его, чтобы понять, был ли процесс вообще запущен.

## SysProcessElementLog

`SysProcessElementLog` показывает выполнение отдельных элементов:

- какой элемент выполнялся;
- где процесс остановился;
- какой user task или script task упал;
- сколько времени занял шаг.

Это основной источник для поиска зависшего или ошибочного шага.

## Диагностика ожидания

Если процесс завис на ожидании:

1. Найдите запись в `SysProcessLog`.
2. Проверьте последний `SysProcessElementLog`.
3. Определите ожидаемый element UId.
4. Проверьте, добавлен ли listener на нужную запись.
5. Проверьте `ProcessListeners` у target entity.
6. Убедитесь, что событие entity действительно произошло.

## Связанные документы

- [Process user tasks](process-user-tasks.md)
- [Process troubleshooting](process-troubleshooting.md)
- [EventListener entity hooks](event-listeners-entity-hooks.md)
- [Entity Schema Dive](entity-schema-overview.md)
