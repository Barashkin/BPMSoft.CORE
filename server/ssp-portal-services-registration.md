# SSP Portal Services And Registration

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, services, registration, password recovery -->

> SSP services, маршруты, регистрация, сброс пароля и whitelist кастомных
> portal services.

## SSP service routing

SSP services используют тот же WCF-паттерн, но часто имеют оба маршрута:

- `[DefaultServiceRoute]`;
- `[SspServiceRoute]`;
- `[ServiceContract]`;
- `[WebInvoke(Method = "POST")]`.

Пример: `SspUserManagementService.SSP.cs`.

## UserManagementService

`UserManagementService.SSP.cs` обслуживает self-service сценарии:

- регистрация;
- восстановление пароля;
- работа с token data;
- создание contact при регистрации;
- проверка зарезервированного login;
- проверка existing `SysAdminUnit` по `Contact`;
- культура пользователя из HTTP context.

`Register` использует `BodyStyle = Bare` и проверяет:

```text
GlobalAppSettings.ShowPortalSelfRegistrationLink
```

Если self-registration выключена, сервис возвращает error result.

## Registration helper

`RegistrationHelper.SSP.cs` отвечает за письма, шаблоны, Contact и интеграцию
с SSP configuration. В self-service сценариях это отдельный слой, а не часть
UI page.

## Password reset and TOTP

`TotpSendResetPasswordLinkService.SSP.cs` — отдельный сервис для отправки
ссылки сброса пароля с TOTP-контуром.

Диагностика:

- logger category `Authentication`;
- `SiteUrl`;
- email template/settings;
- token validity.

## Custom SSP services whitelist

`GetCustomerSspServiceList.SSP.cs` собирает custom REST services не из
репозитория:

- читает `SspServices\CustomerSspServiceList.txt`;
- использует reflection по `ServiceRoutes`;
- формирует список доступных customer SSP services.

Если custom service не виден из портала, проверяйте этот список.

## Практические правила

- Для portal endpoint добавляйте `SspServiceRoute`, если он должен вызываться
  portal user.
- Для self-registration проверяйте `ShowPortalSelfRegistrationLink`.
- Для register/reset password используйте `SystemUserConnection` осторожно:
  это публичный сценарий.
- Ошибки self-service возвращайте структурно, не раскрывая лишние детали.
- Custom SSP service должен быть не только реализован, но и доступен в whitelist.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal users](ssp-portal-users.md)
- [Services overview](services-overview.md)
- [Services contracts routing](services-contracts-routing.md)
