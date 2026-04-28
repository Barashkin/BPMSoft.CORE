# Packages And Configuration Administration

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysPackage, configuration, packages, dependencies -->

> Пакеты и configuration UI: `SysPackage`, зависимости, тип установки и
> клиентские утилиты конфигурации.

## SysPackage

`SysPackage` наследуется от `BaseLookupSchema`, но является не обычным
справочником, а метаданными пакета конфигурации.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `Name` | имя пакета |
| `SysWorkspace` | workspace |
| `UId` | уникальный идентификатор пакета |
| `Version` | версия |
| `Maintainer` | владелец/поставщик |
| `Essential` | системная важность |
| `Annotation` | описание |
| `IsChanged` | изменен |
| `IsLocked` | заблокирован |
| `InstallType` | тип установки |
| `RepositoryRevisionNumber` | ревизия репозитория |
| `SysRepository` | репозиторий |
| `Type` | тип пакета |
| `ProjectPath` | путь проекта |

`Name` и `Description` у пакета не локализуются.

## Dependencies

Ключевые схемы:

- `SysPackageHierarchy` — иерархия пакетов;
- `SysPackageDependency` — зависимости;
- `VwSysPackages` — представление пакетов;
- `VwSysSchemaInPackage` — схемы внутри пакета.

## Install type

`SysPackageInstallType.Base.cs` показывает паттерн fixed values:

- `ValueListSchema`;
- `Items`;
- enum в том же файле.

Значения:

- `SourceCode`;
- `Repository`.

Это не lookup-таблица, а value list schema.

## Configuration UI

Клиентские точки:

- `ConfigurationModuleV2.NUI.js`;
- `ConfigurationViewModule.NUI.js`;
- `ConfigurationGrid.UIv2.js`;
- `ConfigurationGridUtilities.UIv2.js`;
- `ConfigurationGridUtilitiesV2.UIv2.js`;
- `ConfigurationItemGenerator.UIv2.js`;
- `PackageUtilities.Managers.js`;
- `PackageDependenciesDiagramModule.Base.js`.

## Configuration services and helpers

Серверные точки:

- `ConfigurationDataService.NUI.cs`;
- `ConfigurationSectionHelper.NUI.cs`;
- `ConfigurationTools.Base.cs`;
- `ConfigurationServiceResponse.Base.cs`;
- `ICustomConfigurationScriptBuilder.Base.cs`.

Доменные пакеты могут добавлять собственные builders, например:

- `DeduplicationConfigurationScriptBuilder.Deduplication.cs`;
- `MLConfigurationScriptBuilder.ML.cs`;

## Практические правила

- Для анализа пакета смотрите `SysPackage`, dependency schemas и `VwSysSchemaInPackage`.
- Для fixed enum используйте `ValueListSchema`, а не lookup.
- Для UI зависимостей используйте diagram module, а не ручную выборку.
- Не смешивайте runtime syssettings и package metadata.
- Перед переносом проверяйте `IsLocked`, `IsChanged`, `InstallType`.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Workplaces sections](admin-workplaces-sections.md)
- [Entity schema overview](entity-schema-overview.md)
- [Services overview](services-overview.md)
