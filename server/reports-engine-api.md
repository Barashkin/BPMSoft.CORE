# Reports Engine API

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: IReportEngine, ReportEngine, ReportSettings, ReportEngineService -->

> Унифицированный API генерации отчётов: `IReportEngine`, `ReportSettings`, `IReportResult`.

## Контракт

`IReportEngine` — единый server-side entry point для Word и FastReport.

```csharp
public interface IReportEngine
{
    IEnumerable<IReportResult> Generate(ReportSettings settings);
    IReadOnlyList<IReportTemplateInfo> GetReportTemplates();
}
```

`ReportSettings` содержит:

- `Id` — id отчёта;
- `Filters` — фильтры записей;
- `IsSeparateReports` — генерировать отдельный файл на каждую запись.

## ReportType

| Тип | Значение | Описание |
| --- | -------- | -------- |
| `MsWord` | 1 | Word report |
| `FastReport` | 2 | FastReport report |

`ReportEngine` мапит строковое имя типа из `SysModuleReport.Type.Name` на enum через `DescriptionAttribute`.

## Получение шаблонов

`ReportEngine.GetReportTemplates()` читает `SysModuleReport` через ESQ с `UseAdminRights = false`, чтобы учитывать права текущего пользователя.

Основные поля:

- `Caption`;
- `Type.Name`;
- `SysReportSchemaUId`;
- linked entity schema name;
- `ConvertInPDF`.

## Генерация Word

Для Word engine получает `IReportGenerator` по имени `Word`, генерирует отчёт для каждой записи из filters и при необходимости конвертирует в PDF.

```csharp
var configuration = new ReportGeneratorConfiguration {
    RecordId = recordId,
    ReportTemplateId = reportTemplateInfo.TemplateId
};
ReportData reportData = reportGenerator.Generate(_userConnection, configuration);
```

## Генерация FastReport

Для FastReport engine формирует `EsqFilters` и вызывает FastReport generator.

```csharp
var reportParameters = new Dictionary<string, object> {
    ["EsqFilters"] = new Dictionary<string, Filters> {
        [reportTemplateInfo.EntitySchemaName] = filters
    }
};
```

Результат FastReport всегда отдаётся как `.pdf`.

## ReportEngineService

`ReportEngineService` — WCF layer над engine. Сейчас он предоставляет `GetReportTemplates`, возвращая DTO с `id`, `caption`, `type`, `entitySchemaName`.

## Практические правила

- Для нового серверного кода предпочитайте `IReportEngine`.
- Для карточек/секций учитывайте, что список отчётов фильтруется по правам.
- Для массовой генерации используйте `IsSeparateReports` осознанно: это увеличивает нагрузку.
- Для Word результат может быть `.docx` или `.pdf`, для FastReport — `.pdf`.
- Не смешивайте `SysModuleReport.Id` и `SysReportSchemaUId`: для FastReport template id берётся из `SysReportSchemaUId`.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports Word](reports-word.md)
- [Reports FastReport](reports-fastreport.md)
- [Reports troubleshooting](reports-troubleshooting.md)
