@echo off
setlocal
cd /d "%~dp0.."
echo Johan Barrera - 1152538 - Arquitectura de computadores
nasm -v
if errorlevel 1 exit /b 1
nasm -f bin -Werror lab6_instrucciones.asm -o lab6_instrucciones.com -l listados\lab6_instrucciones.lst
if errorlevel 1 exit /b 1
copy /y lab6_instrucciones.com bin\INSTR.COM >nul
nasm -f bin -Werror lab6_modos.asm -o lab6_modos.com -l listados\lab6_modos.lst
if errorlevel 1 exit /b 1
copy /y lab6_modos.com bin\MODOS.COM >nul
nasm -f bin -Werror variantes\lab6_factorial.asm -o variantes\lab6_factorial.com -l listados\lab6_factorial.lst
if errorlevel 1 exit /b 1
copy /y variantes\lab6_factorial.com bin\FACT.COM >nul
nasm -f bin -Werror variantes\lab6_inverso.asm -o variantes\lab6_inverso.com -l listados\lab6_inverso.lst
if errorlevel 1 exit /b 1
copy /y variantes\lab6_inverso.com bin\INVERSO.COM >nul
echo Compilacion finalizada sin errores.
echo Si se modifico el fuente, las direcciones de la guia pueden cambiar.
