# Web Service V2 Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ServiceDesigner, WebServiceV2, REST, SOAP, ServiceSchemaManager -->

> Web Service V2 в ServiceDesigner: view-схема, REST/SOAP designer, параметры,
> auth settings и runtime-вызов через `ServiceSchemaManager`.

## Модель

`VwWebServiceV2Schema.ServiceDesigner.cs` описывает view-схему:

- наследуется от `VwSysSchemaInWorkspaceSchema`;
- `Name = "VwWebServiceV2"`;
- `IsDBView = true`;
- добавляет колонку `TypeName`;
- при loading/deleted бросает events `VwWebServiceV2Loading` и
  `VwWebServiceV2Deleted`;
- содержит embedded process, который проверяет операции
  `CanViewConfiguration` или `CanManageSolution`.

Сопутствующие схемы:

| Схема | Назначение |
| ----- | ---------- |
| `WebServiceV2FolderSchema.ServiceDesigner.cs` | папки web service schemas |
| `WebServiceV2TagSchema.ServiceDesigner.cs` | теги |
| `WebServiceV2InFolderSchema.ServiceDesigner.cs` | связь service schema с папкой |
| `WebServiceV2InTagSchema.ServiceDesigner.cs` | связь service schema с тегом |
| `WebServiceV2FileSchema.ServiceDesigner.cs` | файлы service schema |

## Designer shell

`WebServicesDesigner.ServiceDesigner.js` наследуется от `BaseViewModule` и
переписывает hash:

```text
edit/{schemaId}
  -> CardModuleV2/WebServiceV2Page/edit/{schemaId}

add/{type}/.../{packageUId}
  -> CardModuleV2/{type}WebServiceV2Page/add/packageUId/{packageUId}
```

Для `type = Rest` открывается `RestWebServiceV2Page`, для `type = Soap` -
SOAP-страница.

## REST designer

`RestWebServiceV2Page.ServiceDesigner.js`:

- возвращает `ServiceType.REST`;
- умеет принять wizard URI;
- парсит URI через `UriJsonConverter`;
- конвертирует metadata через `JsonServiceMetaDataConverter`;
- выставляет `baseUri` и caption по domain;
- создаёт default method `UsrMethod1`;
- добавляет method в `schema.methods`.

## SOAP designer

SOAP-контур представлен:

- `SoapWebServiceV2Page.ServiceDesigner.js`;
- `SoapWebServiceMethodPage.ServiceDesigner.js`;
- `SoapServiceMethodModule.ServiceDesigner.js`;
- `SoapServiceParameterPage.ServiceDesigner.js`;
- `SoapServiceResponseParameterPage.ServiceDesigner.js`;
- `DownloadWsdlEndpoint.ServiceDesigner.cs`.

WSDL/download и XML schema helper-ы относятся именно к SOAP-контуру.

## Parameters and builders

Для REST/RAW/Curl/JSON сценариев используются:

- `JsonRequestBuilder.ServiceDesigner.js`;
- `JsonResponseBuilder.ServiceDesigner.js`;
- `RawRequestBuilder.ServiceDesigner.js`;
- `RawResponseBuilder.ServiceDesigner.js`;
- `CurlRequestBuilder.ServiceDesigner.js`;
- `UriRequestBuilder.ServiceDesigner.js`;
- `ServiceMethodBuilder.ServiceDesigner.js`;
- `ParametrizedServiceMethodBuilder.ServiceDesigner.js`.

Parameter UI:

- `ServiceParameterGrid.ServiceDesigner.js`;
- `ServiceResponseParameterGrid.ServiceDesigner.js`;
- `ServiceParameterPage.ServiceDesigner.js`;
- `ServiceResponseParameterPage.ServiceDesigner.js`;
- `ServiceParameterValuePage.ServiceDesigner.js`;
- `ServiceResponseParameterValuePage.ServiceDesigner.js`.

## Auth settings

`ServiceEnums.ServiceDesigner.js` описывает auth captions:

- `None`;
- `Basic`;
- `Digest`;
- `OAuth20`.

`ServiceAuthInfoSettingsPage.ServiceDesigner.js`:

- инициализирует `ServiceSchemaManager`;
- получает service schema по `ServiceSchemaUId`;
- показывает Basic/Digest module или OAuth20 module;
- скрывает Digest и OAuth20 за feature flags `WebServiceDigestAuth` и
  `WebServiceOAuth20Auth`;
- обновляет `method.useAuthInfo` при смене auth type.

## Runtime call

`CallServiceSchemaService.ServiceDesigner.cs` предоставляет WCF method
`Execute(serviceName, methodName, parameters)`.

Поток:

```text
CallServiceSchemaService.Execute
  -> CheckCanExecuteOperation("CanManageSolution")
  -> IServiceSchemaParameterBuilder.Build(parameters)
  -> IServiceSchemaClient.Execute(...)
  -> ServiceSchemaManager.GetInstanceByName(serviceName)
  -> serviceSchemaInstance.CreateServiceClient(userConnection)
  -> serviceClient.CreateRequest(methodName)
  -> serviceClient.Execute(request)
```

Ответ `CallServiceSchemaResponse` включает status, success, request/response raw
data, body и parameter values.

## Связанные документы

- [Integration Tools Overview](integration-tools-overview.md)
- [Integration Tools Runtime](integration-tools-runtime.md)
- [Services Outgoing REST](services-outgoing-rest.md)
- [Auth OAuth 2.0 Apps Tokens](auth-oauth20-apps-tokens.md)
