# SSP Portal Users

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, portal users, SysAdminUnit, SspUserManagementService -->

> Пользователи портала: `SysAdminUnit` с `ConnectionType = SSP`,
> создание, приглашение, роли, лицензии и права на Contact/Account.

## Модель пользователя

Portal user — это `SysAdminUnit` с portal connection type. В коде это
проверяется как:

```text
SysAdminUnit.ConnectionType = 1
```

Репрезентативные схемы:

- `SysAdminUnitSchema.SSP.cs`;
- `VwSspAdminUnitSchema.SSP.cs`;
- `VwSSPSysAdminUnitSchema.Base.cs`;
- `OptionalFuncSspRoleSchema.SSP.cs`.

`VwSSPSysAdminUnit` используется как UI-friendly представление пользователя
портала: contact, account, homepage, активность, password fields и другие
административные поля.

## SspUserManagementService

`SspUserManagementService.SSP.cs` — основной сервис для создания и приглашения
portal users.

Особенности:

- `[ServiceContract]`;
- `[DefaultServiceRoute]`;
- `[SspServiceRoute]`;
- `WebInvoke POST JSON`;
- проверка `UserConnection.DBSecurityEngine.CheckCanManageSspUsers()`;
- бизнес-логика вынесена в `SspUserManagementServiceHelper`;
- ошибки пишутся в `response.Exception`.

Ключевые методы:

- `CreateUsers`;
- `InviteUsers`;
- `CreateUsersByContactsIds`;
- `CheckIfPortalAccountExist`;
- `GetSspAccountInfo`;
- `GetOptionalFuncRolesList`;
- `GetEnabledFuncRolesForUser`;
- `ApplyOptionalFuncRolesForUsers`;
- `ChangeUserActivationStatus`;
- `GetSspLicNames`;
- `GetDefaultSspLicName`.

## AdministrationServicePortalUsers

`AdministrationServicePortalUsers.SSP.cs` — partial расширение
`AdministrationService` для админских операций.

Паттерны:

- работает через `SystemUserConnection`;
- перед изменением проверяет, что user действительно portal user;
- для CRUD требует `CanAdministratePortalUsers`;
- для некоторых проверок учитывает `CanManageUsers`;
- лицензии выдает через `LicManager`;
- роли добавляет в `SysUserInRole`.

Методы:

- `UpdateOrCreatePortalUser`;
- `CanChangePortalUserData`;
- `DeletePortalUser`;
- `AddPortalUserRoles`;
- `RemovePortalUsersInRoles`.

## Contact and Account rights

`SysAdminUnitEventListener.SSP.cs` после вставки portal user:

- проверяет `ContactId`;
- проверяет `ConnectionType`;
- выдает record rights на `Contact` для операций 0 и 1 через `RightsHelper`.

`VwSspAdminUnitEventListener.SSP.cs` расширяет этот подход для account rights
через `PortalAccountId` и `SysAccountRead`.

## Практические правила

- Для portal users не используйте общий user CRUD без проверки `ConnectionType`.
- Для массового создания вызывайте `SspUserManagementService`, а не прямой
  insert в `SysAdminUnit`.
- Для изменения ролей проверяйте account и optional function roles.
- Для лицензий portal user используйте `LicManager` с `SystemUserConnection`.
- После создания portal user проверьте rights на связанный `Contact`/`Account`.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal access rights](ssp-portal-access-rights.md)
- [Administration users roles](admin-users-roles.md)
- [Security SSP portal](security-ssp-portal.md)
