# Security UserConnection Context

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: UserConnection, SystemUserConnection, UseAdminRights, IReadOnlySessionState -->

> Как выбирать контекст выполнения: текущий пользователь, системный пользователь, `UseAdminRights` и session state.

## UserConnection

`UserConnection` представляет текущего пользователя и его права. В сервисах, наследующих `BaseService`, он доступен как свойство.

```csharp
public class MyService : BaseService, IReadOnlySessionState
{
    public void Execute() {
        UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageUsers");
    }
}
```

Это контекст по умолчанию для действий, инициированных пользователем.

## SystemUserConnection

`SystemUserConnection` используется для служебных операций.

```csharp
protected UserConnection SystemUserConnection {
    get {
        return UserConnection.AppConnection.SystemUserConnection;
    }
}
```

Пример: управление portal user roles и лицензиями в `AdministrationServicePortalUsers.SSP.cs`.

## Важная граница

`SystemUserConnection` не должен быть способом обойти права. Типовой безопасный порядок:

1. Проверить operation right у текущего `UserConnection`.
2. Проверить доменное условие.
3. Выполнить служебную запись через `SystemUserConnection`, если обычный пользователь технически не имеет доступа к системной таблице.

## UseAdminRights

`UseAdminRights` управляет правами при работе с Entity/ESQ.

```csharp
var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "Contact") {
    UseAdminRights = false
};
```

`UseAdminRights = false` означает, что запрос должен учитывать права текущего пользователя.

## Когда UseAdminRights нужен

Используйте `UseAdminRights = true` или системный контекст только для:

- служебных таблиц;
- фоновой технической операции;
- миграции/обслуживания;
- действий, где бизнес-право уже проверено отдельно;
- платформенного кода, который должен видеть metadata.

## IReadOnlySessionState

`IReadOnlySessionState` указывает, что сервис читает session, но не пишет в неё.

Это полезно для rights/read endpoints, чтобы снизить риск блокировки session при параллельных запросах.

## Практические правила

- По умолчанию работайте от текущего `UserConnection`.
- Перед `SystemUserConnection` явно сформулируйте, какое право уже проверено.
- Не передавайте `UserConnection` с клиента.
- Для read-only service endpoints используйте `IReadOnlySessionState`.
- В EventListener не повышайте права без явного бизнес-основания.

## Связанные документы

- [Security overview](security-overview.md)
- [Service UserConnection And Security](services-userconnection-security.md)
- [ESQ performance](esq-performance.md)
