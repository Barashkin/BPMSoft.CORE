# Reports Client Print UI

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: PrintReportUtilities, ReportUtilities, ReportEngineClient, FastReportService JS -->

> Клиентский контур печати: меню печатных форм, вызовы сервисов и скачивание файлов.

## PrintReportUtilities

`PrintReportUtilities.NUI.js` — основной mixin для карточек и секций.

Ключевые коллекции:

| Коллекция | Назначение |
| --------- | ---------- |
| `ReportGridData` | данные отчётов модуля |
| `CardPrintMenuItems` | меню печати карточки |
| `SectionPrintMenuItems` | меню печати секции |
| `allowedReportFormatsMenuItems` | доступные форматы |

`BasePrintFormViewModel` вычисляет caption файла и различает DevExpress/Word.

## Загрузка меню

`getModulePrintFormsESQ()` читает `SysModuleReport`, фильтруя по entity schema, типам отчётов и признакам показа.

Основные признаки:

- `ShowInCard`;
- `ShowInSection`;
- `Type.Name`;
- `ConvertInPDF`;
- `SysReportSchemaUId`.

## ReportUtilities

`ReportUtilities` вызывает legacy `ReportService`:

- `CreateReport`;
- `CreateReportsList`;
- `GetReportFile/{key}`;
- export to Excel methods.

Это основной путь для классических Word/DevExpress печатных форм из UI.

## ReportEngineClient

`ReportEngineClient.Reports.js` вызывает `ReportEngineService.GetReportTemplates` и нормализует результат в client collection.

Используйте его для сценариев, где нужен unified list templates, а не только menu print forms.

## FastReportService JS

`FastReportService.FastReport.js` вызывает FastReport endpoint:

- `CreateReport`;
- `GetReportFile/{key}`;
- template download/upload flows.

Он также обрабатывает часть ошибок генерации, включая проблемы со шрифтами.

## Async client flow

В `PrintReportUtilities` есть `_asyncGenerationCallback`: клиент получает task ids, показывает mask и popup, если генерация не завершилась быстро.

## Практические правила

- В секции и карточке не формируйте меню вручную, используйте `PrintReportUtilities`.
- Для отображения отчёта проверьте `ShowInCard` / `ShowInSection`.
- Для Word caption зависит от `ConvertInPDF`: `.docx` или `.pdf`.
- Для DevExpress caption всегда `.pdf` в базовой модели.
- Для долгой генерации используйте async flow и уведомления, а не синхронное ожидание.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports templates storage](reports-templates-storage.md)
- [Reports async generation](reports-async-generation.md)
- [Client service calls](../client/client-service-calls.md)
