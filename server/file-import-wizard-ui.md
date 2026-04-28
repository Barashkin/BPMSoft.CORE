# File Import Wizard UI

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImportWizard, wizard, ServerChannel, import UI -->

> Клиентский мастер импорта: шаги, навигация, upload, progress и result page.

## Wizard module

`FileImportWizard.FileImport.js` наследуется от `BaseWizardModule`. Перед инициализацией он проверяет операции:

- `CanImportFromExcel`;
- `CanViewConfiguration`.

Если обе операции недоступны, wizard показывает стандартное сообщение о недоступности прав.

## Шаги мастера

| Шаг | Schema | Назначение |
| --- | ------ | ---------- |
| 1 | `FileImportStartPage` | выбор объекта и файла |
| 2 | `FileImportTagsMappingPage` | настройка tags |
| 3 | `FileImportColumnsMappingPage` | маппинг колонок |
| 4 | `FileImportDuplicateManagementPage` | стратегия дублей |
| 5 | `FileImportProcessingPage` | прогресс обработки |
| 6 | `FileImportResultPage` | результат и ссылки |

Навигация строится через history hash:

```javascript
this.BPMSoft.combinePath(step.moduleName, step.schemaName, this.importSessionId, this.entitySchemaName)
```

## Start page

`FileImportStartPage` отвечает за:

- выбор import object;
- создание/восстановление `ImportSessionId`;
- загрузку файла;
- применение import template;
- базовую валидацию файла.

Chunked upload отправляет файл в `FileImportUploadFileService/SaveFile` и использует sys setting `FileImportMaxFileSize`.

## Mapping pages

`FileImportColumnsMappingPage` и связанные view models управляют назначениями колонок:

- `ColumnMappingViewModel`;
- `ColumnDestinationViewModel`;
- `LookupColumnDestinationViewModel`;
- `ColumnTypedDestinationViewModel`.

## Processing page

`FileImportProcessingPage` подписывается на `BPMSoft.ServerChannel` и принимает сообщения с header `FileImport`.

Логика обработки:

- проверить sender;
- проверить `importSessionId`;
- взять `status`;
- если `stage === "complete"`, перейти на result page;
- иначе обновить `ProcessingPercent`.

## Result page

`FileImportResultPage` получает итог через `GetImportSessionInfo` и показывает:

- `TotalRowsCount`;
- `ProcessedRowsCount`;
- `ImportedRowsCount`;
- `NotImportedRowsCount`;
- `NewTagsCount`;
- признак успешности tags import.

Также формирует ссылки на импортированные данные и журнал импорта.

## Практические правила

- Не переходите между шагами без `Validate`.
- Не создавайте новый `ImportSessionId` при возврате на шаги wizard.
- Progress-сообщения фильтруйте по `importSessionId`, иначе можно показать статус чужого импорта.
- Для ошибок upload используйте `FileImportConstants`, а не произвольные строки.
- Result page считайте успешной только если импортированы все строки и tags обработаны успешно.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File import services](file-import-services.md)
- [File import mapping validation](file-import-mapping-validation.md)
- [Client Module Overview](../client/client-module-overview.md)
