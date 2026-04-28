# Auth OAuth20 Integration Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: auth, OAuth20, OAuth20Integration, OAuthClientApp, OAuthApplications -->

> Входная точка в OAuth 2.0 Integration Dive. Раздел разделяет два контура:
> platform OAuth client applications и integration OAuth applications.

## Два OAuth-контура

| Контур | Назначение | Ключевые сущности |
| ------ | ---------- | ----------------- |
| Platform OAuth clients | регистрация client/resource в Identity Service | `OAuthClientApp`, `OAuthResource`, `OAuthResourceInClient` |
| Integration OAuth apps | настройки внешних OAuth apps для исходящих интеграций | `OAuthApplications`, `OAuthAppScope`, `OAuthTokenStorage`, `VwOAuthAppUser` |

Эти контуры связаны OAuth 2.0 терминологией, но обслуживают разные сценарии.
Platform clients описывают доступ внешних клиентов к платформе, а integration
apps описывают доступ платформы к внешним OAuth providers.

## Документы пакета

| Документ | Назначение |
| -------- | ---------- |
| [auth-oauth20-data-model.md](auth-oauth20-data-model.md) | схемы `OAuthClientApp`, `OAuthApplications`, resources, scopes, tokens |
| [auth-oauth20-platform-clients.md](auth-oauth20-platform-clients.md) | `OAuthConfigService`, Identity Service, listeners |
| [auth-oauth20-integration-apps.md](auth-oauth20-integration-apps.md) | `OAuth20AppPage`, scopes/users details, shared user |
| [auth-oauth20-service-authenticator.md](auth-oauth20-service-authenticator.md) | `ServiceOAuthAuthenticatorEndpoint` и helper flow |
| [auth-oauth20-boundaries.md](auth-oauth20-boundaries.md) | границы с SSO, Mailbox Office365, Integration Tools, Social |
| [auth-oauth20-pattern-catalog.md](auth-oauth20-pattern-catalog.md) | рабочие паттерны OAuth20 |
| [auth-oauth20-troubleshooting.md](auth-oauth20-troubleshooting.md) | диагностика clients, resources, tokens, callbacks |

## Быстрый выбор

| Задача | Документ |
| ------ | -------- |
| Зарегистрировать platform OAuth client | [auth-oauth20-platform-clients.md](auth-oauth20-platform-clients.md) |
| Настроить внешний OAuth provider | [auth-oauth20-integration-apps.md](auth-oauth20-integration-apps.md) |
| Разобрать scopes/users/tokens | [auth-oauth20-data-model.md](auth-oauth20-data-model.md) |
| Понять login/authorization grant URL | [auth-oauth20-service-authenticator.md](auth-oauth20-service-authenticator.md) |
| Отличить от Office365 mailbox OAuth | [auth-oauth20-boundaries.md](auth-oauth20-boundaries.md) |
| Диагностировать ошибку OAuth | [auth-oauth20-troubleshooting.md](auth-oauth20-troubleshooting.md) |

## Ключевые source files

| Область | Файлы |
| ------- | ----- |
| platform service | `OAuthConfigService.OAuth20.cs`, `OAuthConfigServiceDto.OAuth20.cs` |
| platform model | `OAuthClientAppSchema.OAuth20.cs`, `OAuthResourceSchema.OAuth20.cs`, `OAuthResourceInClientSchema.OAuth20.cs` |
| Identity listeners | `OAuthClientAppListener.OAuth20.cs`, `OAuthResourceListener.OAuth20.cs`, `OAuthResourceInClientListener.OAuth20.cs`, `BaseOAuthApiCaller.OAuth20.cs` |
| integration model | `OAuthApplicationsSchema.Base.cs`, `OAuthAppScopeSchema.OAuth20Integration.cs`, `OAuthTokenStorageSchema.Base.cs`, `VwOAuthAppUserSchema.OAuth20Integration.cs` |
| integration UI | `OAuth20AppPage.OAuth20Integration.js`, `OAuth20AppSection.OAuth20Integration.js`, `OAuth20AppModule.OAuth20Integration.js` |
| endpoint helper | `ServiceOAuthAuthenticatorEndpointHelper.OAuth20Integration.js` |
| social callback boundary | `OAuthAuthenticationModule.NUI.js` |

## Feature flags and settings

| Flag/setting | Назначение |
| ------------ | ---------- |
| `GlobalAppSettings.FeatureEnableOAuth20Integration` | включает `OAuthConfigService` operations |
| `GlobalAppSettings.FeatureUseSeparateSettingsForOAuth20` | выбирает named binding `IIdentityServiceWrapper("OAuth20Integration")` |
| `OAuth20IdentityServerUrl` | используется в сообщении об ошибке подключения к Identity Service |

## Связанные документы

- [Auth OAuth20 Apps And Tokens](auth-oauth20-apps-tokens.md)
- [Auth SSO LDAP Overview](auth-sso-ldap-overview.md)
- [Integration Tools Overview](integration-tools-overview.md)
- [Mailbox Exchange OAuth Office365](mailbox-exchange-oauth-office365.md)
