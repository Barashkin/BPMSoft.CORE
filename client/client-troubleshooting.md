# Client Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: client troubleshooting, AMD, sandbox, diff, ServiceHelper, grid -->

> Практический чеклист диагностики клиентских AMD-модулей BPMSoft.

## Модуль не загружается

Проверки:

- имя в `define("ModuleName", ...)` совпадает с именем схемы;
- зависимости существуют и перечислены в правильном порядке;
- factory function принимает аргументы в том же порядке;
- нет syntax error в `diff`, `attributes`, `messages`;
- CSS dependency подключена через `css!Name`, если нужна.

## Метод не вызывается

Проверки:

- метод находится в `methods`;
- binding в `diff` указывает правильное имя;
- для overridden method вызван `this.callParent(arguments)`, если нужно базовое поведение;
- handler не теряет `scope`;
- attribute `onChange` указывает существующий method.

## Элемент diff не появился

Проверки:

- корректный `parentName`;
- корректный `propertyName` (`items`, `tools`, `activeRowActions`, `tabs`);
- нет duplicate `name`;
- `visible` binding возвращает `true`;
- parent element не был удалён другим `diff`;
- operation `merge` используется только для существующего element.

## Sandbox message не доходит

Проверки:

- message объявлен в `messages` у обоих модулей;
- `mode` и `direction` соответствуют роли;
- PTP tags совпадают;
- используется актуальный `sandbox.id`;
- подписка создана до publish;
- payload shape ожидается одинаковый у отправителя и получателя.

## Detail не обновляется

Проверки:

- master page сохранена и есть `MasterRecordId`;
- filter содержит правильные `masterColumn` и `detailColumn`;
- detail слушает нужное сообщение;
- после изменения данных вызван `reloadGridData` или `updateDetail`;
- `ActiveRow` очищен после смены фильтра;
- custom detail collection реально пересобирает row view models.

## ServiceHelper возвращает неожиданный ответ

Проверки:

- service name и method name совпадают с WCF service;
- параметры соответствуют `BodyStyle`;
- callback читает правильный response shape;
- `scope` передан явно;
- server response содержит `errorInfo`;
- CORS/auth/session не оборвали запрос.

См. [Services troubleshooting](../server/services-troubleshooting.md).

## Client ESQ медленный или возвращает лишнее

Проверки:

- выбраны только нужные колонки;
- есть фильтр по `MasterRecordId` или текущему контексту;
- не выполняется ESQ в цикле UI event;
- тяжелая логика вынесена на сервер;
- после callback проверяется `result.success`.

## Validation не срабатывает

Проверки:

- validator добавлен в `setValidationConfig`;
- validator возвращает `{ invalidMessage: "" }` или message;
- имя колонки совпадает;
- async validation вызывает callback;
- server-side validation не заменена только client-side проверкой.

## Частые ловушки

- `this.BPMSoft` в статическом `return` может работать в существующих generated схемах, но в новых ручных модулях безопаснее использовать `BPMSoft`, если зависимость доступна глобально.
- Комментарии вокруг старого sandbox/service кода могут скрывать устаревший flow.
- Переопределение `BasePageV2` влияет на множество страниц.
- `BPMSoft.ServerChannel.on` требует контроля жизненного цикла подписки.
- `reloadGridData` после каждого insert в цикле может создать лишнюю нагрузку.

## Связанные документы

- [Client Module Overview](client-module-overview.md)
- [Client AMD module anatomy](client-amd-module-anatomy.md)
- [Client sandbox messages](client-sandbox-messages.md)
- [Client service calls](client-service-calls.md)
- [Services troubleshooting](../server/services-troubleshooting.md)
