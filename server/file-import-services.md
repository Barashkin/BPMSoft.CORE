# File Import Services

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImportService, WCF, upload, ImportSession -->

> WCF/API-контур FileImport: загрузка файла, параметры сессии, маппинг и запуск процесса.

## FileImportService contract

`IFileImportService` публикует REST/WCF методы с `BodyStyle.Wrapped`.

| Метод | Назначение |
| ----- | ---------- |
| `SaveFile` | обработать загруженный файл |
| `GetImportSessionInfo` | получить состояние import session |
| `SetImportObject` | выбрать объект импорта |
| `SetFileInfo` | сохранить имя файла |
| `Import` | запустить импорт |
| `GetColumnsMappingParameters` | получить параметры маппинга колонок |
| `SetColumnsMappingParameters` | сохранить маппинг колонок |
| `GetTagsMappingParameters` | получить параметры tags |
| `SetTagsMappingParameters` | сохранить tags mapping |
| `ValidateTagsMappingParameters` | проверить лимиты tags |

## FileImportService implementation

`FileImportService` наследуется от `BaseService`, реализует `IReadOnlySessionState` и получает importer через `IFileImporterFactory`.

```csharp
protected IBaseFileImporter FileImporter =>
    _fileImporter ?? (_fileImporter = FileImporterFactory.GetFileImporter(UserConnection));
```

Основной метод запуска:

```csharp
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanImportFromExcel");
var parameters = FileImporter.FindImportParameters(request.ImportSessionId);
parameters.NeedSendNotify = true;
StartFileImportProcess(request.ImportSessionId);
```

## Запуск процесса

`StartFileImportProcess` запускает `FileImportProcess` с параметром `ImportSessionId`.

Если feature `UseDefaultImportJobOptions` выключена, используется `JobOptions` с `RequestsRecovery = false`.

## Upload endpoint

Начальный экран wizard использует два upload path:

| Path | Когда используется |
| ---- | ------------------ |
| `FileImportService/SaveFile` | legacy/non-chunked upload |
| `FileImportUploadFileService/SaveFile` | chunked upload в `FileImportParameters.FileData` |

Для chunked upload client передаёт:

- `entitySchemaName: "FileImportParameters"`;
- `columnName: "FileData"`;
- `parentColumnName: "Id"`;
- `parentColumnValue: ImportSessionId`;
- `maxFileSizeSysSettingsName: "FileImportMaxFileSize"`.

## Template service

`FileImportTemplateService` управляет шаблонами маппинга:

- применяет template к текущей сессии;
- сохраняет selected template id в `SessionData`;
- сериализует `ImportColumn` в `TemplateData`;
- валидирует `ImportSessionId` и `ImportTemplateId`.

## Validation service

`FileImportValidationService` проверяет возможность использовать хранилище import entities и вызывает validation importer. Важная развилка — feature `UsePersistentFileImport`.

## Практические правила

- Для запуска импорта всегда проверяйте `CanImportFromExcel`.
- Не смешивайте upload импорта с attachment upload через `FileApiService`.
- Все шаги wizard должны работать с одним `ImportSessionId`.
- `GetImportSessionInfo` — основной способ восстановить состояние после перехода между шагами.
- Для templates не храните mapping в произвольном JSON вне `FileImportTemplate.TemplateData`.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File import wizard UI](file-import-wizard-ui.md)
- [File import security limits](file-import-security-limits.md)
- [Services Overview](services-overview.md)
