# Administration Configuration Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: administration, troubleshooting, SysSettings, workplace, rights -->

> Диагностика проблем администрирования: роли, настройки, справочники, рабочие
> места, секции, пакеты и features.

## Пользователь не может выполнить admin-действие

Проверьте:

- operation right `CanManageAdministration`;
- членство пользователя в нужных ролях;
- актуальность `SysAdminUnitInRole`;
- ошибки `SecurityException` в сервисном ответе;
- лицензии, если действие связано с лицензируемой функцией.

Точки входа:

- `AdministrationService.UIv2.cs`;
- `SysAdminOperationGranteeSchema.Base.cs`;
- `SysAdminUnitInRoleSchema.Base.cs`.

## Роль удаляется не полностью

Проверьте:

- дочерние роли через `GetChildAdminUnits`;
- пользователей через `GetChildAdminUnitsAndUsersCount`;
- `ParentRole`;
- связи `SysAdminUnitInRole`;
- привязки к workplace.

После массовых изменений используйте actualize.

## Настройка не применяется

Проверьте:

- `Code` настройки;
- `SysSettingsValue`;
- `IsPersonal`;
- `IsCacheable`;
- права в `SysSettingsRights`;
- startup script в `ConfigurationSectionHelper`, если настройка влияет на UI.

Для счетчиков проверьте `GlobalAppSettings.UseDBSequence`.

## Справочник не открывается или открывается не той страницей

Проверьте:

- `SysLookup.SysEntitySchemaUId`;
- `SysEditPageSchemaUId`;
- `SysGridPageSchemaUId`;
- `IsSimple`;
- наличие схемы и клиентского модуля.

Точки входа:

- `SysLookupSchema.Base.cs`;
- `LookupManager.UIv2.js`;
- `BaseLookupConfigurationSection.UIv2.js`.

## Секция не видна в рабочем месте

Проверьте:

- запись `SysWorkplace`;
- `SysModuleInWorkplace`;
- `SysAdminUnitInWorkplace`;
- `SysApplicationClientType`;
- позиции в рабочем месте;
- cache рабочего места.

Если секция видна, но не открывается, переходите к `SysModule`.

## Секция не открывается

Проверьте:

- `SysModule.SectionModuleSchemaUId`;
- `SysModule.SectionSchemaUId`;
- `SysModule.CardSchemaUId`;
- `SysModule.CardModuleUId`;
- `SysModuleEdit`;
- LCZ-записи для caption/page caption;
- ошибки из `SectionExceptionResources`.

Точка входа: `ConfigurationSectionHelper.NUI.cs`.

## Feature включена, но поведение не меняется

Проверьте:

- `FeatureService.GetFeatureState`;
- запись для текущего пользователя;
- запись для группы `AllEmployers`;
- `ActualState` в `FeatureInfo`;
- кеширование feature states;
- что код действительно проверяет нужный feature code.

## Пакет не переносится или заблокирован

Проверьте:

- `SysPackage.IsLocked`;
- `SysPackage.IsChanged`;
- `InstallType`;
- `SysPackageDependency`;
- `SysPackageHierarchy`;
- `RepositoryRevisionNumber`;
- `ProjectPath`.

Для визуального анализа используйте package dependencies diagram.

## Лицензия не работает

Проверьте:

- `SysLic`;
- `SysLicPackage`;
- `SysLicUser`;
- `VwExpiringLicense`;
- admin API в `AdministrationServiceLicenses.UIv2.cs`;
- соответствие роли и лицензии.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Administration pattern catalog](admin-pattern-catalog.md)
- [Security troubleshooting](security-troubleshooting.md)
