# Process User Tasks

<!-- Версия: 1.2 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessUserTask, AddDataUserTask, ReadDataUserTask, ChangeDataUserTask, DeleteDataUserTask, AI, LLM, ML -->

> UserTask'и выполняют типовые операции процесса: создание, чтение, изменение, удаление записей и открытие пользовательских страниц.
> Для LLM-specific user task см. [AI LLM Process User Task](ai-llm-process-user-task.md).

## Общая модель

Runtime task наследуется от `ProcessUserTask` и выполняет логику в `InternalExecute`.

```csharp
protected override bool InternalExecute(ProcessExecutingContext context) {
    // task logic
    return true;
}
```

Generated process schema создаёт flow element, задаёт имя, тип, параметры и mapping.

## AddDataUserTask

`AddDataUserTask` создаёт новую запись через Entity API.

Ключевые шаги:

- получить `EntitySchema`;
- создать entity;
- вызвать `SetDefColumnValues`;
- заполнить значения из `RecordDefValues`;
- сохранить;
- вернуть `RecordId`.

```csharp
Entity newEntity = entitySchema.CreateEntity(UserConnection);
newEntity.SetDefColumnValues();
newEntity.UseAdminRights = false;
FillRowWithData(newEntity);
newEntity.Save(false);
RecordId = newEntity.PrimaryColumnValue;
```

Если task создаёт записи по результатам фильтра, он сначала читает source collection через ESQ.

## ReadDataUserTask

`ReadDataUserTask` строит ESQ и заполняет result-параметры.

```csharp
EntitySchemaQuery esq = CreateEntitySchemaQuery(entitySchema.Name);
esq.UseAdminRights = false;
SpecifyESQColumns(esq, resultType, ref aggregationColumnName);
ProcessUserTaskUtilities.SpecifyESQFilters(UserConnection, this, entitySchema, esq, DataSourceFilters);
EntityCollection entityCollection = esq.GetEntityCollection(UserConnection);
```

Возможные результаты:

- `ResultEntity`;
- `ResultEntityCollection`;
- `ResultRowsCount`;
- aggregate values;
- `ResultCompositeObjectList`.

## ChangeDataUserTask

`ChangeDataUserTask` выбирает записи по фильтрам и сохраняет новые значения.

Важная защита: при `IsMatchConditions` пустой фильтр считается ошибкой.

```csharp
if (isEmptyFilter) {
    throw new NullOrEmptyException(
        new LocalizableString("BPMSoft.Core",
            "ProcessSchemaChangeDataUserTask.Exception.ChangeDataWithEmptyFilter"));
}
```

Это предотвращает случайное массовое обновление всех записей.

## DeleteDataUserTask

`DeleteDataUserTask` также запрещает удаление без фильтра.

```csharp
if (isEmptyFilter) {
    throw new NullOrEmptyException(
        new LocalizableString("BPMSoft.Core",
            "ProcessSchemaDeleteDataUserTask.Exception.DeleteDataWithEmptyFilter"));
}
```

Дальше task получает collection и вызывает `entity.Delete()`.

## OpenEditPageUserTask и process listeners

`OpenEditPageUserTask` может поставить process listener на изменение записи.

```csharp
IProcessEngine processEngine = UserConnection.ProcessEngine;
processEngine.AddProcessListener(RecordId, ObjectSchemaId, UId, serializedFilters);
```

Это связывает процесс с будущим изменением entity.

## LLM user task

`LlmUserTask` относится к AI / LLM слою и отличается от CRUD-задач: он берёт
`LlmModel`, выбирает `ILlmProvider` по `LlmModel.ApiType.Code`, опционально
добавляет PDF-вложения в prompt и записывает completion text в `Result`.

Подробности: [AI LLM Process User Task](ai-llm-process-user-task.md).

## ML prediction user task

`MLDataPredictionUserTask` относится к ML / Prediction / Scoring слою: он берёт
`MLModel`, запускает single или batch prediction, а для collaborative filtering
строит users/items выборки и вызывает recommendation flow.

Подробности: [ML Process User Tasks](ml-process-user-tasks.md).

## Практические правила

- Для `ReadDataUserTask` всегда проверяйте `ResultRowsCount`.
- Для `ChangeDataUserTask` и `DeleteDataUserTask` не допускайте пустых фильтров.
- Для массовых операций учитывайте права: user tasks обычно используют `UseAdminRights = false`.
- Если логика стала сложной, выносите её в helper/service и вызывайте из ScriptTask.
- Для производительности выбирайте конкретные колонки, а не `AddAllSchemaColumns`.

## Связанные документы

- [Process Overview](process-overview.md)
- [Process runtime and schema](process-runtime-schema.md)
- [AI LLM Process User Task](ai-llm-process-user-task.md)
- [ML Process User Tasks](ml-process-user-tasks.md)
- [ESQ performance](esq-performance.md)
- [Process listeners and logs](process-listeners-and-logs.md)
