@echo off
SETLOCAL EnableDelayedExpansion

echo Starting frontend development server...

REM Set the base directory path (project root)
SET "BASE_DIR=%~dp0"
SET "FRONTEND_DIR=%BASE_DIR%frontend"
SET "CONFIG_FILE=%FRONTEND_DIR%\env.development"

REM Load configuration from env.development if it exists
SET CONFIGURED_PORT=3000
IF EXIST "%CONFIG_FILE%" (
    echo Loading configuration from %CONFIG_FILE%
    FOR /F "tokens=1,2 delims==" %%a IN (%CONFIG_FILE%) DO (
        IF "%%a"=="PORT" (
            SET CONFIGURED_PORT=%%b
        )
    )
)

echo Configured port: %CONFIGURED_PORT%

REM Check if the port is already in use
SET FREE_PORT=%CONFIGURED_PORT%
SET /A MAX_PORT=%CONFIGURED_PORT% + 20

:CHECK_PORT
netstat -ano | findstr ":%FREE_PORT% " > nul
IF NOT ERRORLEVEL 1 (
    echo Port %FREE_PORT% is in use, trying port !FREE_PORT!+1...
    SET /A FREE_PORT+=1
    IF !FREE_PORT! GTR %MAX_PORT% (
        echo Could not find a free port between %CONFIGURED_PORT% and %MAX_PORT%
        SET FREE_PORT=%CONFIGURED_PORT%
        GOTO :CONTINUE
    )
    GOTO :CHECK_PORT
)

:CONTINUE
IF NOT %FREE_PORT%==%CONFIGURED_PORT% (
    echo Port %CONFIGURED_PORT% is in use, using port %FREE_PORT% instead.
    
    SET /P UPDATE_ENV_FILE="Do you want to update env.development with the new port? (y/n) "
    IF /I "!UPDATE_ENV_FILE!"=="y" (
        IF EXIST "%CONFIG_FILE%" (
            SET "UPDATED=0"
            SET "TEMP_FILE=%TEMP%\temp_env.tmp"
            DEL "%TEMP_FILE%" 2>nul
            
            FOR /F "tokens=* usebackq" %%a IN ("%CONFIG_FILE%") DO (
                SET "LINE=%%a"
                IF "!LINE:~0,5!"=="PORT=" (
                    echo PORT=%FREE_PORT%>>"%TEMP_FILE%"
                    SET "UPDATED=1"
                ) ELSE (
                    echo !LINE!>>"%TEMP_FILE%"
                )
            )
            
            IF "!UPDATED!"=="0" (
                echo PORT=%FREE_PORT%>>"%TEMP_FILE%"
            )
            
            COPY /Y "%TEMP_FILE%" "%CONFIG_FILE%" >nul
            DEL "%TEMP_FILE%" 2>nul
            
            echo Updated env.development with PORT=%FREE_PORT%
        ) ELSE (
            echo PORT=%FREE_PORT%>"%CONFIG_FILE%"
            echo Created env.development with PORT=%FREE_PORT%
        )
    )
)

REM Get processes using the port
FOR /F "tokens=5" %%p IN ('netstat -ano ^| findstr ":%FREE_PORT% "') DO (
    SET "PIDS=!PIDS! %%p"
)

IF DEFINED PIDS (
    echo Found these processes running on port %FREE_PORT%:
    FOR %%p IN (%PIDS%) DO (
        FOR /F "tokens=1" %%i IN ('tasklist /FI "PID eq %%p" /NH /FO CSV') DO (
            SET "PROCESS=%%i"
            SET "PROCESS=!PROCESS:"=!"
            echo PID: %%p - Process: !PROCESS!
        )
    )
    
    SET /P KILL_PROCESSES="Do you want to kill these processes? (y/n) "
    IF /I "!KILL_PROCESSES!"=="y" (
        FOR %%p IN (%PIDS%) DO (
            echo Killing process with PID: %%p
            taskkill /F /PID %%p >nul 2>&1
        )
    ) ELSE (
        echo Attempting to use port %FREE_PORT% anyway...
    )
)

REM Set the environment variable for the port
SET PORT=%FREE_PORT%

REM Navigate to the frontend directory
cd "%FRONTEND_DIR%"

REM Check if pnpm is available
WHERE pnpm >nul 2>&1
IF NOT ERRORLEVEL 1 (
    echo Starting development server on port %FREE_PORT% with pnpm...
    pnpm run dev
) ELSE (
    echo Starting development server on port %FREE_PORT% with npm...
    npm run dev
)

ENDLOCAL 