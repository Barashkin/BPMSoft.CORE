# Features And System Designer Administration

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FeatureService, feature flags, SystemDesigner, administration -->

> Feature states и System Designer: как включаются функции и где искать
> административные плитки.

## FeatureService

В платформе используется термин `Feature`, а не отдельная сущность
`FeatureFlag`.

`FeatureService.Base.cs` предоставляет JSON API:

| Метод | Назначение |
| ----- | ---------- |
| `GetFeatureState` | вернуть состояние по коду |
| `SetFeatureState` | установить состояние для текущего пользователя |
| `SetFeaturesState` | установить несколько состояний |
| `SetFeatureStateForAllUsers` | установить состояние для всех |
| `CreateFeature` | создать feature |
| `GetFeaturesInfo` | вернуть features и состояния |
| `GetFeatureStates` | вернуть словарь состояний |

## FeatureInfo

`FeatureInfo` содержит:

- `Id`;
- `Name`;
- `Code`;
- `Description`;
- `StatesInfo`;
- `ActualState`;
- `HasStateForUser`;
- `HasStateForGroup`;
- `GroupState`.

`ActualizeFeatureState` проверяет состояние для текущего пользователя и для
группы `AllEmployersSysAdminUnitUId`.

## State storage

Состояния по admin unit хранятся в `AdminUnitFeatureState`.
Это позволяет включать функцию:

- для конкретного пользователя;
- для группы;
- для всех сотрудников.

## Feature usage

В коде встречается паттерн:

```text
UserConnection.GetFeatureState(code)
UserConnection.SetFeatureState(code, state)
```

Для клиентской части используются feature utilities и сервисные вызовы.

## System Designer

System Designer собирается из UI-модулей:

- `SystemDesigner.UIv2.js`;
- `AdministrationSystemDesignerSectionV2.UIv2.js`;
- `ConfigurationSystemDesignerSectionV2.UIv2.js`;
- `ProcessSystemDesignerSectionV2.UIv2.js`;
- другие `*SystemDesignerSectionV2.UIv2.js`.

Каждый section module отвечает за группу плиток в своей области:
администрирование, конфигурация, процессы, интеграции и т.д.

## Практические правила

- Для feature проверяйте actual state, а не только наличие записи.
- Состояние пользователя имеет приоритет над групповым.
- Включение для всех пользователей идет через специальный API.
- System Designer расширяйте через профильный section module.
- Не называйте платформенный механизм feature flags, если в коде используется
  `Feature`.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Administration services rights](admin-services-rights.md)
- [Client module overview](../client/client-module-overview.md)
- [Security overview](security-overview.md)
