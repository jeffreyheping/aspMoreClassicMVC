#Requires -RunAsAdministrator

# 编码修复，避免中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 组件列表（仅叶子功能，无冗余）
$features = @(
    "IIS-ASP",
    "IIS-StaticContent",
    "IIS-DefaultDocument",
    "IIS-HttpErrors",
    "IIS-HttpLogging",
    "IIS-RequestFiltering",
    "IIS-ManagementConsole"
)

Write-Host "正在安装 IIS + Classic ASP 组件..." -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName $features -All -NoRestart | Out-Null

$appcmd = "$env:SystemRoot\system32\inetsrv\appcmd.exe"

Write-Host "正在配置 ASP 基础运行参数..." -ForegroundColor Yellow
& $appcmd set config /section:asp /enableParentPaths:"True" /commit:apphost
& $appcmd set config /section:asp /scriptErrorSentToBrowser:"True" /commit:apphost
& $appcmd set config /section:asp /scriptLanguage:"VBScript" /commit:apphost

Write-Host "正在配置稳定性优化（解决偶发引擎崩溃）..." -ForegroundColor Yellow
# 黄金兼容组合：32位 + 经典管道
& $appcmd set apppool "DefaultAppPool" /enable32BitAppOnWin64:"True"
& $appcmd set apppool "DefaultAppPool" /managedPipelineMode:"Classic"

# 核心修复：禁用脚本引擎缓存，杜绝 ReuseEngine 偶发崩溃
& $appcmd set config /section:asp /cache.scriptEngineCacheMax:"0" /commit:apphost

Write-Host "正在生成 ASP 测试页..." -ForegroundColor Yellow
$testAspPath = Join-Path $env:SystemDrive "inetpub\wwwroot\test.asp"
@"
<% @Language = "VBScript" %>
<% Option Explicit %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Classic ASP 测试页</title>
</head>
<body>
    <h1>Classic ASP 运行正常</h1>
    <p>服务器时间：<%= Now() %></p>
    <p>脚本引擎：<%= ScriptEngine & " " & ScriptEngineMajorVersion & "." & ScriptEngineMinorVersion %></p>
</body>
</html>
"@ | Out-File -FilePath $testAspPath -Encoding UTF8

Write-Host "正在重启 IIS 使配置生效..." -ForegroundColor Yellow
iisreset /restart | Out-Null

Write-Host "`n安装与配置全部完成！" -ForegroundColor Green
Write-Host "测试地址：http://localhost/test.asp"
Write-Host "IIS 管理器：inetmgr"
Write-Host "网站根目录：C:\inetpub\wwwroot"
Write-Host "`n已启用稳定配置：32位 + 经典管道 + 禁用引擎缓存"