# AI LLM Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, completion, process user task, providers -->

> Входная точка в AI / LLM Dive. Документ описывает пакет `.AI`:
> LLM-модели, провайдеры completion API, `LlmUserTask`, вложения и границы с
> ML/scoring, Process, Email Mining и внешними провайдерами.

## Что покрывает пакет AI

В текущем коде `.AI` реализует completion-only слой:

- конфигурация LLM-моделей в `LlmModel`;
- выбор API-типа через `LlmModelApiType.Code`;
- единый контракт `ILlmProvider.GetCompletionAsync(prompt)`;
- реализации для OpenAI-compatible, Ollama и Yandex;
- process user task `LlmUserTask`;
- PDF attachment extraction и injection в prompt;
- локализованные provider exceptions.

Embeddings/vector/RAG API в пакете `.AI` не обнаружены: поиск по `embedding`
даёт в основном `EmbeddedProcess`, а не векторные сценарии.

## Документы пакета

| Документ | Назначение |
| -------- | ---------- |
| [ai-llm-data-model.md](ai-llm-data-model.md) | `LlmModel`, `LlmModelType`, `LlmModelApiType` |
| [ai-llm-providers.md](ai-llm-providers.md) | `ILlmProvider`, OpenAI-compatible, Ollama, Yandex |
| [ai-llm-process-user-task.md](ai-llm-process-user-task.md) | `LlmUserTask` runtime и property page |
| [ai-llm-attachments.md](ai-llm-attachments.md) | PDF extraction и prompt injection |
| [ai-llm-boundaries.md](ai-llm-boundaries.md) | границы с Process, ML, Email Mining и другими dives |
| [ai-llm-pattern-catalog.md](ai-llm-pattern-catalog.md) | рабочие паттерны расширения AI/LLM |
| [ai-llm-troubleshooting.md](ai-llm-troubleshooting.md) | диагностика моделей, provider API, PDF и user task |

## Основной flow

```text
Process LlmUserTask
  -> LlmModel
  -> LlmModel.ApiType.Code
  -> ClassFactory.Get<ILlmProvider>(code, userConnection, model)
  -> provider.GetCompletionAsync(prompt)
  -> Result
```

Если в user task переданы файлы:

```text
Files
  -> EntityFileLocator
  -> UserConnection.GetFile(...)
  -> ILlmPdfExtractor.Extract(bytes)
  -> ILlmAttachmentInjector.Inject(prompt, attachments)
  -> provider completion
```

## Ключевые source files

| Область | Файлы |
| ------- | ----- |
| Контракт | `ILlmProvider.AI.cs` |
| Провайдеры | `LlmOpenAiCompatibleProvider.AI.cs`, `LlmOllamaProvider.AI.cs`, `LlmYandexProvider.AI.cs` |
| Модель | `LlmModelSchema.AI.cs`, `LlmModelTypeSchema.AI.cs`, `LlmModelApiTypeSchema.AI.cs` |
| Process task | `LlmUserTask.AI.cs`, `LlmUserTaskPropertiesPage.AI.js` |
| Вложения | `LlmAttachmentInjector.AI.cs`, `LlmPdfExtractor.AI.cs`, `LlmAttachment.AI.cs` |
| Ошибки / HTTP | `RestExtensions.AI.cs`, `LlmProviderException.AI.cs` |
| Auth | `AuthorizationUtilities.AI.cs`, `AuthorizationConstants.AI.cs` |

## Быстрый выбор

| Задача | Документ |
| ------ | -------- |
| Настроить LLM-модель | [ai-llm-data-model.md](ai-llm-data-model.md) |
| Добавить/понять provider | [ai-llm-providers.md](ai-llm-providers.md) |
| Использовать LLM в процессе | [ai-llm-process-user-task.md](ai-llm-process-user-task.md) |
| Разобрать PDF-вложения | [ai-llm-attachments.md](ai-llm-attachments.md) |
| Отличить AI от ML/scoring | [ai-llm-boundaries.md](ai-llm-boundaries.md) |
| Диагностировать provider error | [ai-llm-troubleshooting.md](ai-llm-troubleshooting.md) |

## Связанные документы

- [Process Overview](process-overview.md)
- [Process User Tasks](process-user-tasks.md)
- [Services Outgoing REST](services-outgoing-rest.md)
- [Security Overview](security-overview.md)
- [Entity Schema Pattern Catalog](entity-schema-pattern-catalog.md)
