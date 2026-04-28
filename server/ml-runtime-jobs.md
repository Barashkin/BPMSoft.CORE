# ML Runtime Jobs

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, runtime, MLServiceProxy, Quartz, training, batch prediction -->

> Runtime ML-контура: proxy к ML-сервису, обучение, batch prediction и Quartz
> jobs, которые поддерживают модели в актуальном состоянии.

## App start

`MLAppListener` запускается на старте приложения:

```text
OnAppStart
  -> ScheduleJobs()
  -> ScheduleImmediateJob<MLBatchPredictionJob>
  -> ScheduleImmediateJob<MLModelTrainerJob>
  -> remove MLConsts.PredictableEntitiesScriptKey from ApplicationCache
```

Jobs ставятся только если ещё не существуют в scheduler.

## MLServiceProxy

`MLServiceProxy` - базовый `IMLServiceProxy` для внешнего ML-сервиса.

Он хранит:

- `IRestClient`;
- API key;
- `UserConnection`;
- endpoint names для session, upload, classify, score, regress,
  recommendation и cluster naming;
- разные timeout-ы для prediction, batch prediction, upload и recommendation.

Примеры endpoint-ов:

| Сценарий | Endpoint |
| -------- | -------- |
| start session | `/session/start`, `/v2/session/start` |
| upload data | `/data/upload`, `/v2/data/upload` |
| classification | `classifier/predict`, `v2/classifier/predict` |
| scoring | `scorer/predict` |
| regression | `regressor/predict`, `v2/regressor/predict` |

## Обработка ошибок proxy

`MLServiceProxy` преобразует HTTP-ошибки:

- `Unauthorized` проверяет `MLServiceAPIKey` / `CloudServicesAPIKey` через
  `MLHelperService`;
- `Forbidden` бросает `HttpException`;
- `NotFound` трактуется как отсутствующий service method;
- `InternalServerError` и `BadRequest` включают тело ответа в диагностическое
  сообщение;
- status `0` и network errors проходят через общий response status handling.

## Training job

`MLModelTrainerJob`:

- читает `MLModelTrainingPeriodMinutes`;
- если значение `0`, отменяет выполнение и не перепланирует job;
- вызывает `IMLTrainingManager.ProcessAllModels`;
- в `finally` вызывает `SchedulerUtils.ScheduleNextRun`.

`MLModelTrainer` внутри:

- создаёт `IMLServiceProxy` по `MLModelConfig.ServiceUrl`;
- строит training select через `IMLModelQueryBuilder`;
- загружает данные chunks-ами (`MLTrainingChunkSize`);
- стартует train session;
- обновляет `MLTrainSession` и `MLModel` state;
- уведомляет UI через `IMLModelEventsNotifier`.

## Batch prediction job

`MLBatchPredictionJob`:

- читает `MLModelBatchPredictionPeriodMinutes`;
- чистит старые `MLPrediction` по `MLPredictionResultsLifeDays`;
- проверяет ML service URL и API key;
- загружает модели через `MLModelLoader.LoadModelsForBatchPrediction`;
- выбирает `IMLBatchPredictor` по `ProblemType`;
- вызывает `Predict` и `SavePredictedData`;
- обновляет `MLModel.BatchPredictedOn`;
- перепланирует себя через `SchedulerUtils.ScheduleNextRun`.

Если `MLModelBatchPredictionPeriodMinutes = 0`, job не запускает prediction и не
ставит следующий run.

## Predictors по ProblemType

Batch job использует binding name:

```text
ProblemType.ToString().ToUpper()
  -> ClassFactory.TryGet<IMLBatchPredictor>(name)
```

Single entity prediction использует аналогичный подход через
`MLEntityPredictor` и `IMLEntityPredictor`.

## MLHelperService

`MLHelperService` - WCF service/helper для:

- получения ML service URL/API key из system settings;
- проверки license/API key/limits;
- создания уведомлений администраторам;
- отправки client message `MLModelStateChangedMessage`;
- вспомогательных операций UI по моделям.

Это доменный service ML-контура, а не универсальный пример WCF.

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [ML Data Model](ml-data-model.md)
- [ML Troubleshooting](ml-troubleshooting.md)
- [Quartz Class Jobs](quartz-class-jobs.md)
- [Services Outgoing REST](services-outgoing-rest.md)
