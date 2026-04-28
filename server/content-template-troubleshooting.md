# Content Template Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ContentBuilder troubleshooting, EmailTemplate, macros, sending -->

> Диагностика ContentBuilder, email-шаблонов, мультиязычности, макросов и
> отправки писем.

## Builder не открывается

Проверьте:

- запись `EmailTemplate` сохранена;
- `ContentBuilderEnumsModule.ContentBuilderMode.EMAILTEMPLATE`;
- URL из `getContentBuilderUrl`;
- popup blockers браузера;
- наличие `RecordId`;
- доступ к карточке шаблона.

## Preview на карточке не обновляется

Проверьте:

- `ContentBuilderService.ReloadContent`;
- `senderName` равен режиму `EMAILTEMPLATE`;
- `ServerChannel` подписку в `EmailTemplatePageV2`;
- совпадает ли `recordId`;
- ESQ перечитывает колонку `Body`.

## Шаблон сохраняется пустым

Проверьте:

- `validateEmptyItems`;
- `config.Items`;
- legacy HTML conversion в `getHtmlBlockConfig`;
- `bodyConfig`;
- результат `ContentBuilderHelper.toJSON`.

## HTML выглядит некорректно

Проверьте:

- выбранный exporter по `ItemType`;
- MJML config после converter;
- feature `MinifyEmailHtml`;
- sanitize result;
- поддержку HTML конкретным почтовым клиентом.

## Перевод шаблона не найден

Проверьте:

- запись `EmailTemplateLang`;
- `Language`;
- `EmailTemplate`;
- syssetting `DefaultMessageLanguage`;
- fallback в `EmailTemplateStore`.

## Макрос не подставляется

Проверьте:

- alias макроса;
- параметр process user task с таким именем;
- worker id `E6281614-F65B-448C-BAB0-5B1C88D3A380`;
- `SendEmailType`;
- logs `MacrosHelperV2`;
- lookup display value.

## Вложения не попали в письмо

Проверьте:

- feature `UseProcessEmailAttachments`;
- `EntityFileLocator`;
- file storage mode;
- наличие `ActivityFile`;
- доступность source file;
- `FeatureUseFileStorageInProcessUserTasks`.

## Email не отправляется

Проверьте:

- `ActivityId`;
- `EmailSendService.Send`;
- `EmailException.EmailSendStatus`;
- запись `EmailSendStatus` по code;
- mailbox/sender settings;
- `HasFollowingProcessElement`.

## Content blocks или картинки не работают

Проверьте:

- `ContentBlock`;
- `ContentBlockFile`;
- tags block library;
- image macro mode: embedded content или URL;
- sanitize не удаляет нужный HTML.

## Связанные документы

- [Content email templates overview](content-email-templates-overview.md)
- [Content builder export](content-builder-export.md)
- [Email template multilang macros](email-template-multilang-macros.md)
- [Email template process sending](email-template-process-sending.md)
