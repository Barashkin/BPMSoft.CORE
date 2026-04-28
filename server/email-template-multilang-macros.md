# Email Template Multilang And Macros

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EmailTemplateLang, MLangContent, macros, LanguageTabMixin -->

> Мультиязычные email-шаблоны и подстановка макросов в процессах и UI.

## Multilingual builder

`MultiLanguageEmailContentBuilder` добавляет `LanguageTabMixin` и управляет:

- `Languages`;
- `MenuLanguageCollection`;
- `ActiveLanguageTabName`;
- `ActiveLanguageId`;
- `SysLanguage`;
- `MultilingualEntitySchemaName = EmailTemplateLang`;
- `MultilingualConnectionColumnName = EmailTemplate`.

В header добавляется tab panel языков. Основной язык берётся из
`BPMSoft.SysValue.PRIMARY_LANGUAGE`.

## MLang schemas

Ключевые схемы:

- `EmailTemplateLang`;
- `VirtualEmailTplContent`;
- `EmailMLangContentEditSchema`;
- `BaseMLangContentEditSchema`;
- `MLangContentContainerModule`.

`VirtualEmailTplContent` используется как агрегированное представление для
редактирования контента.

## Template store fallback

`EmailTemplateStore.GetTemplate(emailTemplateId, languageId)` сначала ищет
перевод для выбранного языка. Если его нет, возвращает default language из
`DefaultMessageLanguage`.

Если id шаблона или языка пустой, выбрасывается `ArgumentException` с
локализованным сообщением.

## Process macros helper

`EmailTemplateUserTaskMacrosHelper` наследует `BaseEmailUserTaskMacrosHelper`.

Особенности:

- worker id `E6281614-F65B-448C-BAB0-5B1C88D3A380`;
- для `SendEmailType.Auto` возвращает raw macros value;
- добавляет user task в arguments, если найдены process email macros;
- `RecipientEntityMacrosWorker` читает параметры process user task.

## RecipientEntityMacrosWorker

Worker:

- ищет параметр по alias макроса;
- получает значение параметра user task;
- для lookup-параметров подставляет display value записи;
- пишет диагностические сообщения через `MacrosLoggerHelper`.

## Image macros

`ImageMacroListItemViewModel.ContentBuilder.js` покрывает macro items для
изображений. Для таких макросов важно различать встраивание content и URL.

## Практические правила

- Для текста и темы используйте языковые записи `EmailTemplateLang`.
- Не полагайтесь на наличие перевода: всегда учитывайте default fallback.
- Alias макроса должен совпадать с параметром process user task.
- Для lookup macros ожидайте display value, а не raw id.
- При проблемах с макросами проверяйте `MacrosHelperV2` logs.

## Связанные документы

- [Content email templates overview](content-email-templates-overview.md)
- [Email template process sending](email-template-process-sending.md)
- [Process user tasks](process-user-tasks.md)
- [Activity email sending](activity-email-sending.md)
