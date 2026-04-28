# Auth OAuth20 Pattern Catalog

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20, patterns, IdentityServiceWrapper, OAuthApplications -->

> Каталог повторяющихся паттернов OAuth20Integration.

## Pattern: Local entity mirrors Identity Service

`OAuthClientApp`, `OAuthResource` и `OAuthResourceInClient` хранят локальную
модель, а listeners синхронизируют её с Identity Service.

Признаки:

- entity event listener на схеме;
- `CanManageSolution` до изменения;
- `IdentityServiceWrapper` call в `OnInserting`/`OnUpdating`/`OnDeleting`;
- cancel event при ошибке внешнего API.

Source: `OAuthClientAppListener.OAuth20.cs`, `OAuthResourceListener.OAuth20.cs`.

## Pattern: Fail fast on external API error

`BaseOAuthApiCaller.ExecuteApiCall` отменяет entity event и бросает localizable
exception, если Identity Service недоступен или вернул ошибку.

Это защищает от состояния, где запись есть в БД, но не зарегистрирована во
внешнем Identity Service.

## Pattern: One default resource

`OAuthResourceListener` разрешает только один `IsDefault = true` resource.
`OAuthClientAppListener` использует default resource при создании client.

## Pattern: Feature-driven Identity wrapper

`BaseOAuthApiCaller` выбирает named wrapper:

```text
FeatureUseSeparateSettingsForOAuth20
  -> IIdentityServiceWrapper("OAuth20Integration")
```

Иначе используется default `IIdentityServiceWrapper`.

## Pattern: Integration app as provider metadata

`OAuthApplications` хранит endpoints, client credentials, access type и shared
user. Tokens при этом живут отдельно в `OAuthTokenStorage`.

Это разделяет provider configuration и user authorization state.

## Pattern: Page details mirror child entities

`OAuth20AppPage` подключает details:

- `OAuthAppScopeDetail` -> `OAuthAppScope`;
- `OAuthAppUserDetail` -> `VwOAuthAppUser`.

Scopes редактируются как дочерние записи, users показываются через view над
token storage.

## Pattern: OAuth callback via server channel

После authorization code redirect endpoint отправляет client message с sender:

```text
ServiceOAuthAuthenticatorEndpoint
```

UI handler проверяет sender, разбирает response и обновляет state page.

## Pattern: UI never reads raw secure values directly

`OAuth20AppPage` получает secret через endpoint helper
`getOAuthServiceClientSecretKey`, а не через прямое чтение `SecureText` поля.

## Связанные документы

- [Auth OAuth20 Platform Clients](auth-oauth20-platform-clients.md)
- [Auth OAuth20 Integration Apps](auth-oauth20-integration-apps.md)
- [Auth OAuth20 Service Authenticator](auth-oauth20-service-authenticator.md)
- [Auth Pattern Catalog](auth-pattern-catalog.md)
