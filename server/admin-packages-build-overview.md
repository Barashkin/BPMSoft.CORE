# Admin Packages Build Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Administration, packages, configuration, compilation, SysPackage, SysSchema -->

> Capstone dive по пакетам, configuration metadata и сборке. Документ связывает
> `SysPackage`, `SysSchema`, configuration UI, installed apps и build pipeline.

## Когда открывать

| Задача | Где смотреть |
| ------ | ------------ |
| Понять, где лежит пакет и его зависимости | `SysPackage`, `SysPackageDependency`, `SysPackageHierarchy` |
| Найти схему в пакете | `SysSchema`, `VwSysSchemaInPackage`, `VwSysSchemaInWorkspace` |
| Разобрать установленные приложения | `SysInstalledApp`, `SysPackageInInstalledApp` |
| Диагностировать сборку конфигурации | `WorkspaceBuilderUtility`, `IAppConfigurationBuilder.BuildChanged` |
| Понять артефакты доставки | `SysPackageSqlScript`, `SysPackageSchemaData`, `SysPackageReferenceAssembly` |

## Основные слои

| Слой | Назначение |
| ---- | ---------- |
| Package metadata | `SysPackage`, dependencies, hierarchy, install type |
| Schema registry | `SysSchema`, content/properties, views by package/workspace |
| Delivery artifacts | SQL scripts, schema data, reference assemblies, checksums |
| Installed apps | связь marketplace/application level с пакетами workspace |
| Build pipeline | сборка changed configuration и уведомления о результате |

## Package metadata

`SysPackage` наследуется от lookup-подобной схемы, но по смыслу это metadata
единицы поставки. Важные связанные схемы:

- `SysPackageDependency` - зависимости между пакетами;
- `SysPackageHierarchy` - вычисленная/материализованная иерархия;
- `SysPackageInstallType` - value list типа установки;
- `SysPackageInInstalledApp` - связь пакета с установленным приложением.

Зависимости должны рассматриваться как граф. Порядок package layers влияет на
замещения, имя файла `{Class}.{Package}.ext` и итоговую композицию схем.

## Schema registry

`SysSchema` - реестр схем конфигурации. Это не runtime entity schema instance,
а metadata-запись о схеме в workspace/package.

Типичные оси поиска:

| Поле/связь | Как использовать |
| ---------- | ---------------- |
| `Name` | имя схемы/класса |
| `ManagerName` | `EntitySchemaManager`, `ClientUnitSchemaManager`, process/schema managers |
| `SysPackage` | пакет-владелец |
| `UId` | стабильный идентификатор схемы |

Связанные сущности `SysSchemaContent` и `SysSchemaProperty` хранят содержимое и
metadata properties. Для пользовательской навигации удобнее views
`VwSysSchemaInPackage` и `VwSysSchemaInWorkspace`.

## Build pipeline

В Base видны точки входа в platform builder, а не полная реализация компилятора.
Типовой поток:

```text
Client wizard / configuration UI
  -> BPMSoft.SchemaDesignerUtilities.buildChangedConfiguration
  -> WorkspaceBuilderUtility / IAppConfigurationBuilder.BuildChanged
  -> compiler errors or success
  -> ServerChannel / ConfigurationBuildCompleted
  -> dependent listeners, for example Global Search watcher
```

Практические source files:

- `ApplicationStructureItemWizard.Wizards.js`;
- `VwWorkspaceObjectsSchema.Base.cs`;
- `VwAdministrativeObjectsSchema.Base.cs`;
- `ColumnService.NUI.cs`;
- `GlobalSearchEventListener.GlobalSearch.cs`.

## Delivery artifacts

| Схема | Назначение |
| ----- | ---------- |
| `SysPackageSqlScript` | SQL scripts пакета |
| `SysPackageSchemaData` | data bindings/schema data |
| `SysPackageSchemaDataColumn` | колонки data binding |
| `SysPackageReferenceAssembly` | reference assemblies |
| `SysPackageResourceChecksum` | checksum ресурсов пакета |

Эти артефакты относятся к доставке и установке, а не к обычному runtime CRUD.

## Boundaries

| Не путать | Граница |
| --------- | ------- |
| `SysPackage` vs business lookup | package metadata управляет конфигурацией, не бизнес-данными |
| `SysSchema` vs generated `*Schema.cs` | `SysSchema` - registry metadata, generated file - C#/JS source |
| Build pipeline vs Quartz | сборка конфигурации не является обычной фоновой job |
| Configuration UI vs runtime NUI shell | админка пакетов не равна `ConfigurationDataService` для workplace shell |
| Installed apps vs packages | installed app группирует/доставляет пакеты, но не заменяет package graph |

## Troubleshooting

| Симптом | Проверить |
| ------- | --------- |
| Схема не видна после изменения | package owner, `SysSchema`, build changed configuration |
| Ошибка компиляции после правки | compiler output, зависимости пакета, reference assemblies |
| Замещение не применяется | package order, `{Class}.{Package}.ext`, `ExtendParent`/replacement metadata |
| Данные пакета не перенеслись | `SysPackageSchemaData`, колонки binding, install type |
| После сборки не обновился поиск | `ConfigurationBuildCompleted`, Global Search listener |

## Связанные документы

- [Administration And Configuration Overview](admin-configuration-overview.md)
- [Administration Packages Configuration](admin-packages-configuration.md)
- [Entity Schema Overview](entity-schema-overview.md)
- [Naming Conventions](../architecture/naming-conventions.md)
- [Global Search Indexing](global-search-indexing.md)
