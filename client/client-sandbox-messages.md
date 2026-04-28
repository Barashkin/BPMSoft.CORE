# Client Sandbox Messages

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: sandbox, messages, publish, subscribe, PTP, BROADCAST -->

> Sandbox — шина обмена сообщениями между page, section, detail, modules и вложенными компонентами.

## messages block

Сообщения объявляются в `messages`.

```javascript
messages: {
    "GetSocialNetworkData": {
        mode: BPMSoft.MessageMode.PTP,
        direction: BPMSoft.MessageDirectionType.SUBSCRIBE
    },
    "SocialNetworkDataLoaded": {
        mode: BPMSoft.MessageMode.BROADCAST,
        direction: BPMSoft.MessageDirectionType.PUBLISH
    }
}
```

`mode` определяет адресацию, `direction` — роль текущего модуля.

## Message modes

| Mode | Назначение |
| ---- | ---------- |
| `PTP` | point-to-point, обычно с конкретным sandbox id/tag |
| `BROADCAST` | широкая рассылка нескольким подписчикам |

## Directions

| Direction | Назначение |
| --------- | ---------- |
| `PUBLISH` | модуль публикует сообщение |
| `SUBSCRIBE` | модуль подписывается |
| `BIDIRECTIONAL` | модуль может и публиковать, и принимать |

## subscribe

Подписки обычно регистрируются в `subscribeSandboxEvents` или `init`.

```javascript
subscribeSandboxEvents: function() {
    this.callParent(arguments);
    this.sandbox.subscribe("SaveDetail", this.save, this, [this.sandbox.id]);
}
```

Tags ограничивают область доставки.

## publish

Публикация может вернуть значение, если подписчик синхронно отвечает.

```javascript
var socialNetworkData = this.sandbox.publish("GetSocialNetworkData");
if (!socialNetworkData) {
    this.sandbox.subscribe("SocialNetworkDataLoaded", this.onSocialNetworkDataLoaded, this);
}
```

Этот паттерн подходит для "запросить данные, если уже есть, иначе дождаться загрузки".

## Связь page-detail

Типовые сообщения:

- `SaveRecord` — сохранить master page перед действием detail;
- `GetCardState` — получить состояние карточки;
- `UpdateDetail` — обновить detail;
- `DetailChanged`/`DetailSaved` — detail сообщил об изменении;
- `GetColumnsValues` — запросить значения master columns.

## Section messages

Секция может публиковать изменения фильтров.

```javascript
this.sandbox.publish("FiltersChanged", null, [this.sandbox.id]);
this.sandbox.publish("SectionUpdateFilter", null, [this.getQuickFilterModuleId()]);
```

При работе с quick filters используйте id конкретного filter module.

## ServerChannel

Для push-событий используется `BPMSoft.ServerChannel`.

```javascript
BPMSoft.ServerChannel.on(BPMSoft.EventName.ON_MESSAGE, this.onWebSocketMessage, this);
```

Если подписка создаётся вручную, проверьте, где она снимается, чтобы не оставить stale handler.

## Практические правила

- Объявляйте сообщения в `messages`, даже если подписка выполняется вручную.
- Для PTP указывайте tags, иначе сообщение может уйти не тому модулю.
- Не используйте один message name для разных payload shapes.
- Для detail/page взаимодействия проверяйте sandbox id.
- Для broadcast сообщений учитывайте несколько подписчиков и повторные реакции.

## Связанные документы

- [Client Module Overview](client-module-overview.md)
- [Client section and detail patterns](client-section-detail-patterns.md)
- [Client troubleshooting](client-troubleshooting.md)
- [OCC client UI](occ-client-ui.md)
