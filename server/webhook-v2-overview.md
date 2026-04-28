# Webhook V2 Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Webhook, WebhookV2, designer, auth, JWT -->

> Webhook V2 в Integration Tools: view-схема, дизайнер, методы, параметры,
> action rules, auth settings и напоминания о JWT token expiration.

## Модель

`VwWebhookV2Schema.Webhook.cs` описывает view-схему:

- наследуется от `VwSysSchemaInWorkspaceSchema`;
- `Name = "VwWebhookV2"`;
- `IsDBView = true`;
- `UId` не обязателен;
- создаёт entity `VwWebhookV2`;
- работает как metadata view над webhook schema in workspace.

Сопутствующие схемы:

| Схема | Назначение |
| ----- | ---------- |
| `WebhookV2FolderSchema.Webhook.cs` | папки webhook-схем |
| `WebhookV2TagSchema.Webhook.cs` | теги webhook-схем |
| `VwWebhookV2Schema.Webhook.cs` | представление для UI section/page |

## Designer shell

`WebhookDesigner.Webhook.js` наследуется от `BaseViewModule` и нормализует hash:

```text
edit/{schemaId}
  -> CardModuleV2/WebhookV2Page/edit/{schemaId}

add/.../{packageUId}
  -> CardModuleV2/WebhookV2Page/add/packageUId/{packageUId}
```

Модуль добавляет CSS wrapper `webhooks` и использует sandbox-сообщения:

- `GetHistoryState`;
- `ReplaceHistoryState`;
- `LoadModule`;
- `HistoryStateChanged`;
- `RefreshCacheHash`;
- `NavigationModuleLoaded`.

## Webhook page

`WebhookV2Page.Webhook.js` работает с `entitySchemaName: "VwWebhookV2"` и
миксином `WebhookMetaItemViewModelMixin`.

Ключевые virtual attributes:

| Attribute | Назначение |
| --------- | ---------- |
| `Name` | schema name |
| `Caption` | отображаемое имя |
| `Description` | описание |
| `ClientUrl` | клиентский URL |
| `ReceivingRequestsUrl` | URL приёма запросов |
| `IsWebhookLoggingEnabled` | логирование webhook |
| `IsBodyWebhookLoggingEnabled` | логирование body |
| `PackageLookup` / `PackageUId` | пакет сохранения |
| `Schema` | instance webhook schema |
| `ManagerItem` | schema manager item |
| `CanEditSchema` | возможность редактирования |

Деталь `MethodDetail` подключает `WebhookMethodDetail`.

## Методы, параметры и action rules

UI-компоненты:

- `WebhookMethodPage.Webhook.js`;
- `WebhookMethodDetail.Webhook.js`;
- `WebhookMethodModule.Webhook.js`;
- `WebhookParameterPage.Webhook.js`;
- `WebhookResponseParameterPage.Webhook.js`;
- `WebhookActionRulePage.Webhook.js`;
- `WebhookActionRuleGrid.Webhook.js`.

`WebhookEnums.Webhook.js` задаёт captions для action rule types:

- `START_BP`;
- `READ_DATA`;
- `CHANGE_DATA`;
- `CREATE`;
- `DELETE`.

Также enum module описывает data value type captions, empty value passing
format и auth type captions.

## Auth settings

`WebhookAuthInfoSettingsPage.Webhook.js` поддерживает:

- `None`;
- `Basic`;
- `JWT`.

Страница вызывает `WebhookService` через `ServiceHelper`:

| Method | Назначение |
| ------ | ---------- |
| `UseAnonymousAuth` | разрешено ли anonymous auth |
| `IsSecretKeyValid` | можно ли генерировать JWT token |

Для JWT auth хранятся `userId`, `token`, `tokenHeader`, `validBefore`.
Если `userId` или `validBefore` изменились, `WebhookV2Page` очищает token и
предлагает открыть generator.

## JWT expiration notification

`JWTTokenExpirationNotification.Webhook.cs` - process script wrapper, который:

- получает `WebhookSchemaManager`;
- перебирает webhook schemas;
- ищет `JsonWebTokenAuthInfo`;
- проверяет `ValidBefore`;
- создаёт `Reminding` для пользователей с `CanManageSolution`.

Напоминания создаются за 30 дней, 15 дней, в день истечения и после истечения
по нечётным дням до 15 дней.

## Security

UI использует operation `CanManageSolution`:

- `WebhookV2Page.SecurityOperationName`;
- `WebhookDesignerUtilities.canEditSchema`;
- tile visibility в `SystemDesigner.Webhook.js`.

## Связанные документы

- [Integration Tools Overview](integration-tools-overview.md)
- [Integration Tools Runtime](integration-tools-runtime.md)
- [Integration Tools Boundaries](integration-tools-boundaries.md)
- [Notifications Reminders Overview](notifications-reminders-overview.md)
