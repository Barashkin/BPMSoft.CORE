# Administration Users And Roles

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysAdminUnit, roles, users, org structure, administration -->

> Пользователи, роли и оргструктура: `SysAdminUnit`, связи ролей,
> администрирование сессий и страницы UIv2.

## SysAdminUnit

`SysAdminUnit` — центральная сущность административных единиц. Она используется
для пользователей, организационных ролей, функциональных ролей, групп и команд.

Важные поля:

| Поле | Назначение |
| ---- | ---------- |
| `SysAdminUnitTypeValue` | тип admin unit |
| `ParentRole` | иерархия ролей |
| `Contact` | связанный контакт пользователя |
| `Account` | связанный аккаунт |
| `Active` | активность пользователя/роли |
| `LoggedIn` | признак входа |
| `SysCulture` | культура пользователя |
| `TimeZone` | часовой пояс |
| `Email` | email пользователя |
| `SessionTimeout` | timeout сессии |
| `ForceChangePassword` | принудительная смена пароля |
| `Disable2FA` | отключение 2FA |

Схема содержит уникальный индекс по `Name` и `ParentRole`, а также индекс для
`LoggedIn`/`Active`.

## Role links

Ключевые связи:

- `SysAdminUnitInRole` — пользователь/роль внутри роли;
- `SysAdminUnitGrantedRight` — выданные права;
- `SysAdminUnitInWorkplace` — доступ к рабочему месту;
- `SysAdminUnitIPRange` — ограничения по IP;
- `SysAdminUnitFolder` и `SysAdminUnitInFolder` — папки admin units.

## AdministrationService

`AdministrationService.UIv2.cs` использует `IOrgStructureManager` и работает как
WCF/REST JSON service.

Показательные методы:

- `TerminateSession`;
- `TerminateCurrentUserSessions`;
- `TerminateUserSessions`;
- `ValidatePassword`;
- `ActualizeAdminUnitInRole`;
- `GetChildAdminUnits`;
- `GetChildAdminUnitsAndUsersCount`.

Для опасных операций сервис проверяет operation right `CanManageAdministration`.

## Hierarchical select

`GetChildAdminUnits` строит `Select` по `SysAdminUnit`, включает типы
organisation/department/manager/team/functional role и использует
`HierarchicalSelectOptions` с `SelectType = Children`.

## UI pages

Клиентские точки:

- `SysAdminUnitSectionV2.UIv2.js`;
- `SysAdminUnitPageV2.UIv2.js`;
- `SysAdminUnitFuncRolePageV2.UIv2.js`;
- `SysAdminUnitRoleBasePageV2.UIv2.js`;
- LDAP/SSP extensions для отдельных сценариев.

## Практические правила

- Для изменения оргструктуры используйте `AdministrationService` или manager,
  не прямые SQL update.
- Перед удалением роли считайте дочерние roles/users.
- Завершение чужих сессий требует `CanManageAdministration`.
- Проверку пароля делайте через `ValidatePassword`.
- После массовых изменений ролей запускайте actualize.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Administration services rights](admin-services-rights.md)
- [Security server operations](security-server-operations.md)
- [SSP portal security](security-ssp-portal.md)
