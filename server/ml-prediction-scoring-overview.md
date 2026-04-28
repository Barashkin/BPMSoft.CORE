# ML Prediction Scoring Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, prediction, scoring, training, Quartz, ProcessUserTask -->

> Входная точка в ML / Prediction / Scoring Dive. Документ разводит три
> связанных, но разных контура: `.ML` prediction/training, `.MLScoring` bridge и
> `BaseScoring` rules-based scoring.

## Что входит в dive

| Контур | Назначение |
| ------ | ---------- |
| `.MLBase` | схемы данных: `MLModel`, `MLPrediction`, `MLTrainSession`, справочники состояний и типов |
| `.ML` | runtime обучения, предсказаний, proxy к ML-сервису, jobs и user tasks |
| `.MLScoring` | ML-предикторы для scoring problem type |
| `BaseScoring` | rule-based scoring engine и WCF service для scoring map/sync |

Это не generative AI. LLM completion описан отдельно в
[AI LLM Overview](ai-llm-overview.md).

## Документы пакета

| Документ | Назначение |
| -------- | ---------- |
| [ml-data-model.md](ml-data-model.md) | `MLModel`, `MLPrediction`, train sessions, problem types |
| [ml-runtime-jobs.md](ml-runtime-jobs.md) | `MLServiceProxy`, training, batch prediction, Quartz jobs |
| [ml-process-user-tasks.md](ml-process-user-tasks.md) | `MLDataPredictionUserTask`, batch/single/CF modes |
| [ml-base-scoring.md](ml-base-scoring.md) | `ScoringEngine`, `ScoringService`, `ScoringModel`, `ScoringRule` |
| [ml-boundaries.md](ml-boundaries.md) | границы с AI/LLM, Process, Analytics, Email Mining, Services |
| [ml-pattern-catalog.md](ml-pattern-catalog.md) | рабочие паттерны ML/scoring |
| [ml-troubleshooting.md](ml-troubleshooting.md) | диагностика service URL, API key, jobs, model readiness, scoring |

## Основные потоки

### Обучение модели

```text
MLAppListener
  -> MLModelTrainerJob
  -> IMLTrainingManager.ProcessAllModels
  -> MLModelTrainer
  -> MLServiceProxy session/data/training endpoints
  -> MLTrainSession / MLModel state update
```

### Batch prediction

```text
MLBatchPredictionJob
  -> MLModelLoader.LoadModelsForBatchPrediction
  -> ClassFactory.Get<IMLBatchPredictor>(ProblemType)
  -> predictor.Predict(...)
  -> predictor.SavePredictedData(...)
  -> MLPrediction / target entity fields
```

### Process prediction

```text
MLDataPredictionUserTask
  -> batch mode: IMLBatchPredictionJob.ProcessModel
  -> single mode: MLEntityPredictor.PredictEntityValueAndSaveResult
  -> CF mode: MLEntityPredictor.Recommend
```

### Rule-based scoring

```text
ScoringService
  -> ScoringEngine
  -> ScoringModel + ScoringRule
  -> RuleSerializationHelper
  -> scoring map / synchronization / SaveScoredData
```

## Ключевые source files

| Область | Файлы |
| ------- | ----- |
| Data model | `MLModelSchema.MLBase.cs`, `MLPredictionSchema.MLBase.cs`, `MLTrainSessionSchema.MLBase.cs` |
| Service proxy | `MLServiceProxy.ML.cs`, `IMLServiceProxySchema.ML.cs` |
| Training | `MLModelTrainer.ML.cs`, `MLModelTrainerJob.ML.cs` |
| Batch jobs | `MLBatchPredictionJob.ML.cs`, `MLAppListener.ML.cs` |
| Predictors | `MLEntityPredictor.ML.cs`, `MLBaseEntityPredictor.ML.cs`, `MLBatchPredictor.ML.cs` |
| Process | `MLDataPredictionUserTask.ML.cs`, `MLDataPredictionUserTaskPropertiesPage.ML.js` |
| ML scoring | `MLScoringEntityPredictor.MLScoring.cs`, `MLBatchScorer.MLScoring.cs` |
| BaseScoring | `ScoringEngine.BaseScoring.cs`, `ScoringService.BaseScoring.cs`, `ScoringModelSchema.BaseScoring.cs`, `ScoringRuleSchema.BaseScoring.cs` |

## Быстрый выбор

| Задача | Документ |
| ------ | -------- |
| Разобрать модель ML-данных | [ml-data-model.md](ml-data-model.md) |
| Понять training/batch jobs | [ml-runtime-jobs.md](ml-runtime-jobs.md) |
| Вызвать ML из процесса | [ml-process-user-tasks.md](ml-process-user-tasks.md) |
| Отличить ML scoring от BaseScoring | [ml-base-scoring.md](ml-base-scoring.md), [ml-boundaries.md](ml-boundaries.md) |
| Найти паттерн расширения | [ml-pattern-catalog.md](ml-pattern-catalog.md) |
| Диагностировать ошибку | [ml-troubleshooting.md](ml-troubleshooting.md) |

## Связанные документы

- [AI LLM Boundaries](ai-llm-boundaries.md)
- [Process User Tasks](process-user-tasks.md)
- [Quartz Class Jobs](quartz-class-jobs.md)
- [Services Outgoing REST](services-outgoing-rest.md)
- [Security Overview](security-overview.md)
