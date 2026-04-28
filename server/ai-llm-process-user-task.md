# AI LLM Process User Task

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, Process, UserTask, LlmUserTask -->

> Как `LlmUserTask` встраивает LLM completion в бизнес-процесс: параметры,
> runtime pipeline, property page и точки расширения.

## Назначение

`LlmUserTask` - process user task, который:

- получает настроенную `LlmModel`;
- выбирает provider по `LlmModel.ApiType.Code`;
- подставляет PDF-вложения в prompt, если они переданы;
- вызывает `ILlmProvider.GetCompletionAsync`;
- записывает текст ответа в `Result`.

Это bridge между Process engine и AI / LLM provider layer. Общие правила
создания user tasks остаются в документах по Process, здесь описана только
специфика LLM-задачи.

## Runtime pipeline

```text
InternalExecute(context)
  -> GetModel(Model)
  -> ClassFactory.Get<ILlmProvider>(model.ApiType.Code, userConnection, model)
  -> if Files.IsNotEmpty(): inject attachments into Prompt
  -> provider.GetCompletionAsync(Prompt).GetAwaiter().GetResult()
  -> Result = text
  -> return true
```

Вызов provider выполняется как sync-over-async через `GetAwaiter().GetResult()`,
потому что `InternalExecute` синхронный.

## Параметры user task

| Параметр | Назначение |
| -------- | ---------- |
| `Model` | lookup на `LlmModel`; обязателен |
| `Prompt` | mapping-параметр с текстом prompt; обязателен |
| `Files` | mapping-параметр с файлами; опционален |
| `Result` | текст completion result |

## Загрузка модели

`GetModel(Guid id)`:

- создаёт `new LlmModel(UserConnection)`;
- ищет модель по `Id`;
- отдельно загружает `model.ApiType`;
- бросает `LlmProviderException`, если модель или API-тип не найдены.

Это означает, что ошибка настройки модели проявится во время выполнения
процесса, а не на этапе сохранения схемы процесса.

## Client property page

`LlmUserTaskPropertiesPage.AI.js` добавляет редакторы:

- `Model` как lookup `referenceSchemaName: "LlmModel"`;
- `Prompt` как mapping field;
- `Files` как mapping field.

Для `Prompt` добавлен validator: значение обязательно и проверяется по
`prompt.value`. Для `Model` значение и display value инициализируются из
process parameter.

## Вложения

Если `Files` не пустой:

```text
Files composite object
  -> key "File"
  -> EntityFileLocator
  -> UserConnection.GetFile(locator)
  -> file.ReadBytes()
  -> ILlmPdfExtractor.Extract(bytes)
  -> ILlmAttachmentInjector.Inject(Prompt, attachments)
```

Поддержанный в коде сценарий - извлечение текста из PDF. Другие форматы не
обрабатываются отдельными extractor-ами.

## Типовые расширения

- Новый provider: реализовать `ILlmProvider` и добавить `LlmModelApiType.Code`.
- Новый способ подготовки prompt: заменить binding `ILlmAttachmentInjector`.
- Новый способ чтения файлов: заменить binding `ILlmPdfExtractor` или расширить
  `CreateAttachments`.
- Новые параметры user task: синхронно обновлять C# task class и JS property
  page.

## Связанные документы

- [ai-llm-overview.md](ai-llm-overview.md)
- [ai-llm-data-model.md](ai-llm-data-model.md)
- [ai-llm-attachments.md](ai-llm-attachments.md)
- [Process User Tasks](process-user-tasks.md)
