# AI LLM Pattern Catalog

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, patterns, provider, user task -->

> Каталог рабочих паттернов для расширения AI / LLM слоя без смешивания с ML,
> scoring и шаблонами писем.

## Lookup model + provider binding

**Когда использовать:** нужно выбрать provider и параметры модели из настройки.

**Паттерн:**

```text
LlmModel.ApiType.Code
  -> ClassFactory.Get<ILlmProvider>(code, userConnection, model)
```

Код `LlmModelApiType` должен совпадать с `Name` в `[DefaultBinding]`.

## Provider как тонкий адаптер внешнего API

**Когда использовать:** добавляется новый внешний completion API.

Provider должен:

- принимать `UserConnection` и `LlmModel`;
- валидировать prompt;
- создавать request из полей модели;
- вызывать `ThrowIfLlmProviderError`;
- вернуть только текст completion result;
- бросать `LlmProviderException` для пустых или некорректных ответов.

## OpenAI-compatible reuse

**Когда использовать:** внешний сервис поддерживает `/chat/completions`.

Сначала проверьте, достаточно ли `LlmOpenAiCompatibleProvider` с другим
`ApiUrl`, `ApiKey` и `Model`. Новый provider нужен только при отличиях в auth,
payload или response format.

## Sync-over-async в process user task

**Когда использовать:** provider async, а `InternalExecute` синхронный.

Текущий task вызывает:

```text
provider.GetCompletionAsync(Prompt).GetAwaiter().GetResult()
```

Это соответствует сигнатуре process user task, но важно учитывать timeout
внешнего API и длительность выполнения процесса.

## Attachment injection перед provider

**Когда использовать:** provider contract не должен знать о файлах.

Файлы преобразуются в текст до вызова provider:

```text
Files -> LlmAttachment -> Inject(prompt, attachments) -> string prompt
```

Это сохраняет простой `ILlmProvider`, но требует контроля размера prompt.

## Localizable provider exceptions

**Когда использовать:** ошибка должна быть понятной пользователю процесса.

Вместо raw exception создаётся `LlmProviderException` с resource key из
`LlmLocalizableStringConstants`. Для HTTP-ответов используется
`RestExtensions.GetErrorMessage`.

## Client page mirrors runtime parameters

**Когда использовать:** добавляется параметр `LlmUserTask`.

Нужно синхронно менять:

- C# process task parameter/runtime logic;
- JS property page attribute;
- validation в property page;
- документацию по process user task.

## Чего не делать

- Не помещать бизнес-логику provider selection в JS property page.
- Не логировать `ApiKey` и полный request body с секретами.
- Не смешивать `LlmUserTask` с ML prediction user tasks.
- Не добавлять embeddings/RAG в существующий provider contract без явного
  расширения интерфейса.

## Связанные документы

- [ai-llm-overview.md](ai-llm-overview.md)
- [ai-llm-providers.md](ai-llm-providers.md)
- [ai-llm-process-user-task.md](ai-llm-process-user-task.md)
- [ai-llm-boundaries.md](ai-llm-boundaries.md)
