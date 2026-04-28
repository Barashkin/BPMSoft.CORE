# ML Data Model

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, MLModel, MLPrediction, MLTrainSession, EntitySchema -->

> Модель данных ML-контура: `MLModel`, результаты предсказаний, сессии обучения,
> problem types, лимиты и вспомогательные схемы.

## Главные сущности

| Сущность | Назначение |
| -------- | ---------- |
| `MLModel` | основная конфигурация модели, training/prediction settings |
| `MLPrediction` | сохранённый результат предсказания по записи |
| `MLTrainSession` | сессия обучения и её состояние |
| `MLProblemType` | тип задачи ML, по которому выбираются predictor bindings |
| `MLModelState` | состояние модели/training session |
| `MLClassificationResult` | справочник результатов классификации |
| `MLError` | ошибки ML-контура |

`MLBase` содержит именно схемы данных. Runtime-логика живёт в пакете `.ML`.

## MLModel

`MLModel` наследуется от `BaseEntity` и содержит большую часть настроек
обучения и предсказаний.

Ключевые группы полей:

| Группа | Поля |
| ------ | ---- |
| Идентификация | `Name`, `Description`, `RootSchemaUId`, `MLProblemType`, `ModelInstanceUId` |
| Обучение | `TrainingSetQuery`, `TrainingFilterData`, `TrainingOutputFilterData`, `TrainingMinimumRecordsCount`, `TrainingMaxRecordsCount`, `TrainFrequency` |
| Состояние | `State`, `TrainSessionId`, `TrainedOn`, `TriedToTrainOn`, `LastError`, `LastTrainingError` |
| Качество | `InstanceMetric`, `MetricThreshold`, `LowerScoreThreshold`, `MLConfidentValueMethod`, `ConfidentValueLowEdge` |
| Prediction | `PredictionEnabled`, `PredictionSchemaUId`, `TargetColumnUId`, `PredictedResultColumnUId`, `BatchPredictionQuery`, `BatchPredictionFilterData`, `BatchPredictedOn` |
| Collaborative filtering | `CFUserColumnPath`, `CFItemColumnPath`, `CFInteractionValueColumnPath`, `TopN`-сценарии через user task |
| List prediction | `ListPredictResultSchemaUId`, `ListPredictResultSubjectColumn`, `ListPredictResultObjectColumn`, `ListPredictResultValueColumn`, `ListPredictResultModelColumn`, `ListPredictResultDateColumn` |

Практически все runtime-классы сначала загружают `MLModel` в `MLModelConfig`,
а затем работают уже с config object.

## MLPrediction

`MLPrediction` хранит отдельный результат:

| Поле | Назначение |
| ---- | ---------- |
| `Key` | идентификатор записи, для которой сделано предсказание |
| `Value` | предсказанное значение |
| `Probability` | вероятность/уверенность |
| `ModelInstanceUId` | внешняя instance id обученной модели |
| `Model` | lookup на `MLModel` |
| `FeatureContributions` | вклад факторов |
| `Bias` | bias модели |

`MLBatchPredictionJob` может чистить устаревшие записи `MLPrediction` по
`MLPredictionResultsLifeDays`.

## Training session

`MLTrainSession` связывает `MLModel` с конкретной сессией обучения. Runtime
обновляет состояние через `MLModelTrainer`:

- `NotStarted`;
- `DataTransferring`;
- `Training`;
- `Error`;
- `Done`.

`MLModelTrainer.FiniteStates` считает конечными `NotStarted`, `Error` и `Done`.

## ProblemType как runtime binding

`MLProblemType` - не просто справочник. Его `Id` используется как binding name:

```text
problemType.ToString().ToUpper()
  -> ClassFactory.Get<IMLBatchPredictor>(name)
  -> ClassFactory.Get<IMLEntityPredictor>(name)
```

Поэтому добавление нового типа задачи требует не только записи справочника, но
и registered predictor-реализаций.

## Вспомогательные схемы

| Схема | Назначение |
| ----- | ---------- |
| `MLModelColumn` | колонки модели и expressions |
| `MLModelColumnType` | типы колонок |
| `MLModelFolder`, `MLModelInFolder` | папки моделей |
| `MLModelTag`, `MLModelInTag` | теги моделей |
| `MLModelFile` | файлы модели |
| `VwMLTrainingLimitsByModelType` / `VwMLRequestLimitsByModelType` | представления лимитов |

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [ML Runtime Jobs](ml-runtime-jobs.md)
- [Entity Schema Overview](entity-schema-overview.md)
- [File Pattern Catalog](file-pattern-catalog.md)
