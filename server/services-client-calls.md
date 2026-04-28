# Service Client Calls

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, ServiceHelper, callService, AjaxProvider, client -->

> Как клиентские модули BPMSoft вызывают серверные WCF/REST-сервисы.

## Основной URL

Внутренние конфигурационные сервисы обычно доступны по адресу:

```text
/0/rest/{ServiceName}/{MethodName}
```

Клиентский код не должен собирать этот URL вручную, если достаточно `ServiceHelper` или `this.callService`.

## `BPMSoft.ServiceHelper.callService`

Классическая сигнатура:

```javascript
BPMSoft.ServiceHelper.callService(
    "MyService",
    "DoSomething",
    function(response) {
        if (response.Success) {
            // handle response
        }
    },
    { recordId: this.get("Id") },
    this
);
```

В AMD-модулях часто импортируется `ServiceHelper`:

```javascript
define("MyPage", ["ServiceHelper"], function(ServiceHelper) {
    ServiceHelper.callService("MyService", "DoSomething", callback, data, this);
});
```

## Object config style

Встречается вариант с объектом конфигурации:

```javascript
ServiceHelper.callService({
    serviceName: "MyService",
    methodName: "DoSomething",
    data: {
        recordId: this.get("Id")
    },
    callback: function(response) {
        if (response && response.Success) {
            this.reloadGridData();
        }
    },
    scope: this
});
```

Такой стиль удобен, когда параметров вызова много.

## `this.callService`

Некоторые client schema уже имеют helper-метод `callService`.

```javascript
this.callService({
    serviceName: "InsightService",
    methodName: "GetInsightUrlInfo",
    data: {
        slugId: slugRecordId
    }
}, function(response) {
    if (response && response.GetInsightUrlInfoResult) {
        this.$Url = response.GetInsightUrlInfoResult.UrlForView;
        this.$UrlForEdit = response.GetInsightUrlInfoResult.UrlForEdit;
    }
}, this);
```

Обратите внимание на `{MethodName}Result`: это типичный WCF wrapped result.

## Async style

Если доступен promise-helper:

```javascript
const response = await BPMSoft.ServiceHelper.callServiceAsync({
    serviceName: "MyService",
    methodName: "DoSomething",
    data: { recordId: this.get("Id") }
});

if (response.Success) {
    // handle result
}
```

Перед использованием проверьте, что helper доступен в текущей версии и модуле.

## `BPMSoft.AjaxProvider.request`

Прямой request нужен, когда:

- endpoint не совпадает с обычной shape `ServiceHelper`;
- нужно явно задать headers;
- тело запроса не wrapped JSON;
- вызывается custom REST endpoint или stream-like API.

```javascript
BPMSoft.AjaxProvider.request({
    url: BPMSoft.workspaceBaseUrl + "/rest/UisCallRecordService/GetRecordLink",
    scope: this,
    headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
    },
    method: "POST",
    callback: function(request, success, response) {
        if (success) {
            var result = JSON.parse(response.responseText);
            // handle result
        }
    },
    jsonData: JSON.stringify(callId)
});
```

## Обработка ошибок

| Response shape | Проверка |
| ----- | ----- |
| `ConfigurationServiceResponse` | `response.Success` и `response.ErrorInfo` |
| WCF wrapped result | `response.{MethodName}Result` |
| custom JSON string | `JSON.parse(response.responseText)` |
| primitive | проверка самого значения |

Если сервис может вернуть разные shapes, клиентский код быстро становится хрупким. Для новых API лучше стабилизировать contract на сервере.

## Практические правила

- Храните `serviceName` и `methodName` явно рядом с вызовом или в локальной config-функции.
- Не полагайтесь на `response.success`, если сервер возвращает `Success`; проверьте фактический contract.
- Для `BodyStyle.Bare` не используйте wrapped object без проверки server method.
- После ошибки не вызывайте UI update как будто действие успешно.
- Для long-running операций лучше возвращать task/job id, а не держать request открытым.

## Связанные документы

- [Services Overview](services-overview.md)
- [Service contracts and routing](services-contracts-routing.md)
- [Service responses and errors](services-response-errors.md)
- [Services troubleshooting](services-troubleshooting.md)
- [Клиентские утилиты](../client/utilities.md)
