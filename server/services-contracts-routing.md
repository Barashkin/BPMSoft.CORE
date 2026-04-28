# Service Contracts And Routing

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, ServiceContract, OperationContract, WebInvoke, DefaultServiceRoute, SspServiceRoute -->

> Как объявлять WCF/REST endpoint'ы BPMSoft: атрибуты класса, атрибуты метода, `BodyStyle` и маршрутизация.

## Минимальный контракт

Типовой сервис содержит WCF-контракт, REST-метод и совместимость с ASP.NET session.

```csharp
[ServiceContract]
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class MyService : BaseService, IReadOnlySessionState
{
    [OperationContract]
    [WebInvoke(Method = "POST", UriTemplate = "DoSomething",
        BodyStyle = WebMessageBodyStyle.Wrapped,
        RequestFormat = WebMessageFormat.Json,
        ResponseFormat = WebMessageFormat.Json)]
    public ConfigurationServiceResponse DoSomething(Guid recordId) {
        return new ConfigurationServiceResponse();
    }
}
```

В большинстве конфигурационных сервисов используется `POST` и JSON.

## Route attributes

| Атрибут | Назначение |
| ----- | ----- |
| `[DefaultServiceRoute]` | публикует сервис в стандартном app route |
| `[SspServiceRoute]` | добавляет маршрут для портала самообслуживания |
| без route attribute | endpoint всё равно может быть доступен как configuration service, если зарегистрирован платформой |

Пример совмещения основного и SSP route есть в `FileApiService.NUI.cs` и `CompletenessService.Completeness.cs`.

## UriTemplate

`UriTemplate` задаёт последний сегмент URL.

```text
/0/rest/CompletenessService/GetRecordCompleteness
```

Если `UriTemplate` не указан, метод часто вызывается по имени operation, но для новых endpoint'ов лучше задавать его явно. Это облегчает диагностику и client-side вызовы.

## BodyStyle

| Значение | Что ожидает сервис | Когда применять |
| ----- | ----- | ----- |
| `Wrapped` | JSON-объект с параметрами метода | обычные методы с несколькими параметрами |
| `WrappedRequest` | wrapped request, response без дополнительной WCF-обёртки | дизайнеры/сложные DTO |
| `Bare` | тело запроса напрямую соответствует одному параметру | stream upload, webhook DTO, raw JSON |

Пример `Wrapped`:

```json
{
  "recordId": "00000000-0000-0000-0000-000000000000",
  "schemaName": "Contact"
}
```

Пример `Bare` для DTO:

```json
{
  "Resquests": [
    {
      "MessageId": "..."
    }
  ]
}
```

## Stream endpoints

Для загрузки файлов обычно используется `Stream` и `BodyStyle = Bare`.

```csharp
[OperationContract]
[WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
    BodyStyle = WebMessageBodyStyle.Bare,
    ResponseFormat = WebMessageFormat.Json)]
public ConfigurationServiceResponse UploadFile(Stream fileContent) {
    var response = new ConfigurationServiceResponse();
    // upload
    return response;
}
```

Такой endpoint нельзя вызывать как обычный wrapped JSON-метод через стандартный объект параметров.

## Тонкий facade

Хороший сервисный слой часто остаётся тонким:

- принимает параметры;
- создаёт domain service через `ClassFactory`;
- передаёт `UserConnection`;
- переводит исключение в response;
- не содержит большой бизнес-логики.

Пример:

```csharp
private BaseCompletenessService CreateCompletenessService() {
    return ClassFactory.Get<BaseCompletenessService>(
        new ConstructorArgument("userConnection", UserConnection));
}
```

## Частые ошибки

| Симптом | Возможная причина |
| ----- | ----- |
| HTTP 404 | неверные `ServiceName`, `MethodName`, route attribute или `UriTemplate` |
| параметр `null` | mismatch между `BodyStyle` и JSON body |
| HTTP 500 до входа в бизнес-логику | неверный JSON, тип параметра или отсутствует session |
| метод доступен в приложении, но не в SSP | нет `[SspServiceRoute]` или прав портального пользователя |

## Связанные документы

- [Services Overview](services-overview.md)
- [Service responses and errors](services-response-errors.md)
- [Service client calls](services-client-calls.md)
- [Services troubleshooting](services-troubleshooting.md)
