<#
  Verificacion en vivo de fuentes geoespaciales del curso (PowerShell).
  Uso:
      powershell -ExecutionPolicy Bypass -File scripts\verificar_fuentes.ps1
  Requiere: Windows PowerShell 5.1+ (Invoke-WebRequest). No necesita curl.

  Nota: usa HEAD y, si el servidor lo rechaza, reintenta con GET pidiendo
  solo el primer byte (Range 0-0), para no descargar rasteres ni ZIP enteros.
  Los nombres van sin tildes para evitar problemas de codepage en consola.
#>

# Forzar TLS 1.2 (algunos portales gubernamentales lo exigen).
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$fuentes = @(
  @{ n = "IDE Boyaca - raiz REST";            u = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services?f=json" }
  @{ n = "IDE Boyaca - veredas 2024";         u = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0?f=json" }
  @{ n = "IDE Boyaca - hospitales";           u = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Hospitales_Boyac%C3%A1/FeatureServer/0?f=json" }
  @{ n = "IGAC - raiz REST";                  u = "https://mapas.igac.gov.co/server/rest/services?f=json" }
  @{ n = "IGAC - cartografia 1:10k";          u = "https://mapas.igac.gov.co/server/rest/services/carto/carto10000beteitiva15092/MapServer?f=json" }
  @{ n = "DANE - raiz REST";                  u = "https://geoportal.dane.gov.co/mparcgis/rest/services?f=json" }
  @{ n = "DANE - MGN2024 FeatureServer";      u = "https://geoportal.dane.gov.co/mparcgis/rest/services/MGN2024/Serv_CapasMGN_2024/FeatureServer?f=json" }
  @{ n = "DANE - MGN2024 WMS";                u = "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?service=WMS&request=GetCapabilities" }
  @{ n = "DANE - MGN2024 WFS";                u = "https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WFSServer?service=WFS&request=GetCapabilities" }
  @{ n = "SGC - raiz REST";                   u = "https://geoportal.sgc.gov.co/arcgis/rest/services?f=json" }
  @{ n = "Copernicus DEM 30m (tile Boyaca)";  u = "https://copernicus-dem-30m.s3.amazonaws.com/Copernicus_DSM_COG_10_N05_00_W073_00_DEM/Copernicus_DSM_COG_10_N05_00_W073_00_DEM.tif" }
  @{ n = "Earth Search STAC";                 u = "https://earth-search.aws.element84.com/v1/collections" }
  @{ n = "Geofabrik OSM Colombia";            u = "https://download.geofabrik.de/south-america/colombia-latest-free.shp.zip" }
  @{ n = "RUNAP";                             u = "https://runap.parquesnacionales.gov.co/" }
  @{ n = "SIAC";                              u = "https://www.siac.gov.co/" }
  @{ n = "datos.gov.co (Socrata)";            u = "https://www.datos.gov.co/resource/idrk-ba8y.geojson?`$limit=1" }
  @{ n = "Colombia en Mapas";                 u = "https://colombiaenmapas.gov.co/" }
  @{ n = "UPRA geoportal";                    u = "https://geoportal.upra.gov.co/" }
  @{ n = "IDEAM geoportal";                   u = "https://geoportal.ideam.gov.co/" }
)

function Test-Fuente([string]$url) {
  # Devuelve un objeto con Code y Ctype. Intenta HEAD; si falla, GET Range 0-0.
  foreach ($metodo in @('Head','Get')) {
    try {
      $headers = @{}
      if ($metodo -eq 'Get') { $headers['Range'] = 'bytes=0-0' }
      $r = Invoke-WebRequest -Uri $url -Method $metodo -Headers $headers `
             -MaximumRedirection 5 -TimeoutSec 20 -UseBasicParsing -ErrorAction Stop
      $ct = [string]$r.Headers['Content-Type']
      return [pscustomobject]@{ Code = [int]$r.StatusCode; Ctype = ($ct -split ';')[0] }
    } catch {
      $resp = $_.Exception.Response
      if ($resp -ne $null) {
        $code = [int]$resp.StatusCode
        # 405/501 = metodo no permitido -> probar el siguiente metodo
        if ($metodo -eq 'Head' -and ($code -eq 405 -or $code -eq 501)) { continue }
        $ct = ""
        try { $ct = [string]$resp.ContentType } catch {}
        return [pscustomobject]@{ Code = $code; Ctype = ($ct -split ';')[0] }
      }
      if ($metodo -eq 'Get') { return [pscustomobject]@{ Code = 0; Ctype = "" } }
    }
  }
  return [pscustomobject]@{ Code = 0; Ctype = "" }
}

"{0,-38} {1,-6} {2,-26} {3,-8} {4}" -f "FUENTE","HTTP","CONTENT-TYPE","TIEMPO","ESTADO"
"-" * 95

$ok = 0; $fail = 0
foreach ($f in $fuentes) {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $res = Test-Fuente $f.u
  $sw.Stop()
  $t = [math]::Round($sw.Elapsed.TotalSeconds, 2)
  $ctype = if ($res.Ctype) { $res.Ctype } else { "-" }
  if ($res.Code -ge 200 -and $res.Code -lt 300) { $estado = "OK"; $ok++ }
  else { $estado = "FALLA"; $fail++ }
  "{0,-38} {1,-6} {2,-26} {3,-8} {4}" -f $f.n, $res.Code, $ctype, ("{0}s" -f $t), $estado
}

"-" * 95
"Resumen: {0} OK, {1} con falla. Fecha: {2}" -f $ok, $fail, (Get-Date -Format 'yyyy-MM-dd HH:mm')
