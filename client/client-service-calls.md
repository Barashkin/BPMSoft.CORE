# Client Service Calls

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ServiceHelper, callService, AjaxProvider, EntitySchemaQuery, client ESQ -->

> Вызовы серверных сервисов и запросы данных из клиентских модулей.

## ServiceHelper.callService

Классический вариант:

```javascript
ServiceHelper.callService(
    "WebhookService",
    "GetWebhookAuthInfo",
    function(response) {
        this.handleResponse(response);
    },
    data,
    this
);
```

Порядок аргументов зависит от overload, поэтому сверяйтесь с существующим примером в модуле.

## callService config style

В некоторых файлах используется объект конфигурации.

```javascript
ServiceHelper.callService({
    serviceName: "MyService",
    methodName: "MyMethod",
    data: {
        id: this.get("Id")
    },
    callback: this.onServiceResponse,
    scope: this
});
```

Этот стиль лучше читается, если параметров много.

## this.callService

Некоторые modules используют method wrapper на view model.

```javascript
this.callService({
    serviceName: "MyService",
    methodName: "MyMethod",
    data: requestData
}, this.onResult, this);
```

Выбирайте стиль, который уже принят в текущем модуле.

## AjaxProvider

`BPMSoft.AjaxProvider.request` применяется для прямого REST/HTTP вызова.

```javascript
BPMSoft.AjaxProvider.request({
    url: BPMSoft.workspaceBaseUrl + "/rest/UisCallRecordService/GetRecordLink",
    method: "POST",
    jsonData: data,
    callback: function(options, success, response) {
        // handle response
    },
    scope: this
});
```

Для внутренних WCF-сервисов обычно предпочтительнее `ServiceHelper`, потому что он лучше соответствует BPMSoft response conventions.

## Client ESQ

Клиентские модули могут читать данные через `BPMSoft.EntitySchemaQuery`.

```javascript
var esq = Ext.create("BPMSoft.EntitySchemaQuery", {
    rootSchemaName: "BSDeliveryRecipient"
});
esq.addColumn("Id");
esq.filters.add("DeliveryFilter", BPMSoft.createColumnFilterWithParameter(
    BPMSoft.ComparisonType.EQUAL,
    "Delivery",
    this.get("MasterRecordId")
));
esq.getEntityCollection(function(result) {
    if (result.success) {
        this.sandbox.publish("getRecipientCount", result.collection.collection.length);
    }
}, this);
```

Для сложной business logic лучше использовать серверный сервис.

## Process start

Для запуска процесса используйте `ProcessModuleUtilities.executeProcess`.

```javascript
ProcessModuleUtilities.executeProcess({
    sysProcessName: "InsightSynchronizationProcess"
});
```

Подробнее см. [Process starting](../server/process-starting.md).

## Обработка ответа

Проверяйте:

- `success`;
- `response.errorInfo`;
- shape wrapped response;
- наличие expected payload;
- scope callback.

Не полагайтесь на один формат ответа для всех сервисов: WCF methods могут возвращать primitive, DTO или wrapped object.

## Связанные документы

- [Services client calls](../server/services-client-calls.md)
- [Services response errors](../server/services-response-errors.md)
- [Process starting](../server/process-starting.md)
- [Client troubleshooting](client-troubleshooting.md)
