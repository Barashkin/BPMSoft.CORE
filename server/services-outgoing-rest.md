# Services Outgoing REST

<!-- Версия: 1.3 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Services, REST, IWebServiceClient, RestSharp, integrations, AI, LLM, ML, IntegrationTools -->

> Чем внутренний WCF/REST-сервис отличается от исходящего вызова внешнего API и как документировать границу интеграции.
> LLM provider-ы пакета `.AI` являются частным случаем исходящего REST; подробности см. в [AI LLM Providers](ai-llm-providers.md).
> Metadata-driven исходящие Web Service V2 описаны отдельно:
> [Web Service V2 Overview](webservice-v2-overview.md).

## Две стороны service-кода

В BPMSoft service-код часто решает одну из двух задач:

| Задача | Пример |
| ----- | ----- |
| принять запрос от клиента или connector | `/0/rest/MyService/MyMethod` |
| вызвать внешний API из серверного кода | REST client, connector, webhook sender |

Эти задачи стоит разделять: WCF-класс остаётся входной точкой, а внешний HTTP-клиент выносится в отдельный доменный service/helper.

## Исходящий REST через RestSharp

```csharp
var client = new RestClient("https://api.example.com");
var request = new RestRequest("/endpoint", Method.POST);
request.AddJsonBody(payload);
var response = client.Execute(request);
```

Такой код не должен быть размазан по UI-facing methods. Лучше изолировать его в отдельном классе, который принимает `UserConnection`, настройки и DTO.

## AI / LLM provider-ы

`LlmOpenAiCompatibleProvider`, `LlmOllamaProvider` и `LlmYandexProvider`
используют RestSharp как исходящий HTTP-клиент. Их конфигурация хранится в
`LlmModel`: `ApiUrl`, `ApiKey`, `Model`, `Temperature`, `MaxTokens`.

Подробности по payload, auth scheme и обработке ошибок вынесены в
[AI LLM Providers](ai-llm-providers.md).

## ML service proxy

`MLServiceProxy` также является исходящим REST-клиентом, но работает с внешним
ML service: session, upload data, classify, score, regress и recommendation
endpoints. Конфигурация берётся из `MLModelConfig` и system settings.

Подробности: [ML Runtime Jobs](ml-runtime-jobs.md).

## Web Service V2

`ServiceDesigner` позволяет описывать исходящие REST/SOAP вызовы как service
schema metadata. Runtime-вызов идёт через `ServiceSchemaManager` и
`IServiceSchemaClient`, а тестовый facade представлен
`CallServiceSchemaService`.

Подробности: [Web Service V2 Overview](webservice-v2-overview.md) и
[Integration Tools Runtime](integration-tools-runtime.md).

## Исходящий REST через платформенный client

В решении также встречаются обёртки вроде `IWebServiceClient`.

```csharp
var client = ClassFactory.Get<IWebServiceClient>();
var response = client.GetResponseJson(url, postData);
```

Если в проекте уже есть platform wrapper, используйте его вместо нового raw HTTP-клиента.

## Что хранить в SysSettings

Для интеграций обычно выносят:

- base URL;
- token/client secret;
- timeout;
- feature flag;
- mapping внешних статусов;
- retry/batch size.

Секреты не должны попадать в документацию, git или client-side JS.

## Ошибки внешнего API

Не возвращайте raw response внешнего API напрямую в UI. Слой сервиса должен привести ошибку к внутреннему contract:

```csharp
try {
    var apiResponse = externalClient.Send(payload);
    response.Success = apiResponse.IsSuccess;
} catch (Exception e) {
    response.Exception = e;
}
```

Для callback/webhook endpoint'ов контракт ответа должен соответствовать ожиданиям внешней системы. Иногда это строка `"Ok"`, даже если внутренняя ошибка залогирована.

## Logging

Логируйте:

- correlation id или внешний message id;
- endpoint/method без секретов;
- статус ответа;
- код ошибки;
- сокращённое тело ошибки, если оно не содержит персональные данные или токены.

Не логируйте:

- access token;
- refresh token;
- password;
- полный payload с персональными данными без необходимости.

## Когда использовать Quartz

Если внешний API требует повторов, polling или отложенной обработки, не держите HTTP request открытым. Сервис может создать запись/команду и поставить job.

Связанные паттерны:

- [Quartz registration patterns](quartz-registration-patterns.md)
- [Quartz process jobs](quartz-process-jobs.md)
- [Quartz class jobs](quartz-class-jobs.md)

## Связанные документы

- [Services Overview](services-overview.md)
- [Service contracts and routing](services-contracts-routing.md)
- [Service responses and errors](services-response-errors.md)
- [AI LLM Providers](ai-llm-providers.md)
- [ML Runtime Jobs](ml-runtime-jobs.md)
- [Web Service V2 Overview](webservice-v2-overview.md)
- [Integration Tools Runtime](integration-tools-runtime.md)
- [Services troubleshooting](services-troubleshooting.md)
