# Mailbox Exchange OAuth Office365

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Office365, OAuth, Exchange, MailboxSyncSettings, OAuthTokenStorage -->

> Office 365 OAuth в контуре mailbox sync: authenticator endpoints, scope,
> token parsing и создание связанных sync settings.

## Authenticator classes

| Файл | Назначение |
| ---- | ---------- |
| `BaseOffice365OAuthAuthenticator.Exchange.cs` | базовая логика Office 365 OAuth |
| `Office365OAuthAuthenticator.Exchange.cs` | WCF endpoints для authentication flow |

`Office365OAuthAuthenticator` наследует `BaseOffice365OAuthAuthenticator` и
публикует GET methods:

| Method | Назначение |
| ------ | ---------- |
| `AuthenticateUser?userLogin={userLogin}&mailServerId={mailServerId}` | начать OAuth flow |
| `ProcessAuthenticationCode?code={code}` | принять authorization code |

## Office 365 OAuth constants

`BaseOffice365OAuthAuthenticator` задаёт:

| Property | Значение |
| -------- | -------- |
| `AuthorizeUrl` | `https://login.microsoftonline.com/common/oauth2/authorize` |
| `TokenUrl` | `https://login.microsoftonline.com/common/oauth2/token` |
| `Scope` | `Calendars.ReadWrite Contacts.ReadWrite Mail.ReadWrite` |
| `Resource` | `https://outlook.office365.com` |

`AuthenticateUser` добавляет в state `MailServerId` и параметр `prompt=consent`.

## PostprocessAuthentication

После OAuth flow выполняется транзакция:

```text
CreateNewMailboxSyncSettings(userLogin, tokenStorageId)
CreateNewContactCommunications(userLogin)
CreateNewContactSyncSettings(mailboxId)
CreateNewActivitySyncSettings(mailboxId)
```

Если любой шаг падает, transaction rollback.

## id_token parsing

`GetUserNameFromToken` читает `id_token` из OAuth response:

```text
response.id_token
  -> split JWT
  -> base64url decode claim part
  -> claim.unique_name
  -> OAuthUserCredentials.UserLogin
```

Таким образом mailbox email может быть взят из Microsoft claim, а не только из
исходного `userLogin`.

## Token storage boundary

`MailboxSyncSettings.OAuthTokenStorage` ссылается на `OAuthTokenStorage`.
Платформенная модель OAuth applications/tokens описана отдельно в
[Auth OAuth20 Apps And Tokens](auth-oauth20-apps-tokens.md). Этот документ
фиксирует только mailbox-specific Office 365 flow.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Data Model Settings](mailbox-exchange-data-model-settings.md)
- [Auth OAuth20 Apps And Tokens](auth-oauth20-apps-tokens.md)
- [Security UserConnection Context](security-userconnection-context.md)
