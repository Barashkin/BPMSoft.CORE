# File Import Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImport, troubleshooting, Excel, import errors -->

> Диагностика импорта из файла: upload, mapping, lookup, chunks, progress и result logs.

## Wizard не открывается

Проверьте:

- `CanImportFromExcel`;
- `CanViewConfiguration`;
- hash `FileImportModule/FileImportStartPage`;
- наличие bundle modules `FileImportWizardBundle`;
- ошибки AMD-загрузки в браузере.

## Файл не загружается

Проверьте:

- sys setting `FileImportMaxFileSize`;
- upload path `FileImportUploadFileService/SaveFile`;
- `ImportSessionId`;
- chunked upload config;
- допустимый Excel-формат;
- ошибки из `FileImportConstants`.

## Объект импорта не выбирается

Проверьте:

- фильтры `FileImportMixin.getEntitySchemaFilters`;
- доступность схемы в workspace;
- права пользователя на целевую схему;
- что import object содержит `uId`, `name`, `caption`.

## Колонки не сопоставляются

Проверьте:

- заголовки Excel;
- `GetColumnsMappingParameters`;
- применённый `FileImportTemplate`;
- совпадение `ImportColumn.Source`;
- destination view models на клиенте;
- ошибки column processors.

## Lookup значения не создаются

Проверьте:

- license rights на reference schema;
- `GetIsEntitySchemaAppendingAllowed`;
- required columns lookup-схемы;
- события `ChunkLookupValuesHandler.ProcessError`;
- row/cell error в журнале.

## Tags не импортируются

Проверьте:

- `ValidateTagsMappingParameters`;
- `new_tags_limit_exceed`;
- настройки `IndividualTag`;
- `FileImportTagManager`;
- `IsTagImportSuccessful` на result page.

## Импорт завис на Processing

Проверьте:

- состояние `FileImportProcess`;
- `ImportSessionId`;
- сообщения `ServerChannel` с header `FileImport`;
- stage/percent в status;
- logs `FileImportAppender`;
- feature `UsePersistentFileImport`.

## После перезапуска импорт не продолжился

Проверьте:

- `UsePersistentFileImport`;
- `FileImportAppEventListener.OnAppStart`;
- `IsFailOverProcessCompletionEnabled`;
- Quartz job `RestartFileImport`;
- `ImportParametersRepository.GetWithProcessIncomplete`;
- статус process element `FileImportPersistentTask`.

## Result показывает частичный импорт

Проверьте:

- `NotImportedRowsCount`;
- `ExcelImportLog`;
- ошибки save в `ImportEntitySaveError`;
- key columns и duplicate strategy;
- права на создание/изменение целевых записей.

## Нет перехода к result page

Проверьте:

- message header `FileImport`;
- совпадение `importSessionId`;
- `status.stage === "complete"`;
- подписку `BPMSoft.ServerChannel.on`;
- что page не уничтожила subscription раньше времени.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File Import services](file-import-services.md)
- [File Import processing chunks](file-import-processing-chunks.md)
- [File Import security limits](file-import-security-limits.md)
