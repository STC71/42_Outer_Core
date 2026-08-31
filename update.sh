#!/usr/bin/env bash
# Actualizador de repositorios 42 — propuesta revisada el 30/08/2026
# Publica de dentro hacia fuera una cadena de submódulos Git.
set -u
set -o pipefail

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

GH_BIN=''
GIT_PROTOCOL='https'
REPOSITORY_VISIBILITY='private'
REPOSITORY_VISIBILITY_LABEL='privado'
CLEANUP_PATHS=()
LARGE_FILE_LIMIT=$((100 * 1024 * 1024))
UNTRACK_IGNORED_PENDING=0

cleanup() {
    local path
    for path in "${CLEANUP_PATHS[@]+"${CLEANUP_PATHS[@]}"}"; do
        rm -rf "$path"
    done
}
trap cleanup EXIT

print_rule() {
    printf '%s%s────────────────────────────────────────────────────────────%s\n' "$DIM" "$CYAN" "$RESET"
}

print_banner() {
    printf '\n%s%s╔════════════════════════════════════════════════════════════╗%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s║           🚀  ACTUALIZADOR DE REPOSITORIOS 42              ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╠════════════════════════════════════════════════════════════╣%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s║     Implementación de sternero estudiante de 42 Málaga     ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╚════════════════════════════════════════════════════════════╝%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%sGestiona la publicación coordinada de una cadena de repositorios Git.%s\n' "$DIM" "$RESET"
    printf '%s• Parte del submódulo (carpeta) desde el que se ejecuta.%s\n' "$DIM" "$RESET"
    printf '%s• Si aún no existe como submódulo, propone crearlo con confirmación.%s\n' "$DIM" "$RESET"
    printf '%s• Si falta gh, propone instalarlo localmente sin permisos de sudo.%s\n' "$DIM" "$RESET"
    printf '%s• Consulta .gitmodules para localizar únicamente sus repositorios padre.%s\n' "$DIM" "$RESET"
    printf '%s• Actualiza de dentro hacia fuera: submódulo, padres y repositorio principal.%s\n' "$DIM" "$RESET"
    printf '%s• Mantiene fuera los repositorios hermanos y las carpetas no registradas.%s\n' "$DIM" "$RESET"
    printf '%s• Si hay submódulos más internos con cambios, ejecuta antes desde ellos.%s\n' "$DIM" "$RESET"
}

print_progress() {
    local current=$1
    local total=$2
    local label=$3
    local width=28
    local filled empty bar empty_bar

    (( total > 0 )) || total=1
    filled=$((current * width / total))
    empty=$((width - filled))
    printf -v bar '%*s' "$filled" ''
    bar=${bar// /#}
    printf -v empty_bar '%*s' "$empty" ''
    empty_bar=${empty_bar// /-}
    printf '%s%sProgreso%s [%s%s%s%s%s] %s/%s · %s\n' \
        "$BOLD" "$CYAN" "$RESET" "$GREEN" "$bar" "$DIM" "$empty_bar" "$RESET" "$current" "$total" "$label"
}

run_with_progress() {
    local label=$1
    shift
    local log_file command_pid result
    local spinner='|/-\\'
    local frame=0

    log_file=$(mktemp) || return 1
    CLEANUP_PATHS+=("$log_file")
    (
        trap - EXIT
        "$@"
    ) >"$log_file" 2>&1 &
    command_pid=$!
    while kill -0 "$command_pid" 2>/dev/null; do
        printf '\r%s%s%s %s%s%s' "$CYAN" "${spinner:$((frame % 4)):1}" "$RESET" "$DIM" "$label" "$RESET"
        frame=$((frame + 1))
        sleep 0.1
    done
    wait "$command_pid"
    result=$?
    if (( result != 0 )); then
        printf '\r%s❌%s %s\n' "$RED" "$RESET" "$label"
        cat "$log_file" >&2
        return "$result"
    fi
    printf '\r%s✅%s %s\n' "$GREEN" "$RESET" "$label"
    return 0
}

usage() {
    local me
    me=$(basename "$0")

    printf '%s%s🚀 %s%s — actualizador de cadenas de submódulos Git\n' "$BOLD" "$CYAN" "$me" "$RESET"
    printf '\n'
    printf '%sUso:%s\n' "$BOLD" "$RESET"
    printf '  %s [opciones]\n' "$me"
    printf '\n'
    printf '%sDescripción:%s\n' "$BOLD" "$RESET"
    printf '  Publica de dentro hacia fuera el repo del directorio actual y sus padres\n'
    printf '  registrados como submódulos (.gitmodules). Puede crear repos en GitHub,\n'
    printf '  registrar submódulos nuevos y evitar archivos > 100 MiB.\n'
    printf '\n'
    printf '%sOpciones:%s\n' "$BOLD" "$RESET"
    printf '  -n, --dry-run          Simula: muestra acciones sin commit ni push\n'
    printf '      --split-submodule  Migra la ruta actual a cadena de submódulos\n'
    printf '                         (de dentro hacia fuera; ver abajo)\n'
    printf '  -h, --help             Muestra esta ayuda y sale\n'
    printf '\n'
    printf '%sDónde ejecutarlo (publicación normal):%s\n' "$BOLD" "$RESET"
    printf '  Desde el proyecto / submódulo más interno que quieras publicar.\n'
    printf '  Ejemplo:\n'
    printf '    cd 42_outer_core/piscine_pedago_data_science/data_science_0_creation_db\n'
    printf '    ../../%s --dry-run\n' "$me"
    printf '    ../../%s\n' "$me"
    printf '  Si estás en un subdirectorio (p. ej. src/), se usa la raíz Git de ese repo.\n'
    printf '\n'
    printf '%sModo --split-submodule (migración monorepo → cadena de submódulos):%s\n' "$BOLD" "$RESET"
    printf '  Desde una subcarpeta del monorepo (uno o varios niveles), crea la\n'
    printf '  cadena de repos igual que el flujo normal: de dentro hacia fuera.\n'
    printf '  Ejemplo anidado:\n'
    printf '    cd mi_portfolio/grupo1_/mi_proyecto\n'
    printf '    ../../%s --split-submodule --dry-run\n' "$me"
    printf '    ../../%s --split-submodule\n' "$me"
    printf '  Resultado: mi_proyecto → submódulo de grupo1_;\n'
    printf '             grupo1_ → submódulo del portfolio.\n'
    printf '  También vale un solo nivel: cd mi_portfolio/mi_proyecto && ../%s --split-submodule\n' "$me"
    printf '  Saca del índice del principal lo trackeado, init/publica cada nivel,\n'
    printf '  registra gitlinks (160000) y propone commit/push del principal.\n'
    printf '  Requiere origin en el repo principal. No convierte «todas» las carpetas\n'
    printf '  del monorepo de golpe: una ruta (cadena) por ejecución.\n'
    printf '\n'
    printf '%sQué hace (publicación normal):%s\n' "$BOLD" "$RESET"
    printf '  1. Detecta si el repo actual es un submódulo registrado\n'
    printf '  2. Si no, propone crear/registrar la cadena hasta el monorepo con origin\n'
    printf '  3. Construye la lista de repos (hijo → padres → portfolio)\n'
    printf '  4. En cada nivel (con confirmación): prepara índice, commit y push\n'
    printf '\n'
    printf '%sEn el nivel más interno también:%s\n' "$BOLD" "$RESET"
    printf '  • Archivos > 100 MiB → propone añadirlos al .gitignore y sacarlos del índice\n'
    printf '  • Rutas ya en .gitignore pero aún versionadas → propone git rm --cached\n'
    printf '  • No intenta git add de archivos ignorados\n'
    printf '  • Registra borrados de archivos versionados que ya no están en disco\n'
    printf '\n'
    printf '%sMensajes de commit:%s\n' "$BOLD" "$RESET"
    printf '  Por defecto: Update <nombre_repo> · DD/MM/AA HH:MM\n'
    printf '  Puedes aceptar ese mensaje o escribir uno propio; en mensajes\n'
    printf '  personalizados también se añade al final · DD/MM/AA HH:MM.\n'
    printf '\n'
    printf '%sRequisitos:%s\n' "$BOLD" "$RESET"
    printf '  git, find; cuenta de GitHub. Si falta gh, puede instalarlo en ~/.local/bin\n'
    printf '  (sin sudo) y pedir autenticación.\n'
    printf '\n'
    printf '%sDocumentación:%s  update.md (misma carpeta o raíz del portfolio)\n' "$BOLD" "$RESET"
    printf '\n'
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
        s|S|si|SI|Si|sI|sí|Sí|SÍ|sÍ|y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Muestra el mensaje por defecto; Enter/s lo acepta, n pide otro, cualquier texto lo usa.
# Los prompts van a stderr: se usa como commit_message=$(prompt_commit_message ...)
# y si se escribe en stdout el usuario no ve la pregunta (parece un cuelgue).
# Todo mensaje personalizado recibe al final " · DD/MM/AA HH:MM" para trazabilidad.
prompt_commit_message() {
    local default_msg=$1
    local answer stamp
    stamp=$(date '+%d/%m/%y %H:%M')

    printf '\n%s│%s %sMensaje de commit:%s\n' "$BLUE" "$RESET" "$BOLD" "$RESET" >&2
    printf '%s│%s   %s%s%s\n' "$BLUE" "$RESET" "$DIM" "$default_msg" "$RESET" >&2
    printf '%s│%s   %s(si personalizas, se añadirá · %s)%s\n' \
        "$BLUE" "$RESET" "$DIM" "$stamp" "$RESET" >&2
    printf '%s%s?%s Usar este mensaje %s[S/n o escribe otro]:%s ' \
        "$YELLOW" "$BOLD" "$RESET" "$DIM" "$RESET" >&2
    IFS= read -r answer || exit 1
    case "$answer" in
        ''|s|S|si|SI|Si|sI|sí|Sí|SÍ|sÍ|y|Y|yes|YES)
            printf '%s\n' "$default_msg"
            ;;
        n|N|no|NO|No)
            printf '%s%s?%s Nuevo mensaje: ' "$YELLOW" "$BOLD" "$RESET" >&2
            IFS= read -r answer || exit 1
            if [[ -z "$answer" ]]; then
                printf '%s\n' "$default_msg"
            else
                printf '%s · %s\n' "$answer" "$stamp"
            fi
            ;;
        *)
            printf '%s · %s\n' "$answer" "$stamp"
            ;;
    esac
}

