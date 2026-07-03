# 💢 wollok-setup — Instalador Online Automatizado

Script desatendido de PowerShell para instalar, actualizar y configurar de forma automática todo el entorno de desarrollo de **Wollok** en Windows a través de `winget`.


---

## OPCIONES PARA INSTALAR GH CLI

### Instalar gh cli por consola
```powershell
winget install --id GitHub.cli
```

### Instalar gh cli por msi
[Descarga directa de gh msi v2.96]: https://github.com/cli/cli/releases/download/v2.96.0/gh_2.96.0_windows_amd64.msi


### Login con gh cli
```powershell
gh auth login
```

---

## Instrucciones de Uso rápido
> [!IMPORTANT]   
> **Se puede hacer con dos metodos, uno con descarga previa y otro completamente online**

### 🖱️ Método con ejecutable - Con descarga previa

1. Cloná el repo en el pendrive: git clone https://github.com/UNaHur-Materias/autoinstall-wollok.git
2. Ejecutá el archivo `setup.cmd` en la raíz del repositorio recien clonado.
3. Al finalizar te da un informe si hay error, o cierra la ventana si termina correctamente la instalación


### Script


```powershell
c:
cd /
git clone https://github.com/UNaHur-Materias/autoinstall-wollok.git
cd autoinstall-wollok
./setup.cmd

```


### 🖥️ Método por consola PowerShell - Completamente online 

1. Hacé click derecho en el botón de Inicio de Windows y seleccioná **Terminal (Administrador)** o **PowerShell (Administrador)**.
2. Copiá, pegá el siguiente comando y presioná `ENTER`:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force; irm https://raw.githubusercontent.com/UNaHur-Materias/autoinstall-wollok/main/script.ps1 | iex

```

3. Al finalizar te da un informe si hay error, o cierra la ventana si termina correctamente la instalación


> 💡 **Manejo de errores:** El script es tolerante a fallas. Al finalizar la instalación de Node.js o VSCode, refresca dinámicamente las variables de entorno de la sesión para continuar instalando los paquetes de `npm` y las extensiones sin necesidad de reiniciar la consola.

---

## 🎯 Próximos Pasos

Una vez finalizado el proceso con éxito:

1. Abrí **Visual Studio Code**.
2. Creá o abrí una carpeta vacía para tu proyecto.
3. Creá un archivo con extensión `.wlk` y el entorno lsp/diagramas se activará automáticamente.
4. Seguí la guía oficial: [wollok.org — Configurar Nuevo Proyecto](https://www.wollok.org/getting_started/new_project).

---

## 🔗 Recursos Útiles

* [Sitio Oficial Wollok](https://www.wollok.org)
* [Resolución de Problemas Frecuentes](https://www.wollok.org/getting_started/troubleshooting/)
* [Comunidad en Discord](https://discord.gg/ZstgCPKEaa)

---

## 📦 ¿Qué instala y configura?

| Componente | Origen / Método | Comportamiento si ya existe |
| :--- | :--- | :--- |
| **Visual Studio Code** | `winget` (Microsoft.VisualStudioCode) | Lo saltea si ya se encuentra en el `PATH` |
| **Node.js 22 LTS** | `winget` (OpenJS.NodeJS.LTS) | Lo saltea si tenés **v22+**. Actualiza si es menor |
| **wollok-ts-cli** | `npm -g wollok-ts-cli` | Se reinstala/actualiza a la última versión |
| **Extensiones VSCode** | `code --install-extension` | Instala LSP e Highlight de forma forzada |
| **VSCode `settings.json`**| `$env:APPDATA\Code\User` | Inyecta path normalizado, idioma `es` y diagramas |

---

## 💻 Requisitos del Sistema

* **Sistema Operativo:** Windows 10 / 11.
* **PowerShell:** v5.1 o superior (nativo en Windows).
* **Gestor de Paquetes:** `winget` instalado y funcional (incluido en Windows moderno).
* **Red:** Conexión activa a Internet.
* **Permisos:** Requiere ejecutarse en una consola con privilegios de **Administrador**.
