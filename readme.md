# 🐳 Docker — Commandes essentielles

## 📋 Images

| Commande | Description |
|---|---|
| `docker images -a` | Voir toutes les images |
| `docker build .` | Créer l'image depuis le Dockerfile |
| `docker rmi [image_id]` | Supprimer une image |

## 🚀 Containers

| Commande | Description |
|---|---|
| `docker run [image_id]` | Lancer un container depuis une image |
| `docker ps` | Voir les containers en cours d'exécution |
| `docker ps -a` | Voir tous les containers (stoppés inclus) |
| `docker stop [container_id]` | Arrêter un container |
| `docker rm [container_id]` | Supprimer un container |

---

## 🔁 Workflow rapide

```bash
# 1. Construire l'image
docker build -t mon_image .

# 2. Lancer le container
docker run mon_image

# 3. Voir ce qui tourne
docker ps

# 4. Stopper et nettoyer
docker stop [container_id]
docker rm [container_id]
docker rmi mon_image
```

---

> **Tip :** `docker rm $(docker ps -aq)` supprime tous les containers stoppés d'un coup.