choose_visibility() {
    local answer

    while :; do
        printf '%s%s🔐 Visibilidad del repositorio%s %s[p]Privado / [u]Público (por defecto: privado):%s ' \
            "$YELLOW" "$BOLD" "$RESET" "$DIM" "$RESET"
        IFS= read -r answer || return 1
        case "$answer" in
            ''|p|P|privado|PRIVADO|Privado)
                REPOSITORY_VISIBILITY='private'
                REPOSITORY_VISIBILITY_LABEL='privado'
                return 0
                ;;
            u|U|publico|PUBLICO|Público|público|PÚBLICO|public|PUBLIC)
                REPOSITORY_VISIBILITY='public'
                REPOSITORY_VISIBILITY_LABEL='publico'
                return 0
                ;;
            *)
                printf '%s⚠ Introduce p para privado o u para publico.%s\n' "$RED" "$RESET"
                ;;
        esac
    done
}

file_size_bytes() {
    stat -c '%s' "$1" 2>/dev/null || stat -f '%z' "$1"
}

normalize_path() {
    realpath -m "$1"
}

has_ssh_key() {
    [[ -f "$HOME/.ssh/id_ed25519" \
        || -f "$HOME/.ssh/id_rsa" \
        || -f "$HOME/.ssh/id_ecdsa" \
        || -f "$HOME/.ssh/id_ed25519_sk" ]]
}

github_owner_from_url() {
    local url=$1
    printf '%s\n' "$url" | sed -nE \
        's#.*(github\.com[:/]|ssh://git@github\.com/)([^/]+)/.*#\2#p' | head -n 1
}

github_owner_from_repo() {
    local repo=$1
    local url owner

    url=$(git -C "$repo" remote get-url origin 2>/dev/null) || return 1
    owner=$(github_owner_from_url "$url")
    [[ -n "$owner" ]] || return 1
    printf '%s\n' "$owner"
}

repo_has_origin() {
    git -C "$1" remote get-url origin >/dev/null 2>&1
}

# Sube desde el PADRE de start hasta encontrar un repo Git con remoto origin.
# Nunca devuelve start aunque tenga origin (p. ej. el proyecto actual ya
# publicado en GitHub); buscamos el monorepo contenedor (42_outer_core).
find_ancestor_with_origin() {
    local start=$1
    local candidate root start_norm

    start_norm=$(normalize_path "$start")
    candidate=$(dirname "$start_norm")
    while [[ "$candidate" != "/" ]]; do
        if is_repository_root "$candidate" && repo_has_origin "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
        root=$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -n "$root" ]]; then
            root=$(normalize_path "$root")
            if [[ "$root" != "$start_norm" ]] && repo_has_origin "$root"; then
                printf '%s\n' "$root"
                return 0
            fi
        fi
        candidate=$(dirname "$candidate")
    done
    return 1
}

# Resuelve owner + URL de origin desde el propio repo, el padre o un ancestro.
resolve_github_origin_context() {
    local preferred_repo=$1
    local origin_url owner

    if repo_has_origin "$preferred_repo"; then
        origin_url=$(git -C "$preferred_repo" remote get-url origin)
    else
        local ancestor
        ancestor=$(find_ancestor_with_origin "$preferred_repo") || return 1
        origin_url=$(git -C "$ancestor" remote get-url origin)
    fi
    owner=$(github_owner_from_url "$origin_url")
    [[ -n "$owner" && -n "$origin_url" ]] || return 1
    printf '%s\t%s\n' "$owner" "$origin_url"
}

detect_git_protocol() {
    local url=${1:-}

    case "$url" in
        git@*|ssh://*)
            if has_ssh_key; then
                printf 'ssh\n'
                return 0
            fi
            printf '%s⚠ El remoto padre usa SSH pero no hay clave local; se usará HTTPS.%s\n' \
                "$YELLOW" "$RESET" >&2
            printf 'https\n'
            ;;
        *)
            printf 'https\n'
            ;;
    esac
}

remote_url_for() {
    local owner=$1
    local name=$2

    if [[ "$GIT_PROTOCOL" == 'ssh' ]]; then
        printf 'git@github.com:%s/%s.git\n' "$owner" "$name"
    else
        printf 'https://github.com/%s/%s.git\n' "$owner" "$name"
    fi
}

module_remote_name() {
    local name=$1

    [[ "$name" == 42_* ]] || name="42_$name"
    printf '%s\n' "$name"
}

git_dir_of() {
    git -C "$1" rev-parse --git-dir 2>/dev/null
}

repo_has_in_progress_operation() {
    local git_dir

    git_dir=$(git_dir_of "$1") || return 1
    [[ -d "$git_dir/rebase-merge" \
        || -d "$git_dir/rebase-apply" \
        || -f "$git_dir/MERGE_HEAD" \
        || -f "$git_dir/CHERRY_PICK_HEAD" \
        || -f "$git_dir/REVERT_HEAD" ]]
}

init_git_repo() {
    local repo=$1

    if git -C "$repo" init -b main >/dev/null 2>&1; then
        return 0
    fi
    git -C "$repo" init >/dev/null || return 1
    git -C "$repo" symbolic-ref HEAD refs/heads/main >/dev/null
}

current_branch() {
    git -C "$1" symbolic-ref --quiet --short HEAD 2>/dev/null
}

ensure_origin() {
    local repo=$1
    local url=$2

    if git -C "$repo" remote get-url origin >/dev/null 2>&1; then
        git -C "$repo" remote set-url origin "$url"
    else
        git -C "$repo" remote add origin "$url"
    fi
}

github_repo_exists() {
    local slug=$1

    "$GH_BIN" repo view "$slug" >/dev/null 2>&1
}

