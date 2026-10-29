# 📦 npm-dev-assistant

Sous-module Git dédié à l'automatisation et à la gestion simplifiée de l'installation et des dépendances NPM au sein de l'écosystème `dev-tools`.

## 📌 Présentation

`npm-dev-assistant` fournit un script Bash interactif (`npm-Installer.sh`) permettant d'installer, vérifier ou mettre à jour les packages NPM nécessaires à tes projets et outils CLI sans manipuler manuellement des commandes complexes.

## 📁 Structure du dépôt

```text
npm-dev-assistant/
├── npm-Installer.sh     # Script principal d'installation et de gestion NPM
└── README.md            # Documentation du sous-module
```

## ⚙️ Intégration dans l'environnement dev-tools

Ce sous-module est hébergé dans le dépôt central `~/dev-tools/npm-dev-assistant`.

### 1. Chargement dans `.bash_functions`

Le script est sourcé automatiquement au démarrage de Git Bash via ton fichier `~/.bash_functions` :

```bash
# Chargement du sous-module NPM
NPM_HOME="$DEV_TOOLS_HOME/npm-dev-assistant"
[ -f "$NPM_HOME/npm-Installer.sh" ] && source "$NPM_HOME/npm-Installer.sh"
```

### 2. Navigation rapide via `.bash_aliases`

Pour accéder directement au dossier du sous-module :

```bash
alias npm-assist-dir='cd ~/dev-tools/npm-dev-assistant'
```

## 🚀 Utilisation

Une fois chargé dans ton terminal Git Bash, tu peux exécuter le script directement ou appeler les fonctions exposées pour gérer tes modules Node/NPM.

```bash
# Exécution directe du script d'installation
bash ~/dev-tools/npm-dev-assistant/npm-Installer.sh
```

## 🛠️ Maintenance & Développement

Ce dossier est un **sous-module Git indépendant**. Pour valider et pousser des modifications spécifiques à cet outil :

```bash
cd ~/dev-tools/npm-dev-assistant
git add .
git commit -m "feat: amélioration de l'assistant d'installation NPM"
git push origin main
```

---
*Projet autonome faisant partie de la suite d'outils **JtissDev / dev-tools**.*