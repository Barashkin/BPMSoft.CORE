# AI LLM Boundaries

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, boundaries, ML, Process, Email Mining -->

> Границы AI / LLM Dive: что относится к пакету `.AI`, а что является смежной
> подсистемой и должно документироваться отдельно.

## Внутри AI / LLM Dive

К этому dive относятся:

- `LlmModel`, `LlmModelType`, `LlmModelApiType`;
- `ILlmProvider` и provider bindings;
- OpenAI-compatible, Ollama, Yandex completion calls;
- `LlmUserTask` и `LlmUserTaskPropertiesPage`;
- PDF extraction и attachment injection;
- `LlmProviderException`, `RestExtensions`, auth helper-ы AI-пакета.

## Process

Process engine отвечает за жизненный цикл процесса, параметры, execution context
и общие user task mechanics.

AI / LLM Dive покрывает только конкретный user task `LlmUserTask`: как он берёт
модель, готовит prompt и вызывает provider. Общие правила разработки процессов
остаются в Process-документах.

## ML prediction

Пакет `.ML` содержит обучение, предсказания, predictor-ы, training sessions и
ML user tasks. Это не тот же слой, что generative LLM:

- `.AI` вызывает внешний completion API;
- `.ML` работает с моделями предсказаний и отдельной ML-инфраструктурой;
- у них разные сущности, runtime и сценарии ошибок.

Подробности: [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md).

## BaseScoring

`BaseScoring` - rules-based scoring через `ScoringModel` и `ScoringRule`. Это
не LLM и не ML completion. Его нужно документировать отдельно, чтобы не
смешивать правила скоринга с генеративными моделями.

Подробности: [ML Base Scoring](ml-base-scoring.md).

## Content Builder и Email Templates

Content Builder и Email Templates отвечают за шаблоны писем, MJML, макросы и
отправку email через process tasks. Они не вызывают `ILlmProvider` напрямую.

Если бизнес-сценарий генерирует текст письма через LLM, интеграция должна явно
связать `LlmUserTask` с шаблоном/письмом на уровне процесса или кастомного кода.

## Email Mining

Email Mining обрабатывает письма, cloud enrichment и найденные Contact/Account.
Это отдельная подсистема. Наличие cloud parsing не означает использование
`LlmModel` или `.AI` provider layer.

## Global Search

Global Search покрывает полнотекстовый поиск и индексацию. В `.AI` не найдено
отдельного embeddings/vector search API, поэтому semantic/RAG сценарии не
относятся к текущему LLM-слою без кастомной реализации.

## Services

LLM provider-ы сами делают исходящие HTTP-вызовы через RestSharp. В текущем
контуре нет отдельного публичного WCF/REST сервиса для LLM completion, который
следовало бы описывать в Services Dive.

## Security / Admin

Security/Admin покрывают права, роли, доступ к справочникам и хранение секретов
в целом. AI / LLM Dive фиксирует только локальные особенности:

- `ApiKey` хранится как `SecureText`;
- external URL и ключи настраиваются в `LlmModel`;
- provider exceptions не должны раскрывать секреты в логах.

## Связанные документы

- [ai-llm-overview.md](ai-llm-overview.md)
- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [Process Overview](process-overview.md)
- [Content Email Templates Overview](content-email-templates-overview.md)
- [Email Mining Enrichment Overview](email-mining-enrichment-overview.md)
- [Security Overview](security-overview.md)
