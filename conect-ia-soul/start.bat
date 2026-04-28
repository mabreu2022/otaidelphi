@echo off
title Conect IA Soul - Iniciando...
color 0A

echo ============================================
echo    CONECT IA SOUL - Iniciando Servicos
echo ============================================
echo.

:: Mata processos anteriores para liberar porta e VRAM
echo [*] Limpando processos anteriores...
taskkill /F /IM ollama.exe >nul 2>&1
taskkill /F /IM "ollama app.exe" >nul 2>&1

:: Mata Node.js que estiver na porta 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)

:: Aguarda VRAM ser liberada
timeout /t 2 /nobreak >nul

:: Inicia o Ollama em background
echo [1/2] Iniciando Ollama...
start "" /B ollama serve >nul 2>&1

:: Aguarda o Ollama ficar disponivel com retry
echo [*] Aguardando Ollama inicializar...
set TENTATIVAS=0

:CHECK_OLLAMA
set /a TENTATIVAS+=1
if %TENTATIVAS% gtr 15 (
    echo [ERRO] Ollama nao respondeu apos 15 tentativas. Verifique a instalacao.
    pause
    exit /b 1
)
curl -s http://127.0.0.1:11434 >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 2 /nobreak >nul
    goto CHECK_OLLAMA
)
echo [OK] Ollama esta rodando!

:: Inicia o servidor Node.js
echo [2/2] Iniciando server.js...
echo.
node server.js

pause
