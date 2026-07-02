@echo off
REM run_all.bat - Executa todos os testbenches do projeto UNO
REM Execute a partir da pasta src\ModelSim\UNO\
REM Requer ModelSim Intel FPGA Edition 18.1

set VSIM=F:\ModelSim\modelsim_ase\win32aloem\vsim.exe
set ALIB=F:\ModelSim\modelsim_ase\altera\verilog\altera_mf

echo ============================================================
echo  Compilando...
echo ============================================================
%VSIM% -c -do compile.do

echo.
echo ============================================================
echo  Executando cenarios de teste
echo ============================================================

for %%T in (
    tb_distribuicao
    tb_carta_inicial
    tb_jogada_player
    tb_compra_player
    tb_cpu
    tb_cpu_compra
    tb_skip
    tb_empilhamento
    tb_coringa
    tb_coringa_cpu
    tb_win
    tb_lose
    tb_penalidade
) do (
    echo.
    echo --- %%T ---
    %VSIM% -c -L %ALIB% -lib work %%T -do "run -all; quit"
)

echo.
echo --- tb_dealer (embaralhamento completo) ---
%VSIM% -c -L %ALIB% -lib work tb_dealer -do "run -all; quit"

echo.
echo --- tb_view_controller ---
%VSIM% -c -L %ALIB% -lib work tb_view_controller -do "run -all; quit"

echo.
echo --- tb_uno (partida completa) ---
%VSIM% -c -L %ALIB% -lib work tb_uno -do "run -all; quit"

echo.
echo ============================================================
echo  Todos os testes executados.
echo ============================================================
pause
