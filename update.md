<a id="top"></a>

<div align="center">

# 🚀 update.sh — Actualizador automático de repositorios

![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Git](https://img.shields.io/badge/Git-Submodules-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub CLI](https://img.shields.io/badge/GitHub-CLI-181717?style=for-the-badge&logo=github&logoColor=white)

**Publica de forma ordenada una cadena de repositorios Git (submódulos)**  
*Implementación de sternero · estudiante de 42 Málaga*

</div>

---

## 📑 Índice

| # | Sección | Contenido |
|---|---------|-----------|
| 1 | [🎯 Objetivo](#1-objetivo) | Por qué existe el script |
| 2 | [🏠 Idea simple](#2-idea-simple) | Cajas rusas y el ascensor |
| 3 | [🧩 Conceptos](#3-conceptos) | Repo, commit, remoto, submódulo, cadena, `gh` |
| 4 | [▶️ Uso](#4-uso) | Requisitos, [simulación](#44-simulación-muy-recomendable-la-primera-vez), [publicación](#45-publicación-real) |
| 5 | [⚙️ Funcionamiento](#5-funcionamiento) | Detección, cadena, [paso a paso por nivel](#58-en-cada-nivel-de-la-lista) |
| 6 | [🧭 Casos reales](#6-casos-reales) | Tema sin origin, borrados, `.gitignore` vs GitHub |
| 7 | [🛡️ Seguridad](#7-seguridad) | Confirmaciones, límites, decisiones del script |
| 8 | [❓ FAQ](#8-faq) | Preguntas frecuentes |
| 9 | [📁 Estructura del portfolio](#9-estructura-del-portfolio) | Árbol recomendado de carpetas |
| 10 | [✅ Checklist](#10-checklist-antes-de-publicar) | Antes de publicar |
| 11 | [🎓 Glosario](#11-glosario) | Términos en corto |
| 12 | [👤 Autor](#autor) | sternero · 42 Málaga |

---

## 🎯 1. Objetivo

<a id="1-objetivo"></a>

En **GitHub** es habitual tener **varios repositorios uno dentro de otro** (anidados):

```text
42_Outer_Core                          ← 🗂️  portfolio (todo el curso)
 └── piscine_pedago_data_science       ← 📁  tema / piscina
      └── data_science_0_creation_db   ← 📄  proyecto concreto
```

Cada nivel suele tener **su propio repositorio en GitHub**. Cuando terminas trabajo en el proyecto de dentro, un solo `git push` no basta. Hay que:

1. 📤 Subir los cambios del **proyecto**.
2. 🔗 Actualizar el **tema** para que apunte a esa versión nueva.
3. 🔗 Actualizar el **portfolio** para que apunte a la versión nueva del tema.

A mano es lento y fácil equivocarse (olvidar un nivel, colar carpetas hermanas, intentar subir archivos de 2 GB…).

**`update.sh` hace esa cadena por ti:** publica **de dentro hacia fuera**, pide confirmación en cada nivel, crea repos en GitHub si faltan y registra los submódulos bien.

> 💡 **En una frase:**  
> Desde la carpeta del proyecto en el que trabajas, el script sube tus cambios a GitHub y actualiza todos los “contenedores” padres, en orden y con confirmación.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## 🏠 2. Idea simple

<a id="2-idea-simple"></a>

Piensa en **cajas rusas** (una dentro de otra):

| 📦 Caja | En la vida real | En tu disco |
|--------|-----------------|-------------|
| Pequeña | Cuaderno del ejercicio de hoy | `data_science_0_creation_db` |
| Mediana | Carpeta de la asignatura | `piscine_pedago_data_science` |
| Grande | Armario de todo el curso | `42_outer_core` |

Cada caja tiene su **copia en la nube** (un repo en GitHub).

Si cambias una página del cuaderno:

1. 📸 Haces una “foto” del cuaderno y la cuelgas en su estantería de GitHub.
2. 🏷️ En la caja mediana actualizas la **etiqueta** (“ahora el cuaderno es la versión del 30 de agosto”).
3. 🏷️ En el armario actualizas la etiqueta de la caja mediana.

Si solo actualizas el cuaderno y te olvidas de las etiquetas, quien abra el armario desde Internet **seguirá viendo la versión antigua**.

### 🛗 Analogía del ascensor

```text
Piso 2   →  proyecto
Piso 1   →  tema / piscina
Planta 0 →  portfolio
```

El script **entra por el piso en el que estás** y baja el ascensor:

- En cada parada prepara el paquete, lo sella (commit) si hace falta y lo envía a la nube (push).
- **No empieza por la planta baja** sin haber cerrado antes los pisos de arriba: dejaría el edificio a medias.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## 🧩 3. Conceptos

<a id="3-conceptos"></a>

No hace falta ser experto en Git. Basta entender estas piezas.

### 3.1 Repositorio Git

La **caja con historial**: no solo guarda archivos, guarda *versiones* a lo largo del tiempo (como el historial de un documento compartido, pero en tu máquina y en la nube).

### 3.2 Commit

Una **foto congelada** del proyecto en un momento dado, con un mensaje.  
Si el repo es un diario, el commit es **una entrada**.

### 3.3 Remoto (`origin`) y GitHub

La **copia en la nube**. Casi siempre se llama `origin`.  
`git push` = “envía mis fotos nuevas a GitHub”.

### 3.4 Submódulo

Un **repo completo dentro de otro**, pero el padre **no copia todos los archivos del hijo**. Solo guarda:

- la ruta de la carpeta, y  
- el **código del commit exacto** del hijo (como un código de barras de “esta edición concreta”).

En Git eso aparece con el modo **`160000`** (gitlink).

> 🏷️ **Analogía:** en el inventario del armario no guardas el cuaderno entero; guardas una ficha: *“cuaderno de mates, edición del 30 de agosto”*. Quien clone el armario usa esa ficha para **descargar** el cuaderno correcto.

El archivo **`.gitmodules`** es la lista de fichas del padre:

```ini
[submodule "piscine_pedago_data_science"]
        path = piscine_pedago_data_science
        url = https://github.com/STC71/42_piscine_pedago_data_science.git
```

### 3.5 Cadena de submódulos

Varios niveles, cada uno registrado en su padre inmediato:

```text
42_Outer_Core
 └── [submódulo] piscine_pedago_data_science
      └── [submódulo] data_science_0_creation_db
```

### 3.6 Publicar “de dentro hacia fuera”

<a id="36-publicar-de-dentro-hacia-fuera"></a>

Orden obligatorio:

```text
1) 📄 hijo     →  commit + push
2) 📁 padre    →  actualiza la ficha del hijo + commit + push
3) 🗂️  abuelo  →  actualiza la ficha del padre + commit + push
```

Si se hiciera al revés, el padre apuntaría a un commit del hijo que **aún no existe en GitHub**.

### 3.7 GitHub CLI (`gh`)

Herramienta oficial de GitHub en la terminal. El script la usa para iniciar sesión, crear repos y elegir privacidad.  
Si no está instalada, puede proponer instalarla en `~/.local/bin` **sin sudo**.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## ▶️ 4. Uso

<a id="4-uso"></a>

### 4.1 Requisitos

<a id="41-requisitos"></a>

| Necesitas | Para qué |
|-----------|----------|
| `git` | Guardar versiones y subir cambios |
| `find` | Buscar archivos (p. ej. los demasiado grandes) |
| Cuenta de GitHub | Publicar en la nube |
| `gh` (opcional al inicio) | El script puede instalarlo o pedirte login |
| Ejecutar **desde un proyecto** bajo el portfolio | Detectar la cadena de padres |

### 4.2 Dónde suele vivir el script

```text
42_outer_core/
 ├── update.sh              ← el script
 ├── update.md               ← esta guía
 ├── .gitmodules
 ├── piscine_pedago_data_science/
 │    └── data_science_0_creation_db/   ← aquí trabajas
 └── …
```

### 4.3 Primera vez

```bash
chmod +x update.sh
```

### 4.4 Simulación (muy recomendable la primera vez)

<a id="44-simulación-muy-recomendable-la-primera-vez"></a>

```bash
cd piscine_pedago_data_science/data_science_0_creation_db
../../update.sh --dry-run
```

🧪 **No escribe commits ni hace push.** Solo muestra qué cadena detecta y qué haría.

### 4.5 Publicación real

<a id="45-publicación-real"></a>

```bash
../../update.sh
```

Preguntas habituales:

| Te pregunta… | Significa… |
|--------------|------------|
| Crear remoto y publicar este nivel `[s/N]` | Crear el repo en GitHub si aún no existe |
| Visibilidad `[p]` privado / `[u]` público | Privacidad del repo nuevo (por defecto: privado) |
| Añadir archivos grandes al `.gitignore` | Evitar el rechazo de GitHub (> 100 MB) |
| Publicar `'nombre'` en `'main'` `[s/N]` | Confirmar commit + push de ese nivel |

Respuestas que cuentan como **sí:** `s`, `si`, `sí`, `y`, `yes` (da igual mayúsculas o minúsculas).

### 4.6 Ayuda

```bash
./update.sh --help
```

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## ⚙️ 5. Funcionamiento

<a id="5-funcionamiento"></a>

Qué hace el código, en orden.

### 5.1 Arranque

1. **Modo estricto** (`set -u`, `pipefail`) — Si algo va mal (variable sin definir, error en una tubería), se detiene en lugar de seguir a ciegas.
2. **Colores** — Solo en terminal interactiva; en logs el texto sale limpio.
3. **Limpieza al salir** — Borra ficheros temporales que haya creado.

### 5.2 ¿Dónde estoy?

```text
START_DIR     = carpeta desde la que lanzaste el script
current_root  = raíz del repositorio Git de esa carpeta
```

Ejemplo:

```text
Estás en:     .../data_science_0_creation_db/src
START_DIR:    .../data_science_0_creation_db/src
current_root: .../data_science_0_creation_db     ← raíz del repo
```

### 5.3 ¿Ya soy un submódulo registrado?

Pregunta clave: *¿Hay un padre Git que me tenga en su `.gitmodules`?*

| Respuesta | Qué hace el script |
|-----------|-------------------|
| ✅ Sí | Construye la cadena y pasa a publicar |
| ❌ No | Entra en modo **crear / registrar** (siguiente apartado) |

### 5.4 Si aún no estás registrado

**A)** Ejecutaste desde una subcarpeta (`proyecto/src`) y el proyecto aún no es submódulo  
→ Intenta crear la cadena desde el portfolio hasta esa ruta.

**B)** Hay un `git init` pero aún no hay commits  
→ Completa la publicación y el registro en el padre.

**C)** Es un repo local que aún no figura como submódulo *(lo más habitual al montar algo nuevo)*

1. Mira el **padre inmediato**.
2. Si ese padre es repo **y tiene `origin`** → te registra ahí.
3. Si el padre es repo **pero no tiene `origin`** (repo local a medias) → **no se queda ahí**. Sube hasta un ancestro con remoto (en este caso `42_outer_core`) y monta la **cadena completa**.

> ⚠️ `find_ancestor_with_origin` **nunca** elige el propio proyecto actual, aunque ya tenga `origin` en GitHub. Si no, confundiría el cuaderno con el armario.

### 5.5 Crear la cadena

Para una ruta como `piscine_pedago_data_science/data_science_0_creation_db`, recorre los niveles **de dentro hacia fuera**:

| Situación del nivel | Acción |
|---------------------|--------|
| Ya es repo con historial | Lo reutiliza; si falta `origin`, lo crea y publica |
| Aún no es repo | `git init`, primer commit, crea repo en GitHub, push |
| Tiene un hijo en la cadena | Lo registra en su `.gitmodules` |

Nombres en GitHub: se antepone **`42_`** al nombre de la carpeta:

```text
piscine_pedago_data_science  →  42_piscine_pedago_data_science
data_science_0_creation_db   →  42_data_science_0_creation_db
```

El usuario de GitHub (`STC71`, etc.) se lee del `origin` del portfolio.

### 5.6 Registrar un submódulo

1. Escribe o actualiza `.gitmodules` (ruta + URL).
2. Si la carpeta estaba añadida “como carpeta normal”, la corrige.
3. Deja el gitlink (`160000`) y el `.gitmodules` listos.
4. Intenta ordenar la metadata interna del submódulo.

### 5.7 Lista de publicación

```text
repos = [ proyecto actual ]
mientras exista un padre registrado:
    añadir el padre a la lista
```

Ejemplo de lo que verás:

```text
📦 Cadena de publicación (de dentro hacia fuera)
  ▸ data_science_0_creation_db
  ▸ piscine_pedago_data_science
  ▸ 42_outer_core
```

### 5.8 En cada nivel de la lista

<a id="58-en-cada-nivel-de-la-lista"></a>

Tras tu **sí**:

1. **Archivos grandes** (solo en el más interno) — GitHub rechaza archivos **> 100 MB**. Si los hay, los lista y, si aceptas, los mete en `.gitignore` y los saca del índice **sin borrarlos del disco**.
2. **Ignorados aún versionados** (solo en el más interno) — Detecta archivos que **siguen en el índice** pero ya cubre el `.gitignore` (p. ej. un PDF subido antes de añadir `*.pdf`). Te propone dejar de versionarlos con `git rm --cached` (permanecen en disco). Si aceptas, el commit deja de incluirlos en GitHub.
3. **Staging selectivo** — No hace un “añadir todo el disco”.  
   - En el hijo: archivos del proyecto; submódulos solo si ya están registrados.  
   - En el padre: la ficha del hijo de la cadena + archivos sueltos de la raíz; **no** mete hermanos ni carpetas ajenas.  
   - **No intenta `git add` de rutas ignoradas** (evita el error *paths are ignored by .gitignore*).
4. **Borrados** — Además de lo que existe en disco, el script pregunta a Git qué rutas **ya rastreadas** han desaparecido y las incluye en el commit.  
   - En el hijo: cualquier archivo versionado que hayas borrado.  
   - En el padre: borrados en la **raíz** del repo (p. ej. `update_v0.sh`) o bajo el hijo de la cadena.  
   Así no quedan en GitHub copias viejas que ya eliminaste en local.
5. **Commit** — Solo si hay cambios. Propone un mensaje por defecto con marca de tiempo local:
   ```text
   Update data_science_0_creation_db · 30/08/26 12:51
   ```
   Formato por defecto: `Update <nombre> · DD/MM/AA HH:MM`.  
   Puedes **aceptarlo** (Enter o `s`), responder `n` y escribir otro, o **escribir directamente** el mensaje personalizado.  
   Si personalizas el texto, el script **añade igual** ` · DD/MM/AA HH:MM` al final (p. ej. `feat: tests verdes · 30/08/26 13:50`).
6. **Push** — Envía la rama a `origin` (crea el seguimiento remoto si hace falta).

### 5.9 Mapa rápido

```text
main
 ├─ ¿Dónde estoy?
 ├─ ¿Registrado como submódulo?
 │    ├─ No → crear / registrar cadena
 │    └─ Sí → seguir
 ├─ Lista de padres (de dentro a fuera)
 └─ Por cada nivel:
      preparar → commit (si hay cambios) → push
```

### 5.10 Modo `--dry-run`

Misma lógica de detección, pero **sin** crear repos, commits ni pushes. Las líneas van con 🧪 para ver el plan sin riesgos.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## 🧭 6. Casos reales

<a id="6-casos-reales"></a>

### 6.1 Todo ya está registrado

```bash
cd .../data_science_0_creation_db
../../update.sh
```

Detecta padres → muestra la cadena → pregunta → publica 1/N, 2/N, …

### 6.2 Proyecto nuevo bajo un tema aún no publicado

```text
42_outer_core/                     ← tiene origin en GitHub
 └── piscine_pedago_data_science/  ← repo local SIN origin
      └── data_science_0_creation_db/  ← ya tiene origin
```

El script:

1. Ve que el hijo no está registrado.
2. Ve que el padre intermedio no tiene `origin`.
3. Sube hasta `42_outer_core`.
4. Crea/publica el remoto del tema si hace falta.
5. Registra hijo → tema → portfolio.
6. Publica la cadena.

### 6.3 Qué no toca

- Repos **hermanos** (otras piscinas u otros proyectos al mismo nivel).
- Carpetas del padre **fuera** de la cadena activa.
- Historial antiguo (no reescribe commits ni hace rebase automático).

### 6.4 Borraste archivos en local (p. ej. scripts viejos)

Si eliminas en disco ficheros que **ya estaban versionados** (por ejemplo `update_v0.sh` o `update (1).sh` en la raíz del portfolio) y luego ejecutas el script desde un submódulo de la cadena, el nivel correspondiente **incluye esos borrados** en el commit y el push.

No hace falta un `git rm` manual para ese caso: el staging ya los detecta.  
*(Los archivos que nunca se llegaron a commitear no están en Git; borrarlos del disco no genera ningún cambio en el remoto.)*

### 6.5 Un archivo está en `.gitignore` pero sigue en GitHub

Muy habitual: se subió un PDF (o similar) y **después** se añadió `*.pdf` al `.gitignore`.

- El `.gitignore` **no saca** del remoto lo que ya estaba versionado.
- Al publicar el nivel interno, el script **lista** esas rutas y pregunta si dejar de versionarlas (`git rm --cached`).
- Si aceptas, el **nuevo** commit en `main` ya no las incluye.
- Los commits **antiguos** del historial pueden seguir mostrándolas (es normal: Git no reescribe el pasado). Mira siempre la punta de `main`, no un SHA viejo.

### 6.6 Mensajes que puedes ver

| Mensaje | Qué significa |
|---------|----------------|
| Cadena sin registrar… | Hay que montar o registrar la cadena antes de publicar |
| Nivel ya es repo local, pero sin origin | Existe `.git` local; falta el remoto y el primer push |
| Archivos > 100 MB | GitHub los rechazaría; se propone ignorarlos |
| Sin cambios nuevos… | No había diff; igual se comprueba el remoto |
| Sigue sin ser un submódulo registrado | Tras intentar crear/registrar, aún falta el padre en `.gitmodules` |
| Aún versionados aunque los cubre el `.gitignore` | Ofrece `git rm --cached` (siguen en disco) |
| paths are ignored by .gitignore | Ya no debería ocurrir: el staging omite rutas ignoradas |

### 6.7 Comprobar que el submódulo quedó bien

Desde el portfolio:

```bash
cat .gitmodules
git ls-files -s piscine_pedago_data_science
# Debe empezar por 160000

git submodule status
```

Si ves `160000` y la entrada en `.gitmodules`, está bien.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## 🛡️ 7. Seguridad

<a id="7-seguridad"></a>

| Decisión | Por qué |
|----------|---------|
| Confirmación en cada nivel | No publicar un piso del edificio sin querer |
| `--dry-run` | Ensayo sin consecuencias |
| Límite 100 MB | Política de GitHub; mejor avisar antes que fallar a mitad de push |
| Staging selectivo | El commit del padre no se llena de carpetas ajenas |
| Borrados versionados | Si quitas un archivo ya rastreado, el commit lo refleja en GitHub |
| Ignorados aún rastreados | Propone sacarlos del índice si el `.gitignore` ya los cubre |
| No hace `add` de ignorados | Evita fallos al preparar el índice |
| Marca de tiempo en commits | Facilita localizar publicaciones (`DD/MM/AA HH:MM`) |
| Mensaje de commit opcional | Aceptas el por defecto o escribes uno personalizado |
| Marca de tiempo siempre | También en mensajes personalizados (` · DD/MM/AA HH:MM`) |
| `gh` en `~/.local/bin` | Sin `sudo` en máquinas del campus |
| Privado por defecto | Tú eliges si lo haces público |
| SSH / HTTPS | Intenta respetar el remoto del padre y si tienes clave SSH |

El script **no borra tu código del disco**. Los archivos grandes o ignorados que se dejan de versionar **siguen en local**; solo salen del índice y del remoto a partir del nuevo commit. Los borrados que *tú* hagas de archivos ya versionados **sí** se propagan al remoto en el siguiente publish.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## ❓ 8. FAQ

<a id="8-faq"></a>

**¿Puedo ejecutarlo desde la raíz de `42_outer_core`?**  
Está pensado para lanzarlo **desde un proyecto / submódulo interno**. Desde la raíz del portfolio no hay “padre hacia arriba” en el sentido de la cadena.

**¿Qué pasa si digo `N` a mitad?**  
Se detiene en ese nivel. Lo ya publicado en esa ejecución **sigue publicado**. Puedes volver a lanzarlo más tarde.

**¿Sustituye a `git submodule update`?**  
No. `update.sh` **publica** (commit / push / registro).  
`git submodule update --init --recursive` **descarga** al clonar. Son complementarios.

**¿Por qué el remoto se llama `42_nombre_carpeta`?**  
Convención del portfolio: prefijo `42_` para localizar repos y evitar nombres genéricos chocando entre sí.

**¿El push falla porque el remoto está adelantado?**  
El script no hace pull/rebase solo (no quiere resolver conflictos a ciegas):

```bash
cd /ruta/del/repo/que/falló
git pull --rebase origin main   # o tu rama
# resuelve conflictos si los hay
../../update.sh
```

**¿Se suben los CSV enormes del subject?**  
No, si aceptaste el `.gitignore`. Siguen en local. Para datasets grandes en remoto, valora Git LFS u otro almacenamiento.

**¿Si borro un archivo en local, desaparece también de GitHub?**  
Sí, si ese archivo **ya estaba versionado** y publicas el nivel del repo donde vivía (directamente o vía la cadena). El script registra el borrado en el commit. Si el archivo nunca se subió, no hay nada que quitar en el remoto.

**¿Por qué un PDF sigue viéndose en un enlace de GitHub si ya lo saqué del repo?**  
Ese enlace suele apuntar a un **commit antiguo**. En la rama `main` actual ya no está; en el historial sí puede aparecer. Git no borra el pasado al hacer un commit nuevo.

**¿Qué formato tienen los mensajes de commit?**  
Por defecto: `Update <nombre_del_repo> · DD/MM/AA HH:MM` (hora local de la máquina).  
Antes de crear el commit el script te muestra ese mensaje: **Enter** o `s` lo acepta; `n` pide uno nuevo; cualquier otro texto se usa como mensaje.  
En los personalizados también se añade la marca ` · DD/MM/AA HH:MM` al final, para que el historial siga siendo fácil de ordenar en el tiempo.

<div align="right"><a href="#top">⬆️ Volver arriba</a></div>

---

## 📁 9. Ejemplo de estructura del portfolio

<a id="9-estructura-del-portfolio"></a>

```text
42_outer_core/
├── update.sh
├── update.md
├── .gitmodules
├── artificial_intelligence/
├── cyber_security/
├── piscine_pedago_ciber/
├── piscine_pedago_mobile/
├── piscine_pedago_data_science/
│   ├── .gitmodules
│   └── data_science_0_creation_db/
├── unix_kernel/
├── virus/
└── web_database/
```

Cada carpeta de primer nivel en el repo principal es un repo en GitHub; los proyectos dentro de una carpeta también pueden serlo.

---

## ✅ 10. Checklist antes de publicar

<a id="10-checklist-antes-de-publicar"></a>

- [ ] Estoy en la carpeta del **proyecto** que quiero publicar (no en un hermano).
- [ ] Sé qué voy a subir (`git status` tiene sentido).
- [ ] He hecho `../../update.sh --dry-run` y la cadena es la correcta.
- [ ] Tengo sesión en GitHub (`gh auth status`) o aceptaré el login.
- [ ] Si hay archivos > 100 MB, sé si los ignoro o los gestiono aparte.
- [ ] Si el `.gitignore` cubre cosas que aún están en GitHub, aceptaré dejar de versionarlas cuando el script lo proponga.
- [ ] No tengo un merge/rebase a medias en ningún nivel de la cadena.

---

## 🎓 11. Glosario

<a id="11-glosario"></a>

| Término | En corto |
|---------|----------|
| **Staging / índice** | Bandeja de lo que entrará en el próximo commit |
| **gitlink (160000)** | Entrada que apunta al commit de otro repo |
| **Upstream** | Rama remota ligada a la tuya local |
| **Detached HEAD** | Estás en un commit suelto, no en una rama; el script pide cambiar a una rama |
| **Dry-run** | Simulación: muestra el plan sin ejecutarlo |
| **Monorepo / portfolio** | Repo contenedor (`42_Outer_Core`) que agrupa proyectos con submódulos |

---

## 👤 Autor

<a id="autor"></a>

**sternero** — estudiante de 42 Málaga  

Pensado para el flujo del campus (sgoinfre, sin sudo, `gh` local) y para el portfolio [42_Outer_Core](https://github.com/STC71/42_Outer_Core).

> *Automatizar lo repetible para poder centrarse en lo que se construye.*

---

<div align="center">

**¿Duda con una cadena concreta?**  
Prueba primero `--dry-run`, mira la cadena que imprime y, si algo no cuadra, revisa el `.gitmodules` de cada nivel antes de publicar de verdad.

<a href="#top">⬆️ Volver arriba</a>

</div>
