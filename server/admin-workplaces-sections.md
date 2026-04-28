# Workplaces Sections And Navigation

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysWorkplace, SysModule, sections, navigation, workplace, NUI -->

> Рабочие места и секции: от `SysWorkplace` и `SysModule` до загрузки
> клиентской конфигурации.
> Server endpoints и cache-сценарии NUI вынесены в
> [nui-configuration-workplace.md](nui-configuration-workplace.md).

## SysWorkplace

`SysWorkplace` описывает рабочее место. Схема наследуется от
`BaseEntityWithPositionSchema`.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `Name` | локализуемое имя |
| `IsPersonal` | персональное рабочее место |
| `LoaderId` | loader |
| `SysApplicationClientType` | тип клиента |
| `Type` | тип рабочего места |
| `SysWorkplaceParent` | родительское рабочее место |
| `SysImage` | иконка |

Связи:

- `SysModuleInWorkplace` — секции внутри рабочего места;
- `SysAdminUnitInWorkplace` — доступ ролей/пользователей;
- `SysWorkplacePageV2.UIv2.js` и `SysWorkplaceSectionV2.UIv2.js` — UI.

## SysModule

`SysModule` описывает секцию.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `Caption` | имя секции |
| `SysModuleEntity` | сущность секции |
| `Image16`/`Image20`/`Image32` | иконки |
| `FolderMode` | режим папок |
| `GlobalSearchAvailable` | участие в глобальном поиске |
| `HasAnalytics` | аналитика в секции |
| `HasActions` | действия |
| `HasRecent` | recent records |
| `Code` | код |
| `SectionModuleSchemaUId` | модуль секции |
| `SectionSchemaUId` | section schema |
| `CardSchemaUId` | карточка |
| `CardModuleUId` | card module |
| `IsSystem` | системная секция |

## ConfigurationSectionHelper

`ConfigurationSectionHelper.NUI.cs` реализует `ISectionHelper` и участвует в
первичной загрузке конфигурации.

Ключевые функции:

- строит select по `SysModule`;
- подключает `SysModuleInWorkplace` или `SysModuleInSysModuleFolder`;
- читает локализацию через LCZ-схемы;
- добавляет `SysModuleEdit`, `SysModuleEntity`, `SysModuleVisa`;
- сортирует секции по позиции в рабочем месте;
- добавляет startup scripts с системными настройками;
- использует cache keys для рабочего места и login local cache.

## Services

Навигационный контур включает:

- `WorkplaceService.NUI.cs`;
- `NavigationService.Workplace.cs`;
- `SectionService.Workplace.cs`;
- `ConfigurationSectionHelper.NUI.cs`.

## Практические правила

- Если секция не видна, проверяйте `SysModuleInWorkplace` и
  `SysAdminUnitInWorkplace`.
- Если секция открывается без заголовков, проверяйте LCZ-записи.
- Для глобального поиска нужен `GlobalSearchAvailable`.
- Для карточек проверяйте `CardSchemaUId`, `CardModuleUId` и `SysModuleEdit`.
- При странностях после изменения рабочих мест очищайте relevant cache.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [SysSettings and lookups](admin-syssettings-lookups.md)
- [Configuration packages](admin-packages-configuration.md)
- [ESQ overview](esq-overview.md)
- [NUI Configuration Workplace](nui-configuration-workplace.md)
