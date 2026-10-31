@echo off
TITLE VSiDeS Modern - Iniciador del Sistema
COLOR 0B

echo ===============================================================================
echo                VSiDeS Modern (TypeScript + React + PostgreSQL)
echo                   VisualSoft.Com - Omar Alberto Cuervo Toro
echo ===============================================================================
echo.

:: 1. CONFIGURAR Y VERIFICAR NODE.JS Y NPM
IF EXIST "%LOCALAPPDATA%\Programs\nodejs" (
    SET "PATH=%LOCALAPPDATA%\Programs\nodejs;%PATH%"
)

where node >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    COLOR 0C
    echo [ERROR] Node.js no esta instalado o no se encuentra en el PATH del sistema.
    echo Para ejecutar la solucion en TypeScript y React, instale Node.js LTS:
    echo   Opcion 1: Desde https://nodejs.org/ (Descargar e instalar version LTS)
    echo   Opcion 2: Ejecutar en PowerShell: winget install OpenJS.NodeJS.LTS
    echo.
    echo Presione cualquier tecla para salir...
    pause >nul
    exit /b 1
)

echo [OK] Node.js detectado:
node -v
npm -v
echo.

:: 2. VERIFICAR BASE DE DATOS (DOCKER O POSTGRESQL LOCAL)
where docker >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo [1/4] Docker detectado. Levantando contenedor PostgreSQL 16...
    docker compose up -d postgres
    echo [OK] Contenedor PostgreSQL iniciado.
) ELSE (
    echo [AVISO] Docker no esta en PATH. Se asumira PostgreSQL 16 local en localhost:5432.
    echo Asegurese de haber creado la base de datos con:
    echo   psql -U postgres -d vsideg_modern -f database\schema.sql
    echo   psql -U postgres -d vsideg_modern -f database\seed.sql
)
echo.

:: 3. INSTALAR DEPENDENCIAS SI ES LA PRIMERA VEZ
IF NOT EXIST "apps\api\node_modules" (
    echo [2/4] Instalando dependencias de la API Backend (primera vez)...
    cd apps\api && call npm install && cd ..\..
)

IF NOT EXIST "apps\web\node_modules" (
    echo [3/4] Instalando dependencias del Frontend Web (primera vez)...
    cd apps\web && call npm install && cd ..\..
)

echo.
echo [4/4] Iniciando Servidores de Desarrollo...
echo.
echo   - Backend API: http://localhost:4000
echo   - Frontend Web: http://localhost:3000
echo.

start "VSiDeS Backend API" cmd /k "cd apps\api && npm run dev"
start "VSiDeS Frontend Web" cmd /k "cd apps\web && npm run dev"

echo ===============================================================================
echo Solucion iniciada correctamente. Se han abierto las consolas de API y Frontend.
echo ===============================================================================
echo Puede cerrar esta ventana.
pause >nul
