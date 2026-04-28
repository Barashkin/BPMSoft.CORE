# OCC / Sender Jobs Map

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OCC, Sender, Quartz, jobs, scheduler -->

> Сводная карта фоновых задач OCC и Sender. Используйте её как быстрый
> справочник перед детальным разбором routing, request pipeline или Sender.

## Группы задач

OCC использует Quartz jobs для трёх классов задач:

- recovery необработанных webhook/request записей;
- routing, AFK и operator lifecycle;
- delivery/scheduler сценарии Sender.

## OCC request и routing

| Job | Файл | Назначение |
| --- | ---- | ---------- |
| `RequestHandlingJob` | `BPMSoftOCCStrategy.BPMSoftOCC.cs` | повторно обрабатывает `BPMSoftOCCChatRequest` с `Processed = false` |
| `ChatRoutingJob` | `BPMSoftOCCRouting.BPMSoftOCC.cs` | запускает маршрутизацию открытых чатов |
| `SaveAFKChatJob` | `BPMSoftOCCRouting.BPMSoftOCC.cs` | обслуживает AFK-сценарии |
| `ScheduleOperatorLogoutJob` | `BPMSoftOCCOperatorLogoutSchema.BPMSoftOCC.cs` | отложенный logout/смена состояния оператора |

`RequestHandlingJob` является страховочным механизмом. Основной входящий
request часто обрабатывается синхронно из `BPMSoftOCCChatRequestService`, но
job поднимает то, что осталось необработанным.

## Sender

| Job | Файл | Интервал / запуск | Назначение |
| --- | ---- | ----------------- | ---------- |
| `BPMSoftSenderDeliverySchedulerJob` | `BSDeliverySource.BPMSoftSender.cs` | class job, повторяемый запуск | выбирает получателей и запускает `BSDeliveryStrategy` |
| `BPMSoftSenderStatusJob` | `BSDeliverySource.BPMSoftSender.cs` | class job, повторяемый запуск | актуализирует статусы рассылок |
| `BSChatRoutingJob` | `BSRoutingJob.BPMSoftSender.cs` | каждые 10 минут | восстанавливает открытые OCC-чаты, связанные с delivery |
| process job из `BSSchedulerService` | `BSSchedulerService.BPMSoftSender.cs` | cron или single-run | запускает delivery по расписанию |

Sender jobs не отправляют сообщения "мимо" OCC: основной сценарий проходит
через `BSDeliveryStrategy`, OCC-каналы, OCC-чаты и OCC-сообщения.

## Как jobs запускаются

| Сценарий | Что происходит |
| -------- | -------------- |
| Ручной старт рассылки | `BSDeliveryService.StartDelivery(...)` планирует sender jobs и меняет статус delivery |
| Cron-рассылка | `BSSchedulerService.AddProcessToScheduleCronExp(...)` создаёт process job с cron trigger |
| Разовый запуск | `BSSchedulerService.AddProcessToScheduleSingleRun(...)` создаёт process job с simple trigger |
| Перевод в running | `BSSchedulerService.SetRunningDeliveryStatus(...)` планирует sender jobs и обновляет recipients |
| Остановка | `BSDeliveryService.StopDelivery(...)` или `RemoveProcessFromSchedule(...)` меняет delivery/recipient statuses |

## Диагностический порядок

1. Определите, это OCC chat request, routing или Sender delivery.
2. Проверьте доменную сущность: `BPMSoftOCCChatRequest`, `BPMSoftOCCChat`,
   `BPMSoftOCCDelivery`, `BSDeliveryRecipient`.
3. Проверьте, есть ли активный Quartz/process job.
4. Смотрите профильный документ:
   [occ-request-pipeline.md](occ-request-pipeline.md),
   [occ-routing-strategy.md](occ-routing-strategy.md) или
   [bpmsoft-sender.md](../extended/bpmsoft-sender.md).

## Связанные документы

- [Quartz / AppScheduler](scheduler-quartz.md)
- [OCC Request Pipeline](occ-request-pipeline.md)
- [Routing и AFK OCC](occ-routing-strategy.md)
- [BPMSoftSender в OCC-контуре](../extended/bpmsoft-sender.md)
- [OCC Troubleshooting](occ-troubleshooting.md)
