# Image de contenu de doc.devana.ai : la doc seule, sous /documentation, plus le
# `cp` de busybox. En production, un initContainer du Deployment devana-docs
# (infra-k8s, cluster devana-v2) la copie dans le volume que sert le site ;
# Flux suit les tags de cette image. Voir .github/workflows/deploy-docs.yml.
FROM busybox:1.37.0@sha256:a7dbc319b1438115a207e11930dc4bb3e643dcb3ec0bdd694bb36cd8fad289ec

COPY . /documentation

USER 1001:1001
