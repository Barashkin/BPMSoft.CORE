# Integration Tools Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: IntegrationTools, troubleshooting, Webhook, ServiceDesigner -->

> Диагностика Webhook V2 и Web Service V2: designer не открывается, schema не
> сохраняется, auth не работает, token не генерируется или тестовый вызов
> service schema возвращает ошибку.

## Быстрая классификация

| Симптом | Где смотреть |
| ------- | ------------ |
| Designer открывает неверную страницу | `WebhookDesigner`, `WebServicesDesigner`, history hash |
| Нельзя редактировать schema | `CanManageSolution`, `canEditSchema`, package state |
| Webhook token не генерируется | `WebhookAuthInfoSettingsPage`, `WebhookService.IsSecretKeyValid` |
| JWT reminders не приходят | `JWTTokenExpirationNotification`, `WebhookSchemaManager`, `Reminding` |
| Web Service test call запрещён | `CallServiceSchemaService.Execute`, `CanManageSolution` |
| Web Service request собрался неверно | `ServiceSchemaParameterBuilder`, request builders |
| OAuth/Digest auth не виден | feature flags `WebServiceOAuth20Auth`, `WebServiceDigestAuth` |

## Designer открывает неверную страницу

Проверьте hash:

- Webhook edit должен перейти в `CardModuleV2/WebhookV2Page/edit/{schemaId}`;
- Webhook add должен содержать `WebhookV2Page/add/packageUId/{packageUId}`;
- Web Service add должен содержать `{type}WebServiceV2Page/add/packageUId/...`;
- Web Service edit должен перейти в `WebServiceV2Page/edit/{schemaId}`.

Если hash не соответствует, проверяйте `_parseHash`, `_prepareAddParameters` и
`_prepareEditParameters`.

## Нет прав на редактирование

Для Integration Tools ключевая операция - `CanManageSolution`.

Проверьте:

- `WebhookV2Page.SecurityOperationName`;
- `WebhookDesignerUtilities.canEditSchema`;
- `CallServiceSchemaService.Execute`;
- `SystemDesigner.Webhook.js` visibility;
- операции `CanViewConfiguration` / `CanManageSolution` в `VwWebServiceV2`.

## Webhook token не генерируется

`WebhookAuthInfoSettingsPage` перед генерацией вызывает:

```text
WebhookService.IsSecretKeyValid
```

Если ответ неуспешный или `IsValid = false`, token generator не должен
открываться.

Проверьте:

- выбран ли auth type `JWT`;
- заполнены ли `userId` и `validBefore`;
- не изменились ли `userId`/`validBefore` после генерации token;
- доступен ли `WebhookService`;
- включён ли anonymous auth, если нужен auth type `None`.

## JWT reminders не приходят

`JWTTokenExpirationNotification` создаёт reminders только для пользователей,
которые могут выполнить `CanManageSolution`.

Проверьте:

- что процесс запускается;
- что `WebhookSchemaManager.GetItems()` возвращает schemas;
- что auth info имеет тип `JsonWebTokenAuthInfo`;
- что `token` не пустой;
- что `validBefore` парсится как дата;
- что до истечения 30, 15, 0 дней или истекло не более 15 дней.

## Web Service test call падает

`CallServiceSchemaService.Execute`:

- проверяет `CanManageSolution`;
- строит параметры через `IServiceSchemaParameterBuilder`;
- получает schema через `ServiceSchemaManager.GetInstanceByName`;
- создаёт request по method name;
- возвращает raw request/response data.

Проверьте:

- `serviceName` совпадает с schema name;
- `methodName` существует в schema;
- parameters имеют корректные `code`, `value`, `nested`;
- auth settings service schema заполнены;
- base URI и method URI корректны;
- внешний endpoint доступен с сервера.

## OAuth20 или Digest auth не виден

В Web Service V2 auth list фильтруется:

- `Digest` виден при `BPMSoft.isDebug` или feature `WebServiceDigestAuth`;
- `OAuth20` виден при `BPMSoft.isDebug` или feature `WebServiceOAuth20Auth`.

Проверяйте feature state, а не только JS diff.

## Связанные документы

- [Integration Tools Overview](integration-tools-overview.md)
- [Webhook V2 Overview](webhook-v2-overview.md)
- [Web Service V2 Overview](webservice-v2-overview.md)
- [Integration Tools Runtime](integration-tools-runtime.md)
- [Services Troubleshooting](services-troubleshooting.md)
- [Security Troubleshooting](security-troubleshooting.md)
