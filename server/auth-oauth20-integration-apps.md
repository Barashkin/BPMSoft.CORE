# Auth OAuth20 Integration Apps

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20Integration, OAuthApplications, OAuth20AppPage, OAuthTokenStorage -->

> Integration OAuth apps - это настройки внешних OAuth providers, через которые
> платформа получает tokens для исходящих интеграций.

## Назначение

`OAuthApplications` описывает внешний OAuth provider/application: endpoints,
client credentials, scopes, users и способ передачи credentials. В отличие от
`OAuthClientApp`, эта сущность не регистрирует клиента в Identity Service.

## Section and module

| Source file | Назначение |
| ----------- | ---------- |
| `OAuth20AppSection.OAuth20Integration.js` | section OAuth applications |
| `OAuth20AppModule.OAuth20Integration.js` | module wrapper |
| `OAuth20AppModalPage.OAuth20Integration.js` | modal page scenario |
| `SystemDesigner.OAuth20.js` | entry в system designer |

Section работает с folder/tag/file helper-схемами `OAuth20App*`.

## OAuth20AppPage

`OAuth20AppPage.OAuth20Integration.js` работает с entity `OAuthApplications` и
требует operation:

```text
CanManageSolution
```

Ключевые поля:

| Field | Назначение |
| ----- | ---------- |
| `Name` | имя приложения |
| `ClientId` | external client id |
| `SecretKey` | secure secret |
| `AuthorizeUrl` | authorization endpoint |
| `TokenUrl` | token endpoint |
| `RevokeTokenUrl` | revoke endpoint |
| `UseSharedUser` | shared/personal users mode |
| `SharedUser` | shared user |
| `CredentialsLocationInRequest` | где передаются credentials |
| `AccessType` | online/offline/not use |

## Details

| Detail | Entity | Назначение |
| ------ | ------ | ---------- |
| `OAuthAppScopeDetail` | `OAuthAppScope` | scopes OAuth application |
| `OAuthAppUserDetail` | `VwOAuthAppUser` | пользователи с tokens |

`OAuthAppUserDetail` показывает view поверх `OAuthTokenStorage`. Удаление
пользователя выполняется через service endpoint helper, чтобы корректно удалить
OAuth connection.

## Shared user mode

Если `UseSharedUser = true`, users tab скрывается, а page работает с
`SharedUser`. Метод `assignSharedUser` назначает текущего пользователя после
успешного login callback.

Если personal accounts недоступны, `onEntityInitialized` принудительно включает
`UseSharedUser`.

## Defaults on page init

`onEntityInitialized` задаёт defaults:

| Field | Default |
| ----- | ------- |
| `CredentialsLocationInRequest` | `BASIC_HEADER` |
| `AccessType` | `OFFLINE` |

Также page загружает secret через
`ServiceOAuthAuthenticatorEndpointHelper.getOAuthServiceClientSecretKey`.

## Login flow from UI

```text
OAuth20AppPage._loginUser
  -> ServiceOAuthAuthenticatorEndpointHelper.getAuthorizationGrantUrl(appId)
  -> window.open(url)
  -> external provider auth
  -> ServiceOAuthAuthenticatorEndpoint callback
  -> server channel message "ServiceOAuthAuthenticatorEndpoint"
  -> assignSharedUser/updateDetails
```

## Связанные документы

- [Auth OAuth20 Integration Overview](auth-oauth20-integration-overview.md)
- [Auth OAuth20 Data Model](auth-oauth20-data-model.md)
- [Auth OAuth20 Service Authenticator](auth-oauth20-service-authenticator.md)
- [Integration Tools Overview](integration-tools-overview.md)
