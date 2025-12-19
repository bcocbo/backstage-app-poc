FROM nginxdemos/hello:latest

# Metadata
LABEL maintainer="platform@example.com"
LABEL app="demo-app"
LABEL environment="dev"

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
