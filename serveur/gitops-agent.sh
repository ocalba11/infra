#!/bin/sh
# Agent GitOps : synchronise le serveur avec la branche main du dépôt

REMOTE="${GIT_REPO:?Variable GIT_REPO manquante}"
WORK=/srv/checkout
BRANCH=main
INTERVAL=30

# 1. Récupération initiale du dépôt
until git clone -q -b "$BRANCH" "$REMOTE" "$WORK" 2>/dev/null; do
  echo "[gitops] clone impossible ($REMOTE), nouvel essai dans 5s"
  sleep 5
done

while true; do
  cd "$WORK"

  # 2. Y a-t-il un nouveau commit sur main ?
  git fetch -q origin
  if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/$BRANCH)" ]; then
    git reset -q --hard "origin/$BRANCH"
    echo "[gitops] $(date +%T) déploiement : $(git log -1 --format='%h %s (%an)')"
  fi

  # 3. Application de la configuration (à chaque tour)
  cp /etc/nginx/conf.d/default.conf /tmp/default.conf.bak
  cp nginx/site.conf /etc/nginx/conf.d/default.conf
  cp -r www/. /usr/share/nginx/html/

  # 4. Vérification avant rechargement
  if nginx -t 2>/dev/null; then
    nginx -s reload 2>/dev/null
  else
    cp /tmp/default.conf.bak /etc/nginx/conf.d/default.conf
    echo "[gitops] $(date +%T) config invalide sur main, ancienne config conservée"
  fi

  sleep "$INTERVAL"
done