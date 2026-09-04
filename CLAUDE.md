# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Content-only Markdown documentation for **Devana.ai** (enterprise AI platform) and **Odin** (its document-processing service). Published at `doc.devana.ai`.

There is **no build, lint, or test tooling** — no `package.json`, no static-site generator config. The site image (`devana-docs`) lives outside this repo and consumes these files. So:

- "Testing a change" = reading the Markdown and checking relative links by hand.
- **Merging to `main` publishes.** `.github/workflows/deploy-docs.yml` runs `kubectl rollout restart deployment/devana-docs -n devana-production` on every push to `main`. Work on a branch (`docs/<topic>`) and open a PR.

## Layout

| Path | Contents |
|---|---|
| `api/` | REST API reference — `endpoints/`, `integration/` (iframe, custom tools), `authentication/oauth.md`, `reference/` |
| `deployment/` | Self-hosted / on-prem: `requirements.md`, `architecture.md`, `infrastructure/` (k8s manifests, PostgreSQL + HA/OpenShift, Azure), `authentication/sso/`, `configuration/`, `monitoring/`, `troubleshooting/` |
| `changelogs/` | `devana/` (platform) and `odin/` (doc engine), each with an index `README.md` |
| `sdks/` | `devana-ws-tools`, `n8n-nodes-devana`, `frontend-streaming` |
| `others/` | RGPD / subprocessor legal docs |

Several directories are genuinely doubled on disk — `infrastructure/kubernetes/kube/`, `infrastructure/database/db/`, `infrastructure/azure/azure/`, `services/services/`. These are real paths, not typos.

## Language

Mixed, per file. `api/`, `deployment/`, `changelogs/` and `others/` are **French**; root `README.md` and `sdks/` are **English**. Match the language already in the file you are editing; do not translate existing pages.

Section headings use emoji prefixes throughout (`## 🚀 Nouvelles fonctionnalités`, `## 🐛 Corrections de bugs`, `## 📑 Table des matières`). Keep the style of the surrounding file.

## Adding a changelog

Two independent product lines with **different file-naming conventions**:

- Devana: `changelogs/devana/v1/v1.3.0.md` — `v`-prefixed. Older releases in `archive/v0.6/` and `archive/pre-v0.6/`.
- Odin: `changelogs/odin/v2/2.0.26.md` — **no `v` prefix**. Odin v1 files in `changelogs/odin/v1/` *are* `v`-prefixed (`v0.1.25.md`).

For each new release, touch three places:

1. the version file itself;
2. the product index `changelogs/<product>/README.md` (add the entry, move the "Dernière version" marker);
3. root `README.md` — the version badge (line 5) and the changelog bullets (~line 151).

### Template — identique pour Devana et Odin

Référence canonique : `changelogs/devana/v1/v1.2.13.md`. Les fiches Odin existantes (`## Version <x>` + emoji par puce) sont un **format legacy** : toute nouvelle fiche, Devana comme Odin, suit le template ci-dessous.

```markdown
# Version <précédente> → <nouvelle>

---

## ✨ Nouvelles fonctionnalités & améliorations

- **Intitulé court** : ce que ça apporte, en une phrase.

- **Intitulé court** :
  - sous-point
  - sous-point

---

## 🛠️ Corrections de bugs / sécurité

- **Fix — Domaine concerné** : le symptôme tel que l'utilisateur le vivait, puis ce qui a changé.

- **Sécurité** : ce qui est corrigé, sans détail exploitable.

---

## 🔧 Maintenance

- Point court, sans détail d'implémentation.
```

Règles de forme :

- **En français**, ton neutre et factuel.
- Titre = transition de version (`# Version 1.2.12 → 1.2.13`), pas la version seule.
- Les trois sections dans cet ordre, séparées par `---`. Une section vide est **omise**, sauf « Nouvelles fonctionnalités » sur un cycle sans nouveauté : écrire alors `- Aucune nouvelle fonctionnalité majeure sur ce cycle — release principalement axée corrections et maintenance.`
- Un point = un changement perceptible par le client. Plusieurs commits sur le même sujet se regroupent en un point avec sous-points, et plusieurs patchs successifs sur un même sujet peuvent tenir dans une seule ligne.
- Pas d'emoji dans les puces (uniquement dans les titres de section).

### Ce qu'on n'écrit jamais dans un changelog

