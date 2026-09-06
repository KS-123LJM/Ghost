# ============================================
# Ghost 内容数据备份脚本
# 用法：.\scripts\backup.ps1
# 说明：通过Ghost管理API导出内容，或直接复制SQLite数据库
# ============================================

$ErrorActionPreference = "Stop"
$RuntimeDir = Join-Path $PSScriptRoot "..\runtime"
$BackupDir = Join-Path $PSScriptRoot "..\backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 数据备份脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 创建备份目录
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

$BackupFile = Join-Path $BackupDir "ghost_backup_$Timestamp.zip"
$DbFile = Join-Path $RuntimeDir "content\data\ghost-development.db"

# 检查数据库文件
if (-not (Test-Path $DbFile)) {
    Write-Host "[错误] 数据库文件不存在: $DbFile" -ForegroundColor Red
    exit 1
}

# 停止Ghost以确保数据一致性
Write-Host "`n[1/3] 停止Ghost服务..." -ForegroundColor Yellow
Set-Location $RuntimeDir
ghost stop 2>$null
Start-Sleep -Seconds 2

# 复制数据库和内容
Write-Host "[2/3] 备份数据库和内容文件..." -ForegroundColor Yellow
$TempDir = Join-Path $env:TEMP "ghost_backup_$Timestamp"
New-Item -ItemType Directory -Path $TempDir | Out-Null

Copy-Item -Path $DbFile -Destination (Join-Path $TempDir "ghost.db") -Force
if (Test-Path (Join-Path $RuntimeDir "content\images")) {
    Copy-Item -Path (Join-Path $RuntimeDir "content\images") -Destination (Join-Path $TempDir "images") -Recurse -Force
}
if (Test-Path (Join-Path $RuntimeDir "content\themes")) {
    Copy-Item -Path (Join-Path $RuntimeDir "content\themes") -Destination (Join-Path $TempDir "themes") -Recurse -Force
}

# 创建压缩包
Write-Host "[3/3] 创建备份压缩包..." -ForegroundColor Yellow
Compress-Archive -Path (Join-Path $TempDir "*") -DestinationPath $BackupFile -Force

# 清理临时目录
Remove-Item -Path $TempDir -Recurse -Force

# 重新启动Ghost
Write-Host "`n[完成] 重新启动Ghost..." -ForegroundColor Green
ghost start

$FileSize = (Get-Item $BackupFile).Length / 1KB

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  备份完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "备份文件: $BackupFile" -ForegroundColor White
Write-Host "文件大小: $([math]::Round($FileSize, 2)) KB" -ForegroundColor White
Write-Host "包含内容: 数据库、图片、主题" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Green
