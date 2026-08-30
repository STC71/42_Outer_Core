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
    printf '%s%s║           🚀  ACTUALIZADOR DE REPOSITORIOS 42              ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╠════════════════════════════════════════════════════════════╣%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s║     Implementación de sternero estudiante de 42 Málaga     ║%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%s%s╚════════════════════════════════════════════════════════════╝%s\n' "$BOLD" "$BLUE" "$RESET"
    printf '%sGestiona la publicación coordinada de una cadena de repositorios Git.%s\n' "$DIM" "$RESET"
    printf '%s• Parte del submódulo (carpeta) desde el que se ejecuta.%s\n' "$DIM" "$RESET"
    printf '%s• Si aún no existe como submódulo, propone crear el submódulo con confirmación.%s\n' "$DIM" "$RESET"
    printf '%s• Si falta gh, propone instalarlo localmente sin permisos de sudo.%s\n' "$DIM" "$RESET"
    printf '%s• Consulta .gitmodules para localizar únicamente sus repositorios padre.%s\n' "$DIM" "$RESET"
    printf '%s• Actualiza de dentro hacia fuera: submódulo, padres y repositorio principal.%s\n' "$DIM" "$RESET"
    printf '%s• Mantiene fuera los repositorios hermanos y las carpetas no registradas.%s\n' "$DIM" "$RESET"
}

print_progress() {
    local current=$1
    local total=$2
    local label=$3
    local width=28
    local filled=$((current * width / total))
    local empty=$((width - filled))
    local bar

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
    local log_file
    local command_pid
    local result
    local spinner='|/-\\'
    local frame=0

    log_file=$(mktemp) || return 1
    "$@" >"$log_file" 2>&1 &
    command_pid=$!
    while kill -0 "$command_pid" 2>/dev/null; do
        printf '\r%s%s%s %s%s%s' "$CYAN" "${spinner:frame % 4:1}" "$RESET" "$DIM" "$label" "$RESET"
        frame=$((frame + 1))
        sleep 0.1
    done
    wait "$command_pid"
    result=$?
    if (( result != 0 )); then
        printf '\r%s❌%s %s\n' "$RED" "$RESET" "$label"
        cat "$log_file" >&2
        rm -f "$log_file"
        return "$result"
    fi
    printf '\r%s✅%s %s\n' "$GREEN" "$RESET" "$label"
    rm -f "$log_file"
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

choose_visibility() {
    local answer

    while :; do
        printf '%s%s🔐 Visibilidad del repositorio%s %s[p]Privado / [u]Público (por defecto: privado):%s ' \
            "$YELLOW" "$BOLD" "$RESET" "$DIM" "$RESET"
        IFS= read -r answer || return 1
        case "$answer" in
            ''|p|P|privado|PRIVADO)
                REPOSITORY_VISIBILITY='private'
                REPOSITORY_VISIBILITY_LABEL='privado'
                return 0
                ;;
            u|U|publico|PUBLICO|public)
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

