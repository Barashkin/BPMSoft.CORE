# Reports Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: reports troubleshooting, printables, Word, FastReport, PDF -->

> Практическая диагностика отчётов, печатных форм, шаблонов и скачивания.

## Отчёт не виден в меню печати

Проверьте:

- запись `SysModuleReport`;
- привязку `SysModule`;
- тип `MS Word` или поддерживаемый custom type;
- `ShowInCard` / `ShowInSection`;
- права на `SysModuleReport`;
- client cache print forms.

## Word отчёт не генерируется

Проверьте:

- `SysModuleReport.File` заполнен;
- `FileName` соответствует template;
- `RecordId` передаётся корректно;
- macros в документе совпадают с metadata;
- `Use7xFiltersForWordReports` соответствует формату `MacrosSettings`;
- PDF converter доступен, если `ConvertInPDF = true`.

## FastReport возвращает ошибку

Проверьте:

- `SysReportSchemaUId` у `SysModuleReport`;
- запись `FastReportTemplate`;
- поле `FastReportTemplate.Data`;
- data sources в `FastReportDataSource`;
- custom data provider registration;
- XML template без внешних DTD/entities;
- наличие нужных шрифтов на сервере.

## Скачивание не работает после генерации

Проверьте:

- key вида `ReportCacheKey_*`;
- что `GetReportFile/{key}` вызывается в той же user session;
- что файл не был уже скачан и удалён из `SessionData`;
- timeout на клиенте;
- размер ответа и reverse proxy limits.

## Неверный формат файла

Проверьте:

- `ConvertInPDF`;
- `SysAllowedReportFormat`;
- параметр `format` в `ReportService.CreateReport`;
- наличие PDF converter binding;
- client caption extension.

## Пустой или неполный отчёт

Проверьте:

- ESQ filters;
- права пользователя на записи и колонки;
- `UseAdminRights` в кастомном provider;
- tabular part filters;
- custom data source output.

## Ошибка загрузки Word-шаблона

Проверьте:

- `FileImportMaxFileSize`;
- MIME/extension `.docx`;
- корректность `ConfigurationFileApi` payload;
- file column в `SysModuleReport`;
- client dropzone errors.

## Async отчёт не приходит

Проверьте:

- task id в client `ReportStorage`;
- callback URL `ReportCallbackService.svc/Notify`;
- доступность file converter;
- application cache/store;
- notification sender;
- user binding у generation task.

## Экспорт запрещён

Проверьте operation right `CanExportGrid`. Для кастомного массового экспорта добавьте явную проверку операции и понятное сообщение об ошибке.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports security limits](reports-security-limits.md)
- [Reports pattern catalog](reports-pattern-catalog.md)
