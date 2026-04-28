# Auth OAuth20 Data Model

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20, OAuthClientApp, OAuthApplications, OAuthTokenStorage -->

> Модель данных OAuth 2.0: platform client apps, resources, integration apps,
> scopes, users и token storage.

## Platform OAuth clients

`OAuthClientAppSchema.OAuth20.cs` описывает client application, которая
регистрируется в Identity Service.

| Колонка | Назначение |
| ------- | ---------- |
| `Name` | имя client application |
| `ClientId` | client id, приходит из Identity Service |
| `ClientSecret` | secure text secret, приходит из Identity Service |
| `RedirectUrl` | redirect URI |
| `ApplicationUrl` | URL client application |
| `IsActive` | активность client |
| `SystemUser` | system user для client flow |
| `Description` | описание |

`ClientSecret` хранится как `SecureText`.

## OAuth resources

`OAuthResource` описывает API resource/scope платформы, а
`OAuthResourceInClient` связывает resource с client app.

| Схема | Назначение |
| ----- | ---------- |
| `OAuthResource` | resource, который регистрируется в Identity Service |
| `OAuthResourceInClient` | grant access: client -> resource |

В системе должен быть один default resource. `OAuthResourceListener` запрещает
несколько default resources.

## Integration OAuth applications

`OAuthApplicationsSchema.Base.cs` описывает внешний OAuth provider/application.

| Колонка | Назначение |
| ------- | ---------- |
| `Name` | имя приложения |
| `AppClassName` | class name приложения |
| `ClientId` | external provider client id |
| `SecretKey` | secure client secret |
| `ClientClassName` | client class name |
| `AuthorizeUrl` | authorization endpoint |
| `TokenUrl` | token endpoint |
| `RevokeTokenUrl` | revoke endpoint |
| `UseSharedUser` | использовать shared user |
| `SharedUser` | пользователь для shared mode |
| `CredentialsLocationInRequest` | где передавать client credentials |
| `AccessType` | offline/online/not use |
| `Image` | icon/image |

## Scopes and users

`OAuthAppScope` хранит scopes конкретного `OAuthApplications`:

| Колонка | Назначение |
| ------- | ---------- |
| `Scope` | строковое значение scope |
| `OAuth20App` | ссылка на `OAuthApplications` |

`VwOAuthAppUser` - DB view над `OAuthTokenStorage`, используется в detail
`OAuthAppUserDetail` на странице приложения.

## Token storage

`OAuthTokenStorageSchema.Base.cs` хранит tokens пользователя:

| Колонка | Назначение |
| ------- | ---------- |
| `SysUser` | пользователь BPMSoft |
| `OAuthApp` | `OAuthApplications` |
| `UserAppLogin` | login пользователя во внешнем приложении |
| `AccessToken` | access token |
| `ExpiresOn` | срок действия |
| `RefreshToken` | refresh token |

Связь `OAuthApp` настроена как cascade, поэтому tokens удаляются вместе с
OAuth application.

## Folder/tag/file helpers

Для Integration OAuth apps есть helper-схемы:

- `OAuth20AppFolder`;
- `OAuth20AppTag`;
- `OAuth20AppInFolder`;
- `OAuth20AppInTag`;
- `OAuth20AppFile`.

Они обслуживают section UI и навигацию, а не token flow.

## Связанные документы

- [Auth OAuth20 Integration Overview](auth-oauth20-integration-overview.md)
- [Auth OAuth20 Platform Clients](auth-oauth20-platform-clients.md)
- [Auth OAuth20 Integration Apps](auth-oauth20-integration-apps.md)
- [Entity Schema Overview](entity-schema-overview.md)
