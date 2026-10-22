# PoliMusic · Ágora Sonora

Clon funcional de Spotify construido con **Classic ASP (VBScript) + HTML + CSS + JavaScript**
sobre **SQL Server 2025**, con diseño original inspirado en la paleta griega
(azul egeo, azafrán, terracota y mármol).

La base de datos es exactamente la del script `BDD_PoliMusic.sql`: **no se creó ninguna
tabla ni columna adicional**.

---

## 1. Requisitos

| Componente | Detalle |
|---|---|
| Sistema | Windows 10/11 con IIS o IIS Express |
| Servidor web | IIS con la característica **ASP** (Classic ASP) habilitada |
| Base de datos | SQL Server 2025 en `localhost`, base `BDD_PoliMusic` |
| Credenciales BD | `usr_polimusic` / `Politecnica1` (definidas en el script) |
| Navegador | Chrome, Edge o Firefox actualizados |

La configuración de conexión está en `includes/config.asp`
(`DB_SERVER`, `DB_NAME`, `DB_USER`, `DB_PASS`).

---

## 2. Base de datos

La base ya está creada y poblada en este equipo (5 canciones, 5 artistas, 5 álbumes,
5 playlists, 4 usuarios).

Si necesitas recrearla:

1. Abre **SQL Server Management Studio**.
2. Conéctate a `localhost` con autenticación SQL (`usr_polimusic` / `Politecnica1`) o con tu cuenta de administrador.
3. Abre y ejecuta `BDD_PoliMusic.sql` completo.

> El script hace `DROP DATABASE IF EXISTS [BDD_PoliMusic]`, es decir, **borra y vuelve a crear** la base con sus datos de ejemplo.

---

## 3. Cómo ejecutarlo

### Opción A · IIS Express (recomendada, no requiere administrador)

1. En el Explorador de Windows, clic derecho sobre **`run-iisexpress.ps1`** → *Ejecutar con PowerShell*.
2. Abre **http://localhost:8099/** en el navegador.

O desde una consola PowerShell, dentro de la carpeta del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-iisexpress.ps1
```

El script copia la configuración de IIS Express, la apunta a esta carpeta y arranca el sitio
en el puerto **8099**. Se detiene con `Ctrl + C`.

<details>
<summary>Comandos equivalentes, paso a paso</summary>

```powershell
$root = "C:\Users\WebAvanzadas\source\repos\AppWebAvSebastianRamos\webapppolimusicv1_asp"
$src  = Join-Path $env:ProgramFiles "IIS Express\AppServer\applicationHost.config"
$cfg  = Join-Path $env:TEMP "polimusic-iisexpress.config"

$text = Get-Content $src -Raw
$text = $text.Replace('%IIS_BIN%\AppServer\empty_wwwroot', $root)
$text = $text.Replace(':8080:localhost', ':8099:localhost')
Set-Content -Path $cfg -Value $text -Encoding UTF8