Ce dépôt est **public**. Le changelog décrit **ce que le client constate**, jamais comment c'est fait. Sont exclus, sans exception :

- **Code** : extraits, signatures, noms de fonctions, classes, modules, fichiers, chemins.
- **Composants d'infrastructure** : orchestrateur, conteneurs, pods, hôtes, routes internes
- **CI/CD et chaîne de build** : workflows, pipelines, images, registries, scanners, secrets, étapes de déploiement. Si le cycle n'a contenu que ça, écrire au plus `- Mise à jour de la chaîne de build — sans impact fonctionnel.`

- **Dépendances** : numéros de version, noms de bibliothèques — sauf celles que le client manipule directement (SDK public, connecteur API, modèle de LLM).
- **Sécurité** : jamais de vecteur d'attaque, de composant affecté, de version vulnérable ni de mécanisme d'authentification. On annonce le résultat : `- **Sécurité** : remédiation de 13 CVE runtime signalées par notre veille de dépendances.`
- **Dimensionnement** : CPU, RAM, nœuds, réplicas. Les gains de performance s'expriment en relatif (« ×3 », « ~10× plus rapide »), jamais avec les ressources allouées.
- **Interne** : messages de log, formats de trace, endpoints d'administration, outillage de test, documentation interne.

En cas de doute : *est-ce qu'un concurrent ou un attaquant apprend quelque chose sur notre stack en lisant cette ligne ?* Si oui, reformuler côté usage, ou supprimer.

### Traduire un changement en ligne de changelog

| Source (release note / commit) | À ne pas écrire | À écrire |
|---|---|---|
| `fix(db) schema pas pris en compte` | « Correction de la prise en compte du schéma PostgreSQL » | *rien* — invisible pour le client, relève de la maintenance |
| `handle sslmode=prefer with PrismaPg adapter` | « Support de `sslmode=prefer` avec l'adaptateur PrismaPg » | « Fiabilisation de la connexion aux instances déployées en environnement client » |
| `feat(redis): support REDIS_USERNAME` | « Support de `REDIS_USERNAME` (auth ACL) » | « Compatibilité avec les infrastructures clientes exigeant une authentification par utilisateur nommé » |
| `Support OTEL` | --| « Supervision :, les métriques et traces d'exécution peuvent être remontées vers OpenTelemetry» |
| `remove prisma generate at runtime` | « Suppression du `prisma generate` au runtime » | « Démarrage du service plus rapide » |
| `fix: files stuck in Extraction on mass import` | — | « **Fix — Ingestion documentaire** : un fichier ne peut plus rester bloqué indéfiniment à l'état « Extraction » lors d'un import de masse. » |

Un changement sans effet observable par le client n'a pas de ligne. Mieux vaut une section « Maintenance » de deux lignes qu'un inventaire technique.

### Procédure

1. Lire les release notes publiées (`gh release list` / `gh release view` sur le dépôt produit). C'est la source.
2. Si une release note est vide, reconstituer depuis les commits (`gh api repos/<org>/<repo>/compare/<tagA>...<tagB>`) — puis appliquer le filtre ci-dessus, qui élimine généralement la majeure partie.
3. Rédiger la fiche, mettre à jour les trois emplacements.
4. Une branche `docs/changelog-<sujet>`, un commit, une PR vers `main`.

`changelogs/odin/v2/2.0.21.md` is a known anomaly — it holds v1→v2 refactor notes rather than that release's content.

## Relative links — do not mass-"fix"

65 of ~302 relative links do not resolve on the filesystem. This is not accidental drift; the doc renderer resolves paths differently from GitHub. Established patterns:

- `changelogs/*/README.md` prefixes sibling files with `../../../` (`../../../v2/2.0.26.md` for `changelogs/odin/v2/2.0.26.md`) — applied deliberately across several commits.
- `deployment/authentication/README.md` links `./azure.md` for `./sso/azure.md`; `changelogs/odin/README.md` links `../../deployment/services/odin.md` for `deployment/services/services/odin.md` — i.e. one directory level is elided.

Follow the convention of the file you are editing rather than making links filesystem-correct. If you believe a link is genuinely wrong, verify against the live site before changing it.

## Commits

`docs: <description in the file's language>` (French for changelog/api/deployment work). Branch names: `docs/<topic>` (e.g. `docs/changelog-odin-v2`). PRs target `main`.
