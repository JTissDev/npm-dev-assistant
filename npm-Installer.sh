# ==============================================================================
# Block   : NPM Tools
# Desc    : Gestionnaire de packages NPM et automatisation Webpack
# Author  : J.Tiss <jtissdev@gmail.com>
# ==============================================================================

# ------------------------------------------------------------------------------
# Block   : NPM Tools
# Desc    : Assistant interactif d'installation de packages NPM avec support Webpack
# Usage   : npm-add
# Author  : J.Tiss <jtissdev@gmail.com>
# ------------------------------------------------------------------------------
function npm-add() {
    if [[ ! -f "package.json" ]]; then
        echo -e "\e[31mErreur : Aucun fichier package.json trouvé ici.\e[0m"
        return 1
    fi

    local list_file="$DEV_TOOLS_HOME/utils/npm-packages.txt"
    
    if [[ ! -f "$list_file" ]]; then
        echo -e "Aucun package enregistré. Utilisez d'abord la commande \e[33mnpm-menu-add\e[0m."
        return 1
    fi

    local to_install=""
    local -A webpack_rules # Tableau associatif pour stocker les règles à injecter après coup
    
    echo -e "\n📦 === Assistant d'installation NPM ===\n"

    while IFS="|" read -u 3 -r name cmd shortcut wp_rule; do
        [[ -z "$name" ]] && continue
        
        local main_pkg=$(echo "$cmd" | awk '{print $1}')
        
        if grep -q "\"$main_pkg\"" package.json; then
            echo -e "✅ \e[32m$name\e[0m est déjà installé. (Ignoré)"
            continue
        fi
        
        read -p "👉 Installer $name (commande: $cmd) ? (o/N) " resp
        if [[ "${resp,,}" == "o" ]]; then
            to_install="$to_install $cmd"
            # Si une règle Webpack est associée et n'est pas "none", on la met de côté
            if [[ -n "$wp_rule" && "$wp_rule" != "none" ]]; then
                webpack_rules["$name"]="$wp_rule"
            fi
        fi
    done 3< "$list_file"

    if [[ -n "$to_install" ]]; then
        echo -e "\n🚀 Installation de : $to_install\n"
        npm install $to_install
        
       # Une fois les paquets installés, on traite les configurations Webpack si besoin
        if [ ${#webpack_rules[@]} -gt 0 ]; then
            echo -e "\n⚙️ Configuration de Webpack pour les nouveaux modules..."
            for pkg_name in "${!webpack_rules[@]}"; do
                # On s'assure de ne pas appeler webpack-add pour "none"
                if [[ "${webpack_rules[$pkg_name]}" != "none" ]]; then
                    webpack-add "${webpack_rules[$pkg_name]}"
                fi
            done
        fi
    else
        echo -e "\nAucune nouvelle installation demandée."
    fi
}

# ------------------------------------------------------------------------------
# Block   : NPM Tools
# Desc    : Ajoute un nouveau package, sa commande et sa règle Webpack dans npm-packages.txt
# Usage   : npm-menu-add
# Author  : J.Tiss <jtissdev@gmail.com>
# ------------------------------------------------------------------------------
function npm-menu-add() {
    local list_file="$DEV_TOOLS_HOME/utils/npm-packages.txt"

    echo -e "\n➕ === Ajouter un package au menu NPM ==="
    
    read -p "1. Nom d'affichage (ex: Sass) : " name
    read -p "2. Commande complète (ex: sass-loader sass) : " cmd
    read -p "3. Raccourci (ex: sass) : " shortcut
    read -p "4. Règle Webpack (ex: test: /\.scss$/, use: ... ou 'none') : " wp_rule

    [[ -z "$wp_rule" ]] && wp_rule="none"

    if [[ -n "$name" && -n "$cmd" ]]; then
        mkdir -p "$(dirname "$list_file")"

        # Gestion propre du saut de ligne final
        if [[ -f "$list_file" && -s "$list_file" ]]; then
            if [[ -n "$(tail -c 1 "$list_file")" ]]; then
                echo "" >> "$list_file"
            fi
        fi

        echo "$name|$cmd|$shortcut|$wp_rule" >> "$list_file"
        echo -e "\e[32m✅ Package '$name' ajouté avec succès au menu !\e[0m\n"
    else
        echo -e "\e[31mErreur : Le nom et la commande sont obligatoires.\e[0m\n"
    fi
}

# ------------------------------------------------------------------------------
# Block   : NPM Tools
# Desc    : Crée un webpack.config.js si besoin et y injecte la règle du loader
# Usage   : webpack-add "<rule_content>"
# Options : $1 = Snippet de la règle Webpack
# Author  : J.Tiss <jtissdev@gmail.com>
# ------------------------------------------------------------------------------
function webpack-add() {
    local rule_content="$1"
    local config_file="webpack.config.js"

    if [[ -z "$rule_content" || "$rule_content" == "none" ]]; then
        return 0
    fi

    # Si le fichier de config n'existe pas, on le génère automatiquement avec une structure de base
    if [[ ! -f "$config_file" ]]; then
        echo "ℹ️  Aucun 'webpack.config.js' détecté. Création d'un fichier de base..."
        cat << 'EOF' > "$config_file"
const path = require('path');

module.exports = {
    entry: './src/index.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist'),
    },
    module: {
        rules: [
        ]
    }
};
EOF
        echo "✨ Fichier webpack.config.js de base généré avec succès !"
    fi

    # Vérifie si la règle est déjà présente pour éviter les doublons
    if grep -qF "$rule_content" "$config_file"; then
        echo "ℹ️  La règle Webpack est déjà présente dans $config_file."
        return 0
    fi

    # Injection propre dans le tableau 'rules: [' de Webpack
    if grep -q "rules:" "$config_file"; then
        local formatted_rule="            { $rule_content },"
        sed -i "/rules:[[:space:]]*\[/a \          $formatted_rule" "$config_file"
        echo "✨ Règle Webpack injectée avec succès dans $config_file !"
    else
        echo "⚠️  Impossible de trouver le bloc 'rules: [' dans $config_file."
        echo "💡 Veuillez l'ajouter manuellement : { $rule_content }"
    fi
}