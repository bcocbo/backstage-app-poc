# Requirements Document

## Introduction

Este documento define los requisitos para implementar un flujo completo de creación y despliegue de componentes en Backstage, integrando Software Templates, GitOps con ArgoCD, CI/CD automatizado, y un chart transversal de Helm. El objetivo es proporcionar un proceso estandarizado y automatizado que permita a los desarrolladores crear y desplegar servicios de manera self-service, siguiendo las mejores prácticas de GitOps.

## Glossary

- **Backstage**: Plataforma de portal de desarrolladores que centraliza herramientas, servicios y documentación
- **Software Template**: Plantilla predefinida en Backstage para crear nuevos componentes de manera estandarizada
- **Scaffolding**: Proceso automatizado de generación de código y configuración a partir de una plantilla
- **GitOps**: Metodología que utiliza Git como fuente única de verdad para la configuración de infraestructura
- **ArgoCD**: Herramienta de entrega continua declarativa para Kubernetes que implementa GitOps
- **Chart Transversal**: Chart de Helm centralizado y reutilizable que define la estructura base de despliegue
- **Values File**: Archivo YAML que contiene valores específicos para personalizar un chart de Helm
- **CI Pipeline**: Pipeline de integración continua que construye y publica imágenes Docker
- **Image Tag**: Etiqueta de versión de una imagen Docker
- **App-of-Apps Pattern**: Patrón de ArgoCD donde una aplicación gestiona otras aplicaciones
- **Catalog Info**: Archivo YAML que registra un componente en el catálogo de Backstage

## Requirements

### Requirement 1

**User Story:** Como desarrollador, quiero seleccionar una Software Template en Backstage para crear un nuevo servicio, de manera que pueda iniciar un proyecto estandarizado sin configuración manual.

#### Acceptance Criteria

1. WHEN un desarrollador accede al portal de Backstage THEN el sistema SHALL mostrar una lista de Software Templates disponibles con descripciones claras
2. WHEN un desarrollador selecciona una Software Template THEN el sistema SHALL presentar un formulario con campos configurables para el nuevo servicio
3. WHEN un desarrollador completa el formulario THEN el sistema SHALL validar que todos los campos requeridos estén presentes y sean válidos
4. WHEN el formulario es válido THEN el sistema SHALL habilitar el botón de creación del servicio

### Requirement 2

**User Story:** Como desarrollador, quiero que Backstage cree automáticamente los repositorios necesarios al usar una template, de manera que no tenga que configurar repositorios manualmente.

#### Acceptance Criteria

1. WHEN un desarrollador ejecuta una Software Template THEN el sistema SHALL crear un repositorio de código fuente para la aplicación en GitHub
2. WHEN el repositorio de código es creado THEN el sistema SHALL incluir un archivo catalog-info.yaml con la metadata del componente
3. WHEN el repositorio de código es creado THEN el sistema SHALL incluir archivos de CI/CD iniciales (GitHub Actions workflow)
4. WHEN el repositorio de código es creado THEN el sistema SHALL incluir un README.md con instrucciones básicas
5. WHEN todos los archivos son creados THEN el sistema SHALL hacer commit y push al repositorio remoto

### Requirement 3

**User Story:** Como desarrollador, quiero que la template genere la configuración de despliegue usando un chart transversal, de manera que todos los servicios sigan el mismo estándar de despliegue.

#### Acceptance Criteria

1. WHEN la template genera configuración de despliegue THEN el sistema SHALL crear un archivo values.yaml específico para la aplicación
2. WHEN el values.yaml es creado THEN el sistema SHALL hacer referencia al chart transversal centralizado
3. WHEN el values.yaml es creado THEN el sistema SHALL incluir valores únicos de la aplicación (nombre, namespace, imagen, réplicas)
4. WHEN el values.yaml es creado THEN el sistema SHALL incluir el nombre de la imagen y tag inicial
5. WHEN la configuración es generada THEN el sistema SHALL crear un manifiesto de ArgoCD Application que apunte al chart transversal

### Requirement 4

