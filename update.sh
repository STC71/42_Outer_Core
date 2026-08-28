#!/usr/bin/env bash

set -u

if [[ -t 1 ]]; then
    RESET=$'\033[0m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    CYAN=$'\033[36m'
    BLUE=$'\033[34m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    MAGENTA=$'\033[35m'
else
    RESET=''
    BOLD=''
    DIM=''
    CYAN=''
    BLUE=''
    GREEN=''
    YELLOW=''
    RED=''
    MAGENTA=''
fi

print_rule() {
    printf '%s%s────────────────────────────────────────────────────────────%s\n' "$DIM" "$CYAN" "$RESET"
}

print_banner() {
    printf '\n%s%s╔════════════════════════════════════════════════════════════╗%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s║        🚀  ACTUALIZADOR DE REPOSITORIOS 42                 ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╠════════════════════════════════════════════════════════════╣%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s║   Implementación de sternero estudiante de 42 Málaga       ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╚════════════════════════════════════════════════════════════╝%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%sPublica cada submódulo seleccionado y sus repositorios padre.%s\n' "$DIM" "$RESET"
}

usage() {
    printf 'Uso: %s [--dry-run]\n' "$(basename "$0")"
    printf '\n'
    printf 'Actualiza el repositorio Git del directorio actual y sus repositorios padre.\n'
    printf 'Ejecuta el script desde el submodulo mas interno que quieras publicar.\n'
}

fail() {
    printf '\n%s❌ Error:%s %s\n' "$RED" "$RESET" "$1" >&2
    exit 1
}

confirm() {
    local answer

    printf '\n%s%s?%s %s %s[s/N]:%s ' "$YELLOW" "$BOLD" "$RESET" "$1" "$DIM" "$RESET"
    IFS= read -r answer || exit 1
    case "$answer" in
        s|S|si|SI|Si|sI|y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_registered_submodule() {
    local parent_root=$1
    local child_root=$2
    local module_path

    [[ -f "$parent_root/.gitmodules" ]] || return 1
    while IFS=$'\t' read -r module_path; do
        [[ -z "$module_path" ]] && continue
        if [[ "$(realpath -m "$parent_root/$module_path")" == "$child_root" ]]; then
            return 0
        fi
    done < <(git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        --get-regexp '^submodule\..*\.path$' 2>/dev/null \
        | sed 's/^[^[:space:]]*[[:space:]]*//')
    return 1
}

stage_repository() {
    local repo=$1
    local child_path=${2:-}
    local top_level_path
    local module_path
    local registered

    git -C "$repo" add -A || return 1
    [[ -z "$child_path" ]] && return 0

    while IFS= read -r top_level_path; do
        registered=0
        while IFS=$'\t' read -r module_path; do
            [[ -z "$module_path" ]] && continue
            if [[ "${module_path%%/*}" == "$top_level_path" ]]; then
                registered=1
                break
            fi
        done < <(git -C "$repo" config --file "$repo/.gitmodules" \
            --get-regexp '^submodule\..*\.path$' 2>/dev/null \
            | sed 's/^[^[:space:]]*[[:space:]]*//')
        [[ "$top_level_path" == ".git" ]] && continue
        if (( ! registered )); then
            git -C "$repo" reset -q -- "$top_level_path" || return 1
        fi
    done < <(find "$repo" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
}

find_parent_repo() {
    local child_root=$1
    local candidate

    candidate=$(dirname "$child_root")
    while [[ "$candidate" != "/" ]]; do
        if git -C "$candidate" rev-parse --git-dir >/dev/null 2>&1 \
            && is_registered_submodule "$candidate" "$child_root"; then
            printf '%s\n' "$candidate"
            return 0
        fi
        candidate=$(dirname "$candidate")
    done
    return 1
}

is_git_repo() {
    git -C "$1" rev-parse --show-toplevel >/dev/null 2>&1
}

DRY_RUN=0
case "${1:-}" in
    '') ;;
    --dry-run|-n) DRY_RUN=1 ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

START_DIR=$(pwd -P)
is_git_repo "$START_DIR" || fail "el directorio actual no pertenece a un repositorio Git"

current_root=$(git -C "$START_DIR" rev-parse --show-toplevel) || fail "no se pudo determinar la raiz Git"
current_root=$(realpath "$current_root")

find_parent_repo "$current_root" >/dev/null \
    || fail "el repositorio actual no es un submodulo registrado; ejecuta el script desde un submodulo."

repos=()
while :; do
    repos+=("$current_root")
    parent_root=$(find_parent_repo "$current_root" || true)
    [[ -z "$parent_root" ]] && break
    current_root=$parent_root
done

print_banner
print_rule
printf '%s%s📦 Cadena de publicación%s %s(de dentro hacia fuera)%s\n' "$BOLD" "$CYAN" "$RESET" "$DIM" "$RESET"
for repo in "${repos[@]}"; do
    printf '  %s▸%s %s%s%s\n' "$GREEN" "$RESET" "$BOLD" "$(basename "$repo")" "$RESET"
done
print_rule
TOTAL_REPOS=${#repos[@]}

if (( DRY_RUN )); then
    printf '\n%s%s🧪 Modo simulación%s: no se ejecutarán add, commit ni push.\n' "$YELLOW" "$BOLD" "$RESET"
    exit 0
fi

for repo_index in "${!repos[@]}"; do
    repo=${repos[$repo_index]}
    repo_name=$(basename "$repo")
    branch=$(git -C "$repo" symbolic-ref --quiet --short HEAD || true)
    repo_number=$((repo_index + 1))

    [[ -n "$branch" ]] || fail "$repo_name esta en detached HEAD; cambia a una rama antes de continuar"

    if ! confirm "Publicar '$repo_name' en '$branch'?"; then
        printf '%s⏹ Proceso detenido antes de actualizar %s.%s\n' "$YELLOW" "$repo_name" "$RESET"
        exit 0
    fi

    printf '\n%s%s┌─ [%s/%s] %s · %s%s%s%s\n' "$BLUE" "$BOLD" "$repo_number" "$TOTAL_REPOS" "$repo_name" "$BOLD" "$branch" "$RESET" "$BLUE"
    printf '%s│%s %s🔍 Preparando cambios%s\n' "$BLUE" "$RESET" "$CYAN" "$RESET"
    child_path=''
    if (( repo_index > 0 )); then
        child_path=${repos[$((repo_index - 1))]#"$repo"/}
    fi
    stage_repository "$repo" "$child_path" || fail "no se pudieron preparar los cambios de $repo_name"

    if git -C "$repo" diff --cached --quiet; then
        printf '%s│%s %sℹ Sin cambios nuevos; se comprueba el remoto.%s\n' "$BLUE" "$RESET" "$DIM" "$RESET"
    else
        commit_message="Update $repo_name"
        git -C "$repo" commit -m "$commit_message" || fail "no se pudo crear el commit de $repo_name"
    fi

    printf '%s│%s %s☁ Publicando en GitHub...%s\n' "$BLUE" "$RESET" "$CYAN" "$RESET"
    git -C "$repo" push || fail "no se pudo subir $repo_name"
    printf '%s└─%s %s✅ Publicación completada%s\n' "$BLUE" "$RESET" "$GREEN" "$RESET"
done

print_rule
printf '%s%s🎉 Publicación completada: %s/%s repositorios.%s\n\n' "$GREEN" "$BOLD" "$TOTAL_REPOS" "$TOTAL_REPOS" "$RESET"
