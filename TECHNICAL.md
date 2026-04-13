# Documentation technique — OnlyVent Mobile

---

## Architecture générale

L'application suit une architecture en couches :

```
Présentation  ──  pages/
                  components/
                      │
État global   ──  providers/   (ChangeNotifier + Provider)
                      │
Logique       ──  services/    (REST, Socket, Storage)
                      │
Données       ──  models/      (User, Message, Conversation)
```

Chaque couche ne connaît que la couche immédiatement en dessous. Les pages lisent les providers via `context.watch` / `context.read` ; les providers appellent les services ; les services ne dépendent pas des providers.

---

## Structure des fichiers

```
lib/
├── main.dart                        # Entrée, MultiProvider, routing, _Root
├── theme/
│   └── app_theme.dart               # AppColors, AppTheme.dark
├── utils/
│   ├── api.dart                     # URL de base selon la plateforme
│   ├── validators.dart              # Validateurs de formulaires
│   └── time_format.dart             # Formatage des dates
├── models/
│   ├── user.dart                    # User + fromJson/toJson
│   ├── message.dart                 # Message + fromJson/toJson
│   └── conversation.dart            # Conversation + isUnread()
├── services/
│   ├── auth_service.dart            # login(), signup()
│   ├── storage_service.dart         # flutter_secure_storage (mobile) / SharedPreferences (web)
│   ├── socket_service.dart          # Socket.io (connexion + événements)
│   ├── message_service.dart         # REST conversations + historique
│   ├── user_service.dart            # REST profil + recherche + abonnements + upload
│   ├── call_service.dart            # REST création de room Jitsi
│   └── post_service.dart            # REST posts par créateur + feed agrégé
├── providers/
│   ├── auth_provider.dart           # État auth (user, token, status)
│   └── chat_provider.dart           # État chat (conversations, messages, appels)
├── components/
│   ├── components.dart              # Barrel export
│   ├── cyber_avatar.dart
│   ├── cyber_badge.dart
│   ├── cyber_button.dart
│   ├── cyber_card.dart
│   ├── cyber_conversation_tile.dart
│   ├── cyber_divider.dart
│   ├── cyber_incoming_call.dart
│   ├── cyber_loader.dart
│   ├── cyber_message_bubble.dart
│   ├── cyber_message_input.dart
│   ├── cyber_post_card.dart
│   └── cyber_text_field.dart
└── pages/
    ├── home.dart                    # Splash / redirection
    ├── login.dart
    ├── signup.dart
    ├── nav_shell.dart               # Navbar 3 onglets + bannière appel entrant
    ├── conversations.dart
    ├── chat.dart
    ├── feed.dart                    # Fil d'actualité (posts abonnements)
    ├── profile.dart
    └── search_users.dart            # Abonnements + recherche utilisateurs
```

---

## Gestion d'état

### AuthProvider

```
AuthStatus { unknown → authenticated | unauthenticated }
```

- `init()` : appelé au démarrage, lit le token en storage sécurisé et restaure la session
- `login()` / `signup()` : appelle `AuthService`, sauvegarde en storage
- `logout()` : vide le storage, change le statut
- `refreshUser(User)` : mise à jour du profil sans déconnexion

### ChatProvider

- `loadConversations()` : charge la liste via REST
- `loadHistory(userId)` : charge l'historique d'une conversation
- `sendMessage(...)` : émet via Socket.io
- `markAsRead(userId)` : PATCH REST + mise à jour locale
- `totalUnread` : getter calculé depuis toutes les conversations
- `onScrollNeeded` : `Stream<String>` émis à chaque nouveau message pour que `ChatPage` défile vers le bas
- `incomingCall` : objet `IncomingCall?` — non-null quand un appel arrive, déclenche la bannière

---

## Services

### api.dart — URL de base

```dart
abstract final class Api {
  static String get baseUrl {
    if (kIsWeb)           return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';          // iOS simulateur
  }
}
```

### socket_service.dart

Connexion sur le namespace `/chat` avec transport `polling` (plus fiable que websocket sur certains réseaux).

```
Client → serveur :
  send_message   { receiverId, content, type?, fileName? }
  call_request   { targetUserId, roomUrl }
  accept_call    { fromUserId }
  reject_call    { fromUserId }

Serveur → client :
  connected      { userId }
  new_message    Message
  message_sent   Message
  incoming_call  { fromUserId, callerUsername, roomUrl }
  call_accepted  { fromUserId }
  call_rejected  { fromUserId }
```

### user_service.dart — Upload

`uploadAvatar(token, bytes, filename)` envoie une requête `multipart/form-data` à `POST /api/upload`. Le type MIME est dérivé de l'extension du fichier (`.jpg` → `image/jpeg`, etc.) pour satisfaire le filtre côté backend qui vérifie `mimetype.startsWith('image/')`.

---

## Modèles de données

### User

| Champ | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID |
| `email` | `String` | Adresse email |
| `username` | `String` | Nom d'utilisateur |
| `avatar` | `String?` | Chemin relatif — ex : `/uploads/abc.png` |
| `bio` | `String?` | Biographie |
| `creatorId` | `String?` | Si l'utilisateur est créateur |
| `allowVideoCall` | `bool` | Appels vidéo activés |

URL complète avatar : `${Api.baseUrl}${user.avatar}`

### Message

| Champ | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID |
| `senderId` | `String` | UUID expéditeur |
| `receiverId` | `String` | UUID destinataire |
| `content` | `String?` | Texte ou URL du fichier uploadé |
| `type` | `String` | `'text'` ou `'file'` |
| `fileName` | `String?` | Nom original du fichier (affichage) |
| `isRead` | `bool` | Lu par le destinataire |
| `createdAt` | `DateTime` | Date d'envoi |

