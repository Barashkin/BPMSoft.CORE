# OCC Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OCC, boundaries, notifications, email, CTI, mobile, ESN -->

> Границы OCC / Omnichannel: что относится к чату и Sender, а что находится
> в соседних подсистемах.

## Что считать OCC

К OCC относятся:

- `BPMSoftOCCChannel`, `BPMSoftOCCChat`, `BPMSoftOCCChatMessage`,
  `BPMSoftOCCClient`;
- operator status, routing, transfer, AFK;
- WCF-сервисы `BPMSoftOCCChatService`, `BPMSoftOCCChatRequestService`,
  `BPMSoftOCCAddChannelService`;
- msg channel `BPMSoftOCCChat`;
- Sender-рассылки через `BPMSoftOCCDelivery` и OCC-каналы.

## Notifications / Reminders

Notifications и Reminders обслуживают центр уведомлений, напоминания и
системные push/websocket-события. Это не OCC chat transport.

| OCC | Notifications / Reminders |
| --- | ------------------------- |
| `MsgChannelUtilities.PostMessageToAll("BPMSoftOCCChat", ...)` | delivery уведомлений и напоминаний |
| счётчик и события чатов в `CommunicationPanel` | badges, reminder center, push-уведомления |
| `BPMSoftOCCChatMessage` | `Reminding` и связанные модели |

Если проблема в карточке чата или статусе сообщения, начинайте с OCC. Если
проблема в системном уведомлении, reminder badge или push вне чата, смотрите
Notifications / Reminders.

## Activity / Email

OCC message не является email activity.

| OCC | Activity / Email |
| --- | ---------------- |
| external messenger connector | mailbox sync / EmailSender |
| `BPMSoftOCCChatMessage` | `Activity`, email body, mailbox |
| connector status callback | mail delivery/sync status |

Sender в OCC тоже не заменяет email-рассылку: он использует OCC-каналы и
создаёт OCC-чаты/сообщения.

## CTI

OCC и CTI могут встречаться в одном `CommunicationPanel`, но домены разные.

| OCC | CTI |
| --- | --- |
| чат, messaging, operator queue | звонок, call state, telephony provider |
| `BPMSoftOCCChat` | call/activity entities |
| routing чатов | routing/обработка звонков |

Если падает общая панель коммуникаций, проверяйте обе области. Если ломается
статус звонка или dialer, это не OCC.

## Mobile

Classic OCC UI построен на AMD/NUI-модулях. Mobile/offline клиент имеет
собственные ограничения и не наследует автоматически логику classic
`CommunicationPanel`.

Документируйте mobile-сценарии отдельно, если чат используется в мобильном
контуре.

## ESN / Feed

ESN message/post не является OCC chat message.

| OCC | ESN |
| --- | --- |
| `BPMSoftOCCChatMessage` | feed message/post |
| operator chat timeline | social feed |
| external messenger connector | internal collaboration/feed |

Совпадение слова "message" в названиях не означает общий pipeline.

## External connectors

Connector находится за границей BPMSoft.

BPMSoft хранит:

- конфигурацию канала;
- webhook endpoint;
- raw request/status records;
- OCC domain entities.

Connector отвечает за:

- специфику внешнего мессенджера;
- provider API;
- доставку внешних callbacks;
- внешние message ids и channel-specific payload.

Граница контракта проходит через WCF-сервисы OCC и исходящие вызовы из
`BPMSoftOCCApi`.

## Связанные документы

- [OCC Omnichannel Overview](occ-omnichannel-overview.md)
- [Архитектура OCC-подсистем](../architecture/bpmsoft-occ.md)
- [OCC Outgoing Connector Flow](occ-outgoing-connector.md)
- [Notifications / Reminders Overview](notifications-reminders-overview.md)
- [BPMSoftSender в OCC-контуре](../extended/bpmsoft-sender.md)
- [CTI / Telephony Overview](cti-telephony-overview.md)
- [ESN / Feed Overview](esn-feed-social-overview.md)
