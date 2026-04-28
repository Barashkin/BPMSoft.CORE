# SSP Portal Sections And Pages

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SSP, portal sections, PortalSectionHelper, PortalMainPage -->

> Portal sections и страницы: публикация разделов, структура секций,
> главная страница портала и portal UI modules.

## Portal section metadata

Ключевые схемы:

- `SysPortal`;
- `Portal_SysModule`;
- `SysModuleEntityInPortal`;
- `SysModuleEntitySchema.SSP`;
- `SspPageDetail`.

`SysModuleEntityInPortal` определяет, какие module entities опубликованы в
портале.

## PortalSectionHelper

`PortalSectionHelper.SSP.cs` содержит `IAppEventListener`.

На старте приложения:

```text
ClassFactory.Bind<ISectionStructureBuilder, PortalSectionStructureBuilder>(UserType.SSP)
ClassFactory.Bind<ISectionStructureBuilder, GeneralSectionStructureBuilder>(UserType.General)
```

`PortalSectionStructureBuilder` добавляет `JOIN SysModuleEntityInPortal`, чтобы
для SSP выбирать только опубликованные в портал section entities.

`GeneralSectionStructureBuilder` делает обратное: исключает portal entities из
общей структуры.

## Portal main page

`PortalMainPageBuilder.SSP.js` расширяет dashboard builder.

Особенности:

- `PortalMainPageViewConfig` наследует `DashboardsViewConfig`;
- для SSP скрывает settings button;
- для не-SSP добавляет классы настроек;
- `BasePortalMainPageViewModel` вычисляет `IsNotSSP`;
- вкладки скрываются, если portal user видит только одну вкладку;
- для админов проверяются операции `CanManagePortalMainPage` и
  `CanViewConfiguration`.

Смежные файлы:

- `PortalMainPageModule.SSP.js`;
- `SystemDesigner.SSP.js`;
- `SysModuleInWorkplaceDetailV2.SSP.js`.

## Portal profile and mini pages

Клиентские точки:

- `PortalClientProfileSchema.SSP.js`;
- `PortalClientAccountProfileSchema.SSP.js`;
- `PortalContactMiniPage.SSP.js`;
- `PortalAccountMiniPage.SSP.js`;
- `SspAccountProfilePage.SSP.js`;
- `SspPageWizard.SSP.js`.

## Knowledge Base portal pages

Пакет `SspKnowledgeBase` добавляет отдельный portal UX:

- `PortalKnowledgeBaseSection.SspKnowledgeBase.js`;
- `PortalKnowledgeBasePage.SspKnowledgeBase.js`;
- `KnowledgeBaseSearchModule.SspKnowledgeBase.js`;
- `PopularKnowledgeBaseArticlesListModule.SspKnowledgeBase.js`.

## Практические правила

- Для публикации раздела проверяйте `SysModuleEntityInPortal`.
- Для общей секционной структуры учитывайте разные builders для SSP и General.
- Для главной страницы портала проверяйте права `CanManagePortalMainPage` и
  `CanViewConfiguration`.
- Не показывайте portal user административные settings actions.
- Для portal UX используйте SSP-specific page modules, а не только базовые UIv2.

## Связанные документы

- [SSP portal overview](ssp-portal-overview.md)
- [SSP portal access rights](ssp-portal-access-rights.md)
- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Client module overview](../client/client-module-overview.md)
