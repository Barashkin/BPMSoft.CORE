# Email Template Storage

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EmailTemplate, EmailTemplateLang, ContentBlock, files -->

> Хранение email-шаблонов, переводов, content blocks, файлов и событий схемы.

## EmailTemplate

`EmailTemplateSchema.EmailTemplate.cs` расширяет базовую схему `EmailTemplate`.

Дополнительные поля:

| Поле | Назначение |
| ---- | ---------- |
| `ConfigType` | тип конфигурации builder |
| `PreviewImage` | изображение предпросмотра |

`TemplateConfig` помечен как non-localizable general column, поэтому
мультиязычное содержимое хранится отдельно.

## Entity events

`EmailTemplate` бросает embedded process events:

- `EmailTemplateDeleted`;
- `EmailTemplateValidating`.

Эти события являются точками расширения для бизнес-валидации и очистки связанных
данных.

## EmailTemplateLang

`EmailTemplateLang` хранит переводы шаблона. `EmailTemplateStore` читает
перевод по `EmailTemplate` и `Language`. Если перевод для языка не найден,
store возвращает шаблон на языке из системной настройки `DefaultMessageLanguage`.

## Template loader

`ITemplateLoader` задаёт контракт:

- `GetTemplate(id)`;
- `GetTemplate(id, languageId)`.

`EmailTemplateLanguageHandler` использует chain-of-responsibility подход при
выборе языка и loader.

## Files and content blocks

Связанные схемы:

| Схема | Назначение |
| ----- | ---------- |
| `EmailTemplateFile` | файлы шаблона письма |
| `EmailTemplateMacros` | связь шаблона с макросами |
| `ContentBlock` | библиотека content blocks |
| `ContentBlockFile` | файлы content block |
| `ContentBlockTag` | теги blocks |
| `ContentBlockInTag` | связь block/tag |
| `ContentUserBlock` | пользовательские blocks |

## Card UI

`EmailTemplatePageV2`:

- сохраняет новую/изменённую запись перед открытием builder;
- открывает ContentBuilder в новом окне;
- показывает `BodyToDisplay` в iframe;
- фильтрует `Object` по `ManagerName = EntitySchemaManager` и непустому caption.

## Практические правила

- Не храните переводы в основной `EmailTemplate.Body`.
- Для новых языков используйте `EmailTemplateLang`.
- Для preview обновляйте `PreviewImage`, а не встраивайте картинку в name/body.
- Валидацию шаблона подключайте через `EmailTemplateValidating`.
- Файлы шаблона храните в `EmailTemplateFile`.

## Связанные документы

- [Content email templates overview](content-email-templates-overview.md)
- [Email template multilang macros](email-template-multilang-macros.md)
- [Entity Schema Overview](entity-schema-overview.md)
- [File Storage Overview](file-overview.md)