Pour les messages de type `file`, `content` contient l'URL relative (`/uploads/uuid.png`) et `fileName` contient le nom original à afficher.

### Conversation

Calculée depuis la liste des messages — contient `userId`, `username`, `avatar`, `lastMessage`, et expose `isUnread(myUserId)`.

### Post

| Champ | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID |
| `title` | `String` | Titre du post |
| `creatorId` | `String` | ID entité Creator (pour les appels API posts) |
| `creatorUsername` | `String` | Nom d'utilisateur |
| `creatorAvatar` | `String?` | Avatar du créateur |
| `description` | `String?` | Contenu textuel (null si verrouillé) |
| `image` | `String?` | URL de l'image (null si verrouillé) |
| `isLocked` | `bool` | Post réservé aux abonnés payants |
| `likes` | `int` | Nombre de likes |
| `createdAt` | `DateTime` | Date de publication |

`isAccessible` → `!isLocked || (image != null && description != null)` — un post verrouillé sans contenu n'est pas affiché.

### Feed

Le feed est construit côté client en deux étapes :
1. `UserService.getRawSubscriptions(token)` → `List<String>` d'IDs Creator entity (pas de User ID)
2. `PostService.getFeed(token, creatorIds)` → requêtes parallèles `GET /api/posts?creatorId=xxx`, résultats fusionnés et triés par date DESC

---

## Composants réutilisables

| Composant | Props clés | Usage |
|-----------|-----------|-------|
| `CyberTextField` | `label`, `controller`, `validator`, `prefixIcon`, `maxLines` | Champs de formulaire |
| `CyberButton` | `label`, `icon`, `onPressed`, `loading`, `expand` | Bouton primaire avec état loading |
| `CyberButton.secondary` | idem | Bouton secondaire (contour) |
| `CyberAvatar` | `username`, `avatarPath`, `radius`, `showGlow` | Avatar avec initiales en fallback |
| `CyberBadge` | `count`, `child` | Badge compteur rouge sur un widget |
| `CyberCard` | `child`, `padding` | Carte avec effet glow neon |
| `CyberLoader` | `size` | Indicateur de chargement |
| `CyberDivider` | — | Séparateur neon |
| `CyberMessageBubble` | `message`, `isMine` | Bulle de message (texte ou image) |
| `CyberMessageInput` | `onSend`, `onAttach` | Barre de saisie avec bouton pièce jointe |
| `CyberConversationTile` | `conversation`, `myUserId`, `onTap` | Ligne de liste de conversations |
| `CyberIncomingCall` | `callerUsername`, `onAccept`, `onReject` | Bannière appel entrant |

---

## Routing

Défini dans `main.dart`. La page racine `_Root` choisit automatiquement la destination selon `AuthStatus` :

```
AuthStatus.unknown       → CircularProgressIndicator
AuthStatus.authenticated → NavShell (navbar 3 onglets)
AuthStatus.unauthenticated → HomePage
```

`NavShell` utilise un `IndexedStack` pour maintenir les 3 pages en vie simultanément (pas de rechargement au changement d'onglet) :

```
NavShell
  ├── index 0 → ConversationsPage → ChatPage
  ├── index 1 → FeedPage
  └── index 2 → ProfilePage
```

La bannière d'appel entrant (`CyberIncomingCall`) est superposée au-dessus du `NavShell` entier via un `Stack`, pour rester visible quel que soit l'onglet actif.

Après login/signup, `Navigator.popUntil(route.isFirst)` vide la pile pour laisser `_Root` se reconstruire.

Routes nommées disponibles : `/login`, `/signup`, `/home`, `/search`.

---

## Appels vidéo

1. L'appelant appuie sur l'icône caméra dans le chat
2. `CallService.createRoom(token)` fait un `POST /api/video/room` → reçoit une URL Jitsi
3. `ChatProvider.sendCallRequest(targetUserId, roomUrl)` émet `call_request` via socket
4. Le destinataire reçoit `incoming_call` → `ChatProvider.incomingCall` devient non-null → la bannière `CyberIncomingCall` s'affiche par-dessus `ConversationsPage`
5. Acceptation : émet `accept_call`, ouvre l'URL Jitsi avec `url_launcher` en application externe
6. Rejet : émet `reject_call`, la bannière disparaît

---

## Composants supplémentaires

| Composant | Props clés | Usage |
|-----------|-----------|-------|
| `CyberPostCard` | `post` | Carte post avec avatar créateur, image, titre, description (3 lignes), likes |

---

## Sécurité

- **Mobile** : JWT stocké dans `flutter_secure_storage` (Keychain iOS / Keystore Android)
- **Web** : JWT stocké dans `SharedPreferences` (localStorage) — `flutter_secure_storage` utilise la Web Crypto API qui est instable selon les navigateurs
- La branche est contrôlée via `kIsWeb` dans `StorageService`
- Tous les appels REST et la connexion Socket.io transmettent le token dans le header `Authorization: Bearer <token>`
- L'upload n'accepte que les images (filtre côté backend sur le MIME type et l'extension)
- Taille maximale d'upload : 5 MB

---

## Connexion backend (CORS)

Le backend NestJS autorise les origines `localhost` sur n'importe quel port via une regex :

```ts
/^http:\/\/localhost:\d+$/
```

Configuré dans `main.ts` (REST) et `chat.gateway.ts` (Socket.io).