& (Join-Path $env:ProgramFiles "IIS Express\iisexpress.exe") /config:$cfg /site:"Development Web Site"
```
</details>

> **Importante:** no uses `iisexpress.exe /path:...` en esta versión de IIS Express:
> arranca pero sirve la carpeta `empty_wwwroot` (devuelve 404). Hay que pasarle la
> configuración con `/config:` y `/site:`, como hace el script.

### Opción B · IIS completo (requiere administrador)

1. **Habilitar Classic ASP:** Panel de control → *Activar o desactivar características de Windows* →
   *Internet Information Services* → *World Wide Web Services* → *Application Development Features* → marcar **ASP**.
2. Abrir **IIS Manager** (`inetmgr`).
3. *Application Pools* → **Add Application Pool**: nombre `PoliMusic`,
   *.NET CLR version* = **No Managed Code**, *Managed pipeline mode* = **Integrated**.
4. *Sites* → **Add Website**: nombre `PoliMusic`, *Physical path* = esta carpeta,
   *Port* = `8099`, *Application pool* = `PoliMusic`.
5. Abrir **http://localhost:8099/**.

Equivalente por línea de comandos (consola como administrador):

```bat
%windir%\system32\inetsrv\appcmd add apppool /name:PoliMusic /managedRuntimeVersion:""
%windir%\system32\inetsrv\appcmd add site /name:PoliMusic /physicalPath:"C:\Users\WebAvanzadas\source\repos\AppWebAvSebastianRamos\webapppolimusicv1_asp" /bindings:http/*:8099:
%windir%\system32\inetsrv\appcmd set app "PoliMusic/" /applicationPool:PoliMusic
```

### Opción C · Visual Studio

*File* → *Open* → *Web Site...* → seleccionar la carpeta del proyecto → **F5**.
Visual Studio arranca IIS Express con la configuración correcta de forma automática.

### Notas de configuración

- `web.config` define `login.asp` como documento por defecto y desactiva el listado de directorios.
- **No agregues la sección `<asp>` en `web.config`**: en IIS Express provoca
  `New Application Failed: Could not Init the AppConfig, hr = 0x80070021` y el sitio responde 501.

---

## 4. Credenciales de prueba

| Usuario | Contraseña | Rol | `USER_TYPE` |
|---|---|---|---|
| `userAdmin` | `12345678` | Administrador | 1 |
| `userNormal` | `12345678` | Usuario normal | 0 |
| `username1` | `12345678` | Usuario normal (hash SHA1) | 0 |
| `Sebastian.Ramos` | `1804540150` | Usuario normal | 0 |

El login acepta contraseñas **en texto plano** y **hasheadas con SHA1**, porque el script
mezcla ambos formatos. La comparación se hace en SQL Server:

```sql
WHERE USERNAME = @u
  AND (PASSWORD = @p
       OR UPPER(PASSWORD) = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', @p), 2)))
```

---

## 5. Roles y permisos

| Acción | Administrador (`USER_TYPE = 1`) | Usuario normal (`USER_TYPE = 0`) |
|---|---|---|
| Ver Song List y reproducir | Sí | Sí |
| CRUD **canciones** (`TBL_SONG`, `TBL_PLAYER`, `TBL_TRACKLIST`) | Sí | No (bloqueado por servidor) |
| CRUD **artistas** (`TBL_ARTIST`) | Sí | No |
| CRUD **álbumes** + tracklist (`TBL_ALBUM`, `TBL_TRACKLIST`) | Sí | No |
| CRUD **playlists** | Sí (todas) | Solo las propias |

El control de acceso se valida en el servidor con `RequireLogin`, `RequireAdmin` y la
verificación de propiedad de cada playlist (no basta con ocultar el menú).

---

## 6. Funcionalidades

- **Login / logout** con variables de sesión (`Session("UserID")`, `Session("UserName")`, `Session("UserType")`, `Session("UserPhoto")`).
- **Mensaje de bienvenida** que lee el nombre del usuario desde la sesión: *"Bienvenido, {usuario}"*.
- **Texto anunciando el listado**: aviso previo que indica que a continuación se presenta el *Song List*.
- **Song List** con portada, título, artista(s), álbum, reproducciones y duración real del MP3.
- **Reproductor persistente** en todas las páginas: play/pausa, anterior/siguiente, aleatorio,
  repetir (lista / canción), barra de progreso, volumen y silencio.
- **Contador de reproducciones** que se incrementa en `TBL_SONG.PLAYS` al reproducir (AJAX).
- **CRUD completo** de canciones, artistas, álbumes y playlists, con validaciones,
  mensajes flash y confirmación antes de eliminar.
- **Playlists**: crear, editar, eliminar, agregar y quitar canciones, visibilidad
  pública/privada desde `TBL_CATALOG`.
- Diseño responsive (escritorio, tablet y móvil) con `prefers-reduced-motion`.

---

## 7. Estructura del proyecto

```
webapppolimusicv1_asp/
├── BDD_PoliMusic.sql          Script original de la base de datos
├── run-iisexpress.ps1         Arranque rápido con IIS Express
├── web.config                 Documento por defecto y ajustes de IIS
├── login.asp                  Autenticación y creación de sesión
├── logout.asp                 Cierre de sesión
├── default.asp                Bienvenida + Song List + reproductor
├── songs.asp                  CRUD de canciones (admin)
├── artists.asp                CRUD de artistas (admin)
├── albums.asp                 CRUD de álbumes y tracklist (admin)
├── playlists.asp              CRUD de playlists (todos)
├── playlist.asp               Detalle de playlist y gestión de canciones
├── api_play.asp               API JSON que incrementa PLAYS
├── index.asp                  Redirección de entrada
├── includes/
│   ├── init.asp               Incluye config + db + auth + iconos
│   ├── config.asp             Constantes, conexión, helpers de rutas y HTML
│   ├── db.asp                 ADODB con parámetros, catálogos, JSON, flash
│   ├── auth.asp               Sesión y control de roles
│   ├── icons.asp              Iconos SVG inline
│   ├── head.asp               Layout superior (sidebar + topbar)
│   └── foot.asp               Cierre de layout + reproductor
├── css/app.css                Sistema de diseño "Ágora Sonora"
├── js/app.js                  Reproductor y microinteracciones
└── assets/
    ├── songFiles/             5 MP3
    ├── albumImages/           Portadas de álbumes
    ├── artistImages/          Avatares de artistas
    ├── playlistImages/        Portadas de playlists
    ├── userImages/            Fotos de usuario
    └── img/favicon.svg
```

---

## 8. Sobre los assets

El paquete `SongFilesAndImages_resources` incluía **un solo MP3** (`bensound-adventure.mp3`),
las 6 imágenes de playlists y 2 imágenes de usuario.

- Ese MP3 se copió con los nombres que espera el script (`bensound-dreams.mp3`,
  `bensound-energy.mp3`, `bensound-scifi.mp3`, `bensound-tomorrow.mp3`) para que las
  **5 canciones** del catálogo se puedan reproducir.
- El paquete **no traía** `albumImages/` ni `ArtistImages/`, por lo que se generaron
  portadas y avatares (800×800 y 700×700) con la misma paleta griega del sitio.
- Las rutas guardadas en la base (`~/songFiles/...`, `~/albumImages/...`) se resuelven con
  `AssetUrl()` hacia `assets/...`; si el archivo no existe se usa la imagen por defecto
  de su carpeta, así el sitio nunca muestra imágenes rotas.

Para reemplazar una portada basta con guardar el archivo en la carpeta correspondiente y
actualizar la ruta en el CRUD (o dejar el mismo nombre de archivo).

---

## 9. Seguridad implementada

- Todas las consultas usan **parámetros ADODB** (`?` + `CreateParameter`), sin concatenar SQL.
- Toda salida de datos pasa por `H()` (escape HTML).
- Sesión validada en cada página; el rol se verifica en el servidor, no solo en la interfaz.
- La pertenencia de una playlist se comprueba antes de editar o eliminar.
- Los borrados respetan el orden de las claves foráneas (primero las tablas de relación).
