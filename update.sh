#!/usr/bin/env bash

set -u

usage() {
    printf 'Uso: %s [--dry-run]\n' "$(basename "$0")"
    printf '\n'
    printf 'Actualiza el repositorio Git del directorio actual y sus repositorios padre.\n'
    printf 'Ejecuta el script desde el submodulo mas interno que quieras publicar.\n'
}

fail() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

confirm() {
    local answer

    printf '\n%s [s/N]: ' "$1"
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

repos=()
while :; do
    repos+=("$current_root")
    parent_root=$(find_parent_repo "$current_root" || true)
    [[ -z "$parent_root" ]] && break
    current_root=$parent_root
done

printf 'Cadena detectada (se procesara de dentro hacia fuera):\n'
for repo in "${repos[@]}"; do
    printf '  - %s\n' "$(basename "$repo")"
done

if (( DRY_RUN )); then
    printf '\nModo simulacion: no se ejecutaran add, commit ni push.\n'
    exit 0
fi

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo")
    branch=$(git -C "$repo" symbolic-ref --quiet --short HEAD || true)

    [[ -n "$branch" ]] || fail "$repo_name esta en detached HEAD; cambia a una rama antes de continuar"

    if ! confirm "A continuacion se actualizaran, confirmaran y subiran los cambios de '$repo_name' en la rama '$branch'. Continuar?"; then
        printf 'Proceso detenido antes de actualizar %s.\n' "$repo_name"
        exit 0
    fi

    printf '\n[%s] Preparando cambios...\n' "$repo_name"
    git -C "$repo" add -A || fail "no se pudieron preparar los cambios de $repo_name"

    if git -C "$repo" diff --cached --quiet; then
        printf '[%s] No hay cambios nuevos; se intentara subir la rama igualmente.\n' "$repo_name"
    else
        commit_message="Update $repo_name"
        git -C "$repo" commit -m "$commit_message" || fail "no se pudo crear el commit de $repo_name"
    fi

    git -C "$repo" push || fail "no se pudo subir $repo_name"
    printf '[%s] Actualizacion completada.\n' "$repo_name"
done

printf '\nTodos los repositorios detectados fueron procesados.\n'
