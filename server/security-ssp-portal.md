# Security SSP Portal

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, portal, CanAdministratePortalUsers, portal schema access, allowed columns -->

> Особенности прав портала/SSP: портальные пользователи, доступные схемы, колонки и администрирование.

## Portal user operations

Для управления портальными пользователями используется отдельная операция.

```csharp
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanAdministratePortalUsers");
```

В некоторых сценариях допускается OR с `CanManageUsers`.

```csharp
bool canAdministrate = securityEngine.GetCanExecuteOperation("CanManageUsers") ||
    securityEngine.GetCanExecuteOperation("CanAdministratePortalUsers");
```

## Domain check

После operation right проверяется, что запись действительно относится к portal user.

```csharp
private bool IsPortalUser(Guid userId) {
    var select = new Select(UserConnection).Column("Id").From("SysAdminUnit")
        .Where("ConnectionType").IsEqual(Column.Const(1))
        .And("Id").IsEqual(Column.Parameter(userId)) as Select;
    return select.ExecuteScalar<Guid>() == userId;
}
```

Это защищает от изменения обычных пользователей через portal endpoint.

## SystemUserConnection для служебных таблиц

Запись в `SysUserInRole` и управление лицензиями выполняются через `SystemUserConnection`, но только после checks.

```csharp
EntitySchema tableSchema = SystemUserConnection.EntitySchemaManager.GetInstanceByName("SysUserInRole");
Entity sysUserInRole = tableSchema.CreateEntity(SystemUserConnection);
```

## Portal schema access

SSP global search фильтрует доступные сущности и колонки.

```csharp
private bool GetIsLicensedEntity(string entityName) {
    return UserConnection.DBSecurityEngine.GetIsAvailableOnSsp(entityName);
}
```

Allowed columns могут браться из portal access tables и cache.

```csharp
return entitySchema.Columns
    .Where(x => CanReadColumnSSPUser(entityName, x));
```

## Client SSP behavior

В `UsersSectionV2.SSP.js` UI меняется по комбинации прав:

- `CanViewConfiguration`;
- `CanManageUsers`;
- `CanAdministratePortalUsers`.

Если пользователь администрирует только портал, секция фильтрует `ConnectionType = 1` и скрывает добавление обычного пользователя.

## Практические правила

- Для portal endpoints проверяйте и operation right, и тип пользователя.
- Не используйте portal operation для обычных users.
- Для SSP search учитывайте schema, license и allowed columns.
- Для клиентской секции синхронизируйте фильтры и доступные actions.
- Возвращайте структурированный признак `IsSecurityException`, если клиент должен показать специальный сценарий.

## Связанные документы

- [Security overview](security-overview.md)
- [Security UserConnection Context](security-userconnection-context.md)
- [Security client rights](security-client-rights.md)
- [Services contracts routing](services-contracts-routing.md)
