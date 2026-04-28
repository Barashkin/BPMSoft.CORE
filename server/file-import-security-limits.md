# File Import Security And Limits

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImport, security, CanImportFromExcel, FileImportMaxFileSize -->

> Права, лицензии, настройки размера и безопасные границы FileImport.

## Operation rights

Для входа в wizard и запуска импорта используются операции:

| Операция | Где используется | Назначение |
| -------- | ---------------- | ---------- |
| `CanImportFromExcel` | `FileImportWizard`, `FileImportService.Import` | импорт из Excel |
| `CanViewConfiguration` | `FileImportWizard` | доступ к конфигурационному UI |

Серверный запуск импорта обязательно проверяет `CanImportFromExcel`.

## Entity rights

При сохранении данных import processor работает в контексте текущего пользователя. Для lookup append проверяются:

- license rights через `LicHelper.GetSchemaLicRights`;
- schema append rights через `DBSecurityEngine.GetIsEntitySchemaAppendingAllowed`.

Если пользователь не может создавать lookup values, импорт должен дать ошибку, а не silently создать запись под system context.

## Upload limits

Для файла импорта используется sys setting `FileImportMaxFileSize`.

Chunked upload config:

```javascript
{
    maxFileSizeSysSettingsName: "FileImportMaxFileSize",
    uploadWebServicePath: "FileImportUploadFileService/SaveFile"
}
```

Не путайте с `MaxFileSize` для обычных вложений и `FileImportMaxFileSize` для импорта/некоторых template upload сценариев.

## Feature flags

| Feature/sys setting | Назначение |
| ------------------- | ---------- |
| `UsePersistentFileImport` | persistent storage и recovery импорта |
| `UseDefaultImportJobOptions` | выбор `JobOptions` при запуске процесса |
| `RunProcessesInBackgroundOnFileImport` | background save behavior |
| `FileImportMaxFileSize` | максимальный размер файла импорта |

## XML/Excel boundary

FileImport использует Excel/OpenXml processor. Для нестандартных форматов не добавляйте bypass в тот же pipeline без явного parser/validator.

## Практические правила

- Проверяйте права на запуск импорта и права на целевые сущности.
- Не используйте `SystemUserConnection` для сохранения imported entities без отдельного business approval.
- Для больших файлов включайте chunked upload и persistent mode.
- Отличайте ошибки лимита файла от ошибок структуры Excel.
- Логируйте `ImportSessionId` во всех ошибках security/limits.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [Security overview](security-overview.md)
- [File security limits](file-security-limits.md)
- [File Import troubleshooting](file-import-troubleshooting.md)
