# Content Template Security And Limits

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ContentBuilder security, XSS, files, macros, rights -->

> Безопасность шаблонов: HTML sanitize, макросы, права на файлы и отправку.

## HTML sanitize

`MjmlContentExporter.sanitizeHTML` защищает результат экспорта от XSS:

- вызывает `BPMSoft.utils.html.sanitizeHTML`;
- работает с DOM template;
- отдельно обрабатывает comment/style nodes;
- возвращает safe `innerHTML`.

Не отключайте sanitize для HTML, который попадает в email body или preview iframe.

## Minification

Feature `MinifyEmailHtml` включает MJML minification. Она уменьшает HTML, но
может влиять на отображение письма в почтовых клиентах. Проверяйте результат в
основных клиентах перед включением.

## Macro safety

Макросы могут читать параметры процесса и связанные записи. Риски:

- alias не найден;
- lookup id не превращается в display value;
- параметр пустой;
- worker не получил `EmailTemplateUserTask`;
- macro раскрывает данные, недоступные получателю письма.

Для чувствительных данных проверяйте источник и аудит отправки.

## File rights

`EmailTemplateUserTask` читает вложения через `EntityFileLocator`.

В file storage режиме `IFileFactory` создаётся с `WithRightsDisabled`. Это нужно
для системной отправки, но требует аккуратной настройки процесса: пользователь не
должен получить вложение, которое бизнес-логика не разрешает отправлять.

## Template validation

`EmailTemplateValidating` — точка для проверки:

- обязательных полей;
- корректности `Object`;
- непустого body/config;
- допустимых macros;
- ограничений по вложениям и изображениям.

## Service boundary

`EmailSendService.Send` работает по `ActivityId`. Клиент должен передавать id
существующей email activity и корректно обрабатывать `EmailSendStatus`.

## Практические правила

- Не сохраняйте raw HTML без sanitize/export pipeline.
- Проверяйте empty template до сохранения.
- Для attachments задавайте явную бизнес-проверку доступности.
- Не используйте system context для генерации персональных данных без причины.
- Логируйте macro failures с alias и источником.

## Связанные документы

- [Content builder export](content-builder-export.md)
- [Email template process sending](email-template-process-sending.md)
- [Security/Rights Overview](security-overview.md)
- [File security limits](file-security-limits.md)
