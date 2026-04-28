# ML Base Scoring

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ML, BaseScoring, MLScoring, ScoringEngine, ScoringService -->

> Scoring в платформе состоит из двух контуров: `BaseScoring` с правилами и
> `MLScoring` как ML predictor для scoring problem type.

## BaseScoring: rules-based engine

`BaseScoring` не является generative AI и не обучает ML-модель. Это контур
правил:

- `ScoringModel` описывает scoring object и колонку, куда сохраняется score;
- `ScoringRule` описывает фильтр, points, duration и count;
- `RuleSerializationHelper` превращает filter data в criteria/query;
- `ScoringEngine` собирает scoring map и сохраняет scored results;
- `ScoringService` отдаёт WCF endpoints.

## ScoringEngine

`ScoringEngine`:

- читает все `ScoringModel`;
- читает все `ScoringRule`;
- связывает rules с model;
- строит rule criteria через `RuleSerializationHelper`;
- отдаёт `GetScoringMapResponse`;
- сохраняет результаты через `SaveScoredResults`;
- отдаёт данные для синхронизации через `GetSynchronizationRecords`;
- валидирует auth key через `BpmCrmCloudEngine.Authenticate`.

## ScoringService

`ScoringService` публикует WCF methods:

| Method | Назначение |
| ------ | ---------- |
| `GetSynchronizationData` | вернуть изменённые записи для внешнего scoring расчёта |
| `SaveScoredData` | сохранить score values в целевую схему |
| `GetSerializedRuleConditions` | вернуть serialized select query для rule |
| `GetScoringMap` | вернуть scoring map с моделями и правилами |

Часть методов работает в anonymous/system context после проверки auth key.

## MLScoring bridge

`MLScoring` связывает scoring problem type с ML predictor infrastructure.

`MLScoringEntityPredictor`:

- зарегистрирован как `IMLEntityPredictor` и `IMLPredictor<ScoringOutput>`;
- binding name равен `MLConsts.ScoringProblemType`;
- вызывает `proxy.Score(model, data, true)`;
- сохраняет score в entity и `MLPrediction`.

`MLBatchScorer`:

- зарегистрирован как `IMLBatchPredictor` для того же problem type;
- форматирует score как `Convert.ToInt32(scoringOutput.Score * 100)`;
- сохраняет prediction result через `PredictionSaver`.

## Как не перепутать

| Контур | Что делает |
| ------ | ---------- |
| `BaseScoring` | rule map, sync data, save scored data |
| `MLScoring` | ML predictor implementation для scoring problem type |
| `.ML` | общая инфраструктура моделей, proxy, jobs, prediction saver |

`BaseScoring` может существовать без обучения ML-модели. `MLScoring` существует
как специализация ML prediction.

## Связанные документы

- [ML Prediction Scoring Overview](ml-prediction-scoring-overview.md)
- [ML Runtime Jobs](ml-runtime-jobs.md)
- [ML Boundaries](ml-boundaries.md)
- [Services Overview](services-overview.md)
