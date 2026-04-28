# SSP Portal Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, Portal, troubleshooting, access rights -->

> Диагностика SSP/Portal: пользователи, роли, ACL схем/колонок, portal
> sections, главная страница, регистрация, Global Search и external access.

## Portal user не создается или не приглашается

Проверьте:

- operation `CheckCanManageSspUsers`;
- account id в request;
- `CheckCanAddRoles`;
- optional functional roles;
- `response.Exception`;
- default SSP license.

Точки входа:

- `SspUserManagementService.SSP.cs`;
- `SspUserManagementServiceHelper.SSP.cs`;
- `SspUserCreator.SSP.cs`;
- `SspUserInviter.SSP.cs`.

## Админ не может изменить portal user

Проверьте:

- operation `CanAdministratePortalUsers`;
- является ли user portal user (`ConnectionType = 1`);
- `CanManageUsers` для обходной проверки;
- доступность `VwSysAdminUnit`;
- операции с `SystemUserConnection`.

Точка входа: `AdministrationServicePortalUsers.SSP.cs`.

## Portal user не видит секцию

Проверьте:

- `SysModuleEntityInPortal`;
- `PortalSectionStructureBuilder`;
- `SysModuleInWorkplace`;
- `SysAdminUnitInWorkplace`;
- portal workplace/role;
- license availability on SSP.

## Portal user видит секцию, но не видит данные

Проверьте:

- schema ACL в `SysSSPEntitySchemaAccessList` / `PortalSchemaAccessList`;
- record rights;
- column ACL в `PortalColumnAccessList`;
- `SSPSecurityEngine`;
- related schema access.

## Global Search показывает лишние или пустые результаты

Проверьте:

- `GlobalSearchSSPHelper`;
- `UsePortalSchemaAllowedColumns`;
- кеш `AllowedPortalColumnsCacheKey`;
- schema UId в portal access list;
- column UId в `PortalColumnAccessList`;
- license availability `GetIsAvailableOnSsp`.

## Главная страница портала не открывается

Проверьте:

- `PortalMainPageModule`;
- `PortalMainPageBuilder`;
- для admin: `CanManagePortalMainPage` и `CanViewConfiguration`;
- для SSP: скрытие settings button;
- dashboard tabs на главной.

## Self-registration не работает

Проверьте:

- `GlobalAppSettings.ShowPortalSelfRegistrationLink`;
- token fields: имя, email, password;
- зарезервированный login;
- существующий `SysAdminUnit` по `Contact`;
- создание `Contact`;
- `RegistrationHelper`;
- email template/settings.

## Сброс пароля не отправляет ссылку

Проверьте:

- `TotpSendResetPasswordLinkService`;
- logger `Authentication`;
- `SiteUrl`;
- email пользователя;
- token validity;
- настройки почты.

## Custom SSP service не доступен

Проверьте:

- `[SspServiceRoute]`;
- `SspServices\CustomerSspServiceList.txt`;
- `GetCustomerSspServiceList`;
- reflection по service routes;
- права portal user на endpoint.

## External access не работает

Проверьте:

- `ExternalAccess`;
- `ExternalAccessClient`;
- `SysIsolatedRecord`;
- `TempAccessService`;
- `ExternalAccessRequestLog`;
- `DataIsolationEntitiesListener`.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal pattern catalog](ssp-portal-pattern-catalog.md)
- [Security SSP portal](security-ssp-portal.md)
- [Security troubleshooting](security-troubleshooting.md)
