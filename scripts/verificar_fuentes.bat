@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================
REM  Verificacion en vivo de fuentes geoespaciales del curso.
REM  Version cmd / batch. Uso:  scripts\verificar_fuentes.bat
REM  Requiere curl.exe (incluido en Windows 10 y 11).
REM  Pide solo el primer byte (-r 0-0) para no descargar
REM  rasteres ni ZIP completos. Nombres sin tildes a proposito.
REM ============================================================

where curl >nul 2>nul
if errorlevel 1 (
  echo ERROR: no se encontro curl.exe. En Windows 10/11 viene incluido.
  exit /b 1
)

set "OK=0"
set "FAIL=0"
set "TMP=%TEMP%\vf_%RANDOM%.txt"

echo FUENTE                                 HTTP   CONTENT-TYPE                 ESTADO
echo ---------------------------------------------------------------------------------

call :check "IDE Boyaca - raiz REST"            "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services?f=json"
call :check "IDE Boyaca - veredas 2024"         "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0?f=json"
call :check "IDE Boyaca - hospitales"           "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Hospitales_Boyac%%C3%%A1/FeatureServer/0?f=json"
call :check "IGAC - raiz REST"                  "https://mapas.igac.gov.co/server/rest/services?f=json"
call :check "IGAC - cartografia 1:10k"          "https://mapas.igac.gov.co/server/rest/services/carto/carto10000beteitiva15092/MapServer?f=json"
call :check "DANE - raiz REST"                  "https://geoportal.dane.gov.co/mparcgis/rest/services?f=json"
call :check "DANE - MGN2024 FeatureServer"      "https://geoportal.dane.gov.co/mparcgis/rest/services/MGN2024/Serv_CapasMGN_2024/FeatureServer?f=json"
call :check "DANE - MGN2024 WMS"                "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?service=WMS&request=GetCapabilities"
call :check "DANE - MGN2024 WFS"                "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WFSServer?service=WFS&request=GetCapabilities"
call :check "SGC - raiz REST"                   "https://geoportal.sgc.gov.co/arcgis/rest/services?f=json"
call :check "Copernicus DEM 30m (Boyaca)"       "https://copernicus-dem-30m.s3.amazonaws.com/Copernicus_DSM_COG_10_N05_00_W073_00_DEM/Copernicus_DSM_COG_10_N05_00_W073_00_DEM.tif"
call :check "Earth Search STAC"                 "https://earth-search.aws.element84.com/v1/collections"
call :check "Geofabrik OSM Colombia"            "https://download.geofabrik.de/south-america/colombia-latest-free.shp.zip"
call :check "RUNAP"                             "https://runap.parquesnacionales.gov.co/"
call :check "SIAC"                              "https://www.siac.gov.co/"
call :check "datos.gov.co (Socrata)"           "https://www.datos.gov.co/resource/idrk-ba8y.geojson?$limit=1"
call :check "Colombia en Mapas"                 "https://colombiaenmapas.gov.co/"
call :check "UPRA geoportal"                    "https://geoportal.upra.gov.co/"
call :check "IDEAM geoportal"                   "https://geoportal.ideam.gov.co/"

echo ---------------------------------------------------------------------------------
echo Resumen: !OK! OK, !FAIL! con falla.
if exist "%TMP%" del "%TMP%" >nul 2>nul
endlocal
exit /b 0

:check
set "name=%~1"
set "url=%~2"
set "code=000"
set "ctype=-"
curl -s -o nul -L --max-time 20 -r 0-0 -w "%%{http_code}|%%{content_type}" "%url%" > "%TMP%" 2>nul
set "res="
set /p res=<"%TMP%"
for /f "tokens=1,2 delims=|" %%a in ("!res!") do (
  set "code=%%a"
  set "ctype=%%b"
)
if "!code!"=="" set "code=000"
if "!ctype!"=="" set "ctype=-"
for /f "tokens=1 delims=;" %%c in ("!ctype!") do set "ctype=%%c"
set "estado=FALLA"
if "!code:~0,1!"=="2" ( set "estado=OK" & set /a OK+=1 ) else ( set /a FAIL+=1 )
call :printrow "!name!" "!code!" "!ctype!" "!estado!"
goto :eof

:printrow
set "n=%~1                                           "
set "n=!n:~0,38!"
set "c=%~2       "
set "c=!c:~0,6!"
set "ct=%~3                                  "
set "ct=!ct:~0,28!"
echo !n! !c! !ct! %~4
goto :eof
