# SSP Portal Access Rights

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, portal ACL, PortalColumnAccessList, GlobalSearchSSPHelper -->

> Доступ портала к схемам и колонкам: `SysSSPEntitySchemaAccessList`,
> `PortalSchemaAccessList`, `PortalColumnAccessList` и Global Search.

## Schema access

`SysSSPEntitySchemaAccessList` хранит список объектов, доступных portal users.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `EntitySchemaUId` | UId разрешенной entity schema |
| `IsPreset` | преднастроенная запись |

Смежные схемы:

- `PortalSchemaAccessList`;
- `VwSysSSPEntitySchemaAccessList`;
- `SysModuleEntityInPortal`.

## Column access

`PortalColumnAccessList` задает разрешенные колонки для схем портала.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `PortalSchemaList` | ссылка на schema access entry |
| `ColumnUId` | UId колонки |
| `ColumnName` | имя колонки |

`PortalColumnAccessListEventListener` и
`PortalSchemaAccessListEventListener` используются для сопутствующих действий
при изменении ACL.

## Global Search SSP

`GlobalSearchSSPHelper.SSP.cs` переопределяет общий helper для SSP.

Паттерны:

- определяет portal user через `CurrentUser.ConnectionType == UserType.SSP`;
- собирает разрешенные schemas из workplace modules;
- проверяет license availability через `GetIsAvailableOnSsp`;
- читает разрешенные portal columns из `PortalSchemaAccessList` и
  `PortalColumnAccessList`;
- кеширует columns в `ApplicationCache`;
- фильтрует aggregation groups и response groups;
- отключает default score settings для SSP.

Важная настройка:

```text
GlobalAppSettings.UsePortalSchemaAllowedColumns
```

Если включена неподходящая ветка, Global Search может показать лишние или
недостаточные поля.

## Portal schema service

`SspSchemaAccessService.SspWorkplace.cs` обслуживает сценарий разрешения
связанных схем на SSP через `AllowRelatedEntitiesOnSsp` и
`ISspEntitySchemaRepository`.

## Практические правила

- Доступность секции в портале не равна доступности всех колонок.
- Для Global Search проверяйте и schema ACL, и column ACL.
- В portal ACL храните UId схем/колонок, а не только display names.
- После изменения ACL учитывайте кеш `AllowedPortalColumns`.
- Для связанных схем используйте специализированный SSP schema access service.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal users](ssp-portal-users.md)
- [Security SSP portal](security-ssp-portal.md)
- [Security schema record rights](security-schema-record-rights.md)
