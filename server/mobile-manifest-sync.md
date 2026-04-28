# Mobile Manifest And Sync

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Mobile, manifest, SyncOptions, ModelDataImportConfig -->

> Манифест мобильного приложения: features, modules, custom schemas,
> syssettings/lookups import и настройка offline sync.

## Base manifest

`MobileApplicationBaseManifest.Mobile.js` задаёт общий каркас приложения:

- `Features`;
- `UseOptimisticEditing`;
- `UseUTC`;
- `ModuleGroups`;
- `DefaultModuleImageId`;
- `CustomSchemas`;
- `SyncOptions`;
- `Modules`.

`CustomSchemas` подключает инфраструктурные мобильные модули: utilities,
dashboard, service helper, push receiver, local notifications, file controllers
и mobile actions.

## Feature blocks

`Features` включают дополнительные схемы и модели. Примерные блоки:

| Feature | Что добавляет |
| ------- | ------------- |
| `UseMobileCallerId` | dialing codes и employee данные |
| `UseMobileFolders` | folder models и stores |
| `UseMobileDynamicLink` | receiver для deep links |
| `UseMobileSummaries` | summary data |

Feature может содержать `CustomSchemas`, `SyncOptions` и
`ApplicationRequiredModels`.

## SyncOptions

Ключевые настройки синхронизации:

| Настройка | Назначение |
| --------- | ---------- |
| `ImportPageSize` | размер страницы импорта |
| `PagesInImportTransaction` | число страниц в транзакции |
| `UseBatchExport` | batch export изменений |
| `UseSkipToken` | skip token для paging |
| `SysSettingsImportConfig` | системные настройки для клиента |
| `SysLookupsImportConfig` | справочники для offline |
| `ModelDataImportConfig` | модели, фильтры и колонки |

## ModelDataImportConfig

Каждая запись описывает модель синхронизации:

- `Name`;
- `SyncFilter`;
- `QueryFilter`;
- `RequiredDataFilter`;
- `SyncColumns`;
- `ExpandLookups`;
- `SyncByParentObjectWithRights`;
- `HistoricalColumns`.

`SyncFilter` — компактный фильтр mobile SDK. `QueryFilter` повторяет структуру
серверных фильтров и поддерживает macros вроде current user contact.

## Default workplace manifest

`MobileApplicationManifestDefaultWorkplace.Mobile.js` расширяет base manifest и
добавляет синхронизацию Activity, Contact, Account и связанных details.

Показательные паттерны:

- Activity синхронизируется по участникам;
- ActivityParticipant синхронизируется через parent `Activity`;
- Contact details используют `SyncByParentObjectWithRights`;
- SysImage фильтруется по `HasRef`;
- lookup columns ограничиваются через `SyncColumns`.

## Portal manifest

`MobileApplicationManifestPortal.SSP.js` показывает SSP/portal вариант:
меньше features, отдельный набор syssettings и push/local notification контур.

## Практические правила

- Добавляйте модель в manifest только вместе с sync-фильтрами и колонками.
- Для details используйте `SyncByParentObjectWithRights`.
- Не тяните все lookup columns без необходимости.
- Для user-specific данных используйте macros current user/current contact.
- Сначала расширяйте workplace manifest, а не base manifest.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile offline cache](mobile-offline-cache.md)
- [Mobile workplaces security](mobile-workplaces-security.md)
- [ESQ filters](esq-filters.md)
