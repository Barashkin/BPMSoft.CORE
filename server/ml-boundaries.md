# ML Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, scoring, boundaries, AI, Process, Analytics -->

> Границы ML / Prediction / Scoring Dive: что относится к `.ML`, `.MLScoring`
> и `BaseScoring`, а что должно оставаться в соседних документационных блоках.

## Внутри ML / Prediction / Scoring

К этому dive относятся:

- `MLModel`, `MLPrediction`, `MLTrainSession`, `MLProblemType`;
- `MLServiceProxy` и внешний ML service API;
- `MLModelTrainer`, `MLModelTrainerJob`;
- `MLBatchPredictionJob`, `IMLBatchPredictor`;
- `MLEntityPredictor`, `IMLEntityPredictor`, `IMLPredictor`;
- `MLDataPredictionUserTask` и property page;
- `MLScoringEntityPredictor`, `MLBatchScorer`;
- `ScoringEngine`, `ScoringService`, `ScoringModel`, `ScoringRule`.

## AI / LLM

AI / LLM Dive покрывает completion-only `.AI`: `LlmModel`, `ILlmProvider`,
OpenAI-compatible/Ollama/Yandex и `LlmUserTask`.

ML Dive покрывает training/prediction infrastructure. У этих контуров разные
модели данных, runtime и ошибки. `LlmUserTask` нельзя считать заменой
`MLDataPredictionUserTask`.

## Process

Process Dive описывает общий runtime процесса, mapping, logs и user task
механику. ML Dive описывает только ML-specific tasks:

- выбор `MLModel`;
- batch/single prediction mode;
- collaborative filtering filters;
- вызов `IMLBatchPredictionJob` или `MLEntityPredictor`.

## Quartz

Quartz Dive описывает scheduler API и паттерны регистрации. ML Dive описывает
конкретные jobs:

- `MLBatchPredictionJob`;
- `MLModelTrainerJob`;
- регистрацию через `MLAppListener`;
- syssettings периодов.

## Services

Services Dive покрывает WCF/REST как платформенный механизм. ML Dive покрывает
доменные сервисы:

- `MLHelperService`;
- `MLServiceProxy` как исходящий REST;
- `ScoringService`.

## Analytics

Analytics/Dashboards показывают данные и метрики. Они не обучают модели и не
вызывают predictors. Пересечение возможно только если dashboard читает поля,
заполненные ML/scoring.

## Deduplication

Deduplication - отдельная подсистема поиска и merge дублей. Она не использует
`MLModel` в найденном контуре. Сходство есть только на уровне package
configuration builder-паттернов.

## Email Mining

Email Mining обрабатывает письма и enrichment Contact/Account. Это не ML
prediction layer, даже если внутри есть cloud parsing. Интеграция с ML должна
быть явной через модели/процессы/кастомный код.

## Security / Admin

Security/Admin покрывают права, роли, operation rights и system settings в
целом. ML Dive фиксирует локальные особенности:

- `CloudServicesAPIKey` / `MLServiceAPIKey`;
- ML service URL;
- license/limits checks в `MLHelperService`;
- auth key validation в `ScoringService`.

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [AI LLM Boundaries](ai-llm-boundaries.md)
- [Process Overview](process-overview.md)
- [Quartz Registration Patterns](quartz-registration-patterns.md)
- [Services Overview](services-overview.md)
- [Security Overview](security-overview.md)
