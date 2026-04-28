# Auth Pattern Catalog

<!-- Версия: 1.1 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: auth, LDAP, OAuth, SSO, patterns -->

> Каталог повторяемых Auth / SSO / LDAP паттернов в Base.

## LDAP settings through SysSettings

LDAP не хранит настройки в отдельной таблице конфигурации. `LdapSettingsProvider`
читает коды `SysSettings`, нормализует сервер/порт и вычисляет `AuthType`.

## LDAP connector with retry and rebind

`LdapConnector` применяет retry policy к `SearchRequest`. Для временной потери
авторизации в Active Directory делает rebind и повторяет запрос.

## Non-idempotent LDAP operations without recovery

Recovery применяется к поисковым запросам. Для изменений данных retry/rebind
ограничен, чтобы не повторять неидемпотентные операции.

## LDAP staging before SysAdminUnit

LDAP sync сначала складывает данные в `SysLDAPSynchUser` /
`SysLDAPSynchGroup`, затем актуализирует `SysAdminUnit`, `SysUserInRole` и
`LDAPUserInLDAPGroup`.

## Static semaphores for sync critical sections

`SyncWithLDAPProcessHelper` использует static `SemaphoreSlim`, чтобы
синхронизации LDAP не конфликтовали при вставке admin units и jobs.

## Admin UI guarded by operation

`LDAPServerSettings` и OAuth app pages задают operation names:

- `CanManageAdministration`;
- `CanManageSolution`.

Клиентская проверка должна дублироваться серверной проверкой.

## OAuth client listener syncs identity service

`OAuthClientAppListener` отправляет create/update/delete в
`IdentityServiceWrapper`, а затем сохраняет `ClientId`/`ClientSecret` и связь
с default resource.

## OAuth disabled feature guard

`OAuthConfigService` проверяет `GlobalAppSettings.FeatureEnableOAuth20Integration`
и возвращает понятный error response, если интеграция выключена.

## OAuth token storage by user and app

`OAuthTokenStorage` связывает `SysUser`, `OAuthApp`, `UserAppLogin`,
`AccessToken`, `RefreshToken`, `ExpiresOn`.

Подробный каталог OAuth20Integration-паттернов: см.
[auth-oauth20-pattern-catalog.md](auth-oauth20-pattern-catalog.md).

## SAML mapping, not full SSO pipeline

`SAMLFieldNameConverter` — mapping атрибутов SAML в `Contact`. Не используйте
его как доказательство наличия полного SAML login flow в Base package.

## SSP registration with SystemUserConnection

`UserManagementService` использует `SystemUserConnection`, потому что
self-registration выполняется до авторизации пользователя.

## Login reservation check

Self-registration проверяет `LoginReservationPeriod` и
`SysAdminUnitNameReserve`, чтобы не выдать недавно зарезервированный login.

## Password recovery without user enumeration

`TotpSendResetPasswordLinkService` возвращает success даже если email не найден.
Ошибка логируется в `Authentication`, но наружу не раскрывается наличие
пользователя.

## Session termination through IUserSessionManager

`AdministrationService` завершает сессии через `IUserSessionManager.Expire`,
а запись `SysUserSession` используется как источник `SessionId`.
