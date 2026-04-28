# Reports Templates Storage

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysModuleReport, SysAllowedReportFormat, StoredReport, templates, File -->

> Метаданные отчётов: где хранится регистрация печатной формы, шаблоны, форматы и готовые результаты.

## SysModuleReport

`SysModuleReport` — центральная entity для регистрации печатной формы модуля.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `Caption` | название формы |
| `SysModule` | привязка к модулю |
| `Type` | тип отчёта: MS Word, FastReport |
| `File` | Word template file |
| `FileName` | имя файла template |
| `SysReportSchemaUId` | schema/template id для FastReport/DevExpress |
| `ShowInCard` | показывать в карточке |
| `ShowInSection` | показывать в секции |
| `ConvertInPDF` | конвертировать Word в PDF |
| `MacrosList` | список макросов |
| `MacrosSettings` | настройки макросов и табличных частей |

`UseDenyRecordRights = false` указывает, что record deny rights для этой metadata-сущности не применяются.

## SysAllowedReportFormat

`SysAllowedReportFormat` ограничивает форматы вывода для отчёта. `ReportService.ValidateReportFormat` проверяет, можно ли отдавать запрошенный формат.

Если формат не разрешён, legacy service может откатиться к Word output.

## FastReportTemplate

`FastReportTemplate` хранит `.frx` в поле `Data`. Дополнительные data sources описываются через `FastReportDataSource`.

## SysReportTemplate

`SysReportTemplate` используется в WordReporting как шаблон, связанный с отчётом:

- file column;
- size;
- report id.

## StoredReport

`StoredReport` хранит готовый отчёт:

- `Caption`;
- `Name`;
- binary `Data`.

Не путайте его с transient download flow, где `ReportData` кладётся в `UserConnection.SessionData` и удаляется после `GetReportFile`.

## Report и ReportFolder

`Report` / `ReportFolder` — каталог аналитических отчётов. Это не то же самое, что `SysModuleReport` для печатных форм модуля.

## Package schemas

`SysModuleReportPackage` и `SysModuleReportInPackage` используются для поставки отчётов в конфигурационных пакетах.

## Практические правила

- Для печатной формы раздела ищите `SysModuleReport`, а не `Report`.
- Для Word template смотрите `SysModuleReport.File`.
- Для FastReport смотрите `SysReportSchemaUId` и `FastReportTemplate`.
- Для проблем формата проверяйте `SysAllowedReportFormat`.
- Для долговременного хранения результата используйте `StoredReport`, для разовой загрузки — session key.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports Word](reports-word.md)
- [Reports FastReport](reports-fastreport.md)
- [File schema model](file-schema-model.md)