create_github_repo() {
    local slug=$1
    local visibility=$2

    if github_repo_exists "$slug"; then
        printf '%s✅ El repositorio remoto ya existe, se reutiliza:%s %s\n' \
            "$GREEN" "$RESET" "$slug"
        return 0
    fi
    "$GH_BIN" repo create "$slug" "--$visibility" >/dev/null
}

push_branch() {
    local repo=$1
    local branch=$2

    if git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
        git -C "$repo" push
    else
        git -C "$repo" push -u origin "$branch"
    fi
}

is_git_repo() {
    git -C "$1" rev-parse --show-toplevel >/dev/null 2>&1
}

is_repository_root() {
    local repository_root

    repository_root=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 1
    [[ -n "$repository_root" && "$(normalize_path "$repository_root")" == "$(normalize_path "$1")" ]]
}

is_registered_submodule() {
    local parent_root=$1
    local child_root=$2
    local module_path child_normalized parent_normalized listing

    [[ -f "$parent_root/.gitmodules" ]] || return 1
    child_normalized=$(normalize_path "$child_root")
    listing=$(git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        --get-regexp '^submodule\..*\.path$' 2>/dev/null \
        | sed 's/^[^[:space:]]*[[:space:]]*//' || true)
    while IFS= read -r module_path; do
        [[ -z "$module_path" ]] && continue
        parent_normalized=$(normalize_path "$parent_root/$module_path")
        if [[ "$parent_normalized" == "$child_normalized" ]]; then
            return 0
        fi
    done <<< "$listing"
    return 1
}

find_parent_repo() {
    local child_root=$1
    local candidate

    child_root=$(normalize_path "$child_root")
    candidate=$(dirname "$child_root")
    while [[ "$candidate" != "/" ]]; do
        if is_repository_root "$candidate" \
            && is_registered_submodule "$candidate" "$child_root"; then
            printf '%s\n' "$(normalize_path "$candidate")"
            return 0
        fi
        candidate=$(dirname "$candidate")
    done
    return 1
}

find_enclosing_repo() {
    local child_root=$1
    local candidate candidate_root child_normalized

    child_normalized=$(normalize_path "$child_root")
    candidate=$(dirname "$child_root")
    while [[ "$candidate" != "/" ]]; do
        candidate_root=$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -n "$candidate_root" && "$(normalize_path "$candidate_root")" != "$child_normalized" ]]; then
            printf '%s\n' "$(normalize_path "$candidate_root")"
            return 0
        fi
        candidate=$(dirname "$candidate")
    done
    return 1
}

register_submodule() {
    local parent_root=$1
    local rel_path=$2
    local remote_url=$3
    local mode

    [[ -e "$parent_root/.gitmodules" ]] || touch "$parent_root/.gitmodules"

    git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        "submodule.$rel_path.path" "$rel_path"
    git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        "submodule.$rel_path.url" "$remote_url"

    if git -C "$parent_root" ls-files --error-unmatch -- "$rel_path" >/dev/null 2>&1; then
        mode=$(git -C "$parent_root" ls-files -s -- "$rel_path" | awk '{print $1; exit}')
        if [[ "$mode" != "160000" ]]; then
            git -C "$parent_root" rm -r --cached -- "$rel_path" >/dev/null || return 1
        fi
    fi

    git -C "$parent_root" add --force -- .gitmodules "$rel_path" || return 1
    git -C "$parent_root" config "submodule.$rel_path.url" "$remote_url"
    git -C "$parent_root" config "submodule.$rel_path.active" true
    git -C "$parent_root" submodule absorbgitdirs -- "$rel_path" >/dev/null 2>&1 || true
}

