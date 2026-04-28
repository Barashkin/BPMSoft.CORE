# Auth OAuth20 Platform Clients

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20, OAuthClientApp, OAuthConfigService, IdentityServiceWrapper -->

> Platform OAuth clients: регистрация client/resource в Identity Service,
> `OAuthConfigService`, entity listeners и правила безопасности.

## Назначение

Platform OAuth client app описывает внешнее приложение, которому нужен доступ к
ресурсам платформы через OAuth 2.0. Этот контур управляет `OAuthClientApp`,
`OAuthResource` и `OAuthResourceInClient`.

## OAuthConfigService

`OAuthConfigService.OAuth20.cs` публикует WCF methods:

| Method | Назначение |
| ------ | ---------- |
| `AddDefaultResource` | создать default `OAuthResource` |
| `AddClient` | создать `OAuthClientApp` |
| `UpdateClient` | обновить client app |
| `DeleteClient` | удалить client app |
| `GrantAccess` | связать client с resource |
| `DeleteScope` | удалить связь client-resource |

Все methods проверяют:

```text
GlobalAppSettings.FeatureEnableOAuth20Integration
```

Если feature выключена, service возвращает `ConfigurationServiceResponse` с
`OAuthDisabledMessage`.

## AddClient flow

```text
AddClient(AddClientRequest)
  -> IsSysAdminUnitValid(SystemUserId)
  -> create OAuthClientApp
  -> save entity
  -> OAuthClientAppListener.OnInserting
  -> IdentityServiceWrapper.AddClient
  -> write ClientId and ClientSecret
  -> OAuthClientAppListener.OnInserted
  -> create OAuthResourceInClient for default resource
```

`SystemUserId` должен указывать на `SysAdminUnit` с `SysAdminUnitTypeValue = 4`.

## BaseOAuthApiCaller

`BaseOAuthApiCaller.OAuth20.cs` - базовый listener helper:

- проверяет `CanManageSolution`;
- выбирает `IIdentityServiceWrapper`;
- выполняет API call через `ExecuteApiCall`;
- ловит `ApiServerException` и `ApiServerConnectivityException`;
- отправляет websocket message `ActingOnOAuthClientApplication`;
- отменяет entity event через `e.IsCanceled = true`.

Wrapper выбирается так:

```text
FeatureUseSeparateSettingsForOAuth20
  ? ClassFactory.Get<IIdentityServiceWrapper>("OAuth20Integration")
  : ClassFactory.Get<IIdentityServiceWrapper>()
```

## OAuthClientAppListener

`OAuthClientAppListener`:

- `OnInserting` проверяет `CanManageSolution`, наличие default resource,
  вызывает `IdentityServiceWrapper.AddClient`, записывает `ClientId` и
  `ClientSecret`;
- `OnInserted` создаёт `OAuthResourceInClient` для default resource;
- `OnUpdating` вызывает `IdentityServiceWrapper.UpdateClient`;
- `OnDeleting` вызывает `IdentityServiceWrapper.RemoveClient`.

## OAuthResourceListener

`OAuthResourceListener`:

- не допускает более одного default resource;
- регистрирует resource в Identity Service через `AddResource`;
- запрещает удаление resource, если он используется Identity Service;
- запрещает менять `DoNotUseForIdentityService` после создания.

## OAuthResourceInClientListener

`OAuthResourceInClientListener`:

- при вставке вызывает `IdentityServiceWrapper.GrantAccess`;
- при удалении вызывает `IdentityServiceWrapper.DeleteClientScopes`;
- строит `GrantAccessInfo` из `OAuthClientApp.ClientId` и
  `OAuthResource.Name`.

## Security

Все изменения platform OAuth clients/resources требуют `CanManageSolution`.
Ошибки Identity Service должны отменять запись сущности, чтобы локальная БД не
разошлась с внешней регистрацией.

## Связанные документы

- [Auth OAuth20 Integration Overview](auth-oauth20-integration-overview.md)
- [Auth OAuth20 Data Model](auth-oauth20-data-model.md)
- [Auth OAuth20 Troubleshooting](auth-oauth20-troubleshooting.md)
- [Security Server Operations](security-server-operations.md)
