# ============================================================
# weather.ps1 - 성남시 분당구 수내동 날씨 + 미세먼지 수집 스크립트
#   - API 키 불필요 (Open-Meteo 무료 서비스 사용)
#   - 결과를 weather.txt 에 기록(append)
#   - 매일 아침 9시 작업 스케줄러로 자동 실행하는 용도
# ============================================================

# ---- 설정 ----
$lat = 37.3786          # 분당구 수내동 위도
$lon = 127.1145         # 분당구 수내동 경도
$outFile = Join-Path $PSScriptRoot "weather.txt"   # 스크립트와 같은 폴더에 저장

# ---- WMO 날씨 코드 -> 한글 설명 ----
$wmo = @{
    0='맑음'; 1='대체로 맑음'; 2='부분적 흐림'; 3='흐림';
    45='안개'; 48='서리 안개';
    51='약한 이슬비'; 53='이슬비'; 55='강한 이슬비';
    61='약한 비'; 63='비'; 65='강한 비';
    66='어는 비'; 67='강한 어는 비';
    71='약한 눈'; 73='눈'; 75='강한 눈'; 77='싸락눈';
    80='약한 소나기'; 81='소나기'; 82='강한 소나기';
    85='약한 눈소나기'; 86='강한 눈소나기';
    95='천둥번개'; 96='우박 동반 천둥번개'; 99='강한 우박 천둥번개'
}

# ---- 미세먼지 등급 판정 (한국 환경부 기준) ----
function Get-PM25Grade($v) {
    if ($v -le 15)  { return '좋음 😊' }
    elseif ($v -le 35)  { return '보통 🙂' }
    elseif ($v -le 75)  { return '나쁨 😷' }
    else { return '매우 나쁨 🚨' }
}
function Get-PM10Grade($v) {
    if ($v -le 30)  { return '좋음 😊' }
    elseif ($v -le 80)  { return '보통 🙂' }
    elseif ($v -le 150) { return '나쁨 😷' }
    else { return '매우 나쁨 🚨' }
}

$now = Get-Date -Format 'yyyy-MM-dd (ddd) HH:mm'

try {
    # ---- 1) 날씨 가져오기 ----
    $wUrl = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon" +
            "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m" +
            "&timezone=Asia%2FSeoul"
    $w = Invoke-RestMethod -Uri $wUrl -TimeoutSec 20

    $temp   = $w.current.temperature_2m
    $feels  = $w.current.apparent_temperature
    $hum    = $w.current.relative_humidity_2m
    $wind   = $w.current.wind_speed_10m
    $code   = [int]$w.current.weather_code
    $sky    = if ($wmo.ContainsKey($code)) { $wmo[$code] } else { "코드 $code" }

    # ---- 2) 미세먼지 가져오기 ----
    $aUrl = "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon" +
            "&current=pm10,pm2_5&timezone=Asia%2FSeoul"
    $a = Invoke-RestMethod -Uri $aUrl -TimeoutSec 20

    $pm25 = [math]::Round($a.current.pm2_5, 1)
    $pm10 = [math]::Round($a.current.pm10, 1)

    # ---- 3) 보고서 만들기 ----
    $report = @"
========================================
📍 성남시 분당구 수내동  |  🕘 $now
----------------------------------------
🌤️  날씨    : $sky
🌡️  기온    : $temp ℃ (체감 $feels ℃)
💧  습도    : $hum %
🍃  바람    : $wind km/h
----------------------------------------
😷  미세먼지(PM10)   : $pm10 ㎍/㎥  →  $(Get-PM10Grade $pm10)
😷  초미세먼지(PM2.5): $pm25 ㎍/㎥  →  $(Get-PM25Grade $pm25)
========================================

"@

    # ---- 4) 파일에 기록 (append) + 화면 출력 ----
    Add-Content -Path $outFile -Value $report -Encoding UTF8
    Write-Host $report
    Write-Host "✅ 저장 완료: $outFile"
}
catch {
    $err = "[$now] ⚠️ 수집 실패: $($_.Exception.Message)"
    Add-Content -Path $outFile -Value $err -Encoding UTF8
    Write-Host $err
}