**User Story:** Como desarrollador, quiero que la configuración de despliegue se almacene en un repositorio GitOps separado, de manera que siga las mejores prácticas de separación de código y configuración.

#### Acceptance Criteria

1. WHEN la template genera configuración de despliegue THEN el sistema SHALL crear o actualizar archivos en un repositorio GitOps dedicado
2. WHEN se actualiza el repositorio GitOps THEN el sistema SHALL crear un Pull Request con los cambios propuestos
3. WHEN se crea el Pull Request THEN el sistema SHALL incluir una descripción detallada de los cambios y la nueva aplicación
4. WHEN el Pull Request es creado THEN el sistema SHALL notificar al desarrollador con el enlace al PR

### Requirement 5

**User Story:** Como desarrollador, quiero que el pipeline de CI se active automáticamente al crear el repositorio, de manera que la primera imagen Docker se construya sin intervención manual.

#### Acceptance Criteria

1. WHEN un repositorio de aplicación es creado THEN el sistema SHALL incluir un workflow de GitHub Actions configurado
2. WHEN el workflow es activado THEN el sistema SHALL compilar el código de la aplicación
3. WHEN la compilación es exitosa THEN el sistema SHALL construir una imagen Docker con el código
4. WHEN la imagen es construida THEN el sistema SHALL etiquetar la imagen con el commit SHA y tag "latest"
5. WHEN la imagen es etiquetada THEN el sistema SHALL publicar la imagen en un registro de contenedores

### Requirement 6

**User Story:** Como desarrollador, quiero que el pipeline de CI actualice automáticamente el tag de la imagen en el repositorio GitOps, de manera que ArgoCD despliegue la versión correcta sin intervención manual.

#### Acceptance Criteria

1. WHEN el pipeline de CI publica una imagen Docker THEN el sistema SHALL actualizar el valor de imageTag en el values.yaml del repositorio GitOps
2. WHEN el values.yaml es actualizado THEN el sistema SHALL hacer commit del cambio con un mensaje descriptivo
3. WHEN el commit es realizado THEN el sistema SHALL hacer push al branch correspondiente del repositorio GitOps
4. WHEN el push es exitoso THEN el sistema SHALL registrar el evento en los logs del pipeline

### Requirement 7

**User Story:** Como desarrollador, quiero que ArgoCD detecte automáticamente los cambios en el repositorio GitOps, de manera que mi aplicación se despliegue sin intervención manual.

#### Acceptance Criteria

1. WHEN ArgoCD monitoriza el repositorio GitOps THEN el sistema SHALL detectar cambios en el values.yaml dentro de 3 minutos
2. WHEN ArgoCD detecta un cambio THEN el sistema SHALL sincronizar el estado deseado con el cluster de Kubernetes
3. WHEN ArgoCD sincroniza THEN el sistema SHALL utilizar el chart transversal con los valores actualizados
4. WHEN los recursos son aplicados THEN el sistema SHALL desplegar o actualizar la aplicación en el namespace especificado
5. WHEN el despliegue es completado THEN el sistema SHALL reportar el estado como "Synced" y "Healthy"

### Requirement 8

**User Story:** Como desarrollador, quiero ver el estado del despliegue de ArgoCD directamente en Backstage, de manera que no tenga que navegar a la interfaz de ArgoCD.

#### Acceptance Criteria

1. WHEN un desarrollador accede a la página de un componente en Backstage THEN el sistema SHALL mostrar una tarjeta con información de ArgoCD
2. WHEN la tarjeta de ArgoCD es mostrada THEN el sistema SHALL incluir el estado de sincronización (Synced, OutOfSync, Unknown)
3. WHEN la tarjeta de ArgoCD es mostrada THEN el sistema SHALL incluir el estado de salud (Healthy, Progressing, Degraded, Missing)
4. WHEN la tarjeta de ArgoCD es mostrada THEN el sistema SHALL incluir un enlace directo a la aplicación en ArgoCD
5. WHEN el estado cambia en ArgoCD THEN el sistema SHALL actualizar la información en Backstage en tiempo real

