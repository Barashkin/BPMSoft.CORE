# AI LLM Data Model

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, LlmModel, SecureText, lookup -->

> Модель данных AI / LLM слоя: где хранится конфигурация моделей, как выбирается
> provider и какие поля участвуют в runtime-вызове.

## Главные сущности

| Сущность | Назначение |
| -------- | ---------- |
| `LlmModel` | справочник настроенных LLM-моделей |
| `LlmModelType` | тип модели как бизнес-классификация |
| `LlmModelApiType` | API-тип с кодом provider binding |

`LlmModel` наследуется от `BaseLookup`, а `LlmModelApiType` - от
`BaseCodeLookup`. Это важно: runtime выбирает provider не по имени записи, а по
`Code` из `LlmModelApiType`.

## Поля LlmModel

| Поле | Тип | Использование |
| ---- | --- | ------------- |
| `Name` | `LongText` | отображаемое имя модели |
| `ApiKey` | `SecureText` | секрет для внешнего API |
| `Type` | lookup `LlmModelType` | классификация модели |
| `ApiType` | lookup `LlmModelApiType` | binding provider |
| `ApiUrl` | `LongText` | базовый URL provider API |
| `Model` | `LongText` | идентификатор модели у provider |
| `Temperature` | `Float2` | temperature completion request |
| `MaxTokens` | `Integer` | лимит токенов ответа |

`ApiUrl`, `ApiType`, `Model` и `MaxTokens` помечены как application-level
required columns. `ApiKey` хранится как `SecureText`, поэтому его нельзя
логировать или переносить через обычные текстовые dumps.

## Как модель используется

`LlmUserTask` получает `LlmModel` по `Model` parameter, затем загружает
`model.ApiType` и выбирает provider:

```text
ClassFactory.Get<ILlmProvider>(
  model.ApiType.Code,
  userConnection,
  model
)
```

Следствие: для нового provider недостаточно добавить запись `LlmModel`. Нужно,
чтобы `LlmModelApiType.Code` совпадал с именем `[DefaultBinding]`.

## Связь ApiType и provider

| `LlmModelApiType.Code` | Binding | Provider |
| ---------------------- | ------- | -------- |
| `openai` | `LlmConstants.BindingName.OpenAi` | `LlmOpenAiCompatibleProvider` |
| `ollama` | `LlmConstants.BindingName.Ollama` | `LlmOllamaProvider` |
| `yandex` | `LlmConstants.BindingName.Yandex` | `LlmYandexProvider` |

## Практические правила

- `ApiUrl` должен быть базовым адресом, потому что provider сам добавляет
  resource path (`/chat/completions`, `/api/generate` или пустой path для
  Yandex).
- `Model` должен быть в формате, ожидаемом конкретным provider. Для Yandex это
  `ModelUri`, а не короткое имя модели.
- `ApiKey` может быть пустым для локальных сценариев, например Ollama без
  авторизации.
- `Temperature` и `MaxTokens` передаются provider без дополнительной нормализации.

## Связанные документы

- [ai-llm-overview.md](ai-llm-overview.md)
- [ai-llm-providers.md](ai-llm-providers.md)
- [Entity Schema Pattern Catalog](entity-schema-pattern-catalog.md)
