# Migration base de données – Métriques pour les modèles personnalisés

## Introduction

Suite à la mise à jour de Devana et pour répondre aux besoins de nos clients, nous avons dans les statistiques d'utilisation des informations plus précises sur l'utilisation des modèles personnalisés.

---

### Migration de la DB pour restaurer les données passées

Pour restaurer les données antérieures au niveau de la base de données, veuillez lancer la requête suivante :

```bash
curl -X GET API_URL/migration/metrics/custom-model \
  -H "Authorization: Bearer <API_KEY>"
  -H "Content-Type: application/json"
```  
A noté que seul un super admin ou un admin d'une marque blanche peut lancer cette requête.

Après l'exécution de la requête, vous pourrez voir les nouvelles métriques dans le tableau de bord de Devana.