handle_large_files() {
    local child_root=$1
    local file_path
    local relative_file
    local ignore_file="$child_root/.gitignore"
    local file_size
    local large_files=()

    while IFS= read -r file_path; do
        file_size=$(stat -c '%s' "$file_path")
        if (( file_size > 100000000 )); then
            large_files+=("$file_path")
        fi
    done < <(find "$child_root" -type f -not -path "$child_root/.git/*" -print)
    (( ${#large_files[@]} > 0 )) || return 0

    printf '\n%s⚠ Se han encontrado %s archivos que superan el límite de 100 MB de GitHub:%s\n' \
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
        done
        printf '%s✅ Archivos excluidos mediante %s%s\n' "$GREEN" "$ignore_file" "$RESET"
        return 0
    fi
    printf '%s⏹ Publicación cancelada: no se excluyeron los archivos grandes.%s\n' "$RED" "$RESET" >&2
    return 1
}

ensure_github_cli() {
    local gh_path
    local architecture
    local version
    local archive
    local install_dir
    local temporary_dir

    if command -v gh >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/gh" ]]; then
        gh_path=$(command -v gh || printf '%s/.local/bin/gh' "$HOME")
        GH_BIN="$gh_path"
        export PATH="$(dirname "$gh_path"):$PATH"
        printf '%s%s🔎 GitHub CLI encontrado%s: %s\n' "$CYAN" "$BOLD" "$RESET" "$gh_path"
        confirm "Continuar usando esta instalación de gh" || return 1
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
        archive="$temporary_dir/gh.tar.gz"
        mkdir -p "$install_dir" || fail "no se pudo crear $install_dir"
        curl -fL "https://github.com/cli/cli/releases/download/v$version/gh_${version}_linux_${architecture}.tar.gz" \
            -o "$archive" || fail "no se pudo descargar gh"
        tar -xzf "$archive" -C "$temporary_dir" || fail "no se pudo extraer gh"
        cp "$temporary_dir/gh_${version}_linux_${architecture}/bin/gh" "$install_dir/gh" \
            || fail "no se pudo instalar gh en $install_dir"
        chmod 755 "$install_dir/gh"
        GH_BIN="$install_dir/gh"
        export PATH="$install_dir:$PATH"
        printf '%s✅ GitHub CLI %s instalado en %s%s\n' "$GREEN" "$version" "$install_dir" "$RESET"
    fi

    GH_BIN=${GH_BIN:-$(command -v gh)}
    if ! "$GH_BIN" auth status >/dev/null 2>&1; then
        printf '\n%s%s🔑 GitHub CLI no está autenticado%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sSe mostrará un código de un solo uso para completar el acceso.%s\n' "$DIM" "$RESET"
        printf '%sAbre manualmente https://github.com/login/device en tu navegador.%s\n' "$DIM" "$RESET"
        confirm "Iniciar ahora la autenticación de GitHub" \
            || fail "autenticación cancelada; no se puede crear el submódulo remoto"
        "$GH_BIN" auth login \
            --hostname github.com \
            --git-protocol ssh \
            --skip-ssh-key \
            --web \
            || fail "la autenticación de GitHub no se completó"
        "$GH_BIN" auth status >/dev/null 2>&1 \
            || fail "gh sigue sin estar autenticado después del inicio de sesión"
        printf '%s✅ GitHub CLI autenticado correctamente%s\n' "$GREEN" "$RESET"
    else
        printf '%s✅ Sesión de GitHub ya autenticada%s\n' "$GREEN" "$RESET"
    fi
}

create_submodule_from_current_directory() {
    local parent_root=$1
    local child_root=$2
    local relative_path
    local module_name
    local owner
    local remote_name
    local remote_url
    local child_branch
    local file_path
    local file_size
    local repository_visibility

    relative_path=${child_root#"$parent_root"/}
    module_name=$(basename "$child_root")
    owner=$(git -C "$parent_root" remote get-url origin \
        | sed -nE 's#.*github\.com[:/]([^/]+)/.*#\1#p' | head -n 1)
    [[ -n "$owner" ]] || fail "no se pudo determinar el propietario de GitHub desde el remoto del repositorio padre"

    remote_name=$module_name
    [[ "$remote_name" == 42_* ]] || remote_name="42_$remote_name"
    remote_url="git@github.com:$owner/$remote_name.git"

    if (( DRY_RUN )); then
        printf '\n%s%s🧪 Se podría crear el submódulo%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "$relative_path"
        printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
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

    if [[ -e "$child_root/.git" ]]; then
        git -C "$child_root" rev-parse HEAD >/dev/null 2>&1 \
            && fail "la carpeta ya contiene un submodulo con commits"
        git -C "$child_root" reset -q \
            || fail "no se pudo limpiar el estado parcial del nuevo submodulo"
    else
        git -C "$child_root" init -b main >/dev/null \
            || fail "no se pudo inicializar el nuevo submodulo"
    fi
    git -C "$child_root" add -A \
        || fail "no se pudieron preparar los archivos del nuevo submodulo"

    git -C "$child_root" diff --cached --quiet \
        && fail "el nuevo submodulo no contiene archivos para publicar"

    while IFS= read -r file_path; do
        file_size=$(stat -c '%s' "$child_root/$file_path")
        (( file_size <= 100000000 )) \
            || fail "el archivo '$relative_path/$file_path' supera el limite de 100 MB de GitHub"
    done < <(git -C "$child_root" diff --cached --name-only)

    git -C "$child_root" commit -m "Initial commit" >/dev/null \
        || fail "no se pudo crear el commit inicial del nuevo submodulo"
    "$GH_BIN" repo create "$owner/$remote_name" "--$repository_visibility" >/dev/null \
        || fail "no se pudo crear el repositorio remoto $owner/$remote_name"
    git -C "$child_root" remote add origin "$remote_url" \
        || fail "no se pudo configurar el remoto del nuevo submodulo"
    child_branch=$(git -C "$child_root" symbolic-ref --short HEAD)
    git -C "$child_root" push -u origin "$child_branch" >/dev/null \
        || fail "no se pudo publicar el nuevo submodulo"

    git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        "submodule.$relative_path.path" "$relative_path"
    git -C "$parent_root" config --file "$parent_root/.gitmodules" \
        "submodule.$relative_path.url" "$remote_url"
    git -C "$parent_root" add .gitmodules "$relative_path" \
        || fail "no se pudo registrar el nuevo submodulo en el repositorio padre"
    printf '%s✅ Submódulo creado y publicado: %s%s\n' "$GREEN" "$remote_name" "$RESET"
}

create_submodule_chain() {
    local outer_root=$1
    local start_root=$2
    local relative_path
    local owner
    local -a path_parts
    local level
    local target_root
    local child_root
    local child_name
    local module_name
    local remote_name
    local remote_url
    local file_path
    local file_size
    local child_branch
    local repository_visibility

    relative_path=${start_root#"$outer_root"/}
    IFS='/' read -r -a path_parts <<< "$relative_path"
    owner=$(git -C "$outer_root" remote get-url origin \
        | sed -nE 's#.*github\.com[:/]([^/]+)/.*#\1#p' | head -n 1)
    [[ -n "$owner" ]] || fail "no se pudo determinar el propietario de GitHub desde el remoto del repositorio principal"

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
            continue
        fi

        remote_name=${path_parts[$level]}
        [[ "$remote_name" == 42_* ]] || remote_name="42_$remote_name"
        remote_url="git@github.com:$owner/$remote_name.git"

        printf '\n%s%s🧱 Nivel de submódulo detectado%s\n' "$YELLOW" "$BOLD" "$RESET"
        printf '%sRuta local:%s %s\n' "$DIM" "$RESET" "${target_root#"$outer_root"/}"
        printf '%sRepositorio remoto:%s %s/%s\n' "$DIM" "$RESET" "$owner" "$remote_name"
        if [[ -n "$child_name" ]]; then
            printf '%sIncluye el submódulo hijo:%s %s\n' "$DIM" "$RESET" "$child_name"
        fi

        if (( DRY_RUN )); then
            continue
        fi

        choose_visibility || fail "no se pudo seleccionar la visibilidad del repositorio"
        repository_visibility=$REPOSITORY_VISIBILITY
        printf '%sVisibilidad seleccionada:%s %s\n' "$DIM" "$RESET" "$REPOSITORY_VISIBILITY_LABEL"

        if [[ -z "$child_name" ]]; then
            handle_large_files "$target_root" \
                || fail "no se pudieron excluir los archivos grandes; publicación cancelada"
        fi

        if [[ -e "$target_root/.git" ]]; then
            git -C "$target_root" reset -q \
                || fail "no se pudo limpiar el repositorio parcial"
        else
            git -C "$target_root" init -b main >/dev/null \
                || fail "no se pudo inicializar el submodulo"
        fi

        if [[ -n "$child_name" ]]; then
            child_remote_name=$child_name
            [[ "$child_remote_name" == 42_* ]] || child_remote_name="42_$child_remote_name"
            if is_repository_root "$child_root" \
                && git -C "$child_root" remote get-url origin >/dev/null 2>&1; then
                child_remote_url=$(git -C "$child_root" remote get-url origin)
                printf '%s✅ Reutilizando repositorio hijo: %s%s\n' "$GREEN" "$child_remote_url" "$RESET"
                git -C "$target_root" config --file "$target_root/.gitmodules" \
                    "submodule.$child_name.path" "$child_name"
                git -C "$target_root" config --file "$target_root/.gitmodules" \
                    "submodule.$child_name.url" "$child_remote_url"
                git -C "$target_root" add .gitmodules "$child_name" \
                    || fail "no se pudo preparar el submódulo hijo"
            else
                git -C "$target_root" config --file "$target_root/.gitmodules" \
                    "submodule.$child_name.path" "$child_name"
                git -C "$target_root" config --file "$target_root/.gitmodules" \
                    "submodule.$child_name.url" "git@github.com:$owner/$child_remote_name.git"
                git -C "$target_root" add .gitmodules "$child_name" \
                    || fail "no se pudo preparar el submódulo hijo"
            fi
        else
            git -C "$target_root" add -A \
                || fail "no se pudieron preparar los archivos del submódulo"
        fi

        git -C "$target_root" diff --cached --quiet \
            && fail "el submódulo no contiene cambios para publicar"
        git -C "$target_root" commit -m "Initial commit" >/dev/null \
            || fail "no se pudo crear el commit del submódulo"
        if [[ -z "$child_name" ]] || ! is_repository_root "$child_root" || ! git -C "$child_root" remote get-url origin >/dev/null 2>&1; then
            "$GH_BIN" repo create "$owner/$remote_name" "--$repository_visibility" >/dev/null \
                || fail "no se pudo crear el repositorio remoto $owner/$remote_name"
        fi
        git -C "$target_root" remote add origin "$remote_url" \
            || fail "no se pudo configurar el remoto del submódulo"
        child_branch=$(git -C "$target_root" symbolic-ref --short HEAD)
        git -C "$target_root" push -u origin "$child_branch" >/dev/null \
            || fail "no se pudo publicar el submódulo"
        printf '%s✅ Nivel publicado: %s%s\n' "$GREEN" "$remote_name" "$RESET"
    done

    if (( ! DRY_RUN )); then
        git -C "$outer_root" config --file "$outer_root/.gitmodules" \
            --remove-section "submodule.$relative_path" 2>/dev/null || true
        git -C "$outer_root" reset -q -- "$relative_path" 2>/dev/null || true
        module_name=${path_parts[0]}
        remote_name=$module_name
        [[ "$remote_name" == 42_* ]] || remote_name="42_$remote_name"
        remote_url="git@github.com:$owner/$remote_name.git"
        git -C "$outer_root" config --file "$outer_root/.gitmodules" \
            "submodule.$module_name.path" "$module_name"
        git -C "$outer_root" config --file "$outer_root/.gitmodules" \
            "submodule.$module_name.url" "$remote_url"
        git -C "$outer_root" add .gitmodules "$module_name" \
            || fail "no se pudo registrar el submódulo principal"
    fi
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
    local child_top_level

    git -C "$repo" reset -q || return 1
    child_top_level=${child_path%%/*}
    while IFS= read -r top_level_path; do
        [[ "$top_level_path" == ".git" ]] && continue
        if [[ -f "$repo/$top_level_path" || -L "$repo/$top_level_path" ]]; then
            git -C "$repo" add -A -- "$top_level_path" || return 1
        elif [[ -n "$child_path" && "$top_level_path" == "$child_top_level" ]]; then
            git -C "$repo" add -A -- "$child_path" || return 1
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

find_enclosing_repo() {
    local child_root=$1
    local candidate
    local candidate_root

    candidate=$(dirname "$child_root")
    while [[ "$candidate" != "/" ]]; do
        candidate_root=$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -n "$candidate_root" && "$(realpath "$candidate_root")" != "$child_root" ]]; then
            printf '%s\n' "$(realpath "$candidate_root")"
            return 0
        fi
        candidate=$(dirname "$candidate")
    done
    return 1
}

is_git_repo() {
    git -C "$1" rev-parse --show-toplevel >/dev/null 2>&1
}

is_repository_root() {
    local repository_root

    repository_root=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null || true)
    [[ -n "$repository_root" && "$(realpath "$repository_root")" == "$(realpath "$1")" ]]
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

print_banner
print_rule

parent_dir=$(dirname "$current_root")
outer_root=''
if [[ "$START_DIR" != "$current_root" ]]; then
    if ! is_repository_root "$parent_dir"; then
        outer_root=$(find_enclosing_repo "$current_root" || printf '%s' "$current_root")
        create_submodule_chain "$outer_root" "$START_DIR" \
            || fail "no se creo el submodulo solicitado"
    fi
    if (( DRY_RUN )); then
        exit 0
    fi
    current_root=$START_DIR
elif ! git -C "$current_root" rev-parse HEAD >/dev/null 2>&1; then
    parent_root=$(find_enclosing_repo "$current_root") \
        || fail "no se encontro un repositorio padre para reanudar el nuevo submodulo"
    create_submodule_from_current_directory "$parent_root" "$current_root" \
        || fail "no se pudo reanudar el submodulo solicitado"
    if (( DRY_RUN )); then
        exit 0
    fi
elif ! is_repository_root "$parent_dir"; then
    outer_root=$(find_enclosing_repo "$current_root" || true)
    if [[ -n "$outer_root" ]]; then
        create_submodule_chain "$outer_root" "$START_DIR" \
            || fail "no se pudo reorganizar la cadena de submodulos"
        if (( DRY_RUN )); then
            exit 0
        fi
    fi
fi

find_parent_repo "$current_root" >/dev/null \
    || fail "el repositorio actual no es un submodulo registrado; ejecuta el script desde un submodulo."

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
    run_with_progress "Preparando el índice de $repo_name" \
        stage_repository "$repo" "$child_path" \
        || fail "no se pudieron preparar los cambios de $repo_name"

    if git -C "$repo" diff --cached --quiet; then
        printf '%s│%s %sℹ Sin cambios nuevos; se comprueba el remoto.%s\n' "$BLUE" "$RESET" "$DIM" "$RESET"
    else
        commit_message="Update $repo_name"
        run_with_progress "Creando el commit de $repo_name" \
            git -C "$repo" commit -m "$commit_message" \
            || fail "no se pudo crear el commit de $repo_name"
    fi

    printf '%s│%s %s☁ Publicando en GitHub...%s\n' "$BLUE" "$RESET" "$CYAN" "$RESET"
    run_with_progress "Sincronizando $repo_name con GitHub" \
        git -C "$repo" push \
        || fail "no se pudo subir $repo_name"
    printf '%s└─%s %s✅ Publicación completada%s\n' "$BLUE" "$RESET" "$GREEN" "$RESET"
    print_progress "$repo_number" "$TOTAL_REPOS" "$repo_name completado"
done

print_rule
printf '%s%s🎉 Publicación completada: %s/%s repositorios.%s\n\n' "$GREEN" "$BOLD" "$TOTAL_REPOS" "$TOTAL_REPOS" "$RESET"
