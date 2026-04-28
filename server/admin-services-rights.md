# Administration Services Rights And Licenses

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AdministrationService, rights, licenses, WCF, operation rights -->

> Административные сервисы, проверка прав, лицензии и уровни security metadata.

## WCF/REST pattern

Административные сервисы оформлены как WCF services:

- `[ServiceContract]`;
- `[OperationContract]`;
- `[WebInvoke(Method = "POST", RequestFormat = Json, ResponseFormat = Json)]`;
- `UserConnection` берется из `HttpContext.Current.Session`;
- для portal-сценариев используется `[SspServiceRoute]`;
- для обычного UI используется `[DefaultServiceRoute]`.

URL соответствует общему правилу:

```text
/0/rest/{ServiceName}/{MethodName}
```

## AdministrationService partials

`AdministrationService` разбит на partial-классы по доменам:

| Файл | Зона |
| ---- | ---- |
| `AdministrationService.UIv2.cs` | базовые операции |
| `AdministrationServiceUsers.UIv2.cs` | пользователи |
| `AdministrationServiceLicenses.UIv2.cs` | лицензии |
| `AdministrationServiceSysAdminUnitRoles.UIv2.cs` | роли |
| `AdministrationServiceSysAdminUnitGrantedRight.UIv2.cs` | выданные права |

Такой подход держит общий service route, но разделяет код по ответственности.

## Operation rights

Для административных действий сервисы вызывают:

```text
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageAdministration")
```

Если проверка проваливается, код может вернуть ошибку через `WebFaultException`
или через DTO ответа, в зависимости от сервиса.

## Rights metadata

Уровни прав:

| Уровень | Схемы |
| ------- | ----- |
| Operations | `SysAdminOperation`, `SysAdminOperationGrantee` |
| Entity operations | `SysEntitySchemaOperationRight` |
| Process operations | `SysProcessSchemaOperationRight` |
| External service operations | `SysExtServiceOperationRight` |
| Record rights | `SysEntitySchemaRecordRight`, `SysEntitySchemaRecordDefRight` |
| Column rights | `VwSysEntitySchemaColumnRight` |
| Settings rights | `SysSettingsRights` |
| Granted admin unit rights | `SysAdminUnitGrantedRight` |

Client side helpers:

- `RightsServiceHelper.UIv2.js`;
- `SetRightsInfoSchema.UIv2.js`;
- `SysAdminOperationGranteeDetailV2.UIv2.js`;
- `SysAdminUnitGrantedRightDetailV2.UIv2.js`.

Server side:

- `RightsService.NUI.cs`;
- `RightsHelper.NUI.cs`.

## Licenses

Лицензии представлены схемами:

- `SysLic`;
- `SysLicPackage`;
- `SysLicUser`;
- `SysLicPackageNames`;
- `VwExpiringLicense`.

`AdministrationServiceLicenses.UIv2.cs` дает административный API для
лицензионных операций.

## Практические правила

- Для admin API сначала определите требуемое operation right.
- Не смешивайте operation rights и record rights.
- Для пользовательских прав используйте `SysAdminUnit` как subject.
- Для настроек дополнительно проверяйте `SysSettingsRights`.
- Лицензии проверяйте отдельно от ролей: роль не заменяет лицензию.

## Связанные документы

- [Administration overview](admin-configuration-overview.md)
- [Administration users roles](admin-users-roles.md)
- [Security overview](security-overview.md)
- [Security server operations](security-server-operations.md)
- [Security licenses](security-licenses.md)
