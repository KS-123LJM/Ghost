# ============================================
# Ghost 博客系统启动脚本
# 用法：.\scripts\start.ps1
# ============================================

$ErrorActionPreference = "Stop"
$RuntimeDir = Join-Path $PSScriptRoot "..\runtime"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查runtime目录
if (-not (Test-Path $RuntimeDir)) {
    Write-Host "[错误] runtime目录不存在，请先运行安装脚本" -ForegroundColor Red
    exit 1
}

Set-Location $RuntimeDir

# 检查Ghost是否已安装
if (-not (Test-Path "config.development.json")) {
    Write-Host "[错误] Ghost尚未配置，请先运行安装脚本" -ForegroundColor Red
    exit 1
}

# 检查端口是否被占用
$portInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "[警告] 端口2368已被占用，尝试停止现有实例..." -ForegroundColor Yellow
    ghost stop 2>$null
    Start-Sleep -Seconds 2
}

# 启动Ghost
Write-Host "`n[启动] 正在启动Ghost..." -ForegroundColor Green
ghost start

# 等待启动
Write-Host "`n[等待] 等待服务启动..." -ForegroundColor Yellow
$maxRetries = 15
$retryCount = 0
do {
    Start-Sleep -Seconds 2
    $retryCount++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:2368/ghost/api/admin/" -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 301 -or $response.StatusCode -eq 302) {
            break
        }
    } catch {
        # 服务尚未就绪
    }
} while ($retryCount -lt $maxRetries)

# 显示状态
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Ghost 启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "前台地址: http://localhost:2368/" -ForegroundColor White
Write-Host "管理后台: http://localhost:2368/ghost" -ForegroundColor White
Write-Host "运行目录: $RuntimeDir" -ForegroundColor White
Write-Host "`n查看日志: ghost log" -ForegroundColor Gray
Write-Host "停止服务: .\scripts\stop.ps1" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Green
