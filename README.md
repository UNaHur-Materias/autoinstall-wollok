# 💢 wollok-setup

Script de PowerShell para instalar y configurar automáticamente el entorno de desarrollo **Wollok** en Windows.

## ¿Qué instala?

| Componente | Detalle |
|---|---|
| Visual Studio Code | Última versión estable |
| Node.js 22 LTS | Runtime requerido por Wollok CLI |
| wollok-ts-cli | Intérprete del lenguaje Wollok (vía npm) |
| Extensión `wollok-lsp-ide` | Soporte de lenguaje en VSCode |
| Extensión `wollok-highlight` | Resaltado de sintaxis en VSCode |
| `settings.json` de VSCode | Path de Wollok, idioma español, diagrama dinámico |

Si algún componente ya está instalado, el script lo omite o actualiza según corresponda.

## Requisitos previos

- Windows 10 / 11
- PowerShell 5.1 o superior
- `winget` disponible (incluido en Windows 10 21H1+ y Windows 11)
- Conexión a internet
- Ejecutar como **Administrador**

## Uso

Abrí PowerShell **como Administrador** y ejecutá:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force; irm https://raw.githubusercontent.com/UNaHur-Materias/autoinstall-wollok/main/script.ps1 | iex
```

> Reemplazá `TU_USUARIO/TU_REPO` con tu usuario y repositorio de GitHub.

El script muestra el progreso de cada paso y un resumen de versiones instaladas al finalizar.

## Próximos pasos

Una vez completada la instalación:

1. Abrí Visual Studio Code
2. Creá una carpeta de proyecto
3. Seguí la guía oficial: [wollok.org — Nuevo proyecto](https://www.wollok.org/getting_started/new_project)

## Recursos

- [Documentación oficial de Wollok](https://www.wollok.org)
- [Problemas comunes](https://www.wollok.org/getting_started/troubleshooting/)
- [Discord de Wollok](https://discord.gg/ZstgCPKEaa)
