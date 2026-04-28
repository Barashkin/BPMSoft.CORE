# Admin Features Settings System Designer Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Administration, FeatureService, SysSettings, SystemDesigner, SysAdminOperation -->

> Capstone dive по feature flags, системным настройкам и System Designer.
> Документ показывает, какой механизм за что отвечает и где проходит граница с
> правами безопасности.

## Три разных механизма

| Механизм | Для чего | Ключевые source files |
| -------- | -------- | --------------------- |
| Feature flags | включить/выключить возможность для пользователя или admin unit | `FeatureService.Base.cs`, `FeatureServiceRequest.NUI.js` |
| SysSettings | хранить конфигурационные значения платформы/пакетов | `SysSettingsSchema.Base.cs`, `SysSettingsValueSchema.Base.cs`, `SysSettingsService.NUI.cs` |
| System Designer | UI-навигация к админским разделам и плиткам | `SystemDesigner.UIv2.js`, `*SystemDesignerSectionV2.UIv2.js` |

## Feature flags

`FeatureService` работает через `UserConnection.GetFeatureState` и
`SetFeatureState`. Состояние может задаваться для пользователя или группы, а
`FeatureInfo.ActualizeFeatureState` вычисляет фактическое состояние.

Client helper:

```text
FeatureServiceRequest
  -> GetFeatureState
  -> SetFeatureState
  -> SetFeatureStateForAllUsers
```

Feature flag не является правом доступа. Он может скрывать функциональность, но
серверная безопасность всё равно должна проверять операции и права.

## SysSettings

Модель:

| Сущность | Роль |
| -------- | ---- |
| `SysSettings` | metadata настройки: code, type, cacheability, SSP availability |
| `SysSettingsValue` | значение настройки |
| `SysSettingsRights` | права на конкретную настройку |
| `SysSettingsFolder` / `SysSettingsInFolder` | навигация раздела |

Важные свойства:

- `IsPersonal` - значение может быть персональным;
- `IsCacheable` - значение кэшируется;
- `IsSSPAvailable` - настройка доступна в SSP-контуре;
- rights на настройку задаются отдельно от `SysAdminOperation`.

## GlobalAppSettings vs Feature vs SysSettings

| Конструкция | Где используется |
| ----------- | ---------------- |
| `GlobalAppSettings.*` | runtime/static application flags и app settings |
| `FeatureService` / `Feature` | управляемые feature states по пользователям/admin units |
| `SysSettings` | изменяемые настройки платформы в БД |

Не переносите автоматически проверку `GlobalAppSettings.FeatureX` в
`FeatureService`: это разные источники состояния.

## System Designer

`SystemDesigner.UIv2.js` - клиентский композитный модуль. Он:

- проверяет операции через `RightUtilities` и атрибуты вида `CanManage*`;
- использует `SystemOperationsPermissionsMixin`;
- открывает разделы через `openSection`;
- собирает плитки из `SystemDesigner.<Domain>.js` и section modules.

Пример границы: переход в `SysAdminOperationSectionV2` зависит от операции
`CanManageAdministration`, но сама операция и её grantees живут в Security/Admin
metadata.

## Boundaries

| Область | Граница |
| ------- | ------- |
| Features | включают возможность, но не заменяют security checks |
| SysSettingsRights | права на настройку, не общая operation right |
| System Designer | UI-навигация, не источник истины по доступу |
| Security | `DBSecurityEngine` и schema/record rights остаются серверной границей |
| Domain features | доменные флаги лучше документировать в соответствующем dive и ссылаться сюда |

## Troubleshooting

| Симптом | Проверить |
| ------- | --------- |
| Feature включена, но код её не видит | фактическое состояние пользователя, group/all users, cache |
| Feature видна в UI, но операция запрещена | `CanManage*`/operation right на сервере |
| SysSetting меняется, но поведение не меняется | `IsCacheable`, restart/cache, boot script value |
| Настройка не доступна в SSP | `IsSSPAvailable` и portal boundary |
| Плитка System Designer не открывается | operation right, `RightUtilities`, target section name |

## Связанные документы

- [Administration Features System Designer](admin-features-system-designer.md)
- [Administration SysSettings Lookups](admin-syssettings-lookups.md)
- [Administration Services Rights](admin-services-rights.md)
- [Security Server Operations](security-server-operations.md)
- [Security Client Rights](security-client-rights.md)
