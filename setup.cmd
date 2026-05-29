@echo off
:: ─────────────────────────────────────────────────────────────────────────────
::  setup.cmd — Punto de entrada del instalador Wollok online
::  Doble click para ejecutar. Solicita elevación UAC automáticamente.
:: ─────────────────────────────────────────────────────────────────────────────

:: Verificar si ya corre como administrador
net session >nul 2>&1
if %errorLevel% == 0 goto :run

:: Si no, re-lanzar con UAC elevation
echo Solicitando permisos de administrador...
powershell -NoProfile -Command ^
  "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs -Wait"
exit /b

:run
:: Construir ruta sin barra final para evitar duplicación de separadores
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Ejecuta el script remoto pasándole el parámetro de ruta local
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope Process -Force; irm https://raw.githubusercontent.com/UNaHur-Materias/autoinstall-wollok/main/script.ps1 | iex"

if %errorLevel% neq 0 pause