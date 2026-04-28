# File Import Processing Chunks

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImport, chunks, FileImportProcess, background, Quartz -->

> Runtime импорта: `FileImportProcess`, chunks, сохранение сущностей и восстановление незавершённых импортов.

## Import process

`FileImportService.Import` запускает процесс `FileImportProcess` с параметром `ImportSessionId`.

```csharp
var parameters = new Dictionary<string, object> {
    { "ImportSessionId", importSessionId }
};
UserConnection.RunProcess("FileImportProcess", MisfireInstruction.SimpleTrigger.FireNow, parameters, jobOptions);
```

## Persistent mode

Feature `UsePersistentFileImport` переключает режим хранения параметров импорта. В persistent mode параметры сохраняются через `ImportParametersRepository`, а на старте приложения включается recovery.

## Chunk model

Основные сущности runtime:

| Сущность | Назначение |
| -------- | ---------- |
| `ImportSession` | общая сессия импорта |
| `FileImportParameters` | файл, root schema, параметры |
| `ImportSessionChunk` | chunk сессии |
| `EntityChunkData` | данные сущностей chunk |
| `ChunkProcessResult` | результат обработки chunk |
| `BufferedImportEntity` | буферная сущность с `ImportExcelRowIndex` |

## Entity chunk processor

`FileImportEntitiesChunkProcessor`:

1. Проверяет, не отменён ли импорт.
2. Инициализирует primary и child entities.
3. Создаёт individual tags.
4. Сохраняет import entities.
5. Публикует success/error events.

Сохранение может учитывать sys setting `RunProcessesInBackgroundOnFileImport`.

## Lookup chunk processor

`ChunkLookupValuesHandler` отдельно обрабатывает lookup values, чтобы заранее разрешить и провалидировать значения справочников.

## Background recovery

`FileImportAppEventListener.OnAppStart` при `UsePersistentFileImport` планирует `FileImportBackgroundProcessor`.

`FileImportBackgroundProcessor`:

- читает незавершённые параметры через `ImportParametersRepository.GetWithProcessIncomplete`;
- находит процесс по `FileImportProcessId`;
- проверяет состояние persistent task;
- завершает running element через `processEngine.CompleteExecuting`.

## Failover guard

Если `appConnection.IsFailOverProcessCompletionEnabled`, listener не планирует отдельный recovery job, чтобы не конфликтовать с общим failover механизмом.

## Логирование

Лог пишется через logger `FileImportAppender` и `FileImportLogMessageExtensions`: старт, планирование, перезапуск, ошибки.

## Практические правила

- Не храните состояние импорта только в client state.
- Для долгого импорта используйте process + chunks, а не один синхронный service call.
- В persistent mode проверяйте recovery на app start.
- При отмене импорта chunk processor должен быстро выходить.
- Для диагностики связывайте logs по `ImportSessionId`.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File import services](file-import-services.md)
- [Process Overview](process-overview.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
