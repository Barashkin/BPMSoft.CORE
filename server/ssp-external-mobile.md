# SSP External Access And Mobile Portal

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, ExternalAccess, mobile portal, TempAccess -->

> Смежные portal-сценарии: external access, request logs, mobile portal
> manifest и мобильные страницы публикации.

## External access

Пакет `ExternalAccess` обслуживает изолированный и временный доступ.

Ключевые точки:

- `IsolatedAccessService.ExternalAccess.cs`;
- `ExternalAccessSchema.ExternalAccess.cs`;
- `ExternalAccessClientSchema.ExternalAccess.cs`;
- `TempAccessService.ExternalAccess.cs`;
- `TempAccessProxy*.ExternalAccess.cs`;
- `DataIsolationEntitiesListener.ExternalAccess.cs`.

## External access request log

`ExternalAccessRequestLog` хранит запросы внешнего доступа.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `RequestedOn` | дата запроса, default `CurrentDateTime` |
| `RequestedBy` | контакт requester, default `CurrentUserContact` |
| `Url` | URL запроса |
| `CustomerId` | внешний customer id |
| `ExternalAccessId` | ссылка на external access |
| `ExternalAccessDescription` | описание |

Слушатели:

- `ExternalAccessRequestLogListener`;
- `ExternalAccessSysAdminUnitListener`;
- `DataIsolationEntitiesListener`.

## Mobile portal manifest

`MobileApplicationManifestPortal.SSP.js` описывает portal mobile profile.

Паттерны:

- отдельный manifest для portal mode;
- `UseUTC = true`;
- `UseOptimisticEditing = true`;
- импорт syssettings и lookups;
- скрытые базовые modules;
- `RequiredDataFilter` на current contact;
- импорт contact photo через `SysImage`.

Смежные mobile files:

- `MobilePortalMessagePublisherPage.Mobile.js`;
- `MobileOpenPortalMessagePublisherPageAction.Mobile.js`;
- `MobileConstants.Mobile.js` (`PortalUsers`);
- `MobileDesignerEnums.MobileDesignerTools.js` (`WorkplaceType.Portal`).

## Практические правила

- External access диагностируйте через request log, а не только HTTP response.
- Для изолированного доступа проверяйте `SysIsolatedRecord`.
- Для временного доступа проверяйте proxy classes и срок действия.
- Mobile portal не равен обычному mobile workplace: проверяйте portal manifest.
- Для mobile portal sync учитывайте current contact filters.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal access rights](ssp-portal-access-rights.md)
- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
