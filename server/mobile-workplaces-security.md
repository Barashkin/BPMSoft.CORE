# Mobile Workplaces And Security

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Mobile workplace, roles, security, syssettings -->

> Mobile workplace, роли, системные настройки и границы доступа мобильного
> клиента.

## SysMobileWorkplace

`SysMobileWorkplace` — сущность мобильного рабочего места.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `Name` | название рабочего места |
| `Code` | код рабочего места |
| `Type` | тип из `MobileApplicationMode` |

Схема не использует deny record rights и record deactivation.

## SysRoleInMobWorkplace

`SysRoleInMobWorkplace` связывает роль с мобильным рабочим местом.

Поля:

- `SysRole`;
- `SysMobileWorkplace`.

Обе lookup-колонки indexed и cascade. Это важно при удалении роли или рабочего
места.

## MobileApplicationMode

`MobileApplicationMode` — lookup для режима мобильного приложения. Он связан с
`SysMobileWorkplace.Type` и syssetting `MobileApplicationMode`.

## SysSettings import

Base manifest импортирует mobile syssettings, например:

- `MobileApplicationMode`;
- `RunMobileSyncInService`;
- `ShowMobileLocalNotifications`;
- `EnableMobileErrorLog`;
- `MobileDataSyncFrequency`;
- `MobileTrackLocationFrequency`;
- `UseMobileCertificateAuthentication`;
- `MaxFileSize`;
- `FileExtensionsAllowList`.

Portal manifest может иметь отдельный набор settings.

## Rights and sync

Права учитываются на нескольких уровнях:

- workplace доступен через связку role/workplace;
- sync filters ограничивают данные текущим пользователем;
- `SyncByParentObjectWithRights` наследует доступ от parent object;
- service calls идут от текущего пользователя;
- offline cache не должен расширять серверные права.

## Практические правила

- Новое рабочее место должно иметь стабильный `Code`.
- Роли добавляйте через `SysRoleInMobWorkplace`, не через custom list.
- Для child records используйте `SyncByParentObjectWithRights`.
- Не импортируйте чувствительные syssettings без необходимости.
- Offline cache считайте локальной копией разрешённых сервером данных.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
- [Security/Rights Overview](security-overview.md)
- [Security schema and record rights](security-schema-record-rights.md)
