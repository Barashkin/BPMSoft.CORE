# Data Access Beyond ESQ Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: data-access, ESQ, Select, DBExecutor, transactions, StoredProcedure -->

> Capstone dive по доступу к данным за пределами `EntitySchemaQuery`: SQL
> builders, `DBExecutor`, транзакции, stored procedures, custom SQL и bulk.

## Выбор инструмента

| Задача | Инструмент |
| ------ | ---------- |
| Прочитать entity с display values и schema paths | ESQ |
| Создать/изменить запись с events и business logic | Entity API + `Save` |
| Массово обновить много записей | `Update`/`Delete` builders или repository bulk |
| Сложный SQL, aggregates, `HAVING`, `IDataReader` | `Select` + `DBExecutor` |
| Вызвать DB procedure | `StoredProcedure` |
| Выполнить vendor-specific SQL | `CustomQuery` с осторожностью |

## Select/Insert/Update/Delete builders

`BPMSoft.Core.DB` builders используются, когда ESQ слишком тяжёлый или не
выражает нужный SQL.

Типовой read:

```text
new Select(UserConnection)
  .Column("Id")
  .From("SomeTable")
  .Where("SomeColumn").IsEqual(Column.Parameter(value))
```

Типовой update/delete:

```text
new Update(UserConnection, "SomeTable")
  .Set("SomeColumn", Column.Parameter(value))
  .Where("Id").IsEqual(Column.Parameter(id))
```

Такие операции не вызывают entity events как `Entity.Save`. Если нужны
listeners, validation и process events, используйте Entity API.

## DBExecutor and transactions

Для чтения через `IDataReader`:

```text
using (DBExecutor executor = UserConnection.EnsureDBConnection()) {
  using (IDataReader reader = select.ExecuteReader(executor)) {
    ...
  }
}
```

Для транзакций:

```text
DBExecutor executor = UserConnection.EnsureDBConnection();
executor.StartTransaction();
try {
  ...
  executor.CommitTransaction();
} catch {
  executor.RollbackTransaction();
  throw;
}
```

Транзакция должна быть короткой. Не держите её вокруг внешних HTTP calls,
долгих вычислений или UI roundtrip.

## Query expressions

`QueryColumnExpression`, `Column.Func`, агрегаты и `Having` полезны для:

- routing/queue counters;
- dashboard-like aggregations;
- сложной сортировки;
- выборок, где нужно вычисляемое выражение.

Если выражение становится слишком сложным, лучше вынести его в отдельный helper
method и покрыть отдельным troubleshooting section.

## StoredProcedure and CustomQuery

`StoredProcedure` используется для процедур вроде пересчёта, позиционирования,
массовой обработки.

`CustomQuery` оставляйте для случаев, где builder не подходит. Требования:

- параметры через `QueryParameter`, а не string interpolation;
- явная причина, почему builder/ESQ недостаточны;
- проверка DB portability;
- отдельный лог/diagnostics для ошибок.

## Bulk and repositories

`EntityRepository.BulkUpdate(IEnumerable<Guid>, IDictionary<string, object>)`
отличается от доменных bulk operations вроде deduplication/import. Первое -
универсальный repository API, второе - бизнес-процесс с собственными правилами,
логами и recovery.

## Security boundary

Low-level SQL не делает автоматических проверок прав как UI/service layer. Перед
массовыми операциями явно решите:

- нужен ли `UseAdminRights`;
- какой `UserConnection` используется;
- какие operation/schema/record rights должны быть проверены;
- нужны ли entity listeners;
- как логируется изменение.

## Source file map

| Паттерн | Source area |
| ------- | ----------- |
| ESQ + SQL builder | `IndexingEntityListBuilder.GlobalSearch.cs`, OCC routing files |
| Dense `Select`/`Update` usage | `BPMSoftOCC*.cs`, `SyncWithLDAPProcessHelper.LDAP.cs` |
| Transactions | `DeduplicationMergeHandler.Deduplication.cs`, `EntityArchiver.Base.cs` |
| Stored procedure | `BaseEntityWithPositionSchema.Base.cs`, `BaseCompletenessService.Completeness.cs` |
| Custom query | `KnowledgeBaseSchema.BPMSoftOCC.cs` |
| Repository bulk | `EntityRepository.Base.cs`, `ImportParametersRepository.FileImport.cs` |

## Troubleshooting

| Симптом | Проверить |
| ------- | --------- |
| Entity listener не сработал | использован SQL builder вместо Entity API |
| Массовое обновление обошло права | explicit operation/right check перед SQL |
| Deadlock/долгая блокировка | длина транзакции, порядок обновления, индексы |
| SQL работает в одной БД и падает в другой | `CustomQuery`, vendor-specific syntax |
| Память растёт при чтении | streaming через `IDataReader`, не грузить всё в коллекцию |

## Связанные документы

- [ESQ Overview](esq-overview.md)
- [ESQ Performance](esq-performance.md)
- [Entity Schema Overview](entity-schema-overview.md)
- [Security UserConnection Context](security-userconnection-context.md)
- [Services UserConnection Security](services-userconnection-security.md)