### Requirement 9

**User Story:** Como desarrollador, quiero que el componente se registre automáticamente en el catálogo de Backstage, de manera que sea visible y gestionable desde el portal.

#### Acceptance Criteria

1. WHEN la template completa la creación del repositorio THEN el sistema SHALL registrar el componente en el catálogo de Backstage
2. WHEN el componente es registrado THEN el sistema SHALL procesar el archivo catalog-info.yaml
3. WHEN el catalog-info.yaml es procesado THEN el sistema SHALL crear una entidad de tipo Component en el catálogo
4. WHEN la entidad es creada THEN el sistema SHALL asociar el componente con su owner (usuario o equipo)
5. WHEN el registro es exitoso THEN el sistema SHALL mostrar el componente en la página de catálogo

### Requirement 10

**User Story:** Como desarrollador, quiero recibir enlaces y próximos pasos al completar la template, de manera que sepa exactamente qué hacer después de la creación.

#### Acceptance Criteria

1. WHEN la template completa exitosamente THEN el sistema SHALL mostrar una página de resumen con enlaces relevantes
2. WHEN la página de resumen es mostrada THEN el sistema SHALL incluir enlace al repositorio de código fuente
3. WHEN la página de resumen es mostrada THEN el sistema SHALL incluir enlace al Pull Request del repositorio GitOps
4. WHEN la página de resumen es mostrada THEN el sistema SHALL incluir enlace al componente en el catálogo
5. WHEN la página de resumen es mostrada THEN el sistema SHALL incluir instrucciones de próximos pasos (aprobar PR, verificar despliegue)

### Requirement 11

**User Story:** Como administrador de plataforma, quiero que el chart transversal sea configurable y versionado, de manera que pueda actualizar la configuración base sin modificar cada aplicación individual.

#### Acceptance Criteria

1. WHEN el chart transversal es actualizado THEN el sistema SHALL mantener versiones del chart en un repositorio de Helm
2. WHEN una aplicación referencia el chart THEN el sistema SHALL especificar la versión del chart a utilizar
3. WHEN se actualiza la versión del chart en un values.yaml THEN el sistema SHALL permitir que ArgoCD aplique la nueva versión
4. WHEN el chart transversal cambia THEN el sistema SHALL documentar los cambios en un CHANGELOG
5. WHEN se publica una nueva versión del chart THEN el sistema SHALL notificar a los equipos sobre la disponibilidad

### Requirement 12

**User Story:** Como desarrollador, quiero que el pipeline de CI incluya validaciones de calidad de código, de manera que solo se desplieguen imágenes que cumplan con los estándares.

#### Acceptance Criteria

1. WHEN el pipeline de CI se ejecuta THEN el sistema SHALL ejecutar linters de código antes de construir la imagen
2. WHEN el pipeline de CI se ejecuta THEN el sistema SHALL ejecutar pruebas unitarias antes de construir la imagen
3. WHEN las validaciones fallan THEN el sistema SHALL detener el pipeline y reportar los errores
4. WHEN las validaciones pasan THEN el sistema SHALL continuar con la construcción de la imagen
5. WHEN la imagen es construida THEN el sistema SHALL escanear la imagen en busca de vulnerabilidades

### Requirement 13

**User Story:** Como administrador de plataforma, quiero que las templates sean configurables por entorno, de manera que pueda desplegar en desarrollo, staging y producción con diferentes configuraciones.

#### Acceptance Criteria

1. WHEN una template es ejecutada THEN el sistema SHALL permitir seleccionar el entorno de despliegue (dev, staging, prod)
2. WHEN un entorno es seleccionado THEN el sistema SHALL aplicar valores específicos del entorno (namespace, recursos, réplicas)
3. WHEN se despliega en producción THEN el sistema SHALL requerir aprobaciones adicionales
4. WHEN se despliega en desarrollo THEN el sistema SHALL permitir despliegue automático sin aprobaciones
5. WHEN se crea configuración por entorno THEN el sistema SHALL organizar los values en directorios separados por entorno
