# 🍽️ Le Baratie (SAE Mobile)

**BUT Informatique – SAE Mobile 2025**

---

## 👥 Membres du groupe

- **Lucas THOMAS**
- **Ugo DOMINGUEZ**
- **Antony PERDIEUS**
- **Yasin KESKIN**

---

## 🧰 Fonctionnalités

### ✅ Restaurants
- Recherche par nom, ville et type
- Affichage dynamique des restaurants (cards responsives)
- Détail complet : horaires, site, téléphone, accessibilité, livraison, note moyenne

### ✅ Authentification
- Création de compte
- Connexion
- Connexion automatique après inscription
- Gestion de session via `Provider`

### ✅ Avis
- Laisser un avis (note de 0 à 5 + commentaire si connecté)
- Voir les avis laissés sur un restaurant
- Voir tous les avis d’un utilisateur

### ✅ Favoris
- Ajout / Retrait de restaurants en favoris (si connecté)
- Section dédiée dans le profil pour les restaurants favoris

### ✅ Profil
- Accès à son propre profil
- Visualisation de tous ses avis et favoris
- Accès au profil d'autres utilisateurs via un avis

---

## 🛠️ Dépendances
- provider – gestion de l’état global
- go_router – navigation dans l’application
- sqflite – base de données embarquée
- url_launcher – ouverture de lien/téléphone
- shared_preferences – stockage des données locales

---

## ⚙️ Lancer l'application

### 📥 Installation des dépendances

Avant de lancer le projet, installez les dépendances avec :

```bash
flutter pub get
```

### 🚀 Lancement de l'application
```bash
flutter run -d chrome
```
