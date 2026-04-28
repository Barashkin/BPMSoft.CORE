# Auth OAuth20 Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OAuth20, boundaries, SSO, IntegrationTools, Exchange, Social -->

> Границы OAuth20Integration с соседними подсистемами. Цель - не смешивать
> platform OAuth clients, integration OAuth apps и другие auth flows.

## SSO / LDAP / SAML / OpenID

SSO/LDAP документы описывают вход пользователя в платформу, directory sync и
federation. OAuth20Integration описывает OAuth applications и tokens.

| Не путать | Почему |
| --------- | ------ |
| LDAP synchronization | работает с directory users/groups, не OAuth client apps |
| SAML/OpenID login | login pipeline, не `OAuthConfigService` |
| `OAuthClientApp` | внешний client для platform resources, не SSO provider |

См. [Auth SSO LDAP Overview](auth-sso-ldap-overview.md) и
[Auth SSO SAML OpenID](auth-sso-saml-openid.md).

## Mailbox Office365 OAuth

`Office365OAuthAuthenticator` относится к Exchange/mailbox sync. Он получает
Microsoft token и создаёт `MailboxSyncSettings`, contact/activity sync settings.

OAuth20Integration может использовать общую терминологию и token storage, но
Mailbox Office365 flow не является `OAuthConfigService` registration и не
настраивается через `OAuth20AppPage`.

См. [Mailbox Exchange OAuth Office365](mailbox-exchange-oauth-office365.md).

## Integration Tools OAuth20 auth type

`ServiceDesigner` может показывать auth type `OAuth20` для Web Service V2.
Это credentials настройки конкретного outgoing service schema call.

| Integration Tools | OAuth20Integration |
| ----------------- | ------------------ |
| auth type в `ServiceAuthInfoSettingsPage` | registry of OAuth applications |
| используется для Web Service V2 call | используется для external provider authorization |
| зависит от `WebServiceOAuth20Auth` | зависит от `OAuthApplications` и endpoint flow |

См. [Web Service V2 Overview](webservice-v2-overview.md).

## Social accounts

`OAuthAuthenticationModule.NUI.js` разбирает URL hash, берёт
`socialNetworkName` и вызывает:

```text
../rest/SocialNetworksUtilitiesService/GetOAuthTokens
```

Это callback внешних social accounts. Он не является platform OAuth client
registration и не заменяет `ServiceOAuthAuthenticatorEndpoint` flow.

См. [ESN Social Network Integration](esn-social-network-integration.md).

## SSP / portal

SSP/portal документы описывают portal users, permissions, registration и
external access model. OAuth20 apps не управляют ACL и не создают portal users.

Публичные URLs OAuth endpoints не означают, что flow относится к SSP.

## Legacy Google integration

Файлы `*OldGoogleIntegration*.cs` относятся к legacy Google integration. Их
можно использовать как исторический пример OAuth-клиентов, но это не основной
OAuth20Integration registry.

## Связанные документы

- [Auth OAuth20 Integration Overview](auth-oauth20-integration-overview.md)
- [Integration Tools Boundaries](integration-tools-boundaries.md)
- [Mailbox Exchange Boundaries](mailbox-exchange-boundaries.md)
- [SSP Portal Overview](ssp-portal-overview.md)
