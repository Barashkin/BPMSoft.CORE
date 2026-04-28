# Client UI Advanced Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: client, UI, NUI, BasePageV2, BaseSectionV2, sandbox, RightUtilities -->

> Capstone dive по продвинутым UI-паттернам: NUI base modules, package patches,
> details, sandbox, client service calls и границы клиентской безопасности.

## Когда открывать

| Задача | Документ |
| ------ | -------- |
| Разобрать AMD-модуль | [client-amd-module-anatomy.md](client-amd-module-anatomy.md) |
| Понять lifecycle карточки | [client-page-lifecycle.md](client-page-lifecycle.md) |
| Настроить section/detail | [client-section-detail-patterns.md](client-section-detail-patterns.md) |
| Изменить `diff`/`attributes`/rules | [client-diff-attributes-rules.md](client-diff-attributes-rules.md) |
| Связать модули через sandbox | [client-sandbox-messages.md](client-sandbox-messages.md) |
| Вызвать сервер | [client-service-calls.md](client-service-calls.md) |

## NUI base vs package patches

| Вид файла | Роль |
| --------- | ---- |
| `BasePageV2.NUI.js` | базовый слой карточек |
| `BaseSectionV2.NUI.js` | базовый слой секций |
| `BasePageV2.<Package>.js` | пакетное расширение базовой страницы |
| `<Entity>PageV2.<Package>.js` | карточка конкретной сущности |
| `<Entity>SectionV2.<Package>.js` | секция конкретной сущности |

Wide-impact patch базового модуля должен быть редким. Если изменение касается
одной карточки или секции, патчить нужно конкретный модуль, а не `BasePageV2`.

## Details as integration points

Detail связывает master page и дочернюю entity через metadata:

```javascript
details: {
  "SomeDetail": {
    "schemaName": "SomeDetail",
    "entitySchemaName": "ChildEntity",
    "filter": {
      "detailColumn": "Parent",
      "masterColumn": "Id"
    }
  }
}
```

Практические правила:

- `detailColumn` должен быть lookup на master entity;
- обновление detail часто идёт через sandbox messages;
- сложная фильтрация лучше живёт в detail methods, а не в parent page;
- массовые операции detail должны иметь серверную проверку прав.

## Business rules and designer markers

Блоки вида `/**SCHEMA_BUSINESS_RULES*/` и `/**SCHEMA_DIFF*/` могут
обновляться дизайнером. Ручные изменения должны быть минимальными и понятными.

Если правило выражается декларативно, используйте `businessRules`. Если логика
зависит от async service call или сложного состояния page, используйте methods и
attributes с `onChange`.

## Client-service boundary

| Client | Server |
| ------ | ------ |
| `ServiceHelper`, `this.callService`, `AjaxProvider` | WCF/REST service |
| Client ESQ for read scenarios | server ESQ/SQL for trusted operations |
| `RightUtilities` for UX | `DBSecurityEngine` and service checks |
| Sandbox and view model state | business invariants and transactions |

Клиент не должен быть единственным местом проверки прав, лицензий или бизнес-
инвариантов.

## Source file map

| Паттерн | Source file |
| ------- | ----------- |
| base page + rights/services | `BasePageV2.NUI.js` |
| base section + reload messages | `BaseSectionV2.NUI.js` |
| service helper | `ServiceHelper.NUI.js` |
| right utility | `RightUtilities.NUI.js` |
| сложная page + details | `WebhookV2Page.Webhook.js` |
| BasePageV2 package patch | `BasePageV2.WSFieldsmanagement.js` |
| section actions | `InsightApplicationSection.InsightReport.js` |
| direct REST | `UisCtiProvider.WebRTCCore.js` |

## Troubleshooting

| Симптом | Проверить |
| ------- | --------- |
| Метод не вызывается | `define` dependencies, method name, `scope`, parent method |
| UI state не обновляется | attribute binding, `onChange`, `this.set`, view model value |
| Detail пустой | `detailColumn`/`masterColumn`, filters, rights, reload message |
| Sandbox message не приходит | mode PTP/BROADCAST, tags, module id, subscribe timing |
| Кнопка видна без права | server check missing, `RightUtilities` only UX |
| Service call падает 404/500 | route, method name, request shape, service response model |

## Связанные документы

- [Client Module Overview](client-module-overview.md)
- [Client Pattern Catalog](client-pattern-catalog.md)
- [Client Troubleshooting](client-troubleshooting.md)
- [Security Client Rights](../server/security-client-rights.md)
- [Services Client Calls](../server/services-client-calls.md)
