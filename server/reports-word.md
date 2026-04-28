# Reports Word

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Word reports, IReportGenerator, SysModuleReport, MERGEFIELD, WordPrintablePage -->

> MS Word печатные формы: шаблон `.docx`, `IReportGenerator("Word")`, макросы и PDF-конвертация.

## Где хранится шаблон

Word printable регистрируется в `SysModuleReport`. Для Word важны:

- `File` — файл шаблона;
- `FileName`;
- `Caption`;
- `SysModule`;
- `ShowInCard`;
- `ShowInSection`;
- `ConvertInPDF`;
- `MacrosList` / `MacrosSettings`.

## Генератор

`WordReportGenerator` зарегистрирован как `IReportGenerator` с именем `Word`.

```csharp
var reportGenerator = ClassFactory.Get<IReportGenerator>("Word");
var configuration = new ReportGeneratorConfiguration {
    RecordId = recordId,
    ReportTemplateId = templateId
};
ReportData reportData = reportGenerator.Generate(UserConnection, configuration);
```

## Макросы

Шаблон Word использует `MERGEFIELD` поля. Для табличных частей и сложных связей metadata хранится в `SysModuleReportTable`, `MacrosList` и `MacrosSettings`.

В новых сценариях учитывайте feature `Use7xFiltersForWordReports`: она меняет формат хранения и применения фильтров.

## PDF conversion

Если `ConvertInPDF = true`, Word output может быть сконвертирован в PDF.

```csharp
if (convertInPdf) {
    reportData.Data = pdfConverter.Convert(reportData.Data);
    reportData.Format = "pdf";
}
```

## WordPrintablePage

`WordPrintablePage.WordReporting.js` — client page для настройки Word printable. Она:

- управляет `macrosList` / `macrosSettings`;
- загружает `.docx` через `ConfigurationFileApi`;
- валидирует размер через `FileImportMaxFileSize`;
- поддерживает drag-and-drop;
- открывает tabular parts editor.

## WordReportingDesignService

Серверный design-контур отвечает за операции редактирования шаблонов и фильтров. Для конвертации фильтров используется `EntityFilterConverterService.WordReporting.cs`.

## Практические правила

- Для Word-шаблонов храните файл в `SysModuleReport.File`.
- Не редактируйте `MacrosSettings` вручную без понимания версии формата.
- Для PDF проверяйте `ConvertInPDF` и наличие converter binding.
- Для больших шаблонов учитывайте `FileImportMaxFileSize`, а не только `MaxFileSize`.
- Если отчёт не появляется в меню, проверьте `ShowInCard`, `ShowInSection`, `SysModule` и тип `MS Word`.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports templates storage](reports-templates-storage.md)
- [Reports client print UI](reports-client-print-ui.md)
- [File upload download](file-upload-download.md)
