# EventListener Validation And Safety

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, validation, e.IsCanceled, SecurityException, recursion -->

> Как безопасно валидировать данные в listener'ах, отменять операции и не создавать рекурсию или тяжёлые side effects.

## Валидация в before-событиях

Валидацию размещают в `OnSaving`, `OnInserting`, `OnUpdating` или `OnDeleting`.

```csharp
public override void OnSaving(object sender, EntityBeforeEventArgs e) {
    var entity = (Entity)sender;
    ValidateUniqueSlug(entity);
    base.OnSaving(sender, e);
}
```

Для проверки уникальности можно использовать ESQ с `RowCount = 1`.

```csharp
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "InsightSlug");
esq.RowCount = 1;
esq.AddColumn("Id");
esq.Filters.Add(esq.CreateFilterWithParameters(FilterComparisonType.Equal, "Slug", slug));
```

## Отмена операции

Для отмены используется `EntityBeforeEventArgs.IsCanceled`.

```csharp
if (isInvalid) {
    e.IsCanceled = true;
    throw new InvalidOperationException(message);
}
```

Такой паттерн встречается в OAuth listener'ах: операция отменяется, а клиент получает понятную ошибку.

## Исключение или IsCanceled

| Подход | Когда применять |
| --- | --- |
| `throw new ValidateException(...)` | бизнес-валидация, которую должен увидеть пользователь |
| `e.IsCanceled = true` + exception | нужно явно остановить pipeline и вернуть ошибку |
| только `e.IsCanceled = true` | операция должна быть тихо отменена, что встречается редко |
| логирование без отмены | after-событие не должно ломать сохранение |

## Проверка прав

Listener выполняется внутри текущего `UserConnection`, поэтому права пользователя важны.

```csharp
entity.UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageSolution");
```

В `ExternalAccessListener` дополнительно проверяется restricted mode:

```csharp
if (userConnection.IsSystemOperationsRestricted) {
    throw new SystemOperationRestrictedException();
}
```

## Работа с внешними API

Внешний API-вызов внутри before hook опасен: он удлиняет транзакцию и может заблокировать сохранение. Если вызов обязателен, обрабатывайте ошибки явно:

- ловите ожидаемые API exceptions;
- ставьте `e.IsCanceled = true`;
- логируйте техническую ошибку;
- возвращайте пользователю локализованное сообщение;
- не логируйте secrets.

Для необязательной обработки лучше использовать async executor или Quartz job. См. [event-listeners-async-and-jobs.md](event-listeners-async-and-jobs.md).

## Рекурсия

Самый рискованный паттерн: вызывать `Save()` сущности внутри её же listener'а.

```csharp
public override void OnDeleting(object sender, EntityBeforeEventArgs e) {
    var entity = (Entity)sender;
    entity.SetColumnValue("IsArchive", true);
    entity.Save();
    e.IsCanceled = true;
}
```

Такой код может повторно войти в цепочку событий. Если нужен soft delete, лучше:

- вынести операцию в отдельный сервис;
- использовать отдельный флаг состояния;
- проверять, что повторный вход невозможен;
- не изменять ту же запись в before hook без строгой причины.

## Тяжёлая логика

After-события иногда запускают индексацию, cache invalidation или async операции. Чтобы снизить нагрузку:

- проверяйте изменённые колонки;
- выходите рано, если событие не относится к нужному сценарию;
- оборачивайте необязательную after-логику в `try/catch`;
- не делайте массовые выборки без `RowCount` или точных фильтров;
- переносите тяжёлую обработку в job.

Пример раннего выхода:

```csharp
if (!IsChangedIndexedColumns(entity, e)) {
    return;
}
```

## Практические правила

- В before hook проверяйте и заполняйте, в after hook синхронизируйте side effects.
- Исключение в before hook останавливает user operation, поэтому сообщение должно быть понятным.
- Исключение в after hook может сломать уже выполненное действие, если не обработано.
- Не используйте `SystemUserConnection` в entity listener без явного бизнес-основания.
- Всегда фильтруйте по изменённым колонкам, если логика нужна только для части изменений.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener entity hooks](event-listeners-entity-hooks.md)
- [EventListener async and jobs](event-listeners-async-and-jobs.md)
- [Services UserConnection And Security](services-userconnection-security.md)
- [ESQ performance](esq-performance.md)
