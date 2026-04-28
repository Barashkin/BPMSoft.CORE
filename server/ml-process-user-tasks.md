# ML Process User Tasks

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, ProcessUserTask, prediction, collaborative filtering -->

> Как ML prediction вызывается из бизнес-процесса: `MLDataPredictionUserTask`,
> batch mode, single record mode и collaborative filtering.

## Основной user task

`MLDataPredictionUserTask` реализует runtime-логику process element:

```text
InternalExecute(context)
  -> if IsBatchPrediction:
       IMLBatchPredictionJob.ProcessModel(...)
     else:
       MLEntityPredictor.PredictEntityValueAndSaveResult(...)
       or collaborative filtering Recommend(...)
```

Общие правила process user tasks описаны в [Process User Tasks](process-user-tasks.md).

## Batch prediction mode

Если `IsBatchPrediction = true`:

```text
PredictionFilterData
  -> FilterEditConverter.Convert(...)
  -> IMLBatchPredictionJob.ProcessModel(UserConnection, MLModelId, filterEditData, this)
```

`FilterEditConverter` переводит process filters в NUI filters и разрешает
process parameters. Переданный фильтр заменяет исходный batch filter модели.

## Single record prediction

Если batch mode выключен:

```text
ClassFactory.Get<MLEntityPredictor>(userConnection)
  -> UseAdminRights = GlobalAppSettings.FeatureUseAdminRightsInEmbeddedLogic
  -> PredictEntityValueAndSaveResult(MLModelId, RecordId, this)
```

`MLEntityPredictor` загружает model config, проверяет готовность модели,
подготавливает данные записи и выбирает `IMLEntityPredictor` по problem type.

## Collaborative filtering

Для модели с `MLProblemTypeId == MLConsts.CollaborativeFiltering` task работает
иначе:

- загружает `MLModelConfig`;
- проверяет `ListPredictResultSchemaUId`;
- строит ESQ для users по `CFUserColumnPath` и `CFUserFilterData`;
- строит ESQ для items по `CFItemColumnPath` и `CFItemFilterData`;
- выбирает `RecommendationFilterItemsMode`;
- вызывает `predictor.Recommend(MLModelId, users, TopN, items, ...)`.

Если item filter пустой, используется black-list режим; если задан - white-list.

## Property page

`MLDataPredictionUserTaskPropertiesPage.ML.js` задаёт:

| Attribute | Назначение |
| --------- | ---------- |
| `MLModelId` | lookup на `MLModel` |
| `RecordId` | mapping record id для single prediction |
| `DataPredictionMode` | single или collection |
| `PredictionFilterData` | фильтр batch prediction |
| `CFUserFilterData` | фильтр пользователей для recommendation |
| `CFItemFilterData` | фильтр items для recommendation |
| `TopN` | количество рекомендаций |
| `CFFilterAlreadyInteractedItems` | фильтровать уже связанные items |

Страница использует `FilterModuleMixin` и `EntityStructureHelperMixin`, а также
PTP/BROADCAST сообщения фильтров.

## Отличие от LlmUserTask

`MLDataPredictionUserTask` не формирует prompt и не вызывает completion API.
Он работает с `MLModel`, `MLProblemType`, predictors и внешним ML service proxy.

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [ML Runtime Jobs](ml-runtime-jobs.md)
- [ML Data Model](ml-data-model.md)
- [Process User Tasks](process-user-tasks.md)
- [AI LLM Process User Task](ai-llm-process-user-task.md)
