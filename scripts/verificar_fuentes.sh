#!/usr/bin/env bash
# Verificación en vivo de fuentes geoespaciales del curso.
# Uso: bash scripts/verificar_fuentes.sh [--json]
# Requiere: curl. Opcional: jq (no imprescindible).

set -uo pipefail

JSON=0
[[ "${1:-}" == "--json" ]] && JSON=1

declare -a NOMBRES=(
  "IDE Boyacá — raíz REST"
  "IDE Boyacá — veredas 2024"
  "IDE Boyacá — hospitales"
  "IGAC — raíz REST"
  "IGAC — cartografía 1:10k"
  "DANE — raíz REST"
  "DANE — MGN2024 FeatureServer"
  "DANE — MGN2024 WMS"
  "DANE — MGN2024 WFS"
  "SGC — raíz REST"
  "Copernicus DEM 30m (tile Boyacá)"
  "Earth Search STAC"
  "Geofabrik OSM Colombia"
  "RUNAP"
  "SIAC"
  "datos.gov.co (Socrata)"
  "Colombia en Mapas"
  "UPRA geoportal"
  "IDEAM geoportal"
)

declare -a URLS=(
  "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services?f=json"
  "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0?f=json"
  "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Hospitales_Boyac%C3%A1/FeatureServer/0?f=json"
  "https://mapas.igac.gov.co/server/rest/services?f=json"
  "https://mapas.igac.gov.co/server/rest/services/carto/carto10000beteitiva15092/MapServer?f=json"
  "https://geoportal.dane.gov.co/mparcgis/rest/services?f=json"
  "https://geoportal.dane.gov.co/mparcgis/rest/services/MGN2024/Serv_CapasMGN_2024/FeatureServer?f=json"
  "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?service=WMS&request=GetCapabilities"
  "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WFSServer?service=WFS&request=GetCapabilities"
  "https://geoportal.sgc.gov.co/arcgis/rest/services?f=json"
  "https://copernicus-dem-30m.s3.amazonaws.com/Copernicus_DSM_COG_10_N05_00_W073_00_DEM/Copernicus_DSM_COG_10_N05_00_W073_00_DEM.tif"
  "https://earth-search.aws.element84.com/v1/collections"
  "https://download.geofabrik.de/south-america/colombia-latest-free.shp.zip"
  "https://runap.parquesnacionales.gov.co/"
  "https://www.siac.gov.co/"
  "https://www.datos.gov.co/resource/idrk-ba8y.geojson?\$limit=1"
  "https://colombiaenmapas.gov.co/"
  "https://geoportal.upra.gov.co/"
  "https://geoportal.ideam.gov.co/"
)

ok=0; fail=0
printf '%-38s %-6s %-28s %-8s %s\n' "FUENTE" "HTTP" "CONTENT-TYPE" "TIEMPO" "ESTADO"
printf '%s\n' "-------------------------------------------------------------------------------------------------"

for i in "${!URLS[@]}"; do
  url="${URLS[$i]}"
  out=$(curl -4 -s -o /dev/null -L --max-time 20 \
        -w '%{http_code}|%{content_type}|%{time_total}' "$url" 2>/dev/null || echo "000||0")
  code=${out%%|*}; rest=${out#*|}; ctype=${rest%%|*}; t=${rest##*|}
  ctype=${ctype%%;*}
  if [[ "$code" =~ ^2 ]]; then estado="OK"; ok=$((ok+1)); else estado="FALLA"; fail=$((fail+1)); fi
  printf '%-38s %-6s %-28s %-8s %s\n' "${NOMBRES[$i]}" "$code" "${ctype:-—}" "${t}s" "$estado"
done

printf '%s\n' "-------------------------------------------------------------------------------------------------"
printf 'Resumen: %d OK, %d con falla. Fecha: %s\n' "$ok" "$fail" "$(date '+%Y-%m-%d %H:%M %Z')"

if [[ $JSON -eq 1 ]]; then
  printf '\nEjecución en modo JSON no implementada: use la tabla anterior.\n'
fi
