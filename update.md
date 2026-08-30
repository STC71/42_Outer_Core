# 🚀 UPDATE.md — Actualizador de repositorios 42

<div align="center">

![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Git](https://img.shields.io/badge/Git-Submodules-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub CLI](https://img.shields.io/badge/GitHub-CLI-181717?style=for-the-badge&logo=github&logoColor=white)

**Script de publicación coordinada de cadenas de submódulos Git**  
*Implementación de sternero · estudiante de 42 Málaga*

[Objetivo](#-1-objetivo--por-qué-existe-este-script) ·
[Idea simple](#-2-la-idea-en-lenguaje-cotidiano) ·
[Conceptos](#-3-conceptos-clave-antes-de-tocar-el-teclado) ·
[Uso](#-4-cómo-usarlo-paso-a-paso) ·
[Funcionamiento](#-5-funcionamiento-interno-detallado) ·
[Comportamiento](#-6-comportamiento-esperable-y-casos-reales) ·
[Seguridad](#-7-seguridad-y-decisiones-conscientes) ·
[FAQ](#-8-preguntas-frecuentes)

</div>

---

## 📖 1. Objetivo — ¿Por qué existe este script?

En el campus de **42** es habitual organizar el trabajo en **varios repositorios anidados**:

```text
42_Outer_Core                          ← portfolio / monorepo principal
 └── piscine_pedago_data_science       ← “carpeta temática” (también un repo)
      └── data_science_0_creation_db   ← proyecto concreto (también un repo)
```

Cada nivel puede (y suele) vivir en **GitHub por separado**. Cuando terminas una tarea en el proyecto más interno, no basta con un único `git push`: hay que:

1. Guardar y subir los cambios del **proyecto interno**.
2. Actualizar el **repo del medio** para que “apunte” al commit nuevo del hijo.
3. Actualizar el **repo principal** para que “apunte” al commit nuevo del medio.

Hacerlo a mano es lento, fácil de olvidar un paso y propenso a errores (archivos enormes, submódulos mal registrados, hermanos que no debían tocarse…).

**`update.sh` automatiza exactamente esa cadena**: publica **de dentro hacia fuera**, pregunta confirmación en cada nivel, crea repos en GitHub si faltan, registra submódulos y evita mezclar carpetas que no pertenecen a la cadena.

> **En una frase:**  
> *Desde la carpeta del proyecto en el que estás trabajando, el script sube tus cambios hasta GitHub y actualiza todos los “contenedores” padres de forma ordenada y segura.*

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## 🏠 2. La idea en lenguaje cotidiano

Imagina que guardas tus apuntes en **cajas rusas** (una dentro de otra):

| Caja | En el mundo real | En tu disco |
|------|------------------|-------------|
| Caja pequeña | El cuaderno del ejercicio de hoy | `data_science_0_creation_db` |
| Caja mediana | La carpeta de la asignatura | `piscine_pedago_data_science` |
| Caja grande | El armario de todo el curso | `42_outer_core` |

Cada caja tiene su **etiqueta en la nube** (un repositorio en GitHub).

Si cambias una página del cuaderno pequeño:

1. Hay que **fotografiar** el cuaderno actualizado y colgar la foto en su estantería de la nube.
2. En la caja mediana hay que **cambiar la nota** que dice “el cuaderno está en la versión X” por “ahora está en la versión Y”.
3. En el armario grande hay que **actualizar la nota** de la caja mediana.

Si solo actualizas el cuaderno y te olvidas de las notas de las cajas grandes, quien abra el armario desde Internet seguirá viendo la versión antigua.

**Eso es lo que hace el script:** actualiza el cuaderno y todas las notas de las cajas hacia fuera, en el orden correcto, preguntándote en cada paso: *“¿Publicamos esta caja?”*.

### Analogía del ascensor

Piensa en un edificio:

```text
Piso 2  →  proyecto (data_science_0_creation_db)
Piso 1  →  piscina / tema (piscine_pedago_data_science)
Planta  →  portfolio (42_outer_core)
```

El script **entra por el piso en el que estás**, baja el ascensor piso a piso y en cada parada:

- Prepara el “paquete” (staging).
- Lo sella (commit) si hay cambios.
- Lo envía a la nube (push).

Nunca empieza por la planta baja sin haber cerrado antes los pisos de arriba: eso dejaría el edificio inconsistente.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## 🧩 3. Conceptos clave (antes de tocar el teclado)

No hace falta ser experto en Git, pero sí entender estas piezas. Cada una lleva un ejemplo cotidiano.

### 3.1 Repositorio Git

Es la **caja con historial**. No solo guarda archivos: guarda *versiones* de esos archivos a lo largo del tiempo (como un historial de cambios de un documento de Google Docs, pero local y profesional).

### 3.2 Commit

Es una **foto congelada** del estado del proyecto en un momento dado, con un mensaje (“Update data_science_0_creation_db”).  
Si el repositorio es un diario, el commit es **una entrada del diario**.

### 3.3 Remoto (`origin`) y GitHub

El remoto es la **copia en la nube**. Casi siempre se llama `origin` y apunta a una URL de GitHub.  
`git push` = “envía mis fotos nuevas a la nube”.

### 3.4 Submódulo

Un submódulo es **un repositorio completo metido dentro de otro**, pero el padre **no copia todos los archivos del hijo**. Solo guarda:

- la ruta de la carpeta, y  
- el **identificador exacto del commit** del hijo (como un código de barras de la foto concreta).

Eso se ve en el índice de Git con el modo especial **`160000`** (un “gitlink”).

**Analogía:** en el inventario del armario no guardas el cuaderno entero; guardas una ficha que dice *“cuaderno de mates, edición del 30 de agosto”*. Si alguien clona el armario, usa esa ficha para **descargar** el cuaderno correcto.

El archivo **`.gitmodules`** del padre es la lista de fichas:

```ini
[submodule "piscine_pedago_data_science"]
        path = piscine_pedago_data_science
        url = https://github.com/STC71/42_piscine_pedago_data_science.git
```

### 3.5 Cadena de submódulos

Varios niveles anidados, cada uno registrado en el padre inmediato:

```text
42_Outer_Core
 └── [submódulo] piscine_pedago_data_science
      └── [submódulo] data_science_0_creation_db
```

### 3.6 Publicar “de dentro hacia fuera”

Orden obligatorio:

```text
1) hijo más interno  →  commit + push
2) padre             →  actualiza el gitlink del hijo + commit + push
3) abuelo            →  actualiza el gitlink del padre + commit + push
```

Si se hiciera al revés, el padre apuntaría a un commit del hijo que **aún no existe en GitHub**.

### 3.7 GitHub CLI (`gh`)

Herramienta oficial de GitHub en la terminal. El script la usa para:

- comprobar si ya has iniciado sesión,
- crear repositorios nuevos,
- respetar privacidad (privado / público).

Si no está instalada, puede proponer instalarla en `~/.local/bin` **sin sudo**.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## ▶️ 4. Cómo usarlo (paso a paso)

### 4.1 Requisitos

| Requisito | Para qué |
|-----------|----------|
| `git` | Operaciones de versionado |
| `find` | Recorrer archivos (archivos grandes, staging) |
| Cuenta de GitHub | Publicar |
| `gh` (opcional al inicio) | El script puede instalarlo / autenticarlo |
| Ejecución **desde un proyecto** que viva bajo el monorepo | Detectar la cadena de padres |

### 4.2 Ubicación típica del script

```text
42_outer_core/
 ├── update.sh          ← aquí suele vivir
 ├── UPDATE.md           ← esta guía
 ├── .gitmodules
 ├── piscine_pedago_data_science/
 │    └── data_science_0_creation_db/   ← trabajas aquí
 └── …
```

### 4.3 Primera vez: permisos

```bash
chmod +x update.sh
```

### 4.4 Simulación (recomendado siempre la primera vez en un repo nuevo)

```bash
cd piscine_pedago_data_science/data_science_0_creation_db
../../update.sh --dry-run
```

**No escribe commits ni hace push.** Solo muestra qué cadena detecta y qué haría.

### 4.5 Publicación real

```bash
../../update.sh
```

Responde a las preguntas:

| Pregunta | Significado |
|----------|-------------|
| `Crear remoto y publicar este nivel… [s/N]` | Crear el repo en GitHub si aún no existe |
| `Visibilidad [p]Privado / [u]Público` | Privacidad del repo nuevo (por defecto privado) |
| `Añadir archivos grandes al .gitignore…` | Evitar el rechazo de GitHub (> 100 MB) |
| `Publicar 'nombre' en 'main'? [s/N]` | Confirmar commit + push de ese nivel |

Respuestas afirmativas aceptadas: `s`, `si`, `sí`, `y`, `yes` (mayúsculas/minúsculas da igual).

### 4.6 Ayuda

```bash
./update.sh --help
```

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## ⚙️ 5. Funcionamiento interno (detallado)

Esta sección describe **qué hace el código por dentro**, en el orden real de ejecución.

### 5.1 Arranque y entorno

1. **`set -u` y `pipefail`** — Si se usa una variable sin definir o falla un comando en una tubería, el script se detiene en lugar de seguir “a ciegas”.
2. **Colores** — Solo si la salida es una terminal interactiva (`-t 1`). En logs redirigidos, el texto sale limpio.
3. **Trap de limpieza** — Al salir, borra ficheros temporales (`mktemp`) registrados en `CLEANUP_PATHS`.

### 5.2 Detección de la posición actual

```text
START_DIR     = carpeta desde la que ejecutaste el script (pwd -P)
current_root  = raíz del repositorio Git que contiene START_DIR
```

Ejemplo:

```text
Estás en:  .../data_science_0_creation_db/src
START_DIR: .../data_science_0_creation_db/src
current_root: .../data_science_0_creation_db   ← raíz del repo
```

### 5.3 ¿Ya es un submódulo registrado?

El script pregunta: *“¿Existe un padre Git que tenga esta carpeta en su `.gitmodules`?”*  
Función clave: **`find_parent_repo`**.

- **Sí** → construye la cadena de publicación y pasa a la fase de commits/pushes.
- **No** → entra en modo **creación / registro** (casos siguientes).

### 5.4 Casos cuando aún no está registrado

#### Caso A — Estás dentro de un worktree, no en la raíz

Ejemplo: ejecutaste desde `proyecto/src` y `proyecto` aún no es submódulo.  
→ Intenta crear la cadena desde el monorepo contenedor hasta esa ruta.

#### Caso B — Repo sin commits (submódulo a medias)

Había un `git init` pero aún no hay historial.  
→ Completa la publicación y el registro en el padre.

#### Caso C — Repo Git local no registrado (el más habitual al montar proyectos nuevos)

Aquí el script es especialmente cuidadoso:

1. Mira el **padre inmediato** (`dirname` de la raíz actual).
2. Si ese padre es un repo **y tiene `origin`** → registra el hijo ahí (`create_submodule_from_current_directory`).
3. Si el padre es un repo **pero no tiene `origin`** (repo local “huérfano”) → **no se queda ahí**.  
   Sube con **`find_ancestor_with_origin`** hasta encontrar un ancestro con remoto (casi siempre `42_outer_core`) y monta la **cadena completa** (`create_submodule_chain`).

> **Detalle importante:** `find_ancestor_with_origin` **nunca** devuelve el propio proyecto actual, aunque este ya tenga `origin` en GitHub. Si no, confundiría el “cuaderno” con el “armario”.

### 5.5 Creación de cadena (`create_submodule_chain`)

Dada una ruta relativa al monorepo, por ejemplo:

```text
piscine_pedago_data_science/data_science_0_creation_db
```

Recorre los niveles **de dentro hacia fuera**:

| Nivel | Si ya es repo con commits | Si no existe como repo |
|-------|---------------------------|-------------------------|
| Interno | Reutiliza; asegura `origin` si falta | `git init`, commit inicial, crea repo GitHub, push |
| Intermedio | Igual; registra al hijo en `.gitmodules` | Igual + registra hijo |
| Al final | Registra el módulo superior en el monorepo | — |

Nombres remotos: se antepone el prefijo **`42_`** al nombre de la carpeta:

```text
piscine_pedago_data_science  →  42_piscine_pedago_data_science
data_science_0_creation_db   →  42_data_science_0_creation_db
```

El propietario de GitHub (`STC71`, etc.) se deduce de la URL `origin` del monorepo.

### 5.6 Registro de submódulo (`register_submodule`)

1. Escribe/actualiza `.gitmodules` (path + url).
2. Si la ruta estaba añadida como carpeta normal (no como gitlink), la quita del índice.
3. Añade el gitlink (`160000`) y el `.gitmodules`.
4. Intenta `git submodule absorbgitdirs` para dejar la metadata ordenada.

### 5.7 Construcción de la lista de publicación

Con el hijo ya registrado, el script hace:

```text
repos = [ actual ]
mientras exista padre registrado:
    repos += padre
    actual = padre
```

Ejemplo de resultado:

```text
📦 Cadena de publicación (de dentro hacia fuera)
  ▸ data_science_0_creation_db
  ▸ piscine_pedago_data_science
  ▸ 42_outer_core
```

### 5.8 Bucle de publicación (por cada repo de la lista)

Para cada nivel, tras confirmar:

#### 1) Archivos grandes (solo en el más interno)

GitHub rechaza blobs **> 100 MB**.  
`handle_large_files` busca esos archivos, los lista y, si aceptas, los añade al `.gitignore` y los saca del índice (`git rm --cached`) sin borrarlos del disco.

#### 2) Staging inteligente (`stage_repository`)

No hace un `git add -A` ciego sobre todo el árbol. Razones:

| Situación | Qué añade |
|-----------|-----------|
| **Repo más interno** | Archivos y carpetas normales del proyecto; submódulos **solo si ya están registrados** |
| **Repo padre** | El gitlink del **hijo de la cadena** que se está publicando; archivos sueltos en la raíz del padre; **no** mete carpetas hermanas ni repos vecinos no registrados |

**Analogía:** al actualizar la caja mediana, solo cambias la ficha del cuaderno que acabas de publicar; no reordenas el resto de cuadernos de la estantería.

Además:

- Aborta si hay un merge/rebase/cherry-pick a medias.
- Hace `git reset` del índice para partir de un staging limpio controlado por el script.

#### 3) Commit

Si hay algo en el índice: `commit -m "Update <nombre>"`.  
Si no hay cambios nuevos: no crea commit vacío; pasa a comprobar el remoto.

#### 4) Push (`push_branch`)

Envía la rama actual a `origin`, creando upstream (`-u`) si hace falta.

### 5.9 Mapa mental de funciones

```text
main
 ├─ detección de START_DIR / current_root
 ├─ ¿registrado?
 │   ├─ no → create_submodule_chain / create_submodule_from_current_directory
 │   │        ├─ ensure_github_cli
 │   │        ├─ publish_new_repository / create_github_repo
 │   │        └─ register_submodule
 │   └─ sí  → (sigue)
 ├─ construir lista de padres (find_parent_repo)
 └─ para cada repo de dentro a fuera:
      ├─ handle_large_files          (solo el más interno)
      ├─ stage_repository
      ├─ git commit                  (si hay cambios)
      └─ push_branch
```

### 5.10 Modo `--dry-run`

Recorre la misma lógica de detección y creación de cadena, pero:

- no crea repos en GitHub,
- no hace commit ni push,
- imprime líneas con el prefijo `🧪` describiendo lo que *haría*.

Ideal para revisar la cadena antes de tocar nada.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## 🧭 6. Comportamiento esperable y casos reales

### 6.1 Caso feliz (submódulo ya registrado)

```bash
cd .../data_science_0_creation_db
../../update.sh
```

1. Detecta padres vía `.gitmodules`.
2. Muestra la cadena.
3. Pregunta por cada nivel.
4. Publica 1/N, 2/N, … hasta el monorepo.

### 6.2 Proyecto nuevo bajo un tema que aún no está en GitHub

Situación real vivida en 42 Outer Core:

```text
42_outer_core/                          ← tiene origin
 └── piscine_pedago_data_science/       ← repo local SIN origin
      └── data_science_0_creation_db/   ← repo CON origin en GitHub
```

Comportamiento:

1. Detecta que el hijo no está registrado.
2. Ve que el padre intermedio no tiene `origin`.
3. Sube hasta `42_outer_core`.
4. Crea/publica `42_piscine_pedago_data_science` si hace falta.
5. Registra el hijo dentro del tema.
6. Registra el tema dentro de Outer Core.
7. Publica la cadena completa.

### 6.3 Qué NO toca el script

- Repositorios **hermanos** (otras piscinas, otros proyectos al mismo nivel).
- Carpetas del padre que **no** están en la cadena activa.
- El historial antiguo: no hace rebase interactivo ni reescribe commits ajenos.

### 6.4 Mensajes frecuentes

| Mensaje | Significado |
|---------|-------------|
| `🆕 Cadena de carpetas/repos sin registrar…` | Hay que montar o registrar la cadena antes de publicar |
| `🧱 Nivel ya es repo local, pero sin origin` | Existe `.git` local; falta crear el remoto y hacer el primer push |
| `⚠ archivos que superan el límite de 100 MB` | GitHub los rechazaría; se propone ignorarlos |
| `ℹ Sin cambios nuevos; se comprueba el remoto` | No había diff; igual se intenta push por si faltaba upstream |
| `el repositorio actual sigue sin ser un submódulo registrado` | Tras intentar crear/registrar, aún no hay padre en `.gitmodules` |

### 6.5 Cómo verificar que el submódulo quedó bien

Desde el monorepo:

```bash
cat .gitmodules
git ls-files -s piscine_pedago_data_science
# Debe empezar por 160000

git submodule status
```

Si ves `160000` y la entrada en `.gitmodules`, el registro es correcto.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## 🛡️ 7. Seguridad y decisiones conscientes

| Decisión | Motivo |
|----------|--------|
| Confirmación en cada nivel | Evita publicar un piso del edificio sin querer |
| `--dry-run` | Ensayo general sin consecuencias |
| Límite 100 MB | Política de GitHub; mejor fallar antes que a mitad de push |
| Staging selectivo | No contamina el commit del padre con basura de carpetas vecinas |
| Instalación de `gh` en `~/.local/bin` | No pide `sudo` en máquinas del campus |
| Visibilidad configurable | Por defecto **privado**; tú eliges público |
| Detección SSH vs HTTPS | Intenta respetar el protocolo del remoto padre y la presencia de claves |

**El script no es magia destructiva:** no borra tu código fuente. Los archivos grandes excluidos **siguen en tu disco**; solo dejan de versionarse.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## ❓ 8. Preguntas frecuentes

### ¿Puedo ejecutarlo desde la raíz de `42_outer_core`?

El diseño está pensado para ejecutarlo **desde un submódulo / proyecto interno**. Desde la raíz del monorepo no hay “padre registrado” hacia arriba en el sentido de la cadena, y el script se detendrá con un mensaje claro.

### ¿Qué pasa si cancelo a mitad (`N`)?

Se detiene en ese nivel. Los niveles ya publicados en esa ejecución **siguen publicados**. Puedes volver a lanzarlo más tarde; detectará el estado actual.

### ¿Sustituye a `git submodule update`?

No. `update.sh` **publica** (commit/push/registro).  
`git submodule update --init --recursive` **descarga** submódulos al clonar. Son operaciones complementarias.

### ¿Por qué a veces el remoto se llama `42_nombre_carpeta`?

Convención del portfolio STC71 / 42 Outer Core: todos los repos de proyecto en GitHub llevan el prefijo `42_` para localizarlos y evitar colisiones de nombres genéricos.

### ¿Qué hago si el push falla porque el remoto está adelantado?

El script no hace pull/rebase automático (para no resolver conflictos a ciegas). En ese nivel:

```bash
cd /ruta/del/repo/que/falló
git pull --rebase origin main   # o la rama que uses
# resuelve conflictos si los hay
../../update.sh                 # o la ruta relativa que corresponda
```

### ¿Los CSV enormes del subject se suben?

No, si aceptaste añadirlos al `.gitignore`. Siguen en local para practicar; no viajan a GitHub. Para datasets grandes en remoto, valora **Git LFS** u otro almacenamiento.

<div align="right">

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>

---

## 📁 9. Estructura recomendada del portfolio

```text
42_outer_core/                          # monorepo (este repo)
├── update.sh                           # el script
├── UPDATE.md                           # esta guía
├── .gitmodules                         # mapa de submódulos de primer nivel
├── artificial_intelligence/            # submódulo
├── cyber_security/                     # submódulo
├── piscine_pedago_ciber/               # submódulo
├── piscine_pedago_mobile/              # submódulo
├── piscine_pedago_data_science/        # submódulo
│   ├── .gitmodules                     # mapa de proyectos de la piscine
│   └── data_science_0_creation_db/     # submódulo (proyecto)
├── unix_kernel/
├── virus/
└── web_database/
```

Cada “caja” de primer nivel en Outer Core es un repositorio independiente en GitHub; los proyectos dentro de una piscine también pueden serlo.

---

## 🧪 10. Checklist rápida antes de publicar

- [ ] Estoy dentro de la carpeta del **proyecto** que quiero publicar (no en un hermano).
- [ ] `git status` en ese proyecto tiene sentido (sé qué voy a subir).
- [ ] He ejecutado `../../update.sh --dry-run` y la cadena es la esperada.
- [ ] `gh auth status` muestra sesión activa (o aceptaré el login cuando lo pida).
- [ ] Si hay archivos > 100 MB, acepto ignorarlos o los gestiono aparte.
- [ ] No tengo un merge/rebase a medias en ningún nivel de la cadena.

---

## 🎓 11. Glosario express

| Término | Definición breve |
|---------|------------------|
| **Staging / índice** | “Bandeja de entrada” de lo que entrará en el próximo commit |
| **gitlink (160000)** | Entrada especial que apunta a un commit de otro repo |
| **Upstream** | Rama remota asociada a tu rama local (`-u` al hacer push) |
| **Detached HEAD** | Estás mirando un commit concreto, no una rama; el script pide cambiar a una rama antes de publicar |
| **Dry-run** | Simulación: enseña el plan sin ejecutarlo |
| **Monorepo / portfolio** | Repo contenedor (`42_Outer_Core`) que agrupa proyectos vía submódulos |

---

## 👤 Autor

**sternero** — estudiante de 42 Málaga  

Script y documentación pensados para el flujo real del campus (sgoinfre, sin sudo, GitHub CLI local) y para el portfolio [42_Outer_Core](https://github.com/STC71/42_Outer_Core).

> “Automatizar lo repetible para poder centrarse en lo que se aprende.”

---

<div align="center">

**¿Duda con una cadena concreta?**  
Ejecuta primero `--dry-run`, lee la cadena que imprime y, si algo no cuadra, revisa `.gitmodules` de cada nivel antes de publicar de verdad.

[⬆️ Volver arriba](#-updatemd--actualizador-de-repositorios-42)

</div>
