# Reports Async Generation

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: async reports, PDF, ReportCallbackService, notification, File Converter -->

> Асинхронная генерация отчётов: очередь задач, PDF conversion callback и уведомление пользователя.

## Когда нужен async flow

Async flow используется, когда отчёт или PDF-конвертация может выполняться дольше обычного request-response сценария.

Основные причины:

- большой объём данных;
- много записей;
- PDF conversion через внешний file converter;
- необходимость уведомить пользователя после завершения.

## Компоненты

| Компонент | Назначение |
| --------- | ---------- |
| `BaseAsyncReportGenerator` | готовит report и запускает conversion |
| `AsyncReportGenerationService` | создаёт задачи и хранит их в cache/store |
| `BaseAsyncReportGenerationController` | управляет callback URL и выдачей файла |
| `PdfAsyncReportGenerationController` | binding для PDF |
| `ReportCallbackService` | принимает callback завершения |
| `ReportGenerationCompletionNotificationSender` | отправляет уведомление пользователю |

## Общий поток

1. Клиент запускает async generation.
2. Сервер создаёт `UserReportGenerationTask`.
3. Report generator готовит исходный файл.
4. File Converter получает callback URL.
5. `ReportCallbackService` принимает уведомление.
6. Состояние задачи обновляется в cache.
7. Пользователь получает popup/notification.
8. Клиент скачивает готовый файл.

## Client behavior

`PrintReportUtilities` сохраняет timeout id в `ReportStorage` и показывает popup, если отчёт не готов быстро.

```javascript
const timeoutId = setTimeout(function() {
    this._showPopup(resources.localizableStrings.AsynGenerationPopupBody);
}.bind(this), this.asyncReportDownloadTimeout);
```

## Практические правила

- Не блокируйте UI долгим синхронным скачиванием.
- Для PDF conversion проверяйте callback URL и доступность converter service.
- Привязывайте задачу к пользователю, иначе уведомление уйдёт не тому получателю.
- После завершения очищайте temporary state.
- Для диагностики смотрите и server logs, и client `ReportStorage`.

## Связанные документы

- [Reports overview](reports-overview.md)
- [Reports client print UI](reports-client-print-ui.md)
- [Reports troubleshooting](reports-troubleshooting.md)