handle_large_files() {
    local child_root=$1
    local file_path relative_file ignore_file="$child_root/.gitignore"
    local file_size listing
    local large_files=()

    listing=$(mktemp) || return 1
    find "$child_root" -type f -not -path '*/.git/*' -print0 >"$listing"
    while IFS= read -r -d '' file_path; do
        file_size=$(file_size_bytes "$file_path") || continue
        if (( file_size > LARGE_FILE_LIMIT )); then
            large_files+=("$file_path")
        fi
    done < "$listing"
    rm -f "$listing"

    (( ${#large_files[@]} > 0 )) || return 0

    printf '\n%s⚠ Se han encontrado %s archivos que superan el límite de 100 MiB de GitHub:%s\n' \
        "$YELLOW" "${#large_files[@]}" "$RESET"
    for file_path in "${large_files[@]}"; do
        relative_file=${file_path#"$child_root"/}
        printf '  %s•%s %s\n' "$DIM" "$RESET" "$relative_file"
    done
    printf '%sGitHub rechazaría el repositorio si se incluyen.%s\n' "$DIM" "$RESET"
    if confirm "Añadir todos estos archivos al .gitignore y continuar"; then
        touch "$ignore_file" || return 1
        if [[ -s "$ignore_file" && "$(tail -c 1 "$ignore_file")" != $'\n' ]]; then
            printf '\n' >>"$ignore_file"
        fi
        for file_path in "${large_files[@]}"; do
            relative_file=${file_path#"$child_root"/}
            if ! grep -Fqx -- "$relative_file" "$ignore_file"; then
                printf '%s\n' "$relative_file" >>"$ignore_file"
            fi
            if git -C "$child_root" ls-files --error-unmatch -- "$relative_file" >/dev/null 2>&1; then
                git -C "$child_root" rm --cached -- "$relative_file" >/dev/null \
                    || return 1
            fi
        done
        printf '%s✅ Archivos excluidos mediante %s%s\n' "$GREEN" "$ignore_file" "$RESET"
        # Para reaplicar git rm --cached tras el reset del staging
        UNTRACK_IGNORED_PENDING=1
        return 0
    fi
    printf '%s⏹ Publicación cancelada: no se excluyeron los archivos grandes.%s\n' "$RED" "$RESET" >&2
    return 1
}

# Archivos que siguen en el índice de Git pero ya cubre el .gitignore
# (p. ej. un PDF versionado antes de añadir *.pdf). Sin esto siguen en GitHub.
handle_ignored_tracked_files() {
    local repo=$1
    local listing relative_file
    local ignored_tracked=()

    listing=$(mktemp) || return 1
    git -C "$repo" ls-files -i --exclude-standard -z >"$listing" 2>/dev/null || true
    while IFS= read -r -d '' relative_file; do
        [[ -z "$relative_file" ]] && continue
        ignored_tracked+=("$relative_file")
    done <"$listing"
    rm -f "$listing"

    (( ${#ignored_tracked[@]} > 0 )) || return 0

    printf '\n%s⚠ Hay %s archivo(s) aún versionados aunque los cubre el .gitignore:%s\n' \
        "$YELLOW" "${#ignored_tracked[@]}" "$RESET"
    for relative_file in "${ignored_tracked[@]}"; do
        printf '  %s•%s %s\n' "$DIM" "$RESET" "$relative_file"
    done
    printf '%s.gitignore no los quita del remoto hasta hacer git rm --cached.%s\n' "$DIM" "$RESET"

    if confirm "Dejar de versionarlos (permanecen en disco) y continuar"; then
        for relative_file in "${ignored_tracked[@]}"; do
            git -C "$repo" rm --cached -f -- "$relative_file" >/dev/null 2>&1 \
                || git -C "$repo" rm --cached -f -- "$relative_file" \
                || return 1
        done
        printf '%s✅ Dejaron de versionarse %s archivo(s); siguen en tu carpeta local.%s\n' \
            "$GREEN" "${#ignored_tracked[@]}" "$RESET"
        # Marca global para reaplicar tras el reset del staging
        UNTRACK_IGNORED_PENDING=1
        return 0
    fi

    printf '%sℹ Se mantienen versionados (pueden seguir en GitHub).%s\n' "$DIM" "$RESET"
    UNTRACK_IGNORED_PENDING=0
    return 0
}

# Tras git reset del staging, volver a sacar del índice lo ignorado si el usuario aceptó.
reapply_untrack_ignored() {
    local repo=$1
    local listing relative_file

    (( ${UNTRACK_IGNORED_PENDING:-0} )) || return 0

    listing=$(mktemp) || return 1
    git -C "$repo" ls-files -i --exclude-standard -z >"$listing" 2>/dev/null || true
    while IFS= read -r -d '' relative_file; do
        [[ -z "$relative_file" ]] && continue
        git -C "$repo" rm --cached -f -- "$relative_file" >/dev/null 2>&1 || true
    done <"$listing"
    rm -f "$listing"
}

ensure_github_cli() {
    local gh_path architecture version archive install_dir temporary_dir checksums expected actual

    if command -v gh >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/gh" ]]; then
        gh_path=$(command -v gh || printf '%s/.local/bin/gh' "$HOME")
        GH_BIN="$gh_path"
        export PATH="$(dirname "$gh_path"):$PATH"
        printf '%s%s🔎 GitHub CLI encontrado%s: %s\n' "$CYAN" "$BOLD" "$RESET" "$gh_path"
    else
        printf '%s%s📦 GitHub CLI no encontrado%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sSe instalará en %s sin usar sudo.%s\n' "$DIM" "$HOME/.local/bin" "$RESET"
        confirm "Descargar e instalar GitHub CLI" || return 1

        case "$(uname -m)" in
            x86_64) architecture='amd64' ;;
            aarch64|arm64) architecture='arm64' ;;
            *) fail "arquitectura no soportada para la instalación automática de gh" ;;
        esac

        version=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
            | sed -nE 's/.*"tag_name": "v([^"]+)".*/\1/p' | head -n 1) \
            || fail "no se pudo consultar la última versión de gh"
        [[ -n "$version" ]] || fail "no se pudo determinar la versión de gh"

        install_dir="$HOME/.local/bin"
        temporary_dir=$(mktemp -d) || fail "no se pudo crear un directorio temporal para gh"
        CLEANUP_PATHS+=("$temporary_dir")
        archive="$temporary_dir/gh.tar.gz"
        checksums="$temporary_dir/checksums.txt"
        mkdir -p "$install_dir" || fail "no se pudo crear $install_dir"
        curl -fL "https://github.com/cli/cli/releases/download/v$version/gh_${version}_linux_${architecture}.tar.gz" \
            -o "$archive" || fail "no se pudo descargar gh"
        if curl -fsSL "https://github.com/cli/cli/releases/download/v$version/gh_${version}_checksums.txt" \
            -o "$checksums"; then
            expected=$(awk -v name="gh_${version}_linux_${architecture}.tar.gz" '$2 == name {print $1; exit}' "$checksums")
            actual=$(sha256sum "$archive" 2>/dev/null | awk '{print $1}')
            [[ -n "$expected" && -n "$actual" && "$expected" == "$actual" ]] \
                || fail "el checksum de gh no coincide; se aborta la instalación"
        else
            printf '%s⚠ No se pudo verificar el checksum de gh; se continúa con la descarga HTTPS.%s\n' \
                "$YELLOW" "$RESET"
        fi
        tar -xzf "$archive" -C "$temporary_dir" || fail "no se pudo extraer gh"
        cp "$temporary_dir/gh_${version}_linux_${architecture}/bin/gh" "$install_dir/gh" \
            || fail "no se pudo instalar gh en $install_dir"
        chmod 755 "$install_dir/gh"
        GH_BIN="$install_dir/gh"
        export PATH="$install_dir:$PATH"
        printf '%s✅ GitHub CLI %s instalado en %s%s\n' "$GREEN" "$version" "$install_dir" "$RESET"
    fi

    GH_BIN=${GH_BIN:-$(command -v gh)}
    [[ -n "$GH_BIN" && -x "$GH_BIN" ]] || return 1

    if ! "$GH_BIN" auth status >/dev/null 2>&1; then
        printf '\n%s%s🔑 GitHub CLI no está autenticado%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sSe mostrará un código de un solo uso para completar el acceso.%s\n' "$DIM" "$RESET"
        printf '%sAbre manualmente https://github.com/login/device en tu navegador.%s\n' "$DIM" "$RESET"
        confirm "Iniciar ahora la autenticación de GitHub" \
            || fail "autenticación cancelada; no se puede crear el submódulo remoto"
        "$GH_BIN" auth login \
            --hostname github.com \
            --git-protocol "$GIT_PROTOCOL" \
            --web \
            || fail "la autenticación de GitHub no se completó"
        "$GH_BIN" auth status >/dev/null 2>&1 \
            || fail "gh sigue sin estar autenticado después del inicio de sesión"
        printf '%s✅ GitHub CLI autenticado correctamente%s\n' "$GREEN" "$RESET"
    else
        printf '%s✅ Sesión de GitHub ya autenticada%s\n' "$GREEN" "$RESET"
    fi
}

stage_repository() {
    local repo=$1
    local child_path=${2:-}
    local child_top entry abs listing deleted del_list
    local is_innermost=0

    [[ -z "$child_path" ]] && is_innermost=1
    child_top=${child_path%%/*}

    if repo_has_in_progress_operation "$repo"; then
        printf 'hay un merge/rebase/cherry-pick en curso en %s\n' "$repo" >&2
        return 1
    fi

    git -C "$repo" reset -q || return 1

    # Reaplicar git rm --cached de rutas ignoradas tras el reset (si se aceptó antes).
    if (( is_innermost )); then
        reapply_untrack_ignored "$repo" || return 1
    fi

    # 1) Añadir lo que existe en disco (find no ve archivos ya borrados).
    listing=$(mktemp) || return 1
    find "$repo" -mindepth 1 -maxdepth 1 -print0 >"$listing"
    while IFS= read -r -d '' entry; do
        entry=${entry#"$repo"/}
        [[ "$entry" == ".git" ]] && continue
        abs="$repo/$entry"

        if [[ -f "$abs" || -L "$abs" ]]; then
            # No intentar add de rutas ignoradas (p. ej. en.subject.pdf con *.pdf)
            if git -C "$repo" check-ignore -q -- "$entry" 2>/dev/null; then
                continue
            fi
            git -C "$repo" add -A -- "$entry" || { rm -f "$listing"; return 1; }
            continue
        fi
        [[ -d "$abs" ]] || continue

        if is_repository_root "$abs"; then
            if [[ -n "$child_path" && "$entry" == "$child_top" ]]; then
                git -C "$repo" add -A -- "$child_path" || { rm -f "$listing"; return 1; }
            elif (( is_innermost )) && is_registered_submodule "$repo" "$(normalize_path "$abs")"; then
                git -C "$repo" add -A -- "$entry" || { rm -f "$listing"; return 1; }
            fi
            continue
        fi

        if (( is_innermost )); then
            git -C "$repo" add -A -- "$entry" || { rm -f "$listing"; return 1; }
        elif [[ -n "$child_path" && "$entry" == "$child_top" ]]; then
            git -C "$repo" add -A -- "$child_path" || { rm -f "$listing"; return 1; }
        fi
    done < "$listing"
    rm -f "$listing"

    # 2) Registrar borrados: archivos/rutas rastreadas que ya no están en disco.
    #    find no los lista; sin este paso quedan en GitHub (p. ej. update_v0.sh).
    del_list=$(mktemp) || return 1
    git -C "$repo" diff --name-only --diff-filter=D -z >"$del_list" 2>/dev/null || true
    while IFS= read -r -d '' deleted; do
        [[ -z "$deleted" ]] && continue
        if (( is_innermost )); then
            # Proyecto interno: cualquier borrado rastreado cuenta.
            git -C "$repo" add -u -- "$deleted" || { rm -f "$del_list"; return 1; }
        else
            # Padre: solo borrados en la raíz del repo o bajo el hijo de la cadena
            # (no tocamos hermanos ni otras rutas).
            if [[ "$deleted" != */* ]]; then
                git -C "$repo" add -u -- "$deleted" || { rm -f "$del_list"; return 1; }
            elif [[ -n "$child_top" && ( "$deleted" == "$child_top" || "$deleted" == "$child_top"/* ) ]]; then
                git -C "$repo" add -u -- "$deleted" || { rm -f "$del_list"; return 1; }
            fi
        fi
    done < "$del_list"
    rm -f "$del_list"
}

publish_new_repository() {
    local repo=$1
    local owner=$2
    local remote_name=$3
    local visibility=$4
    local remote_url branch slug

    slug="$owner/$remote_name"
    remote_url=$(remote_url_for "$owner" "$remote_name")
    create_github_repo "$slug" "$visibility" \
        || fail "no se pudo crear el repositorio remoto $slug"
    ensure_origin "$repo" "$remote_url" \
        || fail "no se pudo configurar el remoto de $remote_name"
    branch=$(current_branch "$repo")
    [[ -n "$branch" ]] || fail "$remote_name está en detached HEAD"
    git -C "$repo" push -u origin "$branch" >/dev/null \
        || fail "no se pudo publicar $remote_name"
}

create_submodule_from_current_directory() {
    local parent_root=$1
    local child_root=$2
    local relative_path module_name owner remote_name remote_url
    local file_path file_size repository_visibility parent_origin cached_files
    local ancestor_repo

    relative_path=${child_root#"$parent_root"/}
    [[ "$relative_path" != "$child_root" && -n "$relative_path" ]] \
        || fail "la carpeta actual no está dentro del repositorio padre"
    module_name=$(basename "$child_root")

    # Preferir origin del padre; si no tiene, del hijo; si no, de un ancestro.
    parent_origin=''
    if repo_has_origin "$parent_root"; then
        parent_origin=$(git -C "$parent_root" remote get-url origin)
    elif repo_has_origin "$child_root"; then
        parent_origin=$(git -C "$child_root" remote get-url origin)
        printf '%s⚠ El padre no tiene origin; se usa el del hijo para deducir el propietario GitHub.%s\n' \
            "$YELLOW" "$RESET"
    else
        ancestor_repo=$(find_ancestor_with_origin "$parent_root" || true)
        if [[ -n "$ancestor_repo" ]] && repo_has_origin "$ancestor_repo"; then
            parent_origin=$(git -C "$ancestor_repo" remote get-url origin)
            printf '%s⚠ El padre no tiene origin; se usa el de un ancestro con remoto (%s).%s\n' \
                "$YELLOW" "$(basename "$ancestor_repo")" "$RESET"
        else
            fail "ni el padre ni el hijo ni un ancestro tienen remoto origin; configura origin en 42_outer_core"
        fi
    fi
    owner=$(github_owner_from_url "$parent_origin")
    [[ -n "$owner" ]] || fail "no se pudo determinar el propietario de GitHub desde el remoto"
    GIT_PROTOCOL=$(detect_git_protocol "$parent_origin")
    remote_name=$(module_remote_name "$module_name")
    remote_url=$(remote_url_for "$owner" "$remote_name")

    if (( DRY_RUN )); then
        printf '\n%s%s🧪 Se podría crear el submódulo%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "$relative_path"
        printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
        printf '%sProtocolo:%s %s\n' "$DIM" "$RESET" "$GIT_PROTOCOL"
        return 0
    fi

    ensure_github_cli || fail "no se pudo preparar GitHub CLI"

    printf '\n%s%s🆕 Nuevo submódulo detectado%s\n' "$YELLOW" "$BOLD" "$RESET"
    printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "$relative_path"
    printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
    confirm "Crear y publicar este submódulo" || return 1
    choose_visibility || fail "no se pudo seleccionar la visibilidad del repositorio"
    repository_visibility=$REPOSITORY_VISIBILITY
    printf '%sVisibilidad seleccionada:%s %s\n' "$DIM" "$RESET" "$REPOSITORY_VISIBILITY_LABEL"

    handle_large_files "$child_root" \
        || fail "no se pudieron excluir los archivos grandes; publicación cancelada"

    if is_repository_root "$child_root" && git -C "$child_root" rev-parse HEAD >/dev/null 2>&1; then
        printf '%s✅ Se reutiliza el historial Git ya presente en la carpeta%s\n' "$GREEN" "$RESET"
    else
        if [[ -e "$child_root/.git" ]]; then
            git -C "$child_root" rev-parse HEAD >/dev/null 2>&1 \
                && fail "la carpeta ya contiene un submódulo con commits"
            git -C "$child_root" reset -q \
                || fail "no se pudo limpiar el estado parcial del nuevo submódulo"
        else
            init_git_repo "$child_root" \
                || fail "no se pudo inicializar el nuevo submódulo"
        fi
        git -C "$child_root" add -A \
            || fail "no se pudieron preparar los archivos del nuevo submódulo"
        git -C "$child_root" diff --cached --quiet \
            && fail "el nuevo submódulo no contiene archivos para publicar"

        cached_files=$(git -C "$child_root" diff --cached --name-only || true)
        while IFS= read -r file_path; do
            [[ -z "$file_path" ]] && continue
            file_size=$(file_size_bytes "$child_root/$file_path")
            (( file_size <= LARGE_FILE_LIMIT )) \
                || fail "el archivo '$relative_path/$file_path' supera el límite de 100 MiB de GitHub"
        done <<< "$cached_files"

        git -C "$child_root" commit -m "Initial commit" >/dev/null \
            || fail "no se pudo crear el commit inicial del nuevo submódulo (¿user.name / user.email?)"
    fi

    publish_new_repository "$child_root" "$owner" "$remote_name" "$repository_visibility"
    register_submodule "$parent_root" "$relative_path" "$remote_url" \
        || fail "no se pudo registrar el nuevo submódulo en el repositorio padre"
    printf '%s✅ Submódulo creado y publicado: %s%s\n' "$GREEN" "$remote_name" "$RESET"
}

create_submodule_chain() {
    local outer_root=$1
    local start_root=$2
    local relative_path owner
    local -a path_parts
    local level target_root child_root child_name module_name
    local remote_name remote_url child_remote_name child_remote_url
    local repository_visibility outer_origin

    start_root=$(normalize_path "$start_root")
    outer_root=$(normalize_path "$outer_root")
    [[ "$start_root" == "$outer_root"/* ]] \
        || fail "la ruta de inicio no está dentro del repositorio principal"

    relative_path=${start_root#"$outer_root"/}
    [[ -n "$relative_path" ]] || fail "no hay una ruta de submódulo que crear"
    IFS='/' read -r -a path_parts <<< "$relative_path"
    outer_origin=$(git -C "$outer_root" remote get-url origin 2>/dev/null) \
        || fail "el repositorio principal no tiene remoto origin"
    owner=$(github_owner_from_url "$outer_origin")
    [[ -n "$owner" ]] || fail "no se pudo determinar el propietario de GitHub desde el remoto del repositorio principal"
    GIT_PROTOCOL=$(detect_git_protocol "$outer_origin")

    if (( ! DRY_RUN )); then
        ensure_github_cli || fail "no se pudo preparar GitHub CLI"
    fi

    for ((level = ${#path_parts[@]} - 1; level >= 0; level--)); do
        target_root=$outer_root
        for module_name in "${path_parts[@]:0:level+1}"; do
            target_root="$target_root/$module_name"
        done

        if (( level < ${#path_parts[@]} - 1 )); then
            child_name=${path_parts[$((level + 1))]}
            child_root="$target_root/$child_name"
        else
            child_name=''
            child_root=''
        fi

        if is_repository_root "$target_root" \
            && git -C "$target_root" rev-parse HEAD >/dev/null 2>&1; then
            remote_name=$(module_remote_name "${path_parts[$level]}")
            remote_url=$(remote_url_for "$owner" "$remote_name")

            # Repo local ya con commits pero sin origin → publicar en GitHub
            if ! repo_has_origin "$target_root"; then
                printf '\n%s%s🧱 Nivel ya es repo local, pero sin origin%s\n' "$YELLOW" "$BOLD" "$RESET"
                printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "${target_root#"$outer_root"/}"
                printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
                if (( DRY_RUN )); then
                    printf '%s🧪 Se crearía el remoto y se haría push de %s%s\n' \
                        "$YELLOW" "$remote_name" "$RESET"
                else
                    confirm "Crear remoto y publicar este nivel ya existente" \
                        || fail "publicación de la cadena cancelada"
                    choose_visibility || fail "no se pudo seleccionar la visibilidad del repositorio"
                    publish_new_repository "$target_root" "$owner" "$remote_name" "$REPOSITORY_VISIBILITY"
                    printf '%s✅ Nivel publicado: %s%s\n' "$GREEN" "$remote_name" "$RESET"
                fi
            fi

            if [[ -n "$child_name" ]] && is_repository_root "$child_root"; then
                child_remote_url=$(git -C "$child_root" remote get-url origin 2>/dev/null || true)
                if [[ -z "$child_remote_url" ]]; then
                    child_remote_name=$(module_remote_name "$child_name")
                    child_remote_url=$(remote_url_for "$owner" "$child_remote_name")
                fi
                if ! is_registered_submodule "$target_root" "$(normalize_path "$child_root")"; then
                    if (( DRY_RUN )); then
                        printf '%s🧪 Se registraría el hijo %s en %s%s\n' \
                            "$YELLOW" "$child_name" "$(basename "$target_root")" "$RESET"
                    else
                        register_submodule "$target_root" "$child_name" "$child_remote_url" \
                            || fail "no se pudo registrar el submódulo hijo ya existente"
                    fi
                fi
            fi
            continue
        fi

        remote_name=$(module_remote_name "${path_parts[$level]}")
        remote_url=$(remote_url_for "$owner" "$remote_name")

        printf '\n%s%s🧱 Nivel de submódulo detectado%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "${target_root#"$outer_root"/}"
        printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
        if [[ -n "$child_name" ]]; then
            printf '%sIncluye el submódulo hijo:%s %s\n' "$DIM" "$RESET" "$child_name"
        fi

        if (( DRY_RUN )); then
            continue
        fi

        confirm "Crear y publicar este nivel" || fail "creación de la cadena cancelada"
        choose_visibility || fail "no se pudo seleccionar la visibilidad del repositorio"
        repository_visibility=$REPOSITORY_VISIBILITY
        printf '%sVisibilidad seleccionada:%s %s\n' "$DIM" "$RESET" "$REPOSITORY_VISIBILITY_LABEL"

        if [[ -z "$child_name" ]]; then
            handle_large_files "$target_root" \
                || fail "no se pudieron excluir los archivos grandes; publicación cancelada"
        fi

        if is_repository_root "$target_root"; then
            git -C "$target_root" reset -q \
                || fail "no se pudo limpiar el repositorio parcial"
        else
            init_git_repo "$target_root" \
                || fail "no se pudo inicializar el submódulo"
        fi

        if [[ -n "$child_name" ]]; then
            child_remote_name=$(module_remote_name "$child_name")
            if is_repository_root "$child_root" \
                && git -C "$child_root" remote get-url origin >/dev/null 2>&1; then
                child_remote_url=$(git -C "$child_root" remote get-url origin)
                printf '%s✅ Reutilizando repositorio hijo: %s%s\n' "$GREEN" "$child_remote_url" "$RESET"
            else
                child_remote_url=$(remote_url_for "$owner" "$child_remote_name")
            fi
            register_submodule "$target_root" "$child_name" "$child_remote_url" \
                || fail "no se pudo preparar el submódulo hijo"
        else
            git -C "$target_root" add -A \
                || fail "no se pudieron preparar los archivos del submódulo"
        fi

        git -C "$target_root" diff --cached --quiet \
            && fail "el submódulo no contiene cambios para publicar"
        git -C "$target_root" commit -m "Initial commit" >/dev/null \
            || fail "no se pudo crear el commit del submódulo (¿user.name / user.email?)"

        publish_new_repository "$target_root" "$owner" "$remote_name" "$repository_visibility"
        printf '%s✅ Nivel publicado: %s%s\n' "$GREEN" "$remote_name" "$RESET"
    done

    if (( DRY_RUN )); then
        return 0
    fi

    git -C "$outer_root" config --file "$outer_root/.gitmodules" \
        --remove-section "submodule.$relative_path" 2>/dev/null || true
    git -C "$outer_root" reset -q -- "$relative_path" 2>/dev/null || true
    module_name=${path_parts[0]}
    remote_name=$(module_remote_name "$module_name")
    remote_url=$(remote_url_for "$owner" "$remote_name")
    register_submodule "$outer_root" "$module_name" "$remote_url" \
        || fail "no se pudo registrar el submódulo principal"
}

# ---------------------------------------------------------------------------
# --split-submodule: carpeta(s) planas → cadena de submódulos (como update normal)
# Ejemplo: portfolio/grupo1_/mi_proyecto
#   → mi_proyecto (repo) submódulo de grupo1_
#   → grupo1_ (repo) submódulo de portfolio
# ---------------------------------------------------------------------------
split_submodule_folder() {
    local start_dir=$1
    local outer_root rel_path top_seg
    local owner outer_origin
    local commit_message branch
    local -a path_parts
    local i part chain_display tracked_top=0

    start_dir=$(normalize_path "$start_dir")
    outer_root=$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null) \
        || fail "el directorio actual no pertenece a un repositorio Git"
    outer_root=$(normalize_path "$outer_root")

    if [[ "$start_dir" == "$outer_root" ]]; then
        fail "modo --split-submodule: ejecuta el script desde una SUBCARPETA del monorepo, no desde la raíz.
Ejemplo: cd mi_portfolio/grupo1_/mi_proyecto && ../../update.sh --split-submodule"
    fi

    rel_path=${start_dir#"$outer_root"/}
    if [[ -z "$rel_path" || "$rel_path" == "$start_dir" ]]; then
        fail "no se pudo calcular la ruta relativa respecto al repo principal"
    fi

    IFS='/' read -r -a path_parts <<< "$rel_path"
    top_seg=${path_parts[0]}

    # Si el primer nivel ya es submódulo registrado del portfolio, el flujo normal basta
    if is_registered_submodule "$outer_root" "$(normalize_path "$outer_root/$top_seg")"; then
        fail "el nivel '$top_seg' ya es submódulo del repo principal.
Usa el flujo normal (sin --split-submodule) desde el proyecto interno."
    fi

    repo_has_origin "$outer_root" \
        || fail "el repositorio principal ($outer_root) no tiene remoto origin; configúralo antes"

    if repo_has_in_progress_operation "$outer_root"; then
        fail "hay un merge/rebase/cherry-pick en curso en el repo principal; termínalo antes"
    fi

    outer_origin=$(git -C "$outer_root" remote get-url origin)
    owner=$(github_owner_from_url "$outer_origin")
    [[ -n "$owner" ]] || fail "no se pudo determinar el propietario de GitHub desde origin"
    GIT_PROTOCOL=$(detect_git_protocol "$outer_origin")

    if git -C "$outer_root" ls-files --error-unmatch -- "$top_seg" >/dev/null 2>&1 \
        || git -C "$outer_root" ls-files --error-unmatch -- "$rel_path" >/dev/null 2>&1; then
        tracked_top=1
    fi

    chain_display=""
    for ((i = ${#path_parts[@]} - 1; i >= 0; i--)); do
        part=${path_parts[i]}
        if [[ -z "$chain_display" ]]; then
            chain_display=$part
        else
            chain_display="$chain_display → $part"
        fi
    done
    chain_display="$chain_display → $(basename "$outer_root")"

    printf '\n%s%s🔪 Modo --split-submodule%s (cadena, de dentro hacia fuera)\n' \
        "$BOLD" "$YELLOW" "$RESET"
    printf '%sRuta desde el principal:%s %s\n' "$DIM" "$RESET" "$rel_path"
    printf '%sRepo principal:%s %s\n' "$DIM" "$RESET" "$outer_root"
    printf '%sCadena objetivo:%s %s\n' "$DIM" "$RESET" "$chain_display"
    printf '%sRemotos (prefijo 42_):%s\n' "$DIM" "$RESET"
    for part in "${path_parts[@]}"; do
        printf '  • %s/%s\n' "$owner" "$(module_remote_name "$part")"
    done
    printf '%s¿Árbol trackeado en el principal?:%s %s\n' "$DIM" "$RESET" \
        "$(if (( tracked_top )); then echo sí; else echo no; fi)"
    printf '\n%sSe hará (mismo espíritu que update.sh normal):%s\n' "$BOLD" "$RESET"
    printf '  1. Sacar del índice del principal la ruta %s (si aplica)\n' "$top_seg"
    printf '  2. Crear/publicar cada nivel de dentro hacia fuera\n'
    printf '  3. Registrar cada hijo como submódulo (gitlink 160000) en su padre\n'
    printf '  4. Registrar %s como submódulo del principal y commit/push\n' "$top_seg"
    print_rule

    if (( DRY_RUN )); then
        # Reutiliza la simulación detallada de creación de cadena
        create_submodule_chain "$outer_root" "$start_dir" \
            || fail "falló la simulación de la cadena"
        printf '%s🧪 Además se registraría %s en el principal y se propondría commit/push.%s\n' \
            "$YELLOW" "$top_seg" "$RESET"
        printf '%s🧪 Fin de la simulación --split-submodule.%s\n\n' "$YELLOW" "$RESET"
        return 0
    fi

    confirm "Crear la cadena de submódulos para '$rel_path'" \
        || { printf '%s⏹ Cancelado.%s\n' "$YELLOW" "$RESET"; return 0; }

    # 1) Quitar del índice del monorepo (archivos siguen en disco)
    if (( tracked_top )); then
        printf '%s│%s Sacando del índice del principal: %s …\n' "$BLUE" "$RESET" "$top_seg"
        git -C "$outer_root" rm -r --cached -- "$top_seg" >/dev/null 2>&1 \
            || git -C "$outer_root" rm -r --cached -- "$rel_path" >/dev/null \
            || fail "no se pudo hacer git rm --cached en el principal"
    fi

    # 2–3) Misma lógica que el flujo normal al montar cadena sin registrar
    create_submodule_chain "$outer_root" "$start_dir" \
        || fail "no se pudo crear/publicar la cadena de submódulos"

    # 4) Commit (+ push) del principal con el gitlink del primer nivel
    git -C "$outer_root" add --force -- .gitmodules "$top_seg" 2>/dev/null || true
    if git -C "$outer_root" diff --cached --quiet; then
        printf '%sℹ El principal no tiene cambios pendientes tras el registro.%s\n' "$DIM" "$RESET"
    else
        commit_message=$(prompt_commit_message \
            "Split chain $rel_path into submodules · $(date '+%d/%m/%y %H:%M')")
        git -C "$outer_root" commit -m "$commit_message" \
            || fail "no se pudo crear el commit en el repo principal"
        printf '%s✅ Commit creado en el principal (%s)%s\n' \
            "$GREEN" "$(basename "$outer_root")" "$RESET"

        if confirm "¿Hacer push del principal '$(basename "$outer_root")' a origin?"; then
            branch=$(current_branch "$outer_root")
            [[ -n "$branch" ]] || fail "el principal está en detached HEAD"
            push_branch "$outer_root" "$branch" \
                || fail "no se pudo hacer push del principal"
            printf '%s✅ Principal sincronizado con GitHub%s\n' "$GREEN" "$RESET"
        else
            printf '%sℹ Commit del principal queda solo en local; haz push cuando quieras.%s\n' \
                "$DIM" "$RESET"
        fi
    fi

    printf '\n%s%s🎉 Cadena de submódulos lista%s\n' "$GREEN" "$BOLD" "$RESET"
    printf '%s  %s%s\n' "$DIM" "$chain_display" "$RESET"
    printf '%sComprueba:%s git -C %s ls-files -s %s\n' \
        "$DIM" "$RESET" "$outer_root" "$top_seg"
    printf '%s         %s git -C %s/%s ls-files -s  # niveles internos\n\n' \
        "$DIM" "$RESET" "$outer_root" "$top_seg"
    return 0
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

DRY_RUN=0
SPLIT_SUBMODULE=0
while (( $# > 0 )); do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=1
            shift
            ;;
        --split-submodule)
            SPLIT_SUBMODULE=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

command -v git >/dev/null 2>&1 || fail "no se encontró git en PATH"
command -v find >/dev/null 2>&1 || fail "no se encontró find en PATH"

START_DIR=$(pwd -P)
is_git_repo "$START_DIR" || fail "el directorio actual no pertenece a un repositorio Git"

current_root=$(git -C "$START_DIR" rev-parse --show-toplevel) \
    || fail "no se pudo determinar la raíz Git"
current_root=$(normalize_path "$current_root")

print_banner
print_rule

if (( DRY_RUN )); then
    printf '%s%s🧪 Modo simulación%s: no se ejecutarán add, commit ni push.\n' \
        "$YELLOW" "$BOLD" "$RESET"
    print_rule
fi

if (( SPLIT_SUBMODULE )); then
    split_submodule_folder "$START_DIR"
    exit $?
fi

parent_dir=$(dirname "$current_root")
outer_root=''

# --- Proyecto nuevo: carpeta dentro de un repo ya existente (p. ej. data_science_1
# bajo piscine_pedago_data_science). Si no es repo propio ni submódulo registrado,
# proponer crear la cadena bajo ese padre (o bajo el ancestro con origin).
# Esto debe ejecutarse AUNQUE el padre ya esté registrado en Outer Core; si no,
# el script publicaría solo el padre y trataría los archivos del hijo como suyos.
START_DIR_NORM=$(normalize_path "$START_DIR")
if [[ "$START_DIR_NORM" != "$current_root" ]] \
    && ! is_repository_root "$START_DIR_NORM" \
    && ! is_registered_submodule "$current_root" "$START_DIR_NORM"; then
    rel_from_current=${START_DIR_NORM#"$current_root"/}
    printf '%s%s🆕 Carpeta sin registrar como submódulo%s\n' "$YELLOW" "$BOLD" "$RESET"
    printf '%sCarpeta:%s %s\n' "$DIM" "$RESET" "$rel_from_current"
    printf '%sDentro del repo:%s %s\n' "$DIM" "$RESET" "$(basename "$current_root")"

    if repo_has_origin "$current_root"; then
        outer_root=$current_root
    else
        outer_root=$(find_ancestor_with_origin "$current_root" || true)
        [[ -n "$outer_root" ]] \
            || fail "no hay un repositorio con origin que pueda alojar el nuevo submódulo"
        printf '%sℹ El repo inmediato no tiene origin; se usará el ancestro:%s %s\n' \
            "$DIM" "$RESET" "$outer_root"
    fi

    create_submodule_chain "$outer_root" "$START_DIR_NORM" \
        || fail "no se pudo crear el submódulo desde la carpeta actual"
    if (( DRY_RUN )); then
        printf '\n%s🧪 Fin de la simulación de creación de submódulo.%s\n\n' "$YELLOW" "$RESET"
        exit 0
    fi
    current_root=$(git -C "$START_DIR_NORM" rev-parse --show-toplevel 2>/dev/null) \
        || fail "no se pudo resolver la raíz del submódulo recién creado"
    current_root=$(normalize_path "$current_root")
fi

# --- Resolver / crear la cadena de submódulos si aún no está registrada ---
if ! find_parent_repo "$current_root" >/dev/null 2>&1; then
    # Caso 1: estamos en un subdirectorio de un worktree (no en la raíz del repo)
    # y aún no se resolvió arriba (p. ej. rutas raras). Se mantiene como respaldo.
    if [[ "$START_DIR_NORM" != "$current_root" ]]; then
        outer_root=$(find_ancestor_with_origin "$current_root" || true)
        [[ -z "$outer_root" ]] && outer_root=$(find_enclosing_repo "$current_root" || true)
        [[ -n "$outer_root" ]] \
            || fail "no se encontró un repositorio con origin para crear la cadena"
        printf '%s%s🆕 Ruta anidada sin registrar%s: se intentará crear la cadena de submódulos.\n' \
            "$YELLOW" "$BOLD" "$RESET"
        create_submodule_chain "$outer_root" "$START_DIR_NORM" \
            || fail "no se creó el submódulo solicitado"
        if (( DRY_RUN )); then
            printf '\n%s🧪 Fin de la simulación de creación de cadena.%s\n\n' "$YELLOW" "$RESET"
            exit 0
        fi
        current_root=$(git -C "$START_DIR_NORM" rev-parse --show-toplevel 2>/dev/null) \
            || fail "no se pudo resolver la raíz del submódulo recién creado"
        current_root=$(normalize_path "$current_root")
    # Caso 2: repo sin commits (submódulo a medias).
    elif ! git -C "$current_root" rev-parse HEAD >/dev/null 2>&1; then
        parent_root=$(find_enclosing_repo "$current_root") \
            || fail "no se encontró un repositorio padre para reanudar el nuevo submódulo"
        create_submodule_from_current_directory "$parent_root" "$current_root" \
            || fail "no se pudo reanudar el submódulo solicitado"
        if (( DRY_RUN )); then
            printf '\n%s🧪 Fin de la simulación de creación de submódulo.%s\n\n' "$YELLOW" "$RESET"
            exit 0
        fi
    # Caso 3: el directorio actual ES un repo Git, pero NO está registrado
    # como submódulo del padre (caso típico al montar proyectos nuevos
    # localmente antes de pushear Outer_Core).
    else
        immediate_parent=$(dirname "$current_root")
        outer_root=$(find_ancestor_with_origin "$current_root" || true)
        [[ -z "$outer_root" ]] && outer_root=$(find_enclosing_repo "$current_root" || true)

        # Si el padre inmediato es repo PERO no tiene origin (repo local a medias),
        # hay que montar la cadena desde el ancestro que sí tiene origin
        # (p. ej. 42_outer_core), no intentar registrar solo en el padre huérfano.
        if is_repository_root "$immediate_parent" && repo_has_origin "$immediate_parent"; then
            printf '%s%s🆕 Repo Git detectado sin registrar en el padre%s\n' \
                "$YELLOW" "$BOLD" "$RESET"
            printf '%sHijo:%s %s\n' "$DIM" "$RESET" "$current_root"
            printf '%sPadre:%s %s\n' "$DIM" "$RESET" "$immediate_parent"
            create_submodule_from_current_directory "$immediate_parent" "$current_root" \
                || fail "no se pudo registrar el submódulo en el repositorio padre"
            if (( DRY_RUN )); then
                printf '\n%s🧪 Fin de la simulación de registro de submódulo.%s\n\n' "$YELLOW" "$RESET"
                exit 0
            fi
        elif [[ -n "$outer_root" ]]; then
            printf '%s%s🆕 Cadena de carpetas/repos sin registrar como submódulos%s\n' \
                "$YELLOW" "$BOLD" "$RESET"
            printf '%sDesde (hijo):%s %s\n' "$DIM" "$RESET" "$current_root"
            printf '%sHasta (ancestro con origin):%s %s\n' "$DIM" "$RESET" "$outer_root"
            if is_repository_root "$immediate_parent" && ! repo_has_origin "$immediate_parent"; then
                printf '%sℹ El padre inmediato (%s) es un repo local sin origin; se incluirá en la cadena.%s\n' \
                    "$DIM" "$(basename "$immediate_parent")" "$RESET"
            fi
            create_submodule_chain "$outer_root" "$current_root" \
                || fail "no se pudo reorganizar la cadena de submódulos"
            if (( DRY_RUN )); then
                printf '\n%s🧪 Fin de la simulación de reorganización.%s\n\n' "$YELLOW" "$RESET"
                exit 0
            fi
            current_root=$(normalize_path "$current_root")
        else
            fail "el repositorio actual no está dentro de otro repo Git con origin; no hay cadena que publicar.
Ejecuta el script desde un proyecto bajo 42_outer_core (u otro monorepo con remoto origin)."
        fi
    fi
fi

# Tras intentar registrar/crear, debe existir al menos un padre registrado.
find_parent_repo "$current_root" >/dev/null \
    || fail "el repositorio actual sigue sin ser un submódulo registrado.
Comprueba con:
  git -C \"$(dirname "$current_root")\" config --file .gitmodules --get-regexp path
  ls -la \"$current_root/.git\"
y vuelve a ejecutar el script desde el submódulo más interno."

repos=()
while :; do
    repos+=("$current_root")
    parent_root=$(find_parent_repo "$current_root" || true)
    [[ -z "$parent_root" ]] && break
    current_root=$parent_root
done

printf '%s%s📦 Cadena de publicación%s %s(de dentro hacia fuera)%s\n' "$BOLD" "$CYAN" "$RESET" "$DIM" "$RESET"
for repo in "${repos[@]}"; do
    printf '  %s▸%s %s%s%s\n' "$GREEN" "$RESET" "$BOLD" "$(basename "$repo")" "$RESET"
done
print_rule
TOTAL_REPOS=${#repos[@]}
print_progress 0 "$TOTAL_REPOS" 'Listo para comenzar'

if (( DRY_RUN )); then
    printf '\n%s%s🧪 Modo simulación%s: cadena detectada, no se modifica nada.\n\n' \
        "$YELLOW" "$BOLD" "$RESET"
    exit 0
fi

for repo_index in "${!repos[@]}"; do
    repo=${repos[$repo_index]}
    repo_name=$(basename "$repo")
    branch=$(current_branch "$repo")
    repo_number=$((repo_index + 1))

    [[ -n "$branch" ]] || fail "$repo_name está en detached HEAD; cambia a una rama antes de continuar"

    if ! confirm "Publicar '$repo_name' en '$branch'?"; then
        printf '%s⏹ Proceso detenido antes de actualizar %s.%s\n' "$YELLOW" "$repo_name" "$RESET"
        exit 0
    fi

    printf '\n%s%s┌─ [%s/%s] %s · %s%s%s%s\n' \
        "$BLUE" "$BOLD" "$repo_number" "$TOTAL_REPOS" "$repo_name" "$BOLD" "$branch" "$RESET" "$BLUE"
    printf '%s│%s %s🔍 Preparando cambios%s\n' "$BLUE" "$RESET" "$CYAN" "$RESET"

    child_path=''
    if (( repo_index > 0 )); then
        child_path=${repos[$((repo_index - 1))]#"$repo"/}
    else
        handle_large_files "$repo" \
            || fail "no se pudieron excluir los archivos grandes; publicación cancelada"
        handle_ignored_tracked_files "$repo" \
            || fail "no se pudieron gestionar los archivos ignorados aún versionados"
    fi

    run_with_progress "Preparando el índice de $repo_name" \
        stage_repository "$repo" "$child_path" \
        || fail "no se pudieron preparar los cambios de $repo_name"

    if git -C "$repo" diff --cached --quiet; then
        printf '%s│%s %sℹ Sin cambios nuevos; se comprueba el remoto.%s\n' "$BLUE" "$RESET" "$DIM" "$RESET"
    else
        # Marca temporal local (DD/MM/AA HH:MM); el usuario puede personalizar el mensaje
        commit_message=$(prompt_commit_message \
            "Update $repo_name · $(date '+%d/%m/%y %H:%M')")
        run_with_progress "Creando el commit de $repo_name" \
            git -C "$repo" commit -m "$commit_message" \
            || fail "no se pudo crear el commit de $repo_name (¿user.name / user.email?)"
    fi

    printf '%s│%s %s☁ Publicando en GitHub...%s\n' "$BLUE" "$RESET" "$CYAN" "$RESET"
    run_with_progress "Sincronizando $repo_name con GitHub" \
        push_branch "$repo" "$branch" \
        || fail "no se pudo subir $repo_name (si el remoto está adelantado, haz pull/rebase y reintenta)"
    printf '%s└─%s %s✅ Publicación completada%s\n' "$BLUE" "$RESET" "$GREEN" "$RESET"
    print_progress "$repo_number" "$TOTAL_REPOS" "$repo_name completado"
done

print_rule
printf '%s%s🎉 Publicación completada: %s/%s repositorios.%s\n\n' \
    "$GREEN" "$BOLD" "$TOTAL_REPOS" "$TOTAL_REPOS" "$RESET"
