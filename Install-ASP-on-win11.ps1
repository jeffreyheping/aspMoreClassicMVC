#Requires -RunAsAdministrator

# 仅保留叶子功能，父级由 -All 自动安装
$features = @(
    "IIS-ASP",                  # Classic ASP 核心
    "IIS-StaticContent",        # 静态文件
    "IIS-DefaultDocument",      # 默认文档
    "IIS-HttpErrors",           # 错误页
    "IIS-HttpLogging",          # 访问日志
    "IIS-RequestFiltering",     # 基础安全
    "IIS-ManagementConsole"     # IIS 图形管理器
)

Enable-WindowsOptionalFeature -Online -FeatureName $features -All -NoRestart | Out-Null

# 补上 Classic ASP 必备配置
$appcmd = "$env:SystemRoot\system32\inetsrv\appcmd.exe"
& $appcmd set config /section:asp /enableParentPaths:"True" /commit:apphost
& $appcmd set config /section:asp /scriptErrorSentToBrowser:"True" /commit:apphost
& $appcmd set config /section:asp /defaultLanguage:"VBScript" /commit:apphost

iisreset /restart | Out-Null
Write-Host "安装完成，测试地址：http://localhost/test.asp"
