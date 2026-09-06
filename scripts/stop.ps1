# ============================================
# Ghost 博客系统停止脚本
# 用法：.\scripts\stop.ps1
# ============================================

$ErrorActionPreference = "Stop"
$RuntimeDir = Join-Path $PSScriptRoot "..\runtime"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (-not (Test-Path $RuntimeDir)) {
    Write-Host "[错误] runtime目录不存在" -ForegroundColor Red
    exit 1
}

Set-Location $RuntimeDir

Write-Host "`n[停止] 正在停止Ghost..." -ForegroundColor Yellow
ghost stop

Write-Host "`n[完成] Ghost已停止" -ForegroundColor Green
Write-Host "如需重新启动，请运行: .\scripts\start.ps1`n" -ForegroundColor Gray
