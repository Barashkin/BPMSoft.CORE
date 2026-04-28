# OCC Pattern Catalog

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OCC, patterns, RequestHandler, routing, connector, Sender -->

> Каталог типовых паттернов доработки OCC и Sender. Используйте его как
> навигатор перед изменением channel, request pipeline, routing, client UI или
> delivery-логики.

## Новый тип канала

Обычный состав изменения:

1. lookup/тип канала в OCC.
2. Клиентский view module для страницы канала.
3. Метод в `BPMSoftOCCAddChannelService`.
4. JSON payload для connector API.
5. Сохранение `BPMSoftOCCChannel`.
6. Проверка webhook/status callback контракта.

Опорные документы:
[occ-channel-integrations.md](occ-channel-integrations.md),
[bpmsoft-occ-services.md](bpmsoft-occ-services.md).

## Новый входящий request type

Request pipeline построен как набор стратегий вокруг `RequestHandler`.

Перед изменением:

- проверьте DTO `Request` в `BPMSoftOCCStrategy.BPMSoftOCC.cs`;
- определите, создаёт ли событие клиента, чат, сообщение или только служебный
  статус;
- учитывайте три пути обработки: WCF, entity event, `RequestHandlingJob`;
- не ломайте idempotency: request может быть обработан повторно.

Для сообщений, которые должны попасть в UI, используйте существующий
`BPMSoftOCCChat` msg channel и принятые `header` значения.

## Status callback

Для статусов исходящих сообщений используйте
`BPMSoftOCCChatMessageStatusRequestHandler`.

Правила:

- status code должен существовать в `BPMSoftOCCChatMessageOutgoingStatus`;
- поиск сообщения идёт по `CrmMessageId` или `ExternalMessageId`;
- не понижайте статус, если в CRM уже записан более поздний код;
- batch-сценарии должны отправлять в UI один агрегированный payload.

Опорный документ:
[occ-outgoing-connector.md](occ-outgoing-connector.md).

## Edit/Delete message

Edit/delete лучше не смешивать с обычным status callback.

Используйте специализированные обработчики:

- `BPMSoftOCCChatMessageEditMessageRequestHandler`;
- `BPMSoftOCCChatMessageDeleteMessageRequestHandler`.

Для edit важно сохранять исходный текст в `BPMSoftOCCOriginalChatMessage`, чтобы
при ошибке connector можно было откатить текст сообщения.

## Routing customisation

Routing зависит от operator unit, channel bindings, queue position и статусов
оператора.

Перед изменением:

- проверьте `BPMSoftOCCRouting.BPMSoftOCC.cs`;
- учитывайте `ChatRoutingJob` и transfer-сценарии;
- не меняйте выбор оператора только на client UI;
- проверяйте закрытые, paused и AFK-состояния отдельно.

Опорный документ:
[occ-routing-strategy.md](occ-routing-strategy.md).

## Sender delivery extension

Sender-логика проходит через:

```text
BPMSoftOCCDelivery
  -> BSDeliveryService / BSSchedulerService
  -> BPMSoftSenderDeliverySchedulerJob
  -> BSDeliveryStrategy
  -> OCC chat/message
```

При доработке delivery:

- добавляйте поля в `BPMSoftOCCDelivery` только если они нужны стратегии или UI;
- отдельно проверяйте `BSDeliveryRecipient` и группы получателей;
- учитывайте тип контента (`Text`, `Picture`, `File`, mixed);
- не отправляйте сообщения напрямую в connector в обход OCC message model.

Опорный документ:
[bpmsoft-sender.md](../extended/bpmsoft-sender.md).

## Client UI extension

Client UI в classic OCC построен вокруг AMD/NUI-модулей:

- `CommunicationPanel.BPMSoftOCC.js`;
- `BPMSoftOCCChatModule.BPMSoftOCC.js`;
- `BPMSoftOCCChatTimelineItemViewModel.BPMSoftOCC.js`;
- channel view modules.

Паттерн изменения:

1. Найти server event/header, который уже приходит в UI.
2. Проверить view model и timeline item.
3. Добавить отображение без изменения server contract, если контракт уже
   достаточен.
4. Если нужен новый header, описать его в server handler и client listener.

Опорный документ:
[occ-client-ui.md](../client/occ-client-ui.md).

## Recovery и диагностика

При неочевидных ошибках сначала определяйте слой:

| Слой | Признак | Документ |
| ---- | ------- | -------- |
| Webhook | есть raw request, нет чата | [occ-request-pipeline.md](occ-request-pipeline.md) |
| Outgoing | сообщение без внешнего id | [occ-outgoing-connector.md](occ-outgoing-connector.md) |
| Routing | чат есть, оператора нет | [occ-routing-strategy.md](occ-routing-strategy.md) |
| Sender | delivery не движется | [bpmsoft-sender.md](../extended/bpmsoft-sender.md) |
| Scheduler | job не срабатывает | [occ-jobs-map.md](occ-jobs-map.md) |

## Антипаттерны

- Обрабатывать webhook только в WCF и забывать про entity event/job recovery.
- Создавать chat message без согласования с `BPMSoftOCCChatMessage` status/edit
  model.
- Отправлять Sender-сообщения напрямую во внешний connector в обход OCC.
- Путать `BPMSoftOCCChat` msg channel с общими Notifications/Reminders.
- Исправлять routing на клиенте вместо серверной стратегии.

## Связанные документы

- [OCC Omnichannel Overview](occ-omnichannel-overview.md)
- [OCC Boundaries](occ-boundaries.md)
- [OCC Outgoing Connector Flow](occ-outgoing-connector.md)
- [OCC / Sender Jobs Map](occ-jobs-map.md)
- [OCC Troubleshooting](occ-troubleshooting.md)
