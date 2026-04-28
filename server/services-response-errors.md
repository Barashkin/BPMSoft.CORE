# Service Responses And Errors

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, ConfigurationServiceResponse, BaseResponse, DataContract, errors -->

> Как сервисы BPMSoft возвращают результат, ошибку и полезную нагрузку клиенту.

## Базовый ответ

`ConfigurationServiceResponse` наследуется от `BaseResponse` и по умолчанию создаётся успешным.

```csharp
[DataContract]
public class ConfigurationServiceResponse : BaseResponse
{
    public ConfigurationServiceResponse() {
        Success = true;
    }

    public Exception Exception {
        set {
            Success = false;
            ResponseStatus = SetResponseStatus(value);
            ErrorInfo = SetErrorInfo(value);
        }
    }
}
```

При присваивании `Exception` сервис получает:

- `Success = false`;
- `ResponseStatus.ErrorCode`;
- `ResponseStatus.Message`;
- `ResponseStatus.StackTrace`;
- `ErrorInfo` с теми же ключевыми данными.

## Рекомендуемый шаблон

```csharp
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "DoSomething",
    BodyStyle = WebMessageBodyStyle.Wrapped,
    RequestFormat = WebMessageFormat.Json,
    ResponseFormat = WebMessageFormat.Json)]
public ConfigurationServiceResponse DoSomething(Guid recordId) {
    var response = new ConfigurationServiceResponse();
    try {
        // business logic
    } catch (Exception e) {
        response.Exception = e;
    }
    return response;
}
```

Это предпочтительный вариант для новых конфигурационных endpoint'ов.

## Наследники response

Если сервис возвращает данные, response обычно расширяет `ConfigurationServiceResponse`.

```csharp
[DataContract]
public class CompletenessServiceResponse : ConfigurationServiceResponse
{
    [DataMember(Name = "completeness")]
    public int Completeness { get; set; }
}
```

Преимущество такого подхода: у клиента есть единая модель `Success/ErrorInfo`, но полезная нагрузка остаётся типизированной.

## Primitive/string responses

В решении встречаются сервисы, которые возвращают `bool`, `string` или serialized JSON string.

| Тип | Пример | Комментарий |
| ----- | ----- | ----- |
| `bool` | `CtiRightsService.GetUserHasOperationLicense` | удобно для простых checks |
| `string` `"Ok"` | OCC request callbacks | часто используется для connector/webhook |
| `string` с JSON | portal administration methods | legacy shape, требует ручного parse на клиенте |
| `void` | batch recalculation endpoint | подходит только если клиенту не нужна диагностика |

Для новых endpoint'ов лучше выбирать `ConfigurationServiceResponse` или наследника, если нет явной причины сохранять legacy contract.

## Wrapped result на клиенте

WCF может вернуть результат внутри свойства `{MethodName}Result`.

```javascript
this.callService({
    serviceName: "InsightService",
    methodName: "GetInsightUrlInfo",
    data: { slugId: slugRecordId }
}, function(response) {
    if (response && response.GetInsightUrlInfoResult) {
        this.$Url = response.GetInsightUrlInfoResult.UrlForView;
    }
}, this);
```

Если сервис возвращает `ConfigurationServiceResponse`, клиент чаще проверяет `response.Success` или `response.success`, в зависимости от используемого helper'а и конкретного DTO.

## Error handling strategy

| Ситуация | Что делать |
| ----- | ----- |
| ожидаемая бизнес-ошибка | вернуть response с `Success = false` и понятным сообщением |
| security violation | использовать `DBSecurityEngine.CheckCanExecuteOperation` и преобразовать исключение в response, если клиент должен показать сообщение |
| webhook callback | логировать ошибку и возвращать contract, ожидаемый внешней системой |
| неизвестная ошибка | `response.Exception = e`, плюс server log для диагностики |

## Чего избегать

- Не смешивать в одном новом API несколько shapes ответа.
- Не возвращать raw exception message как единственный contract для UI.
- Не скрывать ошибку `Success = true`, если действие фактически не выполнено.
- Не полагаться на stack trace на клиенте как на пользовательское сообщение.

## Связанные документы

- [Services Overview](services-overview.md)
- [Service contracts and routing](services-contracts-routing.md)
- [Service UserConnection And Security](services-userconnection-security.md)
- [Service client calls](services-client-calls.md)
- [Services troubleshooting](services-troubleshooting.md)
