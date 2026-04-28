# Auth OAuth20 Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20, troubleshooting, IdentityServiceWrapper, OAuthTokenStorage -->

> Диагностика проблем OAuth20Integration: platform client apps, Identity Service,
> integration OAuth apps, tokens и callbacks.

## OAuthConfigService returns OAuth disabled

Проверьте:

- `GlobalAppSettings.FeatureEnableOAuth20Integration`;
- доступность нужного WCF method;
- что запрос не пытается обходить service через прямую запись сущностей.

## Client app is not created

Проверьте:

- у пользователя есть `CanManageSolution`;
- `SystemUserId` указывает на `SysAdminUnit` типа system user
  (`SysAdminUnitTypeValue = 4`);
- существует ровно один default `OAuthResource`;
- Identity Service доступен по настройкам OAuth20.

Если ошибка пришла от Identity Service, `BaseOAuthApiCaller` отменит entity
event и отправит message `ActingOnOAuthClientApplication`.

## Default resource errors

Симптомы:

- `NoDefaultResourceMessage`;
- `MoreThanOneDefaultResourceMessage`;
- ошибка при создании client app.

Проверьте `OAuthResource`:

- есть один resource с `IsDefault = true`;
- нет второго default resource;
- `DoNotUseForIdentityService` не менялся после создания.

## Cannot delete OAuth resource

`OAuthResourceListener` запрещает удаление resource, который используется
Identity Service. Удаление разрешено только для ресурсов с
`DoNotUseForIdentityService = true`.

## Grant access does not work

Проверьте:

- `OAuthClientApp.ClientId` существует;
- `OAuthResource.Name` существует;
- запись `OAuthResourceInClient` не дублирует уже выданный доступ;
- Identity Service отвечает на `GrantAccess`/`DeleteClientScopes`.

## OAuth20AppPage cannot login user

Проверьте:

- заполнены `ClientId`, `Name`, `AuthorizeUrl`, `TokenUrl`;
- secret доступен через `GetOAuthClientSecret`;
- если `UseSharedUser = true`, заполнен `SharedUser`;
- `GetAuthorizationGrantUrl/{appId}` возвращает URL;
- popup не заблокирован браузером.

## Refresh token is not found

Если UI показывает `RefreshTokenNotFound`, provider завершил authorization, но
refresh token не пришёл. Проверьте:

- `AccessType` должен требовать offline access, если нужен refresh token;
- scopes provider разрешают refresh token;
- provider не требует повторного consent;
- redirect URL совпадает с registered callback.

## User does not appear in OAuthAppUserDetail

Проверьте:

- запись создана в `OAuthTokenStorage`;
- `OAuthTokenStorage.OAuthApp` указывает на нужное `OAuthApplications`;
- `SysUser` соответствует текущему/shared user;
- detail читает `VwOAuthAppUser`, а не исходную entity напрямую.

## Social OAuth callback opens wrong flow

Если URL содержит `socialNetworkName` и попадает в
`OAuthAuthenticationModule.NUI.js`, это social account callback:

```text
../rest/SocialNetworksUtilitiesService/GetOAuthTokens
```

Не диагностируйте его как `ServiceOAuthAuthenticatorEndpoint` или
`OAuthConfigService` flow.

## Связанные документы

- [Auth OAuth20 Integration Overview](auth-oauth20-integration-overview.md)
- [Auth OAuth20 Platform Clients](auth-oauth20-platform-clients.md)
- [Auth OAuth20 Service Authenticator](auth-oauth20-service-authenticator.md)
- [Auth Troubleshooting](auth-troubleshooting.md)
