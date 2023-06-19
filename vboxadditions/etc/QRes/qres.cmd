@echo off

pushd "%~dp0"

:loop
timeout /t 1 > nul
qres /x:1366 /y:768 |find "is not supported" >nul && goto :loop

popd