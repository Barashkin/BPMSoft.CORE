# Reports Security And Limits

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: reports security, CanExportGrid, SysAllowedReportFormat, FileImportMaxFileSize -->

> Права, ограничения форматов и лимиты файлов в подсистеме отчётов.

## Права на список отчётов

`ReportEngine.GetReportTemplates()` и client print menu читают `SysModuleReport` с учётом прав текущего пользователя. Если отчёт не виден, сначала проверяйте metadata, затем права.

## Права на данные

Генерация строит ESQ с `UseAdminRights = false` в основных flows, поэтому данные отчёта должны соответствовать правам пользователя.

Если в кастомном provider используется `SystemUserConnection` или `UseAdminRights = true`, перед этим нужна явная проверка операции или бизнес-прав.

## Operation rights

В отчётном контуре встречается явная проверка операции для экспорта:

```csharp
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanExportGrid");
```

Используйте такой подход для действий, которые выходят за рамки обычного чтения записи: массовый экспорт, административная выгрузка, генерация по скрытым данным.

## Ограничение форматов

`SysAllowedReportFormat` определяет, какие форматы разрешены для отчёта. `ReportService.ValidateReportFormat` не должен обходиться кастомным кодом.

Типичный симптом нарушения: пользователь просит PDF/DOCX, но сервис возвращает другой формат или ошибку.

## Upload limits

Для загрузки Word-шаблонов в designer используется `FileImportMaxFileSize`. Это отдельный сценарий от обычного attachment upload.

Также учитывайте общую файловую подсистему:

- file column в `SysModuleReport`;
- `ConfigurationFileApi`;
- правила file storage;
- sanitization и ограничения имени файла.

## XML safety

FastReport template — XML. При чтении шаблона используется запрет DTD и external resolver.

Для кастомного импорта `.frx` сохраняйте этот принцип: не включайте DTD и external entity resolution.

## Практические правила

- Не генерируйте отчёты под system context без отдельной проверки прав.
- Для экспорта проверяйте operation right.
- Для формата проверяйте `SysAllowedReportFormat`.
- Для загрузки шаблонов проверяйте `FileImportMaxFileSize`.
- Для FastReport XML не разрешайте external entities.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Security overview](security-overview.md)
- [File security limits](file-security-limits.md)
- [Reports troubleshooting](reports-troubleshooting.md)
