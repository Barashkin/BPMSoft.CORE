# ESN Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ESN, troubleshooting, feed, mentions -->

> Диагностика ESN должна идти от UI к сервису и модели: сначала понять, какой
> модуль показывает ленту, затем проверить `EsnService`/`EsnCenter`, права,
> подписки и данные `SocialMessage`.

## Лента не показывает сообщения

Проверьте:

1. Модуль `ESNFeedModule.ESN.js` и schema `SocialFeed`.
2. Вызов `EsnService` из `SocialFeedUtilities`.
3. Наличие записей `SocialMessage` с нужными `EntitySchemaUId` и `EntityId`.
4. Права чтения через `IEsnSecurityEngine`.
5. Подписки `SocialSubscription` для пользователя/роли.
6. `EsnLogContext` и логгер `EsnCenterLogger`, если включено логирование.

## Комментарии не загружаются

Проверьте:

- что комментарии имеют `Parent = Id` родительского `SocialMessage`;
- что `CommentCount` на родительском сообщении актуален;
- что `SocialFeedUtilities` загружает начальные комментарии (`initCommentCount`);
- что `EsnCenter.ReadComments` проходит проверку прав.

## Лайк не ставится или счетчик неверный

Проверьте:

- записи `SocialLike` по `User` и `SocialMessage`;
- методы `EsnCenter.LikeMessage` / `UnLikeMessage`;
- `IEsnLikeRepository`;
- синхронизацию `LikeCount` на `SocialMessage`;
- клиентский `MobileSocialMessageLikeManager` для mobile.

## Нельзя удалить пост

Проверьте:

- `IEsnSecurityEngine.CanDeletePost`;
- автора сообщения (`CreatedBy`);
- `UseEsnRights` и клиентские `CanDelete`, но не полагайтесь только на них;
- `EsnCenter.InnerDeletePost`, который выбрасывает `SecurityException`.

## Mentions не находят контакты

Проверьте:

1. Endpoint `ESNFeedModuleService`.
2. Размер страницы `MentionContactsPageSize = 5`.
3. Активность `SysAdminUnit`.
4. Права чтения `Contact` через `DBSecurityEngine`.
5. Для SSP: `UserType.SSP`, feature `IsSSPContactSocialMentions`,
   `SocialMentionSearchRule`.
6. Клиентский `SocialMentionUtilities.ESN.js`.

## SSP mentions показывают не тех пользователей

Проверьте:

- правила `SocialMentionSearchRule`;
- `EntitySchema`, `FilterByColumn`, `UserColumn`;
- текущий `entitySchemaUId` и `entityId`;
- дополнительные portal contacts в `ESNFeedModuleService`.

## Timeline не показывает ESN

Проверьте:

- `EsnTimelineDataProvider.Timeline.js`;
- что `config.entities.length === 1`;
- параметры `schemaUId`, `entityId`, `ReadMessageCount`, `OffsetDate`;
- ответ `EsnService.ReadEntityMessage`;
- `SocialMessageTimelineItemViewModel`.

## Уведомления не приходят или не читаются

Проверьте:

- записи `ESNNotification` по `Owner`;
- `Type`, `IsRead`, `SocialMessage`;
- `ESNNotificationType`;
- `EsnNotificationSettings`;
- клиентский `ESNNotificationModule`;
- websocket/channel constants в `ESNConstants`.

## Mobile feed отображает поврежденный HTML

Проверьте:

- `MobileFeedList.formatMessage`;
- допустимые теги `a` и `br`;
- преобразование URL/email;
- `truncateHtmlText`, если текст обрезается;
- `MobileSocialMessageHtmlField`.

## Путается ESN и внешние соцсети

Если проблема связана с постами/комментариями/лайками, смотрите ESN:

- `SocialMessage`;
- `SocialFeed`;
- `EsnCenter`;
- `EsnService`.

Если проблема связана с внешним social search/OAuth, смотрите
`SocialNetworkIntegration`:

- `SocialSearch`;
- `GoogleClientConnector`;
- `SocialAccountAuthModule`.
