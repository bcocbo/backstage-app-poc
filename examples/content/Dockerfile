{% if values.applicationType == 'prebuilt' %}
# Usando imagen preconstruida
FROM ${{ values.image }}:${{ values.imageTag }}

# Metadata
LABEL maintainer="platform@example.com"
LABEL app="${{ values.name }}"
LABEL environment="${{ values.environment }}"

# Exponer puerto (ajustar según la imagen)
EXPOSE 80

{% elif values.language == 'nodejs' %}
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependencias
# Usar npm ci si existe package-lock.json, sino npm install
RUN if [ -f package-lock.json ]; then \
      npm ci --only=production; \
    else \
      npm install --only=production; \
    fi

# Copiar código fuente
COPY . .

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copiar node_modules y código desde builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/*.js ./

# Usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Comando de inicio
CMD ["node", "index.js"]

{% elif values.language == 'python' %}
# Build stage
FROM python:3.11-slim AS builder

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.11-slim

WORKDIR /app

# Copiar dependencias desde builder
COPY --from=builder /root/.local /root/.local

# Copiar código fuente
COPY . .

# Usuario no-root
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Agregar .local/bin al PATH
ENV PATH=/root/.local/bin:$PATH

# Exponer puerto
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python healthcheck.py || exit 1

# Comando de inicio
CMD ["python", "app.py"]

{% elif values.language == 'java' %}
# Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar pom.xml
COPY pom.xml .

# Descargar dependencias
RUN mvn dependency:go-offline

# Copiar código fuente
COPY src ./src

# Build
RUN mvn clean package -DskipTests

# Production stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copiar JAR desde builder
COPY --from=builder /app/target/*.jar app.jar

# Usuario no-root
RUN addgroup -g 1001 -S spring && \
    adduser -S spring -u 1001 && \
    chown -R spring:spring /app

USER spring

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Comando de inicio
ENTRYPOINT ["java", "-jar", "app.jar"]

{% elif values.language == 'golang' %}
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar go mod files
COPY go.mod go.sum ./

# Descargar dependencias
RUN go mod download

# Copiar código fuente
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Production stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copiar binario desde builder
COPY --from=builder /app/main .

# Usuario no-root
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001 && \
    chown -R appuser:appuser /root

USER appuser

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Comando de inicio
CMD ["./main"]

{% elif values.language == 'dotnet' %}
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder

WORKDIR /app

# Copiar csproj y restaurar dependencias
COPY *.csproj ./
RUN dotnet restore

# Copiar código fuente y build
COPY . ./
RUN dotnet publish -c Release -o out

# Production stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

# Copiar build desde builder
COPY --from=builder /app/out .

# Usuario no-root
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Exponer puerto
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Comando de inicio
ENTRYPOINT ["dotnet", "${{ values.name }}.dll"]

{% endif %}

# Metadata común
LABEL app.name="${{ values.name }}"
LABEL app.environment="${{ values.environment }}"
LABEL app.type="${{ values.applicationType }}"
{% if values.applicationType == 'custom' %}
LABEL app.language="${{ values.language }}"
{% endif %}
