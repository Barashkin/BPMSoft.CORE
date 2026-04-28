# ML Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, troubleshooting, prediction, scoring, Quartz -->

> Диагностика ML / Prediction / Scoring: service URL/API key, training jobs,
> batch prediction, model readiness, process user task и scoring service.

## Быстрая классификация

| Симптом | Где смотреть |
| ------- | ------------ |
| Jobs не запускаются | `MLAppListener`, scheduler, `MLModelTrainingPeriodMinutes`, `MLModelBatchPredictionPeriodMinutes` |
| Training не начинается | `MLModelTrainerJob`, `IMLTrainingManager`, `MLModelTrainer` |
| Batch prediction ничего не делает | `MLBatchPredictionJob`, `MLModelLoader`, `PredictionEnabled` |
| Single prediction не сохраняет результат | `MLEntityPredictor`, `MLPredictionSaver`, target column |
| Process task падает на фильтрах | `MLDataPredictionUserTask.FilterEditConverter` |
| Внешний ML API возвращает ошибку | `MLServiceProxy`, `MLHelperService` |
| Scoring service возвращает 403 | `ScoringEngine.ValidateAuthKey`, cloud auth key |

## Jobs не запускаются

Проверьте:

- что `MLAppListener.OnAppStart` отработал;
- что в scheduler есть `MLBatchPredictionJob` и `MLModelTrainerJob`;
- что syssettings периодов не равны `0`;
- что job не упала до `finally`;
- что `SchedulerUtils.ScheduleNextRun` вызывается.

Если период равен `0`, job пишет информационный log и не перепланируется.

## Service URL или API key не настроены

`MLBatchPredictionJob` перед prediction проверяет:

- `MLUtils.CheckIsServiceUrlSet`;
- `MLUtils.CheckApiKey`.

`MLServiceProxy` при `Unauthorized` дополнительно проверяет
`MLServiceAPIKey` и `CloudServicesAPIKey` через `MLHelperService`.

Проверьте system settings:

- `MLServiceUrl`;
- `MLServiceAPIKey`;
- `CloudServicesAPIKey`;
- license/limit settings и доступность cloud services.

## Модель не готова к prediction

`MLEntityPredictor` отфильтровывает модель, если:

- `ModelInstanceUId` пустой;
- `ServiceUrl` пустой;
- `PredictionEntitySchemaUId` пустой;
- `PredictedResultColumnName` пустой;
- выбранные модели относятся к разным prediction entity schema.

Также проверьте состояние training session и `PredictionEnabled`.

## Batch prediction не сохраняет данные

Проверьте:

- что модель попадает в `LoadModelsForBatchPrediction`;
- что для `MLProblemTypeId` есть `IMLBatchPredictor` binding;
- что `BatchPredictionFilterData` не отсекает все записи;
- что target column настроена;
- что `MLPredictionResultsLifeDays` не очищает ожидаемые результаты слишком рано.

## Process user task падает

Для `MLDataPredictionUserTask` проверьте:

- `MLModelId`;
- `RecordId` для single prediction;
- `PredictionFilterData` для batch prediction;
- `CFUserFilterData`, `CFItemFilterData`, `TopN` для collaborative filtering;
- что `FilterEditConverter` может разрешить process parameters.

Если model config не загружается, task может завершиться без результата или
бросить `InvalidObjectStateException`.

## Внешний ML API возвращает ошибку

`MLServiceProxy` обрабатывает HTTP status:

- `401 Unauthorized` - API key/license;
- `403 Forbidden` - доступ запрещён;
- `404 NotFound` - method endpoint не найден;
- `500 InternalServerError` - ошибка ML service;
- `400 BadRequest` - некорректный request body или данные.

Смотрите log category `ML` и уведомления, созданные через `MLHelperService`.

## Scoring service возвращает 403

`ScoringService` вызывает `ScoringEngine.ValidateAuthKey`. Если
`BpmCrmCloudEngine.Authenticate` возвращает failure, service бросает
`WebFaultException<string>` со статусом `Forbidden`.

Проверьте:

- auth headers/request key;
- `CloudServicesAPIKey`;
- доступность system user connection для anonymous сценария;
- корректность `schemaName`, `columns`, `schemaColumnName`.

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [ML Runtime Jobs](ml-runtime-jobs.md)
- [ML Process User Tasks](ml-process-user-tasks.md)
- [ML Base Scoring](ml-base-scoring.md)
- [Quartz Troubleshooting](quartz-troubleshooting.md)
- [Services Troubleshooting](services-troubleshooting.md)
