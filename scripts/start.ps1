# ============================================
# Ghost 博客系统启动脚本
# 用法：.\scripts\start.ps1
# 说明：直接使用Node.js启动Ghost，不依赖ghost CLI实例注册
# ============================================

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot
$RuntimeDir = Join-Path $ProjectDir "runtime"
$PidFile = Join-Path $RuntimeDir "ghost.pid"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查runtime目录
if (-not (Test-Path $RuntimeDir)) {
    Write-Host "[错误] runtime目录不存在，请先运行安装" -ForegroundColor Red
    exit 1
}

# 检查端口是否被占用
$portInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if ($portInUse) {
    $existingPid = $portInUse.OwningProcess | Select-Object -First 1
    Write-Host "[提示] 端口2368已被占用 (PID: $existingPid)，Ghost可能已在运行" -ForegroundColor Yellow
    Write-Host "前台地址: http://localhost:2368/" -ForegroundColor Green
    Write-Host "管理后台: http://localhost:2368/ghost/" -ForegroundColor Green
    exit 0
}

# 查找可用的Node.js（优先使用v22+版本）
Write-Host "`n[1/3] 检测Node.js环境..." -ForegroundColor Yellow
$nodePath = $null

# 优先检查豆包沙箱环境的Node.js（v22.23.2）
$sandboxNodes = Get-ChildItem "$env:LOCALAPPDATA\Doubao\User Data\sandbox_runtime\bases" -Directory -ErrorAction SilentlyContinue
foreach ($base in $sandboxNodes) {
    $candidate = Join-Path $base.FullName "node\node.exe"
    if (Test-Path $candidate) {
        $version = & $candidate --version 2>$null
        if ($version -match "v(\d+)" -and [int]$Matches[1] -ge 20) {
            $nodePath = $candidate
            Write-Host "  使用沙箱环境Node.js: $version" -ForegroundColor Green
            break
        }
    }
}

# 如果沙箱环境没有，检查系统Node.js
if (-not $nodePath) {
    $systemNode = Get-Command node -ErrorAction SilentlyContinue
    if ($systemNode) {
        $version = & node --version 2>$null
        if ($version -match "v(\d+)" -and [int]$Matches[1] -ge 20) {
            $nodePath = $systemNode.Source
            Write-Host "  使用系统Node.js: $version" -ForegroundColor Green
        } else {
            Write-Host "  [警告] 系统Node.js版本过低 ($version)，Ghost需要Node.js 20+" -ForegroundColor Yellow
        }
    }
}

if (-not $nodePath) {
    Write-Host "[错误] 未找到兼容的Node.js（需要v20+），请安装Node.js 22 LTS" -ForegroundColor Red
    exit 1
}

# 启动Ghost
Write-Host "`n[2/3] 启动Ghost服务..." -ForegroundColor Yellow
Set-Location $RuntimeDir

# 使用Node.js直接启动Ghost（后台运行）
$process = Start-Process -FilePath $nodePath -ArgumentList "current/index.js" -WorkingDirectory $RuntimeDir -PassThru -WindowStyle Hidden
$process.Id | Out-File $PidFile -Encoding utf8

Write-Host "  Ghost进程已启动 (PID: $($process.Id))" -ForegroundColor Green

# 等待服务启动
Write-Host "`n[3/3] 等待服务启动..." -ForegroundColor Yellow
$maxRetries = 20
$retryCount = 0
$started = $false

do {
    Start-Sleep -Seconds 2
    $retryCount++
    try {
        # 使用前台首页检查服务是否启动
        $response = Invoke-WebRequest -Uri "http://localhost:2368/" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $started = $true
            break
        }
    } catch {
        # 服务尚未就绪
    }
} while ($retryCount -lt $maxRetries)

if ($started) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Ghost 启动完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "前台地址: http://localhost:2368/" -ForegroundColor White
    Write-Host "管理后台: http://localhost:2368/ghost/" -ForegroundColor White
    Write-Host "运行目录: $RuntimeDir" -ForegroundColor White
    Write-Host "进程PID: $($process.Id)" -ForegroundColor White
    Write-Host "`n停止服务: .\scripts\stop.ps1" -ForegroundColor Gray
    Write-Host "========================================`n" -ForegroundColor Green
} else {
    Write-Host "`n[警告] 服务启动超时，请检查日志: $RuntimeDir\content\logs\" -ForegroundColor Yellow
    Write-Host "进程PID: $($process.Id)" -ForegroundColor White
}
