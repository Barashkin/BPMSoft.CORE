# Services Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, troubleshooting, WCF, REST, ServiceHelper, WebInvoke -->

> Практический чеклист диагностики WCF/REST-сервисов BPMSoft.

## Сервис возвращает 404

Проверьте:

- имя сервиса в client call совпадает с именем класса;
- имя метода совпадает с `UriTemplate` или operation method;
- сервис скомпилирован и находится в актуальном пакете;
- для SSP-сценария есть `[SspServiceRoute]`;
- URL строится как `/0/rest/{ServiceName}/{MethodName}`.

Если используется `ServiceHelper`, временно проверьте сформированный URL через `buildConfigurationUrl`.

## Параметр приходит `null`

Частые причины:

- сервер ждёт `Wrapped`, а клиент отправил bare body;
- сервер ждёт `Bare`, а клиент отправил объект `{ parameterName: value }`;
- имя JSON-поля не совпадает с именем параметра метода;
- тип параметра не соответствует JSON;
- передан stringified JSON там, где метод ждёт DTO, или наоборот.

Сравните `[WebInvoke(BodyStyle = ...)]` и фактический request body.

## Клиент не видит результат

Проверьте response shape:

| Сервер возвращает | Где искать на клиенте |
| ----- | ----- |
| `ConfigurationServiceResponse` | `response.Success`, payload fields |
| обычный object через WCF | `response.{MethodName}Result` |
| `string` | строковое поле result или `response.responseText` |
| direct `AjaxProvider` | `JSON.parse(response.responseText)` |

Если client code проверяет `response.success`, а сервер отдаёт `Success`, условие может не сработать.

## HTTP 500

Проверьте:

- есть ли `try/catch` в service method;
- не падает ли JSON deserialization до входа в business logic;
- доступен ли `UserConnection`;
- есть ли права на операцию;
- не выбрасывает ли `ClassFactory.Get` ошибку binding/constructor;
- не попадает ли `Stream` endpoint под обычный JSON вызов.

Для новых методов возвращайте `ConfigurationServiceResponse`, чтобы клиент получал structured error.

## Ошибка прав

Проверьте:

- `CheckCanExecuteOperation` и точное имя операции;
- лицензии через `LicHelper`, если UI скрывает/показывает действие;
- различие между текущим `UserConnection` и `SystemUserConnection`;
- права портального пользователя в SSP route;
- domain-specific проверки, например доступность только portal user records.

Не исправляйте ошибку прав переходом на `SystemUserConnection` без явного бизнес-требования.

## Сервис работает в приложении, но не в портале

Проверьте:

- наличие `[SspServiceRoute]`;
- права portal user;
- доступность схем/таблиц для portal context;
- не используется ли UI-only dependency;
- не ожидается ли session state, которого нет в текущем сценарии.

## ServiceHelper callback не вызывается

Проверьте:

- корректность `serviceName` и `methodName`;
- JavaScript error до вызова;
- network response в браузере;
- не уходит ли request на другой workspace base URL;
- не блокируется ли endpoint CORS/proxy настройками для внешнего URL.

Для прямых вызовов `AjaxProvider` проверьте ветку `success === false` и `response.responseText`.

## Webhook/callback возвращает "Ok", но данные не появились

Проверьте:

- лог сервиса/пакета;
- запись raw request в staging entity, если она предусмотрена;
- корректность deserialization;
- handler strategy после записи raw request;
- асинхронные job'ы, если обработка отложенная;
- idempotency: не был ли request уже обработан.

В callback endpoint'ах `"Ok"` может означать только принятие запроса, а не успешное выполнение всей бизнес-цепочки.

## Performance проблемы

Проверьте:

- не выполняется ли тяжёлый ESQ/SQL в синхронном UI request;
- нет ли долгого внешнего API call внутри service method;
- не держит ли request файл/stream слишком долго;
- не блокируется ли session из-за записи в session state;
- можно ли перенести работу в Quartz job.

Смежные документы:

- [ESQ performance](esq-performance.md)
- [Quartz class jobs](quartz-class-jobs.md)
- [Services outgoing REST](services-outgoing-rest.md)

## Связанные документы

- [Services Overview](services-overview.md)
- [Service contracts and routing](services-contracts-routing.md)
- [Service responses and errors](services-response-errors.md)
- [Service UserConnection And Security](services-userconnection-security.md)
- [Service client calls](services-client-calls.md)
