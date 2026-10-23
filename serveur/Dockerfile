FROM nginx:alpine

RUN apk add --no-cache git \
 && git config --system --add safe.directory '*'

COPY gitops-agent.sh /usr/local/bin/gitops-agent.sh

# Supprime les fins de ligne Windows, rend l'agent exécutable
# et le lance au démarrage du conteneur, avant nginx
RUN sed -i 's/\r$//' /usr/local/bin/gitops-agent.sh \
 && chmod +x /usr/local/bin/gitops-agent.sh \
 && printf '#!/bin/sh\n/usr/local/bin/gitops-agent.sh &\n' > /docker-entrypoint.d/99-gitops.sh \
 && chmod +x /docker-entrypoint.d/99-gitops.sh