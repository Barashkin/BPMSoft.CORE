# AI LLM Providers

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, provider, RestSharp, OpenAI, Ollama, Yandex -->

> Провайдерный слой AI / LLM: единый контракт `ILlmProvider`, bindings через
> `ClassFactory`, HTTP-вызовы через RestSharp и различия OpenAI-compatible,
> Ollama и Yandex.

## Контракт provider

`ILlmProvider` содержит один метод:

```text
Task<string> GetCompletionAsync(string prompt)
```

Контракт не принимает chat history, tools, embeddings или streaming callback.
Все текущие реализации отправляют один user prompt и возвращают текст ответа.

## Регистрация provider

Provider регистрируется через `[DefaultBinding]`:

| Provider | Binding name |
| -------- | ------------ |
| `LlmOpenAiCompatibleProvider` | `openai` |
| `LlmOllamaProvider` | `ollama` |
| `LlmYandexProvider` | `yandex` |

`LlmUserTask` выбирает реализацию по `model.ApiType.Code`. Поэтому код
справочника `LlmModelApiType` является частью runtime-контракта.

## OpenAI-compatible

`LlmOpenAiCompatibleProvider`:

- создаёт `RestClient` на `_model.ApiUrl`;
- добавляет `Authorization: Bearer <ApiKey>`, если ключ заполнен;
- отправляет POST на `/chat/completions`;
- формирует request с `model`, `messages`, `stream = false`, `temperature`,
  `max_tokens`;
- возвращает `completion.Choices.FirstOrDefault().Message.Content`.

Этот provider подходит не только для OpenAI, но и для совместимых API, если они
поддерживают `/chat/completions`.

## Ollama

`LlmOllamaProvider`:

- отправляет POST на `/api/generate`;
- передаёт `model`, `prompt`, `stream = false`;
- кладёт `temperature` и `max_tokens` в `options`;
- возвращает поле `response`.

Авторизация Bearer добавляется только если `ApiKey` заполнен. Для локальной
Ollama-инсталляции ключ часто не нужен.

## Yandex

`LlmYandexProvider`:

- использует `_model.ApiUrl` без дополнительного resource path;
- добавляет авторизацию через scheme `ApiKey`;
- передаёт `modelUri`, `completionOptions` и один user message;
- конвертирует `MaxTokens` в строку;
- возвращает `Result.Alternatives.FirstOrDefault().Message.Text`.

Для Yandex поле `Model` должно содержать ожидаемый provider-ом `modelUri`.

## Ошибки HTTP и пустого ответа

Все provider вызывают:

```text
response.ThrowIfLlmProviderError(_userConnection)
```

`RestExtensions.ThrowIfLlmProviderError` считает ошибкой HTTP status `>= 400` и
status `0`. Сообщение берётся из `IRestResponse.ErrorMessage`, а если оно
пустое - из `response.Content`.

Если provider вернул успешный статус, но тело не распарсилось или в нём нет
ожидаемого варианта ответа, бросается `LlmProviderException` с локализованным
сообщением о пустом ответе.

## Как добавить provider

1. Создать класс, реализующий `ILlmProvider`.
2. Зарегистрировать `[DefaultBinding(typeof(ILlmProvider), Name = "...")]`.
3. Добавить или использовать запись `LlmModelApiType` с тем же `Code`.
4. Описать формат `ApiUrl`, `Model`, `ApiKey`, `Temperature`, `MaxTokens`.
5. Сохранять наружу только `string` completion result или явно расширять
   контракт, если нужны structured outputs.

## Связанные документы

- [ai-llm-data-model.md](ai-llm-data-model.md)
- [ai-llm-process-user-task.md](ai-llm-process-user-task.md)
- [ai-llm-troubleshooting.md](ai-llm-troubleshooting.md)
- [Services Outgoing REST](services-outgoing-rest.md)
