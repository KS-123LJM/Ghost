# ============================================
# Ghost 博客系统停止脚本
# 用法：.\scripts\stop.ps1
# 说明：停止Ghost服务进程
# ============================================

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot
$RuntimeDir = Join-Path $ProjectDir "runtime"
$PidFile = Join-Path $RuntimeDir "ghost.pid"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$stopped = $false

# 方法1：从PID文件读取进程ID并停止
if (Test-Path $PidFile) {
    $ghostPid = Get-Content $PidFile -Raw
    $ghostPid = $ghostPid.Trim()
    if ($ghostPid -match "^\d+$") {
        $process = Get-Process -Id $ghostPid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "`n[停止] 停止Ghost进程 (PID: $ghostPid)..." -ForegroundColor Yellow
            Stop-Process -Id $ghostPid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $stopped = $true
            Write-Host "  进程已停止" -ForegroundColor Green
        }
    }
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

# 方法2：查找占用2368端口的进程并停止
if (-not $stopped) {
    $portCheck = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
    if ($portCheck) {
        $portPid = $portCheck.OwningProcess | Select-Object -First 1
        Write-Host "`n[停止] 停止占用端口2368的进程 (PID: $portPid)..." -ForegroundColor Yellow
        Stop-Process -Id $portPid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $stopped = $true
        Write-Host "  进程已停止" -ForegroundColor Green
    }
}

# 方法3：查找所有Ghost相关的node进程并停止
if (-not $stopped) {
    $ghostProcesses = Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -match "ghost" -or $_.CommandLine -match "current/index.js"
    }
    if ($ghostProcesses) {
        foreach ($proc in $ghostProcesses) {
            Write-Host "`n[停止] 停止Ghost进程 (PID: $($proc.ProcessId))..." -ForegroundColor Yellow
            Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 2
        $stopped = $true
        Write-Host "  进程已停止" -ForegroundColor Green
    }
}

# 验证端口是否释放
Start-Sleep -Seconds 1
$portCheck = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if ($portCheck) {
    Write-Host "`n[警告] 端口2368仍被占用，可能需要手动结束进程" -ForegroundColor Yellow
    $portCheck | Format-Table LocalPort, State, OwningProcess
} else {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Ghost 已停止！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "端口2368已释放" -ForegroundColor White
    Write-Host "`n重新启动: .\scripts\start.ps1" -ForegroundColor Gray
    Write-Host "========================================`n" -ForegroundColor Green
}
# 脚本结束
