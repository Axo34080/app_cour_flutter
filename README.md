# OnlyVent — Application Mobile

Extension mobile de la plateforme **OnlyVentilateur**, permettant aux utilisateurs de communiquer en temps réel depuis leur smartphone avec les utilisateurs connectés sur le site web.

---

## Prérequis

| Outil | Version minimum |
|-------|----------------|
| Flutter SDK | 3.11+ |
| Dart | 3.0+ |
| Android Studio / Xcode | Pour lancer un émulateur |
| Backend OnlyVentilateur | En cours d'exécution sur le port `3000` |

---

## Installation et lancement

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Lancer sur émulateur Android
flutter run

# 3. Lancer sur le web (développement)
flutter run -d chrome
```

> **Android** : l'émulateur accède au backend via `10.0.2.2:3000` (alias de `localhost`).  
> **Web** : le backend doit tourner sur `localhost:3000` avec CORS configuré.

---

## Fonctionnalités

### Authentification
- **Inscription** : email, nom d'utilisateur, mot de passe (min. 6 caractères)
- **Connexion** : email + mot de passe
- **Session persistante** : le token JWT (valide 7 jours) est sauvegardé de façon sécurisée — pas besoin de se reconnecter à chaque lancement
- **Déconnexion** : via la page Profil

### Messagerie en temps réel
- Liste de toutes les conversations avec aperçu du dernier message
- Badge indiquant le nombre de messages non lus
- Chat en temps réel via Socket.io
- Envoi de messages texte
- Envoi d'images (galerie) directement dans la conversation
- Affichage des images reçues dans les bulles de message
- Marquage automatique comme lu à l'ouverture d'une conversation
- Défilement automatique vers le dernier message

### Contacts
- Liste des abonnements (créateurs suivis) accessible depuis le bouton de nouvelle conversation
- Recherche d'utilisateurs par nom d'utilisateur (min. 2 caractères) pour contacter quelqu'un que l'on ne suit pas

### Profil
- Modification du nom d'utilisateur et de la bio
- Changement de photo de profil (galerie)

### Appels vidéo
- Démarrage d'un appel vidéo Jitsi Meet depuis le chat
- Notification d'appel entrant avec bannière en superposition
- Acceptation ou rejet de l'appel

---

## Navigation

```
Lancement
   │
   ├── Pas de session → Page d'accueil → Connexion / Inscription
   │
   └── Session active → Liste des conversations
                              │
                              ├── Tap sur une conversation → Chat
                              ├── Bouton ✏️ → Abonnements / Recherche
                              └── Bouton 👤 → Profil
```

---

## Stack technique

| Package | Rôle |
|---------|------|
| `provider` | Gestion d'état (AuthProvider, ChatProvider) |
| `socket_io_client` | Connexion temps réel avec le backend |
| `flutter_secure_storage` | Stockage sécurisé du JWT |
| `http` | Appels REST |
| `image_picker` | Sélection d'images dans la galerie |
| `url_launcher` | Ouverture des appels Jitsi dans le navigateur |
| `google_fonts` | Typographie Space Grotesk |

---

## Design

Thème **dark cyberpunk** cohérent sur toute l'application.

| Rôle | Couleur |
|------|---------|
| Fond | `#0A0A0F` |
| Surface (cartes) | `#12121A` |
| Neon primaire (cyan) | `#00E5FF` |
| Neon secondaire (rose) | `#FF006E` |
| Texte principal | `#E0E0FF` |
| Police | Space Grotesk |

---

## Connexion avec le backend

L'application partage le backend NestJS de la version web. Aucune modification du backend n'est nécessaire côté fonctionnel — la même API REST et les mêmes événements Socket.io sont réutilisés.

```
App Web  ──┐
           ├──▶  NestJS API (port 3000)
App Mobile ─┘
```
