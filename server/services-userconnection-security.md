# Service UserConnection And Security

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, UserConnection, SystemUserConnection, DBSecurityEngine, LicHelper -->

> Как сервисы получают `UserConnection`, когда нужен `SystemUserConnection` и где проверять права.

## Security/Rights Dive

Подробная документация по правам вынесена в отдельный пакет:

| Документ | Назначение |
| -------- | ---------- |
| [security-overview.md](security-overview.md) | Карта Security/Rights Dive |
| [security-server-operations.md](security-server-operations.md) | `DBSecurityEngine`, operation rights, exceptions |
| [security-userconnection-context.md](security-userconnection-context.md) | `UserConnection`, `SystemUserConnection`, `UseAdminRights` |
| [security-schema-record-rights.md](security-schema-record-rights.md) | schema, record и column rights |
| [security-licenses.md](security-licenses.md) | `LicHelper`, `LicManager`, license failures |
| [security-client-rights.md](security-client-rights.md) | `RightUtilities` и клиентские проверки |
| [security-ssp-portal.md](security-ssp-portal.md) | SSP/portal access и portal users |
| [security-troubleshooting.md](security-troubleshooting.md) | Диагностика отказов доступа |

## UserConnection в BaseService

Если сервис наследуется от `BaseService`, `UserConnection` доступен как свойство базового класса.

```csharp
[ServiceContract]
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class CompletenessService : BaseService, IReadOnlySessionState
{
    private BaseCompletenessService CreateCompletenessService() {
        return ClassFactory.Get<BaseCompletenessService>(
            new ConstructorArgument("userConnection", UserConnection));
    }
}
```

Это основной вариант для серверных сервисов конфигурации.

## UserConnection из session

В старом коде встречается ручное получение connection из ASP.NET session.

```csharp
private UserConnection UserConnection {
    get {
        return _userConnection ??
            (_userConnection = (UserConnection)HttpContext.Current.Session["UserConnection"]);
    }
}
```

Для новых сервисов предпочтительнее `BaseService`, если нет платформенного ограничения.

## IReadOnlySessionState

`IReadOnlySessionState` указывает, что сервис читает session, но не должен её изменять. Это снижает риск блокировок session при параллельных запросах.

Используется в:

- `CompletenessService.Completeness.cs`;
- `FileApiService.NUI.cs`;
- `BPMSoftOCCChatRequestService.BPMSoftOCC.cs`;
- `CtiRightsService.CTIBase.cs`.

## SystemUserConnection

`SystemUserConnection` нужен для операций, которые должны идти от системного пользователя: служебные таблицы, лицензии, роли, обход ограничений обычного пользователя.

```csharp
protected UserConnection SystemUserConnection {
    get {
        return UserConnection.AppConnection.SystemUserConnection;
    }
}
```

Использовать его нужно точечно. Если действие инициировано пользователем, права пользователя всё равно должны быть проверены явно.

## Проверка операций

Стандартная проверка права на операцию:

```csharp
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanAdministratePortalUsers");
```

Если права нет, будет исключение. Для проверки без исключения:

```csharp
if (UserConnection.DBSecurityEngine.GetCanExecuteOperation("CanManageUsers")) {
    return string.Empty;
}
```

## Проверка лицензий

Для license checks используется `LicHelper`.

```csharp
bool hasLicense = UserConnection.LicHelper.GetHasOperationLicense(operation);
```

Такой endpoint может возвращать простой `bool`, если клиенту нужен только флаг доступности.

## SecurityException как domain signal

В сервисах администрирования портальных пользователей `SecurityException` используется для доменной проверки: можно ли изменять конкретную запись.

```csharp
if (!IsPortalUser(userId)) {
    throw new SecurityException("No right for update");
}
```

Это не заменяет operation rights. Обычно сначала проверяется операция, затем доменное условие.

## Практические правила

- Проверяйте права в публичном service method до выполнения изменения.
- Не принимайте `UserConnection` параметром от клиента.
- Не используйте `SystemUserConnection` как способ обойти права без бизнес-основания.
- Для read-only endpoint'ов добавляйте `IReadOnlySessionState`, если сервис не пишет в session.
- Для внешних callbacks фиксируйте, от чьего имени выполняется запись и какие операции разрешены.

## Связанные документы

- [Services Overview](services-overview.md)
- [Service contracts and routing](services-contracts-routing.md)
- [Service responses and errors](services-response-errors.md)
- [Security overview](security-overview.md)
- [Services troubleshooting](services-troubleshooting.md)
