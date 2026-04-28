# SysSettings And Lookups Administration

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysSettings, SysLookup, lookups, settings, administration -->

> Системные настройки и справочники: хранение, права, UI и сервисные сценарии.

## SysSettings

`SysSettings` наследуется от `BaseCodeLookupSchema`. Код настройки уникален:
схема создает индекс `IUSysSettingsCode`.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `Code` | код настройки |
| `ValueTypeName` | тип значения |
| `SysFolder` | папка настройки |
| `IsPersonal` | персональное значение |
| `IsCacheable` | кеширование |
| `ReferenceSchemaUId` | schema для lookup-значения |
| `IsSSPAvailable` | доступность для SSP |

Значения хранятся отдельно в `SysSettingsValue`. Права задаются через
`SysSettingsRights`, а события обрабатывает `SysSettingsRightsEventListener`.

## SysSettingsService

`SysSettingsService.NUI.cs` — небольшой service над
`BPMSoft.Core.Configuration.SysSettings`.

Методы:

- `GetIncrementValue(sysSettingName)` — читает текущее значение, увеличивает и
  сохраняет default value;
- `GetIncrementValueVsMask(sysSettingName, sysSettingMaskName)` — подставляет
  номер в маску;
- при `GlobalAppSettings.UseDBSequence` использует `SequenceMap`.

## Settings in boot scripts

`ConfigurationSectionHelper` добавляет часть настроек в стартовый клиентский
скрипт:

- `RequestsCachingTtl`;
- `RequestsCachingOptions`;
- `StringColumnSearchMinCharCount`;
- цвета section panel;
- hash изображений логотипов.

Это значит, что не все настройки читаются только через карточку или сервис:
часть попадает в runtime-конфигурацию при логине.

## Settings UI

Клиентские файлы:

- `SysSettingsSection.UIv2.js`;
- `SysSettingPage.UIv2.js`;
- `SysSettingPageCSS.UIv2.less`.

Для пользовательских настроек важно проверять тип значения, персональность,
права и кеширование.

## SysLookup

`SysLookup` описывает системный справочник и связь со схемой данных.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `SysFolder` | папка справочника |
| `IsSystem` | системный справочник |
| `IsSimple` | простой справочник |
| `SysEditPageSchemaUId` | карточка записи |
| `SysGridPageSchemaUId` | грид |
| `SysEntitySchemaUId` | entity schema справочника |

Клиентские точки:

- `LookupManager.UIv2.js`;
- `LookupSection.UIv2.js`;
- `BaseLookupConfigurationSection.UIv2.js`;
- `ConfigurationGridLookupUtilities.UIv2.js`.

## Практические правила

- Для системных настроек используйте `Code`, а не display name.
- Для инкрементов учитывайте `UseDBSequence`.
- Для lookup-значений проверяйте `ReferenceSchemaUId`.
- `IsCacheable` влияет на поведение после изменения значения.
- Для новых lookup metadata заполните entity schema и страницы редактирования.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Configuration packages](admin-packages-configuration.md)
- [Entity schema overview](entity-schema-overview.md)
- [Client module overview](../client/client-module-overview.md)
