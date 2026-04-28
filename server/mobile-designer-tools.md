# Mobile Designer Tools

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MobileDesignerTools, manifest, mobile designer -->

> Инструменты дизайнера мобильного приложения: metadata, settings modules,
> converter и генерация manifest.

## Основные модули

В `MobileDesignerTools` есть отдельный контур для проектирования mobile UI и
конвертации настроек в manifest.

| Файл | Назначение |
| ---- | ---------- |
| `MobileDesignerModule.MobileDesignerTools.js` | shell модуля дизайнера |
| `MobileBaseDesignerModule.MobileDesignerTools.js` | базовый designer module |
| `MobileSectionDesignerModule.MobileDesignerTools.js` | дизайнер section |
| `MobilePageDesignerModule.MobileDesignerTools.js` | дизайнер page |
| `MobileDetailDesignerModule.MobileDesignerTools.js` | дизайнер detail |
| `MobileGridDesignerModule.MobileDesignerTools.js` | дизайнер grid |
| `MobileDesignerConfigManager.MobileDesignerTools.js` | управление config |
| `MobileDesignerMetadataToManifestConverter.MobileDesignerTools.js` | metadata to manifest |

## Metadata to manifest

`MobileDesignerMetadataToManifestConverter` — ключевая точка, где настройки
дизайнера превращаются в JSON manifest. Если UI дизайнера меняется, проверяйте,
что converter сохраняет совместимый manifest.

## Settings modules

Для разных частей UI есть отдельные settings:

- `MobileBaseDesignerSettings`;
- `MobileGridDesignerSettings`;
- `MobileRecordDesignerSettings`;
- `MobileActionsDesignerSettings`.

Они задают свойства, которые затем попадают в manifest/profile files.

## Manifest helpers

Дополнительные утилиты:

- `MobileDesignerApplicationManifest`;
- `MobileDesignerManifestColumnResolver`;
- `MobileDesignerSchemaManager`;
- `MobileDesignerConverter`;
- `MobileDesignerUtils`;
- `MobileSha3`.

## Workplace designer

`SysMobileWorkplaceSection` и `SysMobileWorkplacePage` покрывают управление
мобильными рабочими местами в UI.

## Практические правила

- При изменении designer metadata проверяйте converter.
- Не редактируйте generated profile вручную без понимания designer source.
- Для новых секций настройте grid, record page, details и actions.
- Проверяйте, что generated manifest содержит нужные модели sync.
- Изменения workplace UI сверяйте с `SysMobileWorkplace` и ролями.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
- [Mobile SDK pages](mobile-sdk-pages.md)
- [Client Module Overview](../client/client-module-overview.md)
