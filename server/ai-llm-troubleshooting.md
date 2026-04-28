# AI LLM Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, troubleshooting, provider, process -->

> Диагностика AI / LLM сценариев: модель не найдена, provider не выбирается,
> внешний API возвращает ошибку, ответ пустой или PDF-вложение не читается.

## Быстрая классификация

| Симптом | Где смотреть |
| ------- | ------------ |
| Process падает до HTTP-вызова | `LlmUserTask.GetModel`, запись `LlmModel` |
| Provider не найден | `LlmModel.ApiType.Code`, `[DefaultBinding]` |
| HTTP status `>= 400` или `0` | `RestExtensions.ThrowIfLlmProviderError` |
| Успешный HTTP, но пустой result | response DTO provider-а |
| PDF не извлекается | `LlmPdfExtractor`, формат файла |
| Prompt в процессе пустой | `LlmUserTaskPropertiesPage` и mapping `Prompt` |

## Модель не найдена

Проверьте:

- parameter `Model` в `LlmUserTask`;
- существует ли запись `LlmModel` с этим `Id`;
- заполнены ли обязательные поля `ApiType`, `ApiUrl`, `Model`, `MaxTokens`;
- доступна ли запись процессному пользователю.

Если `LlmModel` не найден, task бросает `LlmProviderException` с ключом
`LlmModelNotFoundError`.

## API-тип не найден или provider не выбирается

`LlmUserTask` отдельно загружает `model.ApiType`. Если API-тип не найден,
возникает `LlmModelApiTypeNotFoundError`.

Если API-тип есть, но provider не создаётся:

- проверьте `LlmModelApiType.Code`;
- сравните его с `LlmConstants.BindingName`;
- проверьте наличие `[DefaultBinding(typeof(ILlmProvider), Name = "...")]`;
- убедитесь, что сборка с provider доступна приложению.

## Ошибка внешнего API

Все provider считают ошибкой:

- HTTP status `>= 400`;
- status `0`, например network/TLS/DNS issue.

Сообщение берётся из `IRestResponse.ErrorMessage`, если оно заполнено, иначе из
`response.Content`.

Проверьте:

- `ApiUrl` без лишнего path или с нужным базовым URL;
- `ApiKey` и схему авторизации provider-а;
- `Model` в формате конкретного API;
- доступность внешнего endpoint с сервера приложения;
- proxy/firewall/TLS настройки.

## Успешный HTTP, но пустой ответ

Provider бросает `LlmProviderException`, если response body не распарсился или
не содержит ожидаемого поля:

- OpenAI-compatible: `choices[0].message.content`;
- Ollama: `response`;
- Yandex: `result.alternatives[0].message.text`.

Чаще всего причина в несовместимом API, неправильном endpoint или изменившемся
response schema.

## PDF-вложение не читается

`LlmPdfExtractor` работает только с PDF bytes через `UglyToad.PdfPig`. При
`PdfDocumentFormatException` ошибка оборачивается в `LlmProviderException`.

Проверьте:

- что composite object содержит ключ `File`;
- что `EntityFileLocator` указывает на существующий файл;
- что файл действительно PDF;
- что PDF не повреждён и не является изображением без текстового слоя.

## Prompt пустой или не проходит validation

В `LlmUserTaskPropertiesPage` prompt обязателен и проверяется по `prompt.value`.
Если значение приходит из mapping, проверьте, что источник mapping возвращает
строку, а не пустой объект.

## Связанные документы

- [ai-llm-overview.md](ai-llm-overview.md)
- [ai-llm-data-model.md](ai-llm-data-model.md)
- [ai-llm-providers.md](ai-llm-providers.md)
- [ai-llm-process-user-task.md](ai-llm-process-user-task.md)
- [ai-llm-attachments.md](ai-llm-attachments.md)
