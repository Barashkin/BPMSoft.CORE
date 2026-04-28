# ESN Pattern Catalog

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ESN, patterns, feed, social -->

> Каталог повторяемых паттернов ESN / Feed / Social в Base.

## Пост и комментарий одной сущностью

`SocialMessage.Parent` определяет иерархию:

- `Parent` пустой — пост;
- `Parent` заполнен — комментарий.

Счетчики `LikeCount` и `CommentCount` хранятся на `SocialMessage`.

## Привязка к произвольной записи

ESN использует универсальную пару:

```text
EntitySchemaUId + EntityId
```

Так устроены `SocialMessage`, `SocialSubscription`, `SocialMessageEntity`.

## Лайк как запись

`SocialLike` хранит:

- `User`;
- `SocialMessage`.

Это упрощает проверку лайка конкретным пользователем и список "кто лайкнул".

## Подписка как запись SysAdminUnit

`SocialSubscription` связывает `SysAdminUnit` с произвольной записью.
`CanUnsubscribe` отделяет пользовательскую отписку от системной подписки.

## Канал с правом публикации

`SocialChannel.PublisherRightKind` задает модель публикации на уровне канала.
Для сложной настройки см. `SocialChannelPublisher`.

## Фасад ESN

`EsnCenter` не ходит в БД напрямую, а делегирует:

- likes — `IEsnLikeRepository`;
- чтение — `IEsnMessageReader`;
- запись/удаление — `IEsnMessageRedactor`;
- права — `IEsnSecurityEngine`.

## Серверная проверка прав

Перед чтением/удалением `EsnCenter` проверяет `IEsnSecurityEngine`.
Клиентские флаги прав не заменяют серверную проверку.

## Feature-gated client rights

`SocialFeedUtilities`:

- при `UseEsnRights` выставляет локальные права;
- иначе использует `RightUtilities` по схеме `SocialMessage`.

## Mention contacts with SSP branch

`ESNFeedModuleService` возвращает `ContactForMention` и добавляет SSP-контакты,
если включен feature `IsSSPContactSocialMentions`.

## Mention search rules

`SocialMentionSearchRule` задает:

- схему;
- колонку фильтрации;
- колонку пользователя.

Это позволяет подбирать mentions по контексту текущей записи.

## Timeline through Ajax provider

`EsnTimelineDataProvider` вызывает `EsnService.ReadEntityMessage`, затем
преобразует `response.EsnMessages` в timeline rows.

## Mobile HTML sanitizing

`MobileFeedList` оставляет ограниченный набор тегов (`a`, `br`), распознает
URL/email и обрезает HTML без разрыва тегов.

## SocialNetworkIntegration boundary

Файлы `*.SocialNetworkIntegration.js` описывают внешний social search/OAuth
контур, а не внутренние ESN-посты.

## Diagnostics context

`EsnLogContext` включает логирование `EsnCenterLogger`. Используйте его для
диагностики чтения фида и фильтрации сообщений.
